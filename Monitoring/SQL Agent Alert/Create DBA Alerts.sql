use [msdb]
go
-- Alert for multiple failed logins (potential brute force)
EXEC dbo.sp_add_alert 
    @name = N'Multiple Failed Logins',
    @message_id = 18456,
    @severity = 0,
    @notification_message = N'Multiple failed login attempts detected - potential brute force attack',
    @category_name = N'[Uncategorized]',
    @include_event_description_in = 1;
GO
-- send emails to DBA operator
EXEC msdb.dbo.sp_add_notification @alert_name=N'Multiple Failed Logins', @operator_name=N'DBA', @notification_method = 1;
GO
-- Alert for divide by zero errors (RLS side-channel attacks)
EXEC dbo.sp_add_alert 
    @name = N'Divide By Zero Security Alert',
    @message_id = 8134,
    @severity = 0,
    @notification_message = N'Divide by zero error detected - potential RLS side-channel attack',
    @category_name = N'[Uncategorized]',
    @include_event_description_in = 1;
GO
-- send emails to DBA operator
EXEC msdb.dbo.sp_add_notification @alert_name=N'Divide By Zero Security Alert', @operator_name=N'DBA', @notification_method = 1;
GO