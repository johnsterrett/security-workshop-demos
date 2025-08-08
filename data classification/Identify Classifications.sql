
/* Run this for SQL Server 2019 and above
sys.sensitivity_classification was added in SQL Server 2019 */
USE [contoso]
Go

SELECT
    schema_name(O.schema_id) AS schema_name,
    O.NAME AS table_name, C.NAME AS column_name,
    information_type,label,rank,rank_desc
FROM sys.sensitivity_classifications sc
    JOIN sys.objects O
    ON  sc.major_id = O.object_id
JOIN sys.columns C 
    ON  sc.major_id = C.object_id  
    AND sc.minor_id = C.column_id
     
/* Run this for SQL Server 2017/2016 */ 
SELECT
    schema_name(O.schema_id) AS schema_name,
    O.NAME AS table_name,
    C.NAME AS column_name,
    information_type,
    sensitivity_label 
FROM
    (
        SELECT
            IT.major_id,
            IT.minor_id,
            IT.information_type,
            L.sensitivity_label 
        FROM
        (
            SELECT
                major_id,
                minor_id,
                value AS information_type 
            FROM sys.extended_properties 
            WHERE NAME = 'sys_information_type_name'
        ) IT 
        FULL OUTER JOIN
        (
            SELECT
                major_id,
                minor_id,
                value AS sensitivity_label 
            FROM sys.extended_properties 
            WHERE NAME = 'sys_sensitivity_label_name'
        ) L 
        ON IT.major_id = L.major_id AND IT.minor_id = L.minor_id
    ) EP
    JOIN sys.objects O
    ON  EP.major_id = O.object_id 
    JOIN sys.columns C 
    ON  EP.major_id = C.object_id AND EP.minor_id = C.column_id

