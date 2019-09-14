USE EXPSTD

/*Product tables*/
CREATE SCHEMA product
CREATE TABLE product.product (
	productId INT
	,productName VARCHAR(25)
	,productCode VARCHAR(5)
	,productTypeID INT
	,soldFrom DATE
	,soldTo DATE
)
CREATE TABLE product.type (
	productTypeId INT
	,productTypeName VARCHAR(25)
)
CREATE TABLE product.grouping (
	productGroupingId INT
	,productGroupingName VARCHAR(25)
)
CREATE TABLE product.groupingRelationship (
	productId INT
	,productGroupingId INT
)

/*Policy tables*/
CREATE SCHEMA policy
CREATE TABLE policy.policy (
	policyId INT
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
	typeId INT
	,typeDesc VARCHAR(25)
	,typeValue VARCHAR(25)
)
/*Coverage tables*/
CREATE SCHEMA coverage
CREATE TABLE coverage.coverage (
	coverageId INT
	,policyId INT
	,coverageTypeId INT
	,productId INT
	,issueDate DATE
	,terminationDate DATE
	,statusId INT
	,lifeId INT
)

CREATE TABLE coverage.values (
	coverageId INT
	,amount DECIMAL(13,4)
	,amountTypeId INT
	,effectiveDate DATE
)

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
	tableId INT
	,tableDescription VARCHAR(25)
	,assumptionTypeId INT
)

CREATE TABLE assumption.type (
	assumptionTypeId INT
	,typeDescription VARCHAR(25)
)