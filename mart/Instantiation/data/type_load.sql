WITH policy_status AS (
	SELECT 11 AS typeId,'POLICY_STATUS' AS typeDesc,'INFORCE' AS typeValue
	UNION ALL SELECT 12,'POLICY_STATUS','LAPSE'
	UNION ALL SELECT 13,'POLICY_STATUS','DEATH'
	UNION ALL SELECT 14,'POLICY_STATUS','NONFORFEITURE'
)
,coverage_status AS (
	SELECT 111 AS typeId,'COVERAGE_STATUS' AS typeDesc,'INFORCE' AS typeValue
	UNION ALL SELECT 121,'COVERAGE_STATUS','TERMINATED'
	UNION ALL SELECT 131,'COVERAGE_STATUS','DEATH_PAID'
	UNION ALL SELECT 132,'COVERAGE_STATUS','DEATH_UNPAID'
	UNION ALL SELECT 133,'COVERAGE_STATUS','DEATH_PENDING'
	UNION ALL SELECT 141,'COVERAGE_STATUS','NONFORFEITURE'
)
,coverage_type AS (
	SELECT 21 AS typeId,'COVERAGE_TYPE' AS typeDesc,'BASE' AS typeValue
	UNION ALL SELECT 22,'COVERAGE_TYPE','RIDER'
)
,us_state AS (
	SELECT 3111 AS typeId,'US_STATES' AS typeDesc,'AL'
	UNION ALL SELECT 3112,'US_STATES','AK'
	UNION ALL SELECT 3113,'US_STATES','AZ'
	UNION ALL SELECT 3114,'US_STATES','AR'
	UNION ALL SELECT 3115,'US_STATES','CA'
	UNION ALL SELECT 3116,'US_STATES','CO'
	UNION ALL SELECT 3117,'US_STATES','CT'
	UNION ALL SELECT 3118,'US_STATES','DE'
	UNION ALL SELECT 3119,'US_STATES','DC'
	UNION ALL SELECT 3120,'US_STATES','FL'
	UNION ALL SELECT 3121,'US_STATES','GA'
	UNION ALL SELECT 3122,'US_STATES','HI'
	UNION ALL SELECT 3123,'US_STATES','ID'
	UNION ALL SELECT 3124,'US_STATES','IL'
	UNION ALL SELECT 3125,'US_STATES','IN'
	UNION ALL SELECT 3126,'US_STATES','IA'
	UNION ALL SELECT 3127,'US_STATES','KS'
	UNION ALL SELECT 3128,'US_STATES','KY'
	UNION ALL SELECT 3129,'US_STATES','LA'
	UNION ALL SELECT 3130,'US_STATES','ME'
	UNION ALL SELECT 3131,'US_STATES','MD'
	UNION ALL SELECT 3132,'US_STATES','MA'
	UNION ALL SELECT 3133,'US_STATES','MI'
	UNION ALL SELECT 3134,'US_STATES','MN'
	UNION ALL SELECT 3135,'US_STATES','MS'
	UNION ALL SELECT 3136,'US_STATES','MO'
	UNION ALL SELECT 3137,'US_STATES','MT'
	UNION ALL SELECT 3138,'US_STATES','NE'
	UNION ALL SELECT 3139,'US_STATES','NV'
	UNION ALL SELECT 3140,'US_STATES','NH'
	UNION ALL SELECT 3141,'US_STATES','NJ'
	UNION ALL SELECT 3142,'US_STATES','NM'
	UNION ALL SELECT 3143,'US_STATES','NY'
	UNION ALL SELECT 3144,'US_STATES','NC'
	UNION ALL SELECT 3145,'US_STATES','ND'
	UNION ALL SELECT 3146,'US_STATES','OH'
	UNION ALL SELECT 3147,'US_STATES','OK'
	UNION ALL SELECT 3148,'US_STATES','OR'
	UNION ALL SELECT 3149,'US_STATES','PA'
	UNION ALL SELECT 3150,'US_STATES','RI'
	UNION ALL SELECT 3151,'US_STATES','SC'
	UNION ALL SELECT 3152,'US_STATES','SD'
	UNION ALL SELECT 3153,'US_STATES','TN'
	UNION ALL SELECT 3154,'US_STATES','TX'
	UNION ALL SELECT 3155,'US_STATES','UT'
	UNION ALL SELECT 3156,'US_STATES','VT'
	UNION ALL SELECT 3157,'US_STATES','VA'
	UNION ALL SELECT 3158,'US_STATES','WA'
	UNION ALL SELECT 3159,'US_STATES','WV'
	UNION ALL SELECT 3160,'US_STATES','WI'
	UNION ALL SELECT 3161,'US_STATES','WY'
)
,coverage_amount_type AS (
	SELECT 411 AS typeId,'COVERAGE_AMOUNT' AS typeDesc,'FACE' AS typeValue
	UNION ALL SELECT 421,'COVERAGE_AMOUNT','CASH_VALUE'
)
,party_relationship AS (
	SELECT 511 AS typeId,'PARTY_RELATIONSHIP' AS typeDesc,'PRIMARY_INSURED' AS typeValue
	UNION ALL SELECT 512,'PARTY_RELATIONSHIP','SECONDARY_INSURED'
	UNION ALL SELECT 521,'PARTY_RELATIONSHIP','POLICY_OWNER'
	UNION ALL SELECT 531,'PARTY_RELATIONSHIP','PAYOR'
)
,transaction_type AS (
	SELECT 61 AS typeId,'TRANSACTION' AS typeDesc,'PREMIUM' AS typeValue
)
,all_types AS (
	SELECT * FROM policy_status
	UNION ALL SELECT * FROM coverage_status
	UNION ALL SELECT * FROM coverage_type
	UNION ALL SELECT * FROM us_state
	UNION ALL SELECT * FROM coverage_amount_type
	UNION ALL SELECT * FROM party_relationship
	UNION ALL SELECT * FROM transaction_type
)

INSERT INTO type.type SELECT * FROM all_types;

/*Inforce files generated without respect to IDs in-database*/
/*Updating to leverage type mapping table*/
UPDATE policy.policy SET issueStateId = issueStateId + 3110;
UPDATE coverage.coverage SET coverageTypeId = coverageTypeId + 20;
UPDATE party.life SET birthStateId = birthStateId + 3110;
UPDATE party.relationship SET relationshipTypeId = relationshipTypeId + 510;
