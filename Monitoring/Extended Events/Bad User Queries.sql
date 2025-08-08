USE [WideWorldImporters]
GO
SELECT 1/0 -- Divide by zero used to get access via RLS
GO

EXEC xp_cmdshell 'dir *.exe'; --general very bad.....
GO

CREATE USER TestFailures WITHOUT LOGIN
GO
GRANT SELECT ON Sales.Customers TO TestFailures
ALTER ROLE [Far West Sales] ADD MEMBER TestFailures
GO

EXECUTE AS USER = 'TestFailures'
GO
SELECT * FROM Sales.Customers
SELECT * FROM Sales.Orders
GO

REVERT;
GO

EXEC dbo.StoredProcedureDoesNotExist
GO

SELECT * FROM dbo.TableOrViewDoesNotExist

DROP USER TestFailures

BEGIN TRAN
UPDATE Sales.Orders
SET CustomerID = 2
WHERE OrderId = 1

ROLLBACK

SELECT * FROM Sales.Orders WHERE OrderID = 1
GO
