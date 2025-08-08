use [ProcureSQL]
go
select top 1000 * from dbo.vw_LoginAudit order by event_time desc
GO
-- Make sure we access our select top 1000 rows
select * from vw_DataAccessAudit ORDER BY event_time desc
GO
-- Make sure we see the db_datareader role added to UnmaskedReader
select * from vw_PrivilegeChangeAudit order by event_time desc
GO

