USE master;
GO

-- Step 1: Create the Server Audit
IF EXISTS (SELECT 1 FROM sys.server_audits WHERE name = 'ComplianceSecurityAudit')
BEGIN
    ALTER SERVER AUDIT ComplianceSecurityAudit WITH (STATE = OFF);
    DROP SERVER AUDIT ComplianceSecurityAudit;
END
GO
-- Get GUID and use it for lines 16 to 28 if you are using Availability Groups
DECLARE @Guid uniqueidentifier = NEWID()
SELECT @Guid
GO

CREATE SERVER AUDIT ComplianceSecurityAudit
TO FILE 
(   FILEPATH = 'C:\SQLSecurityLogs\SQLAuditLogs\',
    MAXSIZE = 500 MB,
    MAX_ROLLOVER_FILES = 50,
    RESERVE_DISK_SPACE = OFF )
WITH 
(    QUEUE_DELAY = 1000,
    ON_FAILURE = CONTINUE
   ,AUDIT_GUID = '178F2358-FBD6-4D2C-9521-BD54EB1805E0'  
  /* Availability Groups must match  this comes from the value returned on line 13 */
);
GO

