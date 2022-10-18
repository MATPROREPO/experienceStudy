WITH study_metadata AS (
    SELECT CAST(CURRENT_DATE AS DATE) AS runDate
        ,CAST(CURRENT_DATE -61 * INTERVAL'1 day' AS DATE) AS studyEnd
        ,CAST(CURRENT_DATE -10 * INTERVAL'1 year' -61 * INTERVAL'1 day' AS DATE) AS studyStart -- 10yr study
)

/*Utilize fraction of the integers table to help the optimizer*/
,small_integers AS (
	SELECT *
	FROM auxiliary.integers
	CROSS JOIN study_metadata
	WHERE i < (EXTRACT(YEAR FROM studyEnd) - EXTRACT(YEAR FROM studyStart) + 1) * 12
)

/*Policies potentially exposed to last-exposed policy-year*/
/*First obtain the terminal duration for all policies*/
,policy_duration AS (
	SELECT p.policyId
		,EXTRACT(YEAR FROM COALESCE(p.terminationDate,x.runDate)) - EXTRACT(YEAR FROM p.issueDate)
			+ CASE WHEN EXTRACT(MONTH FROM COALESCE(p.terminationDate,x.runDate)) * 100 + EXTRACT(DAY FROM COALESCE(p.terminationDate,x.runDate))
					>= EXTRACT(MONTH FROM p.issueDate) * 100 + EXTRACT(DAY FROM p.issueDate) THEN 1 ELSE 0 END AS duration
	FROM policy.policy AS p
	CROSS JOIN study_metadata AS x
)

/*Policies exposed from later of issue date or study start date and sooner of terminal anniversary or study end date*/
,policy_exposure_period AS (
    SELECT p.policyId
        ,GREATEST(p.issueDate,x.studyStart) AS baseExposureStart
        ,LEAST(CAST(p.issueDate + p_d.duration * INTERVAL'1 year' AS DATE),x.studyEnd) AS baseExposureEnd
		,p_d.duration + CASE WHEN p.issueDate + p_d.duration * INTERVAL'1 year' > x.studyEnd THEN -1 ELSE 0 END AS full_duration
    FROM policy.policy AS p
	INNER JOIN policy_duration AS p_d
		ON p.policyid = p_d.policyid
    CROSS JOIN study_metadata AS x
)

/*Calendar date breaks, for use in the overall policy exposure breaks later*/
/*Could decompose into policy-month breaks if interested in exploring intra-year seasonality or other features*/
,policy_calendar_breaks AS (
	SELECT p_e.policyid,CAST(DATE_TRUNC('month',p_e.baseExposureStart) + i.i * INTERVAL'1 month' AS DATE) AS dateValue
	FROM policy_exposure_period AS p_e
	INNER JOIN small_integers AS i
		ON i.i <= (EXTRACT(YEAR FROM p_e.baseExposureEnd) - EXTRACT(YEAR FROM p_e.baseExposureStart)) * 12 + (EXTRACT(MONTH FROM p_e.baseExposureEnd) - EXTRACT(MONTH FROM p_e.baseExposureStart))
	WHERE DATE_TRUNC('month',p_e.baseExposureStart) + i.i * INTERVAL'1 month' <= p_e.baseExposureEnd
		AND DATE_TRUNC('month',p_e.baseExposureStart) + i.i * INTERVAL'1 month' >= p_e.baseExposureStart
)

/*Could decompose into policy-monthaversary breaks if interested in exploring lapse skew or other intra-year behaviours*/
/*Similar to calendar date breaks, to be incorporated in overall policy exposure breaks*/
,policy_anniversary_breaks AS (
	SELECT p_e.policyid,CAST(p_e.baseExposureStart + i.i * INTERVAL'1 year' AS DATE) AS dateValue
	FROM policy_exposure_period AS p_e
	INNER JOIN auxiliary.integers AS i
		ON i.i <= (EXTRACT(YEAR FROM p_e.baseExposureEnd) - EXTRACT(YEAR FROM p_e.baseExposureStart))
	WHERE p_e.baseExposureStart + i.i * INTERVAL'1 year' <= p_e.baseExposureEnd
		AND p_e.baseExposureStart + i.i * INTERVAL'1 year' >= p_e.baseExposureStart
)

/*Listing of all dates overwhich something happened (transaction, policy issuance, change in calendar month, etc.)*/
/*Avoiding UNION and instead leveraging UNION ALL/GROUP BY for efficiency*/
,policy_exposure_breaks_all AS (
	SELECT policyId,dateValue
	FROM (
	    SELECT policyId,baseExposureStart AS dateValue
    	FROM policy_exposure_period
	    UNION ALL
    	SELECT policyId,baseExposureEnd
	    FROM policy_exposure_period
    	UNION ALL
	    SELECT policyId,issueDate
    	FROM policy.policy
	    UNION ALL
    	SELECT policyId,terminationDate
	    FROM policy.policy
    	UNION ALL
	    SELECT policyId,issueDate
    	FROM coverage.coverage
	    UNION ALL
    	SELECT policyId,terminationDate
	    FROM coverage.coverage
    	WHERE terminationDate IS NOT NULL
	    UNION ALL
    	SELECT c.policyId,v.effectiveDate
    	FROM coverage.coverage AS c
	    INNER JOIN coverage.values AS v
    	    ON c.coverageId = v.coverageId
	    UNION ALL
    	SELECT p.policyId,v.transactionDate
	    FROM policy.policy AS p
    	INNER JOIN transactions.values AS v
        	ON p.policyId = v.sourceId
	    UNION ALL
    	SELECT p.policyId,v.transactionDate
	    FROM policy.policy AS p
    	INNER JOIN transactions.values AS v
	        ON p.policyId = v.destinationId
		UNION ALL
		SELECT c.policyId,c.dateValue
		FROM policy_calendar_breaks AS c
		UNION ALL
		SELECT c.policyId,c.dateValue
		FROM policy_anniversary_breaks AS c
	) AS x
	GROUP BY 1,2
)

/*Unique listing of all exposure breaks limited to study period*/
/*Will have one trailing exposure period at the tail end with a NULL exposureEnd date due to usage of window function*/
/*Exposure periods organized as [inclusive,exclusive) date pairs*/
,policy_exposures_pairs AS (
	SELECT p_x.policyid
		,p_x.datevalue AS exposureStart
		,LEAD(p_x.datevalue) OVER (PARTITION BY p_x.policyid ORDER BY p_x.dateValue ASC) AS exposureEnd
	FROM policy_exposure_breaks_all AS p_x
	INNER JOIN policy_exposure_period AS p_e
		ON p_x.policyid = p_e.policyid
	WHERE p_x.datevalue >= p_e.baseExposureStart
		AND p_x.datevalue <= p_e.baseExposureEnd
)

,policy_life_data AS (
	SELECT p.policyid
		,rl.dateofdeath
		,rl.dateofbirth
		,EXTRACT(YEAR FROM p.issueDate) - EXTRACT(YEAR FROM rl.dateofbirth)
			+ CASE WHEN (EXTRACT(MONTH FROM p.issueDate) * 100 + EXTRACT(DAY FROM p.issueDate)) >= (EXTRACT(MONTH FROM rl.dateofbirth) * 100 + EXTRACT(DAY FROM rl.dateofbirth))
				THEN 1 ELSE 0 END - 1 AS issueAge
	FROM policy.policy AS p
	INNER JOIN coverage.coverage AS c
		INNER JOIN type.type AS coverageType
			ON c.coverageTypeId = coverageType.typeid
		ON p.policyid = c.policyid
	INNER JOIN party.relationship AS rx
		ON c.coverageid = rx.coverageid
	INNER JOIN party.life AS rl
		ON rx.partyid = rl.partyid
	WHERE coverageType.typevalue IN ('BASE')
)

,policy_exposures AS (
	SELECT e.*
		,CAST(e.exposureEnd - e.exposureStart + CASE WHEN axc.dt IS NOT NULL THEN -1 ELSE 0 END AS DOUBLE PRECISION) / 365 AS exposureValue
		,CASE WHEN e.exposureStart < p.issuedate + p_e.full_duration * INTERVAL'1 year' --Expose only full durations; lapses can occur only at anniversary
				AND e.exposureStart < COALESCE(l.dateofdeath,CAST(CURRENT_DATE AS DATE)) --Expose only to point of death for non-lapse terminations per Balducci hypothesis
			THEN 1 ELSE 0 END AS isLapseExposure
		,1 AS isMortalityExposure --Definitionally true per above; all exposure periods extend to anniversary year; lapses only occur at anniv so no truncation per balducci, and deaths are automatically completed
		,EXTRACT(MONTH FROM e.exposureStart) AS calendarMonth
		,EXTRACT(YEAR FROM e.exposureStart) AS  calendarYear
		,(EXTRACT(YEAR FROM e.exposureStart) - EXTRACT(YEAR FROM p.issueDate))
			+ CASE WHEN (EXTRACT(MONTH FROM e.exposureStart) * 100 + EXTRACT(DAY FROM e.exposureStart)) >= 
					(EXTRACT(MONTH FROM p.issueDate) * 100 + EXTRACT(DAY FROM p.issueDate)) 
				THEN 1 ELSE 0 END AS duration
		,CASE WHEN e.exposureEnd = p.terminationDate THEN 1 ELSE 0 END AS terminalExposure
	FROM policy_exposures_pairs AS e
	INNER JOIN policy_exposure_period AS p_e
		ON e.policyid = p_e.policyid
	INNER JOIN policy.policy AS p
		ON e.policyid = p.policyid
	INNER JOIN policy_life_data AS l
		ON e.policyid = l.policyid
	LEFT JOIN auxiliary.calendar AS axc
		ON e.exposureStart >= axc.dt
		AND e.exposureEnd < axc.dt
		AND 29 = axc.dayOfMonth
		AND 2 = axc.monthOfYear
	WHERE e.exposureEnd IS NOT NULL
)

SELECT SUM(terminalExposure) / SUM(exposureValue)
FROM policy_exposures
WHERE isLapseExposure = 1