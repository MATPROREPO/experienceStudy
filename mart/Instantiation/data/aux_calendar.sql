INSERT INTO auxiliary.calendar(dt,dayOfYear,dayOfQuarter,dayOfMonth,dayOfWeek,weekOfYear,weekOfQuarter,weekOfMonth,monthOfYear,monthOfQuarter,quarterOfYear,holidayName,isHoliday) (
WITH integers AS (
        SELECT CAST(i0.i + i1.i + i2.i + i3.i + i4.i + i5.i + i6.i + i7.i + i8.i + i9.i + i10.i + i11.i + i12.i + i13.i + i14.i + i15.i + i16.i AS INTEGER) AS i
        FROM (SELECT 0 AS i UNION ALL SELECT POWER(2,0)) AS i0
        CROSS JOIN (SELECT 0 AS i UNION ALL SELECT POWER(2,1)) AS i1
        CROSS JOIN (SELECT 0 AS i UNION ALL SELECT POWER(2,2)) AS i2
        CROSS JOIN (SELECT 0 AS i UNION ALL SELECT POWER(2,3)) AS i3
        CROSS JOIN (SELECT 0 AS i UNION ALL SELECT POWER(2,4)) AS i4
        CROSS JOIN (SELECT 0 AS i UNION ALL SELECT POWER(2,5)) AS i5
        CROSS JOIN (SELECT 0 AS i UNION ALL SELECT POWER(2,6)) AS i6
        CROSS JOIN (SELECT 0 AS i UNION ALL SELECT POWER(2,7)) AS i7
        CROSS JOIN (SELECT 0 AS i UNION ALL SELECT POWER(2,8)) AS i8
        CROSS JOIN (SELECT 0 AS i UNION ALL SELECT POWER(2,9)) AS i9
        CROSS JOIN (SELECT 0 AS i UNION ALL SELECT POWER(2,10)) AS i10
        CROSS JOIN (SELECT 0 AS i UNION ALL SELECT POWER(2,11)) AS i11
        CROSS JOIN (SELECT 0 AS i UNION ALL SELECT POWER(2,12)) AS i12
        CROSS JOIN (SELECT 0 AS i UNION ALL SELECT POWER(2,13)) AS i13
        CROSS JOIN (SELECT 0 AS i UNION ALL SELECT POWER(2,14)) AS i14
		CROSS JOIN (SELECT 0 AS i UNION ALL SELECT POWER(2,15)) AS i15
		CROSS JOIN (SELECT 0 AS i UNION ALL SELECT POWER(2,16)) AS i16
    )

    ,initial_dates AS (
        SELECT CAST('1800-01-01' AS DATE) + i.i * INTERVAL'1 day' AS dt
        FROM integers AS i
    )
    ,initial_calendar AS (
        SELECT
            d.dt AS dt
            ,DATE_PART('day',d.dt - DATE_TRUNC('year',d.dt)) AS dayOfYear
			,DATE_PART('day',d.dt - DATE_TRUNC('quarter',d.dt)) AS dayOfQuarter
			,DATE_PART('day',d.dt) AS dayOfMonth
			,DATE_PART('dow',d.dt) AS dayOfWeek
			,DATE_PART('week',d.dt) AS weekOfYear -- ISO standard, indexed from Monday
			--Week of Month/Quarter are indexed from first Sunday in unit
			--Not sure if this is helpful for certain calculations?  Maybe!
			,FLOOR(DATE_PART('day',d.dt - (DATE_TRUNC('quarter',d.dt) + (CASE WHEN DATE_PART('dow',DATE_TRUNC('quarter',d.dt)) = 0 THEN 0 ELSE 7 - DATE_PART('dow',DATE_TRUNC('quarter',d.dt)) END) * INTERVAL'1 day')) / 7) + 1 AS weekOfQuarter
			,FLOOR(DATE_PART('day',d.dt - (DATE_TRUNC('month',d.dt) + (CASE WHEN DATE_PART('dow',DATE_TRUNC('month',d.dt)) = 0 THEN 0 ELSE 7 - DATE_PART('dow',DATE_TRUNC('month',d.dt)) END) * INTERVAL'1 day')) / 7) + 1 AS weekOfMonth
			,DATE_PART('month',d.dt) AS monthOfYear
			,DATE_PART('month',d.dt) - (DATE_PART('quarter',d.dt) - 1) * 3 AS monthOfQuarter
			,DATE_PART('quarter',d.dt) AS quarterOfYear
        FROM initial_dates AS d
    )
	,easter_date AS (
		SELECT d.yr
			,d.dt 
				+ INTERVAL'1 day' 
					* (d.yr_i 
						- ((d.yr + CAST(d.yr * 0.25 AS INTEGER) + d.yr_i + 2 
						- d.yr_c + CAST(d.yr_c * 0.25 AS INTEGER)) % 7) + 28) AS dt
		FROM (
			SELECT d.*
				,d.yr_h 
					- CAST(d.yr_h / 28 AS INTEGER) 
						* (1 - CAST(d.yr_h/28 AS INTEGER) 
							* CAST(29 / (d.yr_h + 1) AS INTEGER) 
							* CAST((21 - d.yr_g) / 11 AS INTEGER)) AS yr_i
			FROM (
				SELECT d.*
					,(d.yr_c - CAST(d.yr_c * 0.25 AS INTEGER) 
							- CAST((8 * d.yr_c + 13) * 0.04 AS INTEGER)
							+ 19 * d.yr_g + 15)
						% 30 AS yr_h
				FROM (
					SELECT d.*
						,d.yr * 0.01 AS yr_c
						,d.yr % 19 AS yr_g
					FROM (
						SELECT d.dt,CAST(DATE_PART('year',d.dt) AS INTEGER) AS yr
						FROM initial_calendar AS d
						WHERE monthOfYear = 3 AND dayOfMonth = 1
					) AS d
				) AS d
			) AS d
		) AS d
	)
	,calendar_holiday_names AS (
		--Limited to US market/federal holidays for now
		--Need to incorporate logic for observance of day...
		SELECT i.*
			,CASE WHEN i.monthOfYear = 1 AND i.dayOfMonth = 1 THEN 'New Year''s Day'
				WHEN i.monthOfYear = 1 AND i.dayOfWeek = 1 AND i.dayOfMonth > (3 - 1) * 7 AND dayOfMonth <= 3 * 7 THEN 'Martin Luther King''s Birthday'
				WHEN i.monthOfYear = 2 AND i.dayOfWeek = 1 AND i.dayOfMonth > (3 - 1) * 7 AND dayOfMonth <= 3 * 7 THEN 'Washington''s Birthday'
				WHEN i.monthOfYear = 5 AND i.dayOfWeek = 1 AND DATE_PART('month',i.dt + 7 * INTERVAL'1 day') = 6 THEN 'Memorial Day'
				WHEN i.monthOfYear = 6 AND i.dayOfMonth = 19 THEN 'Juneteenth'
				WHEN i.monthOfYear = 7 AND i.dayOfMonth = 4 THEN 'Independence Day'
				WHEN i.monthOfYear = 9 AND i.dayOfWeek = 1 AND i.dayOfMonth > (1 - 1) * 7 AND dayOfMonth <= 1 * 7 THEN 'Labour Day'
				WHEN i.monthOfYear = 10 AND i.dayOfWeek = 1 AND i.dayOfMonth > (2 - 1) * 7 AND dayOfMonth <= 2 * 7 THEN 'Indigenous People''s Day'
				WHEN i.monthOfYear = 11 AND i.dayOfMonth = 11 THEN 'Veteran''s Day'
				WHEN i.monthOfYear = 11 AND i.dayOfWeek = 4 AND i.dayOfMonth > (4 - 1) * 7 AND dayOfMonth <= 4 * 7 THEN 'Thanksgiving Day'
				WHEN i.monthOfYear = 12 AND i.dayOfMonth = 25 THEN 'Christmas Day'
				WHEN i.dt = e.dt - 2 * INTERVAL'1 day' THEN 'Good Friday'
				WHEN i.dt = e.dt THEN 'Easter Sunday'
				ELSE NULL END AS holidayName
		FROM initial_calendar AS i
		LEFT JOIN easter_date AS e
			ON DATE_PART('year',i.dt) = e.yr
	)
	
	SELECT i.*
		,CASE WHEN i.holidayName IS NOT NULL THEN TRUE ELSE FALSE END AS isHoliday
	FROM calendar_holiday_names AS i
)

