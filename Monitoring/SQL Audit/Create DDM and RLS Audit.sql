
-- Step 4: Create Specific Audit for DDM and RLS Protection
USE [master];
GO

IF EXISTS (SELECT 1 FROM sys.server_audits WHERE name = 'DDM_RLS_SecurityAudit')
BEGIN
    ALTER SERVER AUDIT DDM_RLS_SecurityAudit WITH (STATE = OFF);
    DROP SERVER AUDIT DDM_RLS_SecurityAudit;
END
GO

CREATE SERVER AUDIT DDM_RLS_SecurityAudit
TO FILE 
(
    FILEPATH = 'C:\SQLSecurityLogs\SQLAuditLogs\DDM_RLS\'
    ,MAXSIZE = 200 MB
    ,MAX_ROLLOVER_FILES = 30
    ,RESERVE_DISK_SPACE = OFF
)
WITH 
(
    QUEUE_DELAY = 1000
    ,ON_FAILURE = CONTINUE
    /* ,AUDIT_GUID = NEWID() -- Needs to match for availability group or database mirroring */
);
GO

-- Step 5: Create Custom Audit Actions for DDM/RLS Monitoring
USE [contosohr]; -- Change this to your actual database name
GO

IF EXISTS (SELECT 1 FROM sys.database_audit_specifications WHERE name = 'DDM_RLS_SpecificAudit')
BEGIN
    ALTER DATABASE AUDIT SPECIFICATION DDM_RLS_SpecificAudit WITH (STATE = OFF);
    DROP DATABASE AUDIT SPECIFICATION DDM_RLS_SpecificAudit;
END
GO

CREATE DATABASE AUDIT SPECIFICATION DDM_RLS_SpecificAudit
FOR SERVER AUDIT DDM_RLS_SecurityAudit
-- Monitor UNMASK permission usage (DDM bypass detection)
ADD (DATABASE_PERMISSION_CHANGE_GROUP),

-- Monitor security policy changes (RLS tampering detection)
ADD (SCHEMA_OBJECT_CHANGE_GROUP),

-- Monitor bulk data access (potential exfiltration)
ADD (SELECT ON SCHEMA::dbo BY public),

-- Monitor stored procedure execution that might bypass security
ADD (EXECUTE ON SCHEMA::dbo BY public)
WITH (STATE = ON);
GO

-- Step 6: Enable All Audits
use [master]
go
ALTER SERVER AUDIT DDM_RLS_SecurityAudit WITH (STATE = ON);
GO
