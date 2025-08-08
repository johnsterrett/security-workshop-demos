use [contosohr]
go
declare @LastName NVARCHAR(50) = N'Smith'
SELECT TOP (1000) [EmployeeID]
      ,[SSN]
      ,[FirstName]
      ,[LastName]
      ,[Salary]
  FROM [contosohr].[dbo].[Employees]
  WHERE LastName = @LastName
  go