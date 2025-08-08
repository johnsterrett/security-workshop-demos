CREATE DATABASE [ProcureSQL]
GO

USE [ProcureSQL]
GO

CREATE OR ALTER VIEW dbo.vw_LoginAudit AS
SELECT 
    event_time,
    action_id,
    server_principal_name,
    client_ip,
    application_name,
    database_name,
    succeeded,
    class_type,
    
    [statement]
FROM sys.fn_get_audit_file('C:\SQLSecurityLogs\SQLAuditLogs\*.sqlaudit', DEFAULT, DEFAULT)
WHERE 1=1
and application_name not like 'Microsoft SQL Server Extension Agent%' 
AND (action_id  = 'LGIF' -- Failed Login
 OR action_id = 'LGIS') -- Successful Login
--ORDER BY action_id ASC, event_time desc
   -- select top 1000 * from dbo.vw_FailedLoginAudit order by event_time desc
   -- select * from vw_FailedLoginAUdit where action_id like 'LGIF'
GO

-- Create view for data access monitoring (GDPR, HIPAA, PCI)
CREATE OR ALTER VIEW vw_DataAccessAudit AS
SELECT 
    event_time,
    server_principal_name,
    database_name,
    schema_name,
    object_name,
    statement,
    class_type,
    action_id
FROM sys.fn_get_audit_file('C:\SQLSecurityLogs\SQLAuditLogs\*.sqlaudit', DEFAULT, DEFAULT)
WHERE 1=1
AND action_id IN ('SL', 'IN', 'UP', 'DL') -- SELECT, INSERT, UPDATE, DELETE
AND schema_name NOT IN ('sys', 'INFORMATION_SCHEMA')
 -- select * from vw_DataAccessAudit ORDER BY event_time desc
GO

-- Create view for privilege changes (All Regulations)
CREATE OR ALTER VIEW vw_PrivilegeChangeAudit AS
SELECT 
    event_time,
    server_principal_name,
    database_name,
    object_name,
    action_id,
    class_type,
     [statement]
FROM sys.fn_get_audit_file('C:\SQLSecurityLogs\SQLAuditLogs\*.sqlaudit', DEFAULT, DEFAULT)
WHERE action_id IN ('APRL', 'ADDM', 'DRPM', 'GR', 'RV') -- Role membership and permission changes
   OR class_type IN ('SERVER ROLE', 'DATABASE ROLE', 'SCHEMA', 'OBJECT');
   -- select * from vw_PrivilegeChangeAudit order by event_time desc
GO