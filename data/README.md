# experienceStudy: Data
Synthetically generated insurance data set, similar to one that might be received by an aggregator
Data is subsequently normalized within the study structure to facilitate downstream analysis and maintenance.
Field | Format | Description
--- | --- | ---
policyNumber | string | 10-character string; uniquely identifies a policy or contract
rider | string | 2-character string; uniquely identifies a coverage underneath a policy
issueDate | date | Identifies the issue or effective date of the policy or coverage
planCode | string | Product identifier for the policy or coverage
statusCode | string | String denotation of the current policy status
issueAgent | integer | Uniquely identifies a specific agent associated with policy issueance



Policy info
    Issue date
    Base product
    Termination date
    Policy number
    Issue state
    Issue agent
    Policy status
    Product code

Person info
    Date of birth
    Gender
    Date of death
    Name
    Residence state

Coverage info
    Product code
    Issue date
    Termination date
    Coverage Status
    Associated insured
    Face amount
    NAR amount

Reinsurance info
    Reinsurer
    Agreement
    Ceded amount
    Ceded basis