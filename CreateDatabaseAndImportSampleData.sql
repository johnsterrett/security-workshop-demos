CREATE DATABASE contosohr
GO

USE [contosohr]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Employees](
	[EmployeeID] [int] IDENTITY(1,1) NOT NULL,
	[SSN] [char](11) COLLATE Latin1_General_BIN2 NOT NULL,
	[FirstName] [nvarchar](50) NOT NULL,
	[LastName] [nvarchar](50) COLLATE Latin1_General_BIN2 NOT NULL,
	[Salary] [money]  NOT NULL,
 CONSTRAINT [PK_dbo.Employees2] PRIMARY KEY CLUSTERED 
(
	[EmployeeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

BULK INSERT dbo.Employees
FROM 'C:\security-workshop-demos\SampleData.csv'
WITH (
    FIRSTROW = 2,                -- skip header row if present
    FIELDTERMINATOR = ',',       -- delimiter (comma for CSV)
    ROWTERMINATOR = '\n',        -- new line ends each row
    TABLOCK
);