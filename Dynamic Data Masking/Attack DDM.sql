use [contosohr]
go

select * from dbo.Employees order by salary desc

-- We know employeeID 45 makes 99872

-- A Masked user can guess at the filters to see if it returns data.
EXECUTE AS USER = 'MaskedReader';
SELECT *
FROM dbo.Employees
WHERE Salary > 99871.00 and Salary < 99873.00
REVERT
GO


EXECUTE AS USER = 'MaskedReader';
GO
;with cte as (
SELECT
    FirstName,LastName,
    CASE 
        WHEN Salary > 100000 THEN '100000+'
        WHEN Salary > 90000 THEN '90000+'
        WHEN Salary > 80000 THEN '80000+'
        WHEN Salary > 70000 THEN '70000+'
        WHEN Salary > 60000 THEN '60000+'
        WHEN Salary > 50000 THEN '50000+'
        WHEN Salary > 40000 THEN '40000+'
        WHEN Salary > 30000 THEN '30000+'
        WHEN Salary > 20000 THEN '20000+'
        WHEN Salary > 10000 THEN '10000+'
        ELSE '>1000'
    END SalaryHistogram
FROM dbo.Employees
WHERE Salary IS NOT NULL
)
select COUNT(*) AS Amt, SalaryHistogram
FROM cte
GROUP BY SalaryHistogram
ORDER BY SalaryHistogram desc;
GO
REVERT;
GO

