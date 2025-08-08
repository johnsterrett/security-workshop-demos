use [contosohr]
go

CREATE TABLE dbo.Managers(
    RelationshipID INT IDENTITY(1,1) PRIMARY KEY,
    ManagerID INT not null,
    EmployeeID INT not null, 
    StartDate datetime not null,
    EndDate datetime default null,
    Bonus MONEY MASKED WITH (FUNCTION = 'random(10000,500000)'),
    [Year] INT MASKED WITH (FUNCTION = 'random(1900, 2025)')
);

-- Mask datetime was added in SQL 2022 --
GO
ALTER TABLE dbo.Managers
ALTER COLUMN StartDate
ADD MASKED WITH (
    FUNCTION = 'datetime("YMDhms")');

ALTER TABLE dbo.Managers
ALTER COLUMN EndDate
ADD MASKED WITH (
    FUNCTION = 'datetime("YMDhms")');
GO

INSERT INTO dbo.Managers (ManagerID, EmployeeID, StartDate, EndDate, Bonus, [Year])
VALUES (45, 188,'1/1/2025',null, 10000,2025)
INSERT INTO dbo.Managers (ManagerID, EmployeeID, StartDate, EndDate, Bonus, [Year])
VALUES (45, 164,'3/1/2025',null, 10000,2025)
INSERT INTO dbo.Managers (ManagerID, EmployeeID, StartDate, EndDate, Bonus, [Year])
VALUES (45, 2,'3/1/2025',null, 10000,2025)
INSERT INTO dbo.Managers (ManagerID, EmployeeID, StartDate, EndDate, Bonus, [Year])
VALUES (45, 81,'1/1/2025',null, 10000,2025)
INSERT INTO dbo.Managers (ManagerID, EmployeeID, StartDate, EndDate, Bonus, [Year])
VALUES (45, 117,'1/1/2025','5/1/2025', 10000,2025)
GO
-- Notice we can see everything as a db owner, sa, control or unmasked permission
SELECT * FROM dbo.Managers
GO
