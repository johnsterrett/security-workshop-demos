use [contosohr]
GO
-- DROP SECURITY POLICY RLS.SecurityPolicy_ManagerID_Managers
-- DROP USER [RBrown]
GO


select * from dbo.employees
select * from dbo.Managers
go

CREATE USER [RBrown] WITHOUT LOGIN;
GRANT SELECT ON SCHEMA::dbo TO [RBrown];
GO

CREATE SCHEMA RLS
AUTHORIZATION dbo
GO

CREATE TABLE RLS.ManagerAccess
(MgrID INT not null constraint pk_ManagerAccess PRIMARY KEY CLUSTERED
,MgrLogin nvarchar(255)
)

INSERT INTO RLS.ManagerAccess (MgrID, MgrLogin)
VALUES(45, 'RBrown')
GO

-- Create function for RLS
--Simple access predicate with a lookup
CREATE OR ALTER FUNCTION RLS.AccessPredicate_ManagerID_Managers(@MgrID	int)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
	SELECT 
		1 AccessResult
	FROM dbo.Managers M 
		INNER JOIN RLS.ManagerAccess MA
			ON M.ManagerID	= MA.MgrID
	WHERE MA.MgrID = @MgrID
		AND MA.MgrLogin	= USER_NAME()
GO

--Enforce the access predicate defined above
--Note that the STATE = ON
CREATE SECURITY POLICY RLS.SecurityPolicy_ManagerID_Managers
ADD FILTER PREDICATE RLS.AccessPredicate_ManagerID_Managers(ManagerID) ON dbo.Managers
,ADD BLOCK PREDICATE RLS.AccessPredicate_ManagerID_Managers(ManagerID) ON dbo.Managers AFTER UPDATE
WITH (STATE = ON, SCHEMABINDING = ON)
GO

--Show the current user name
SELECT USER_NAME()
--Rows returned with RLS applied will be zero
-- our filter predicate only returns for RBrown
SELECT *
FROM dbo.Managers

--Change the user running the SELECT
EXECUTE AS USER = 'RBrown'
--Show the current user name
SELECT USER_NAME()
SELECT *
FROM dbo.Managers
REVERT

-- Notice data masking is still in play.
-- Lets let RBrown see the real data for his employees

GRANT UNMASK ON dbo.Managers to [RBrown];
--Change the user running the SELECT
EXECUTE AS USER = 'RBrown'
SELECT *
FROM dbo.Managers
REVERT

/* Lets modify so dbo can see the rows */
DROP SECURITY POLICY RLS.SecurityPolicy_ManagerID_Managers
GO

ALTER FUNCTION RLS.AccessPredicate_ManagerID_Managers(@MgrID	int)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
    -- add dbo to acess all rows
	SELECT 1 AccessResult
	WHERE IS_MEMBER('db_owner') = 1 
	UNION
	SELECT 
		1 AccessResult
	FROM dbo.Managers M 
		INNER JOIN RLS.ManagerAccess MA
			ON M.ManagerID	= MA.MgrID
	WHERE MA.MgrID = @MgrID
		AND MA.MgrLogin	= USER_NAME()
GO

CREATE SECURITY POLICY RLS.SecurityPolicy_ManagerID_Managers
ADD FILTER PREDICATE RLS.AccessPredicate_ManagerID_Managers(ManagerID) ON dbo.Managers
,ADD BLOCK PREDICATE RLS.AccessPredicate_ManagerID_Managers(ManagerID) ON dbo.Managers AFTER UPDATE
WITH (STATE = ON, SCHEMABINDING = ON)
GO

-- Now dbo should be able to see all rows
--Show the current user name
SELECT USER_NAME()
SELECT *
FROM dbo.Managers

