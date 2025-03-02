/*
    Copyright (c) 2016-2025 Taras Guliak XDBTIME
    All rights reserved.
    Version: 2025.02

    SQL script to show snapshots for particular date. Performance comparison report can be built based on ranges of snapshots.

    Parameters:
        1. DBID
        2. Instance Number
        3. Date (DD-MON-YY)

    Example:
        SQL> @xdbawrlistsnap.sql

        XDBTIME reports for Oracle EE (with Diagnostic Pack)
        Copyright (c) 2016, 2025, XDBTIME Taras Guliak
        Version: 2025.02

        Snapshots per DBID and Instance Number and Date

        Enter DBID: 2806000505
        Enter Instance Number: 1
        Enter Date (DD-MON-YY): 02-FEB-23

        SNAP_ID             BEGIN_INTERVAL_TIME               END_INTERVAL_TIME    DB_TIME_IN_MINUTES
        __________ _______________________________ _______________________________ _____________________
             11636 02-FEB-23 00.00.46.300000000    02-FEB-23 00.15.46.589000000                        0
             ...
             11690 02-FEB-23 13.30.03.533000000    02-FEB-23 13.45.15.488000000                    15.24
             11691 02-FEB-23 13.45.15.488000000    02-FEB-23 14.00.24.008000000                    17.81
             ...
             11730 02-FEB-23 23.30.37.053000000    02-FEB-23 23.45.37.351000000                        0

        95 rows selected.


        DBID            : 2806000505
        Instance Number : 1

        Run @xdbawrcompare.sql to generate performance comparison report
*/
set termout on;
set linesize 2100;
prompt
prompt XDBTIME reports for Oracle EE (with Diagnostic Pack)
prompt Copyright (c) 2016, 2025, XDBTIME Taras Guliak
prompt Version: 2025.02
prompt
prompt Snapshots per DBID and Instance Number and Date
prompt

set verify off


accept dbid char prompt 'Enter DBID: '
accept instance_number char prompt 'Enter Instance Number: '
accept interval_date char prompt 'Enter Date (DD-MON-YY): '

SELECT
    snap_id,
    begin_interval_time,
    end_interval_time,
    ROUND((value - prev_value)/1000000/60,2) db_time_in_minutes 
FROM
(
    SELECT 
        stm.snap_id,
        begin_interval_time,
        end_interval_time, 
        value,
        LAG(value, 1, 0) OVER (PARTITION BY stat_name ORDER BY stat_name, end_interval_time) prev_value
    FROM cdb_hist_sys_time_model stm
    INNER JOIN cdb_hist_snapshot s ON stm.dbid=s.dbid AND stm.instance_number=s.instance_number AND stm.snap_id = s.snap_id
    WHERE stat_name = 'DB time'
        AND stm.dbid = &dbid
        AND stm.instance_number = &instance_number
        AND TRUNC(s.end_interval_time) = TO_DATE('&interval_date','DD-MON-YY')
)
WHERE prev_value>0
ORDER BY 1;
prompt
prompt DBID            : &dbid 
prompt Instance Number : &instance_number
prompt
prompt Run @xdbawrcompare.sql to generate performance comparison report
prompt
set verify on
set linesize 78;