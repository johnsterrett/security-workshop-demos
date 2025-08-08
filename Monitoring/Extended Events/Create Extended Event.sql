-- Create Extended Events session for comprehensive security monitoring
IF EXISTS (SELECT 1 FROM sys.server_event_sessions WHERE name = 'SecurityMonitoring')
    DROP EVENT SESSION SecurityMonitoring ON SERVER;
GO

CREATE EVENT SESSION SecurityMonitoring ON SERVER
-- Error events that may indicate attacks
ADD EVENT sqlserver.error_reported(
    ACTION(
        sqlserver.client_app_name,
        sqlserver.client_hostname,
        sqlserver.database_name,
        sqlserver.server_principal_name,
        sqlserver.session_id,
        sqlserver.sql_text,
        sqlserver.tsql_stack,
        sqlserver.username
    )
    WHERE (
        -- Divide by zero errors (potential RLS side-channel attacks)
        [error_number] = 8134 OR
        -- Permission denied errors (potential privilege escalation)
        [error_number] = 229 OR [error_number] =  230 OR [error_number] =  15281 OR
        -- SQL injection probing errors
       [error_number] =  102 OR [error_number] = 105 OR [error_number] = 207 OR [error_number] = 208 OR [error_number] =  2812 OR
        -- Arithmetic overflow errors (potential data type attacks)
        [error_number] = 8115 OR [error_number] = 232 OR [error_number] =  245 OR
        -- Potential tampering with disk or corruption 
        [error_number]=823  OR [error_number]=824 OR [error_number]=825 OR
        -- Potential tampering with access
        [message] like '%permission%' OR [message] like '%denied%') OR [error_number]=15281
        -- Login failures from potential brute-force attacks, credential stuffing, etc...
        OR [error_number]=18456
    ) ,


ADD EVENT sqlserver.rpc_completed(
    ACTION(
        sqlserver.client_app_name,
        sqlserver.client_hostname,
        sqlserver.database_name,
        sqlserver.server_principal_name,
        sqlserver.session_id,
        sqlserver.sql_text,
        sqlserver.username
    )
    WHERE (
        -- Excessive result sets (potential data exfiltration)
        [row_count] > 10000 
        -- Add specific database or table filters as needed
        /* AND sqlserver.database_name = N'YourSensitiveDatabase' */
         -- Auditing Changes
        OR ([statement] like '%ALTER SERVER AUDIT%' OR [statement] like '%DROP SERVER AUDIT%' OR [statement] like '%CREATE SERVER AUDIT%')
        -- Extended Event Changes
        OR ([statement] like '%ALTER EVENT SESSION%' OR [statement] like '%DROP EVENT SESSION%' OR [statement] like '%CREATE EVENT SESSION%')
        -- Audit DDM UNMASK
        OR ([statement] like '%UNMASK%')
        or [statement] like '%xp[_]%'
    )
),


ADD EVENT sqlserver.sql_batch_completed(
    ACTION(
        sqlserver.client_app_name,
        sqlserver.client_hostname,
        sqlserver.database_name,
        sqlserver.server_principal_name,
        sqlserver.session_id,
        sqlserver.sql_text,
        sqlserver.username
    )
    WHERE (
         -- Batch completion with large result sets (alternative capture)
        [row_count] > 10000 
        -- Add specific database or table filters as needed
        /* AND sqlserver.database_name = N'YourSensitiveDatabase' */
        or [batch_text] like '%xp[_]%'
        -- Auditing Changes
        OR ([batch_text] like '%ALTER SERVER AUDIT%'  OR [batch_text] like '%DROP SERVER AUDIT%' OR [batch_text] like '%CREATE SERVER AUDIT%')
         -- Extended Event Changes
        OR ([batch_text] like '%ALTER EVENT SESSION%' OR [batch_text] like '%DROP EVENT SESSION%' OR [batch_text] like '%CREATE EVENT SESSION%')
         -- Audit DDM UNMASK
        OR ([batch_text] like '%UNMASK%')
    )
),

-- Specific query patterns that may indicate attacks
ADD EVENT sqlserver.sql_statement_completed(
    ACTION(
        sqlserver.client_app_name,
        sqlserver.client_hostname,
        sqlserver.database_name,
        sqlserver.server_principal_name,
        sqlserver.session_id,
        sqlserver.username
    )
    WHERE (
        -- Potential divide-by-zero attack patterns
       ( [statement] like '%/%' AND
        [statement] like '%CASE%' ) 
       or [statement] like '%xp[_]%'
      -- Auditing Changes
        OR ([statement] like '%ALTER SERVER AUDIT%'  OR [statement] like '%DROP SERVER AUDIT%' OR [statement] like '%CREATE SERVER AUDIT%')
     -- Extended Event Changes
        OR ([statement] like '%ALTER EVENT SESSION%' OR [statement] like '%DROP EVENT SESSION%' OR [statement] like '%CREATE EVENT SESSION%')
     -- Audit DDM UNMASK
     OR ([statement] like '%UNMASK%')
      )
)

-- Store events in both ring buffer (for immediate analysis) and file (for forensics)
ADD TARGET package0.ring_buffer(
    SET max_memory = 4096,
        max_events_limit = 5000
),
ADD TARGET package0.event_file(
    SET filename = N'C:\SQLSecurityLogs\SecurityMonitoring.xel',
        max_file_size = 200,
        max_rollover_files = 20
)
WITH (MAX_MEMORY = 8192 KB,
    EVENT_RETENTION_MODE = ALLOW_SINGLE_EVENT_LOSS,
    MAX_DISPATCH_LATENCY = 30 SECONDS,
    STARTUP_STATE = ON
);
GO
-- Start the Extended Events session
ALTER EVENT SESSION SecurityMonitoring ON SERVER STATE = START;
GO
