/* Remember our MaskedUser and Unmasked User created earlier? */
use [contosohr]
GO

GRANT SELECT ON dbo.Employees to UnmaskedReader;
GRANT SELECT ON dbo.Managers to UnmaskedReader;

GRANT ALTER ON SCHEMA::[dbo] TO [MaskedReader];
GRANT SELECT ON SCHEMA::[dbo] TO [MaskedReader];
GRANT CREATE TABLE TO [MaskedReader];
GO

/* Test masked user */
EXECUTE AS USER = 'MaskedReader'
GO
SELECT * FROM dbo.Managers
REVERT
GO
-- Does select into still mask data? --
EXECUTE AS USER = 'MaskedReader'
GO
SELECT * INTO dbo.ManagerDump FROM dbo.Managers
SELECT * FROM dbo.ManagerDump
DROP TABLE dbo.ManagerDump
REVERT
GO

-- Allow unmasked user to see all unmasked data --
GRANT UNMASK ON SCHEMA::dbo TO UnmaskedReader;
GO

-- See Unmasked can now see unmasked data --
EXECUTE AS USER = 'UnmaskedReader'
GO
SELECT * FROM dbo.Managers
REVERT
GO

CREATE USER  [Accountant] WITHOUT LOGIN;
GRANT SELECT ON SCHEMA::[dbo] TO [Accountant];

-- new unmask column level in SQL 2022
GRANT UNMASK ON dbo.Managers (Bonus) TO  [Accountant];
GRANT UNMASK ON dbo.Managers ([Year]) TO  [Accountant];

-- See Unmasked can now see unmasked data --
-- notice startdate and enddate are still masked
-- Bonus and Year are not masked
EXECUTE AS USER = 'Accountant'
GO
SELECT * FROM dbo.Managers
REVERT
GO

/* see columns masked and their masking function */
SELECT c.name, tbl.name as table_name, c.is_masked, c.masking_function
FROM sys.masked_columns AS c
JOIN sys.tables AS tbl
    ON c.[object_id] = tbl.[object_id]
WHERE is_masked = 1;

/* Note: A masked user can see masking rules with view state access */
EXECUTE AS USER = 'MaskedReader'
GO
SELECT
    SS.name            SchemaName
    ,SO.name        TableName
    ,SC.name        ColumnName
    ,SC.is_masked    ColumnIsMasked
    ,ST.name        ColumnDataType
    ,CASE 
        WHEN st.max_length = -1 THEN 0
        WHEN st.name IN ('nchar','nvarchar') 
   THEN SC.max_length / 2
        WHEN st2.name IN ('nchar','nvarchar') 
   THEN SC.max_length / 2
        ELSE SC.max_length
    END    MaxLength
    ,st.precision
    ,st.scale
    ,M.masking_function
FROM sys.objects SO
    INNER JOIN sys.columns SC
        ON so.object_id = sc.object_id
    INNER JOIN sys.schemas SS
        ON so.schema_id = ss.schema_id
    INNER JOIN sys.types ST
        ON SC.system_type_id = ST.system_type_id
        AND SC.user_type_id    = ST.user_type_id
    LEFT JOIN sys.types st2
        ON st.system_type_id = st2.system_type_id 
        AND st2.system_type_id = st2.user_type_id
        AND st.is_user_defined = 1
    LEFT JOIN sys.masked_columns M
        ON SC.object_id = M.object_id
        AND SC.column_id = M.column_id
WHERE SC.is_masked = 1
ORDER BY
    SS.name
    ,SO.name
    ,SC.name;
GO
REVERT;
GO

/* Who can see Unmasked Data? */
SELECT
	@@SERVERNAME	COLLATE Latin1_General_100_CI_AS  ServerName
	,DB_NAME()	COLLATE Latin1_General_100_CI_AS  DatabaseName
	,SU.name	COLLATE Latin1_General_100_CI_AS  UserName
	,SR.name	COLLATE Latin1_General_100_CI_AS  RoleName
	,'Database role' COLLATE Latin1_General_100_CI_AS SecurityType
FROM sys.database_role_members DRM
	INNER JOIN sys.sysusers SU
		ON DRM.member_principal_id = SU.uid
	INNER JOIN sys.sysusers SR
		ON DRM.role_principal_id = SR.uid
WHERE SR.name IN ('db_owner')
UNION
SELECT
	@@SERVERNAME    COLLATE Latin1_General_100_CI_AS  ServerName
	,'master'	COLLATE Latin1_General_100_CI_AS  DatabaseName
	,SP.name	COLLATE Latin1_General_100_CI_AS  LoginName
	,ROL.name	COLLATE Latin1_General_100_CI_AS  RoleName
	,'Server role'  COLLATE Latin1_General_100_CI_AS  SecurityType
FROM master.sys.server_role_members SRM
	INNER JOIN [master].sys.server_principals SP
		ON SRM.member_principal_id = SP.principal_id
	INNER JOIN [master].sys.server_principals ROL
		ON SRM.role_principal_id = ROL.principal_id
WHERE ROL.[name] IN ('sysadmin')
UNION
SELECT
	@@SERVERNAME    COLLATE Latin1_General_100_CI_AS ServerName
	,db_name()	COLLATE Latin1_General_100_CI_AS DatabaseName
	,SUGR.name	COLLATE Latin1_General_100_CI_AS UserName
	,DP.permission_name	COLLATE Latin1_General_100_CI_AS RoleName
	,'Database permission'	COLLATE Latin1_General_100_CI_AS SecurityType
FROM sys.database_permissions DP
	INNER JOIN sys.sysusers SUGR
		ON DP.grantee_principal_id = SUGR.uid
WHERE DP.permission_name	IN 
   ('ALTER ANY MASK','CONTROL','UNMASK')