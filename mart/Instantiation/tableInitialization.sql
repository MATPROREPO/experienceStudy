USE experience_study;

/*Product tables*/
CREATE SCHEMA product
CREATE TABLE product.product (
	productId INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY -- Auto increment
	,productName VARCHAR(25)
	,productCode VARCHAR(5)
	,productTypeID INT
	,soldFrom DATE
	,soldTo DATE
);
CREATE TABLE product.type (
	productTypeId INT -- Auto increment
	,productTypeName VARCHAR(25)
);
CREATE TABLE product.grouping (
	productGroupingId INT -- Auto increment
	,productGroupingName VARCHAR(25)
);
CREATE TABLE product.groupingRelationship (
	productId INT
	,productGroupingId INT
);

/*Policy tables*/
CREATE SCHEMA policy;
CREATE TABLE policy.policy (
	policyId INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY -- Auto increment
	,policyNumber VARCHAR(25)
	,productId INT
	,issueDate DATE
	,terminationDate DATE
	,statusId INT
	,issueStateId INT
);

/*Type table: intended to hold a variety of common information, such as states, genders, status codes, etc. etc. etc.*/
/*Merits in singular type table vs atomistic schema-driven type tables?*/
CREATE SCHEMA type;
CREATE TABLE type.type (
	typeId INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY -- Auto increment
	,typeDesc VARCHAR(25)
	,typeValue VARCHAR(25)
);

/*Coverage tables*/
CREATE SCHEMA coverage;
CREATE TABLE coverage.coverage (
	coverageId INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY -- Auto increment
	,policyId INT
	,coverageNumber VARCHAR(25)
	,coverageTypeId INT
	,productId INT
	,issueDate DATE
	,terminationDate DATE
	,statusId INT
);

CREATE TABLE coverage.values (
	coverageAmountId INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY -- Auto increment
	,coverageId INT
	,amount DECIMAL(13,4)
	,amountTypeId INT
	,effectiveDate DATE
);

/*Ultimately multiple party types can be supported; starting with lives*/
/*In a variable-party system would it make sense to include a json-array for storage of type-specific attributes?*/
CREATE SCHEMA party;
CREATE TABLE party.life (
	partyId INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY -- Auto increment
	,fullName VARCHAR(255)
	,dateOfBirth DATE
	,dateOfDeath DATE
	,birthStateId INT
);

CREATE TABLE party.relationship (
	coverageId INT
	,partyId INT
	,relationshipTypeId INT
);



/*Transactional amount tables*/
/*To store things such as premium payments, refunds, claim payments, etc.*/
CREATE SCHEMA transactions;
CREATE TABLE transactions.values (
	transactionId INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY -- Auto increment
	,transactionTypeId INT
	,sourceId INT
	,destinationId INT
	,amount DECIMAL(13,4)
	,transactionDate DATE
);

CREATE SCHEMA study;
CREATE TABLE study.exposures (
	startDate DATE
	,endDate DATE
	,exposureTypeId INT
	,exposureValue DOUBLE PRECISION
	,coverageId INT
);

CREATE SCHEMA assumption;
CREATE TABLE assumption.rate (
	tableId INT
	,intervalNumber SMALLINT
	,rate DECIMAL(11,10)
);

CREATE TABLE assumption.table (
	tableId INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY -- Auto increment
	,tableDescription VARCHAR(25)
	,assumptionTypeId INT
);

CREATE TABLE assumption.type (
	assumptionTypeId INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY -- Auto increment
	,typeDescription VARCHAR(25)
);

/*Need relationship tables to bridge between assumptions*/

CREATE SCHEMA auxiliary;
CREATE TABLE auxiliary.integers (
	i BIGINT
);

CREATE TABLE auxiliary.calendar (
	id INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY -- Auto increment
	,dt DATE
	,dayOfYear INT
	,dayOfQuarter INT
	,dayOfMonth INT
	,dayOfWeek INT
	,weekOfYear INT
	,weekOfQuarter INT
	,weekOfMonth INT
	,monthOfYear INT
	,monthOfQuarter INT
	,quarterOfYear INT
	,holidayName VARCHAR
	,isHoliday BOOLEAN
);

CREATE INDEX policy_policy ON policy.policy (policyId ASC);
CREATE INDEX coverage_policy ON coverage.coverage (policyId ASC);