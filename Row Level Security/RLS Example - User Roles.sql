USE [contosohr]
GO
CREATE ROLE [West] AUTHORIZATION [dbo]
CREATE ROLE [East] AUTHORIZATION [dbo]
GO
GO
use [contosohr]
GO
GRANT SELECT ON [dbo].[Employees] TO [West]
GRANT SELECT ON [dbo].[Managers] TO [West]
GO
use [contosohr]
GO
GRANT SELECT ON [dbo].[Managers] TO [East]
GRANT SELECT ON [dbo].[Employees] TO [East]
GO

ALTER TABLE dbo.Managers ADD Region NVARCHAR(256)

UPDATE dbo.Managers 
SET Region = N'West'

UPDATE dbo.Managers 
SET Region = N'East'
WHERE EmployeeID = 188

ALTER ROLE [West] ADD MEMBER [RBrown]
GO

-- Adjust security Policy to have use group policies
DROP SECURITY POLICY RLS.SecurityPolicy_ManagerID_Managers 
GO

CREATE OR ALTER FUNCTION RLS.AccessPredicate_ManagerID_Managers(@Region NVARCHAR(256))
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
    -- add dbo to acess all rows
	SELECT ISNULL (AccessResult, 0) AS AccessResult
	FROM (
		SELECT 1 AccessResult
		FROM dbo.Managers M
		WHERE m.Region = @Region
		AND IS_ROLEMEMBER(M.Region,USER_NAME())=1 ) AS AccessPred
GO

CREATE SECURITY POLICY RLS.SecurityPolicy_ManagerID_Managers
ADD FILTER PREDICATE RLS.AccessPredicate_ManagerID_Managers(Region) ON dbo.Managers
,ADD BLOCK PREDICATE RLS.AccessPredicate_ManagerID_Managers(Region) ON dbo.Managers AFTER UPDATE
WITH (STATE = ON, SCHEMABINDING = ON)
GO

--- Test access

-- Now dbo should be able to see all rows
--Show the current user name
SELECT USER_NAME()
SELECT *
FROM dbo.Managers

EXECUTE AS USER = 'RBrown'
SELECT USER_NAME()
SELECT *
FROM dbo.Managers
REVERT

CREATE USER [JDoe] WITHOUT LOGIN;
GRANT SELECT ON SCHEMA::dbo TO [JDoe];
ALTER ROLE [East] ADD MEMBER [JDoe];
GO

EXECUTE AS USER = 'JDoe'
SELECT USER_NAME()
SELECT *
FROM dbo.Managers
REVERT

-- remember dbo aka users in role db_owner don't have access
-- We will use the dbo user in our side attack demo

SELECT USER_NAME()
SELECT *
FROM dbo.Managers