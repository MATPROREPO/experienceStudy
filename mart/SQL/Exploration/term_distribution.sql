/*De-normalizing the coverage view*/
WITH coverage AS (
	SELECT c.*,coverageType.typeValue AS coverageType
	FROM coverage.coverage AS c
	INNER JOIN type.type AS coverageType
		ON c.coverageTypeId = coverageType.typeId
)

/*Initial tables were not output with statuses*/
/*Need to then look for cases where term date = death date to identify deaths*/
/*Bucketing decrements by business-defined durational cuts*/
,term_buckets AS (
	SELECT CASE WHEN c.terminationDate - c.issueDate = 0 THEN 0
			WHEN c.terminationDate - c.issueDate < 32 THEN 32
			WHEN c.terminationDate - c.issueDate < 367 THEN 367
			WHEN c.terminationDate - c.issueDate < 365.25 * 5 + 1 THEN 365.25 * 5 + 1
			WHEN c.terminationDate IS NOT NULL THEN 999999
			ELSE -1 END AS bucket
		,SUM(CASE WHEN c.terminationDate <> l.dateOfDeath THEN 1 ELSE 0 END) AS lapseCount
		,SUM(CASE WHEN c.terminationDate = l.dateOfDeath THEN 1 ELSE 0 END) AS deathCount
		,SUM(CASE WHEN c.terminationDate IS NOT NULL THEN 1 ELSE 0 END) AS termCount
	FROM coverage AS c
	INNER JOIN party.relationship AS pr
		ON c.coverageid = pr.coverageid
	INNER JOIN party.life AS l
		ON pr.partyid = l.partyid
	WHERE c.coverageType IN ('BASE')
	GROUP BY 1
)

/*Labeling of buckets in the above*/
/*Broken out into seperate table to easily ORDER BY within the output*/
,bucket_labels AS (
	SELECT 0 AS bucket,'Same day!' AS label
	UNION ALL SELECT 32,'First month'
	UNION ALL SELECT 367,'First year'
	UNION ALL SELECT 365.25 * 5 + 1,'First five years'
	UNION ALL SELECT 999999,'Five or more years'
	UNION ALL SELECT -1,'Inforce'
)

/*Output buckets in proportion of total decrements in database*/
,output AS (
	SELECT x.label
		,b.lapseCount / SUM(b.termCount) OVER () AS lapseProp
		,b.deathCount / SUM(b.termCount) OVER () AS deathProp
	FROM term_buckets AS b
	LEFT JOIN bucket_labels AS x
		ON b.bucket = x.bucket
	ORDER BY b.bucket
)

SELECT *
FROM output