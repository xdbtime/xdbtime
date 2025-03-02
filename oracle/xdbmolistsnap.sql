/*
    Copyright (c) 2016-2025 Taras Guliak XDBTIME
    All rights reserved.
    Version: 2025.02

    SQL script to show snapshots for particular date. Performance comparison report can be built based on ranges of snapshots.

    Parameters:
        1. Date (DD-MON-YY)

    Example:
        SQL> @xdbmolistsnap.sql

        XDBTIME reports for Oracle (based on xdbmonitoring schema)
        Copyright (c) 2016, 2025, XDBTIME Taras Guliak
        Version: 2025.02

        Snapshots per Date

        Enter Date (DD-MON-YY): 03-FEB-23

        SNAP_ID    BEGIN_INTERVAL_TIME      END_INTERVAL_TIME    DB_TIME_IN_MINUTES
        __________ ______________________ ______________________ _____________________
                 2 03-02-2023 21:45:00    03-02-2023 21:50:00                     0.06
                 3 03-02-2023 21:50:00    03-02-2023 21:55:00                     1.58
                 4 03-02-2023 21:55:00    03-02-2023 22:00:02                     1.13
                 5 03-02-2023 22:00:02    03-02-2023 22:05:00                     3.28
                 6 03-02-2023 22:05:00    03-02-2023 22:10:00                     0.44
                 7 03-02-2023 22:10:00    03-02-2023 22:15:00                      0.5
                 8 03-02-2023 22:15:00    03-02-2023 22:20:00                      0.5
                 9 03-02-2023 22:20:00    03-02-2023 22:25:00                      0.5

        8 rows selected.


        Run @xdbmocompare.sql to generate performance comparison report
*/
set termout on;
prompt
prompt XDBTIME reports for Oracle (based on xdbmonitoring schema)
prompt Copyright (c) 2016, 2025, XDBTIME Taras Guliak
prompt Version: 2025.02
prompt
prompt Snapshots per Date
prompt

set verify off


accept interval_date char prompt 'Enter Date (DD-MON-YY): '

SELECT
    snap_id,
    TO_CHAR(begin_interval_time,'DD-MM-YYYY HH24:MI:SS') begin_interval_time,
    TO_CHAR(end_interval_time,'DD-MM-YYYY HH24:MI:SS') end_interval_time,
    ROUND((value - prev_value)/1000000/60,2) db_time_in_minutes 
FROM
(
    SELECT 
        s.sample_id snap_id,
        s.sample_time end_interval_time, 
        LAG(s.sample_time, 1, startup_time) OVER (PARTITION BY stat_name ORDER BY stat_name, s.sample_time) begin_interval_time,
        value,
        LAG(value, 1, 0) OVER (PARTITION BY stat_name ORDER BY stat_name, s.sample_time) prev_value
    FROM xdbmonitoring.tbl_snapshot s
        INNER JOIN xdbmonitoring.tbl_sys_time_model stm ON s.sample_id = stm.sample_id
    WHERE stat_name = 'DB time'
        AND TRUNC(s.sample_time) = TO_DATE('&interval_date','DD-MON-YY')
)
WHERE prev_value>0
ORDER BY 1;

prompt
prompt Run @xdbmocompare.sql to generate performance comparison report
prompt
set verify on