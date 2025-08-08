use [contosohr]
go

 ALTER TABLE dbo.Employees ALTER COLUMN FirstName 
 ADD MASKED WITH (FUNCTION = 'default()');

 ALTER TABLE dbo.Employees ALTER COLUMN SSN 
 ADD MASKED WITH (FUNCTION = 'default()');

 ALTER TABLE dbo.Employees ALTER COLUMN LastName 
 ADD MASKED WITH (FUNCTION = 'partial(2,"xxxx",0)');
 
 ALTER TABLE dbo.Employees ALTER COLUMN Salary 
 ADD MASKED WITH (FUNCTION = 'random(30000,50000)');
 GO
 
 /* Mask user was created in the step 6 of the Vulerability
 Assessment Exercise. We will include the scripts incase you
 skipped that step 

		CREATE USER MaskedReader WITHOUT LOGIN;
		GO
		CREATE USER UnmaskedReader WITHOUT LOGIN;
		GO

 */
 
 GRANT SELECT ON dbo.Employees TO MaskedReader
 GO

 EXECUTE AS USER = 'MaskedReader'
 GO

 SELECT * FROM dbo.Employees
 REVERT 
 GO
