USE [contosohr]
GO

SELECT TOP (1000) [EmployeeID]
      ,[SSN]
      ,[FirstName]
      ,[LastName]
      ,[Salary]
  FROM [contosohr].[dbo].[Employees]
  WHERE LastName = N'Smith'