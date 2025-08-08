-- Step 3: Create Database Audit Specifications for Each Sensitive Database
USE [contosohr]; -- Change this to your actual database name
GO

IF EXISTS (SELECT 1 FROM sys.database_audit_specifications WHERE name = 'DatabaseLevelComplianceAudit')
BEGIN
    ALTER DATABASE AUDIT SPECIFICATION DatabaseLevelComplianceAudit WITH (STATE = OFF);
    DROP DATABASE AUDIT SPECIFICATION DatabaseLevelComplianceAudit;
END
GO

CREATE DATABASE AUDIT SPECIFICATION DatabaseLevelComplianceAudit
FOR SERVER AUDIT ComplianceSecurityAudit
-- Data Access Monitoring (All Regulations)
ADD (DELETE ON SCHEMA::[dbo] BY [public]),
ADD (INSERT ON SCHEMA::[dbo] BY [public]),
ADD (SELECT ON SCHEMA::[dbo] BY [public]),
ADD (UPDATE ON SCHEMA::[dbo] BY [public]),
-- Schema and Object Changes (All Regulations)
ADD (SCHEMA_OBJECT_CHANGE_GROUP),
ADD (SCHEMA_OBJECT_OWNERSHIP_CHANGE_GROUP),
ADD (SCHEMA_OBJECT_PERMISSION_CHANGE_GROUP),
-- Database Role and Permission Changes (All Regulations)
ADD (DATABASE_ROLE_MEMBER_CHANGE_GROUP),
ADD (DATABASE_PRINCIPAL_CHANGE_GROUP),
ADD (DATABASE_PERMISSION_CHANGE_GROUP),
-- Application Role Changes (PCI, SOX)
ADD (APPLICATION_ROLE_CHANGE_PASSWORD_GROUP),
-- Sensitive Operations for Side-Channel Attack Detection
ADD (DATABASE_OBJECT_ACCESS_GROUP)
WITH (STATE = ON);
GO