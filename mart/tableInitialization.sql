USE EXPSTD

/*Product tables*/
CREATE SCHEMA product
CREATE TABLE product.product (
	productId INT -- Auto increment
	,productName VARCHAR(25)
	,productCode VARCHAR(5)
	,productTypeID INT
	,soldFrom DATE
	,soldTo DATE
)
CREATE TABLE product.type (
	productTypeId INT -- Auto increment
	,productTypeName VARCHAR(25)
)
CREATE TABLE product.grouping (
	productGroupingId INT -- Auto increment
	,productGroupingName VARCHAR(25)
)
CREATE TABLE product.groupingRelationship (
	productId INT
	,productGroupingId INT
)

/*Policy tables*/
CREATE SCHEMA policy
CREATE TABLE policy.policy (
	policyId INT -- Auto increment
	,policyNumber VARCHAR(25)
	,productId INT
	,issueDate DATE
	,terminationDate DATE
	,statusId INT
	,issueStateId INT
)
/*Type table: intended to hold a variety of common information, such as states, genders, status codes, etc. etc. etc.*/
CREATE SCHEMA type
CREATE TABLE type.type (
	typeId INT -- Auto increment
	,typeDesc VARCHAR(25)
	,typeValue VARCHAR(25)
)
/*Coverage tables*/
CREATE SCHEMA coverage
CREATE TABLE coverage.coverage (
	coverageId INT -- Auto increment
	,policyId INT
	,coverageTypeId INT
	,productId INT
	,issueDate DATE
	,terminationDate DATE
	,statusId INT
	,lifeId INT
)

CREATE TABLE coverage.values (
	coverageAmountId INT -- Auto increment
	,coverageId INT
	,amount DECIMAL(13,4)
	,amountTypeId INT
	,effectiveDate DATE
)

/*Transactional amount tables*/
/*To store things such as premium payments, refunds, claim payments, etc.*/
CREATE SCHEMA transactions
CREATE TABLE transactions.values AS (
	transactionId INT -- Auto increment
	,transactionTypeId INT
	,sourceId INT
	,destinationId INT
	,amount DECIMAL(13,4)

CREATE SCHEMA study
CREATE TABLE study.exposures (
	startDate
	,endDate
	,exposureTypeId
	,exposureValue
	,coverageId
)

CREATE SCHEMA assumption
CREATE TABLE assumption.rate (
	tableId INT
	,genderId INT
	,classId INT
	,issueAge SMALLINT
	,duration SMALLINT
	,rate DECIMAL(11,10)
)

CREATE TABLE assumption.table (
	tableId INT -- Auto increment
	,tableDescription VARCHAR(25)
	,assumptionTypeId INT
)

CREATE TABLE assumption.type (
	assumptionTypeId INT -- Auto increment
	,typeDescription VARCHAR(25)
)

CREATE SCHEMA auxillary
CREATE TABLE auxillary.integers (
	i BIGINT
)

CREATE TABLE auxillary.calendar (
	id INT -- Auto increment
	,dt DATE
	,dayNum INT
	,weekNum INT
	,dayOfWeek INT
	,monthNum INT
	,dayOfMonth INT
	,weekOfMonth INT
	,quarterNum INT
	,dayOfQuarter INT
	,isHoliday BINARY
)
