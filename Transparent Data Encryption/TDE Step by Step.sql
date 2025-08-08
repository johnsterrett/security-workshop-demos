
-- Step 1 - Create a Master Key 
-- For all replicas on Availability Groups
USE master;
GO
CREATE MASTER KEY ENCRYPTION BY PASSWORD = '!ChangeThisWithAStrongerPassword1';

-- Step 2 - Create the certificate used for the database encryption key
-- Complete on secondary replica if in a availability group.
CREATE CERTIFICATE TDECert WITH SUBJECT = 'TDE Cert';

-- Step 3 - Backup the Certification. Required if database files will ever
-- reside on another server. Needed for Availability Groups too... 

BACKUP CERTIFICATE TDECert
TO FILE = 'c:\dba\TDECert.cer'
WITH PRIVATE KEY (
   FILE = 'c:\dba\TDECert.pvk',
   ENCRYPTION BY PASSWORD = '!ChangeThisWithAStrongerPassword1');-- usually different :-)

 --Step 4 - Verify you can drop and restore your certificate
 DROP CERTIFICATE TDECert
 GO

USE master;
GO

CREATE CERTIFICATE TDECert 
FROM FILE = 'C:\dba\TDECert.cer'
WITH PRIVATE KEY (FILE = 'C:\dba\TDECert.pvk', 
     DECRYPTION BY PASSWORD = '!ChangeThisWithAStrongerPassword1');
GO

-- Step 5 - CREATE TDE Database Encryption Key
/* Notice the Warning: This is why we test and validate we have good backup of certificate 
Warning: The certificate used for encrypting the database encryption key has not been backed up. You should immediately back up the certificate and the private key associated with the certificate.
*/
USE [WideWorldImporters]
GO
CREATE DATABASE ENCRYPTION KEY WITH ALGORITHM = AES_256
ENCRYPTION BY SERVER CERTIFICATE TDECert;
GO


-- Step 6 - Enable TDE
USE [master]
GO
-- If going from encrypted to decrypted back to encrypted you need log backup
-- Remember TDE uses new log
-- BACKUP LOG [WideWorldImporters] TO DISK = 'c:\dba\wwi_log.bak'
-- CANNOT UNDO Until full scan completes.
ALTER DATABASE [WideWorldImporters] SET ENCRYPTION ON;
GO
-- SQL 2019+ You can pause and resume initial scan
ALTER DATABASE [WideWorldImporters] SET ENCRYPTION SUSPEND;
GO

select DB_NAME(database_id) AS DatabaseName,
percent_complete,
encryption_scan_state_desc,
encryption_scan_modify_date,
CASE 
        WHEN encryption_state = 0 THEN 'No Encryption'
        WHEN encryption_state = 1 THEN 'Unencrypted'
        WHEN encryption_state = 2 THEN 'Encryption In Progress'
        WHEN encryption_state = 3 THEN 'Encrypted'
        WHEN encryption_state = 4 THEN 'Key Change In Progress'
        WHEN encryption_state = 5 THEN 'Decryption In Progress'
        WHEN encryption_state = 6 THEN 'Protection Change In Progress'
        ELSE 'Unknown State'  END AS encryption_state
 FROM sys.dm_database_encryption_keys

 -- vlf_encrypter_thumbrint will show which vlfs are in TDE
 select * from  sys.dm_db_log_info (DB_ID('WideWorldImporters'))

-- Wait a bit.... 
ALTER DATABASE [WideWorldImporters] SET ENCRYPTION RESUME;

select DB_NAME(database_id) AS DatabaseName,
percent_complete,
encryption_scan_state_desc,
encryption_scan_modify_date,
CASE 
        WHEN encryption_state = 0 THEN 'No Encryption'
        WHEN encryption_state = 1 THEN 'Unencrypted'
        WHEN encryption_state = 2 THEN 'Encryption In Progress'
        WHEN encryption_state = 3 THEN 'Encrypted'
        WHEN encryption_state = 4 THEN 'Key Change In Progress'
        WHEN encryption_state = 5 THEN 'Decryption In Progress'
        WHEN encryption_state = 6 THEN 'Protection Change In Progress'
        ELSE 'Unknown State'  END AS encryption_state
 FROM sys.dm_database_encryption_keys

 
 
 USE [WideWorldImporters]
 go
 create table dbo.showlogencrypt (id int, txt char(2000))
 INSERT into dbo.showlogencrypt VALUES (1, 'look at vlfs')

  -- vlf_encrypter_thumbrint will show which vlfs are in TDE
 select * from  sys.dm_db_log_info (DB_ID('WideWorldImporters'))

 BACKUP DATABASE [WideWorldImporters] TO DISK = 'c:\dba\wwi_tde_enabled.bak'
 GO
 -- notice the encryption columns at the end
 RESTORE HEADERONLY FROM DISK ='c:\dba\wwi_tde_enabled.bak'
 go
 -- Remove TDE
 -- CANNOT UNDO Until full scan completes.
 use [master]
 GO
ALTER DATABASE [WideWorldImporters] SET ENCRYPTION OFF;
ALTER DATABASE [WideWorldImporters] 
SET ENCRYPTION SUSPEND;

select DB_NAME(database_id) AS DatabaseName,
percent_complete,
encryption_scan_state_desc,
encryption_scan_modify_date,
CASE 
        WHEN encryption_state = 0 THEN 'No Encryption'
        WHEN encryption_state = 1 THEN 'Unencrypted'
        WHEN encryption_state = 2 THEN 'Encryption In Progress'
        WHEN encryption_state = 3 THEN 'Encrypted'
        WHEN encryption_state = 4 THEN 'Key Change In Progress'
        WHEN encryption_state = 5 THEN 'Decryption In Progress'
        WHEN encryption_state = 6 THEN 'Protection Change In Progress'
        ELSE 'Unknown State'  END AS encryption_state
 FROM sys.dm_database_encryption_keys

 --- Wait a while..... 
 ALTER DATABASE [WideWorldImporters] SET ENCRYPTION RESUME;
 
 select DB_NAME(database_id) AS DatabaseName,
percent_complete,
encryption_scan_state_desc,
encryption_scan_modify_date,
CASE 
        WHEN encryption_state = 0 THEN 'No Encryption'
        WHEN encryption_state = 1 THEN 'Unencrypted'
        WHEN encryption_state = 2 THEN 'Encryption In Progress'
        WHEN encryption_state = 3 THEN 'Encrypted'
        WHEN encryption_state = 4 THEN 'Key Change In Progress'
        WHEN encryption_state = 5 THEN 'Decryption In Progress'
        WHEN encryption_state = 6 THEN 'Protection Change In Progress'
        ELSE 'Unknown State'  END AS encryption_state
 FROM sys.dm_database_encryption_keys
  select * from  sys.dm_db_log_info (DB_ID('WideWorldImporters'))
 
-- CLEANUP
Use [WideWorldImporters]
GO
DROP DATABASE ENCRYPTION KEY
DROP table IF EXISTS dbo.showlogencrypt
-- Drop on all replicas
Use [master]
go
DROP CERTIFICATE TDECert 
DROP MASTER KEY


/* Now that TDE is gone, cert is gone, lets restore */
RESTORE DATABASE [TDESample] FROM DISK = 'c:\dba\wwi_tde_enabled.bak'
go
/*
simulating restoring on a new instance without cert....
Msg 33111, Level 16, State 3, Line 151
Cannot find server certificate with thumbprint '0x9F5FE6B38F4F62A0B09318EB5597927E39FF3568'.
Msg 3013, Level 16, State 1, Line 151
RESTORE DATABASE is terminating abnormally.
*/

-- Create Master key
USE master;
GO
CREATE MASTER KEY ENCRYPTION BY PASSWORD = '!ChangeThisWithAStrongerPassword1';
-- Restore Cert back that matches the cert in the restore
USE master;
CREATE CERTIFICATE TDECert 
FROM FILE = 'C:\dba\TDECert.cer'
WITH PRIVATE KEY (FILE = 'C:\dba\TDECert.pvk', 
     DECRYPTION BY PASSWORD = '!ChangeThisWithAStrongerPassword1');

-- Restore now works. Might need to change path for new files
RESTORE DATABASE [TDESample] FROM DISK = 'c:\dba\wwi_tde_enabled.bak'
WITH MOVE 'WWI_Primary' TO 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\WideWorldImporters_tmp.mdf',
MOVE 'WWI_UserData' TO 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\WideWorldImporters_UserData_tmp.ndf',
MOVE 'WWI_Log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\WideWorldImporters_tmp.ldf',
MOVE 'WWI_InMemory_Data_1' TO 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\WideWorldImporters_InMemory_Data_1_tmp'
GO

-- See that TDESample is encrypted with TDE
 select DB_NAME(database_id) AS DatabaseName,
percent_complete,
encryption_scan_state_desc,
encryption_scan_modify_date,
CASE 
        WHEN encryption_state = 0 THEN 'No Encryption'
        WHEN encryption_state = 1 THEN 'Unencrypted'
        WHEN encryption_state = 2 THEN 'Encryption In Progress'
        WHEN encryption_state = 3 THEN 'Encrypted'
        WHEN encryption_state = 4 THEN 'Key Change In Progress'
        WHEN encryption_state = 5 THEN 'Decryption In Progress'
        WHEN encryption_state = 6 THEN 'Protection Change In Progress'
        ELSE 'Unknown State'  END AS encryption_state
FROM sys.dm_database_encryption_keys

-- Cleanup
DROP DATABASE [TDESample]
Use [master]
go
DROP CERTIFICATE TDECert 
DROP MASTER KEY