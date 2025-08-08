/* Make sure you change your email address below... */

DECLARE @Email NVARCHAR(2000) = N'<YourEmailAddress>'
IF  NOT EXISTS (SELECT name FROM msdb.dbo.sysoperators WHERE name = N'DBA')
begin
EXEC msdb.dbo.sp_add_operator @name=N'DBA', 
@enabled=1, 
@weekday_pager_start_time=90000, 
@weekday_pager_end_time=180000, 
@saturday_pager_start_time=90000, 
@saturday_pager_end_time=180000, 
@sunday_pager_start_time=90000, 
@sunday_pager_end_time=180000, 
@pager_days=0, 
@email_address=@Email, @category_name=N'[Uncategorized]' 
end 