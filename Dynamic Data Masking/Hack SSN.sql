USE [contosohr]
GO
SET NOCOUNT ON
GO

/* Detect SSN Pattern  */
SELECT *, CHARINDEX('-', SSN), CHARINDEX('-', SSN, 5) FROM dbo.Employees
GO

EXECUTE AS USER = 'MaskedReader';
GO
SELECT COUNT(*) FROM dbo.Employees
SELECT COUNT(*) FROM dbo.Employees WHERE CHARINDEX('-', SSN) = 4
SELECT COUNT(*) FROM dbo.Employees WHERE CHARINDEX('-', SSN, 5) = 7
REVERT;
GO

-- Now that we know the pattern break them up into three parts
USE [contosohr]
GO

SET NOCOUNT ON
GO
/*
* Example showing how to unmask a known format.
* Each section is unmasked separately which allows
* for a very fast unmasking process.
*/
EXECUTE AS USER = 'MaskedReader';
GO
DECLARE @SSN1 TABLE (
    SSN1 char(3) PRIMARY KEY CLUSTERED
);
DECLARE 
    @SSN1Loop1        int = 0
    ,@SSN1Loop2        int = 0
    ,@SSN1Loop3        int = 0
WHILE @SSN1Loop1 < 10
BEGIN
    SELECT @SSN1Loop2 = 0
    WHILE @SSN1Loop2 < 10
    BEGIN
        SELECT @SSN1Loop3 = 0
        WHILE @SSN1Loop3 < 10
        BEGIN
            INSERT INTO @SSN1 (SSN1)
            SELECT CONVERT(char(1),@SSN1Loop1) 
                    + CONVERT(char(1),@SSN1Loop2) 
                    + CONVERT(char(1),@SSN1Loop3)
            SELECT @SSN1Loop3 += 1
        END
        SELECT @SSN1Loop2 += 1
    END
    SELECT @SSN1Loop1 += 1
END
--SELECT * FROM @SSN1
DECLARE @SSN2 TABLE (
    SSN2 char(2) PRIMARY KEY CLUSTERED
)
DECLARE 
    @SSN2Loop1        int = 0
    ,@SSN2Loop2        int = 0
WHILE @SSN2Loop1 < 10
BEGIN
    SELECT @SSN2Loop2 = 0
    WHILE @SSN2Loop2 < 10
    BEGIN
        INSERT INTO @SSN2 (SSN2)
        SELECT CONVERT(char(1),@SSN2Loop1) 
                  + CONVERT(char(1),@SSN2Loop2)
        SELECT @SSN2Loop2 += 1
    END
    SELECT @SSN2Loop1 += 1
END
--SELECT * FROM @SSN2
DECLARE @SSN3 TABLE (
    SSN3 char(4) PRIMARY KEY CLUSTERED
)
DECLARE 
    @SSN3Loop1        int = 0
    ,@SSN3Loop2        int = 0
    ,@SSN3Loop3        int = 0
    ,@SSN3Loop4        int = 0
WHILE @SSN3Loop1 < 10
BEGIN
    SELECT @SSN3Loop2 = 0
    WHILE @SSN3Loop2 < 10
    BEGIN
        SELECT @SSN3Loop3 = 0
        WHILE @SSN3Loop3 < 10
        BEGIN
            SELECT @SSN3Loop4 = 0
            WHILE @SSN3Loop4 < 10
            BEGIN
                INSERT INTO @SSN3 (SSN3)
                SELECT CONVERT(char(1),@SSN3Loop1)  
                     + CONVERT(char(1),@SSN3Loop2) 
                     + CONVERT(char(1),@SSN3Loop3) 
                     + CONVERT(char(1),@SSN3Loop4)
                SELECT @SSN3Loop4 += 1
            END
            SELECT @SSN3Loop3 += 1
        END
        SELECT @SSN3Loop2 += 1
    END
    SELECT @SSN3Loop1 += 1
END
SELECT
   e.EmployeeID
   ,FirstName
    ,e.LastName
    ,e.SSN
    ,T1.SSN1
    ,T2.SSN2
    ,T3.SSN3
FROM dbo.Employees e
    LEFT JOIN @SSN1 T1
        ON SUBSTRING(e.SSN,1,3) = T1.SSN1
    LEFT JOIN @SSN2 T2
        ON SUBSTRING(e.SSN,5,2) = T2.SSN2
    LEFT JOIN @SSN3 T3
        ON SUBSTRING(e.SSN,8,4) = T3.SSN3
ORDER BY e.EmployeeID;
GO
REVERT
GO