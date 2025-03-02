/*
    Copyright (c) 2016-2025 Taras Guliak XDBTIME
    All rights reserved.
    Version: 2025.02

    SQL script to show snapshot summary per date. 
    With @xdbmolistsnap.sql you can get list of snapshots for particular date.
    Performance comparison report can be built based on ranges of snapshots.

    Parameters:
        1. Last N hours - where you are looking for snapshots.
        2. Period duration in hours - where you are looking for snapshots.

    Example:
        SQL> @xdbmolistdates.sql

        XDBTIME reports for Oracle (based on xdbmonitoring schema)
        Copyright (c) 2016, 2025, XDBTIME Taras Guliak
        Version: 2025.02

        Snapshot Summary per Date


        INTERVAL_DATE    MIN_SNAP_ID    MAX_SNAP_ID        MIN_SAMPLE_TIME        MAX_SAMPLE_TIME    DB_TIME_IN_MINUTES
        ________________ ______________ ______________ ______________________ ______________________ _____________________
        03-FEB-23                     1              6 03-02-2023 21:45:00    03-02-2023 22:10:00                     6.48


        Run @xdbmolistsnap.sql to get list of snapshots for particular date
*/

set termout on;
prompt
prompt XDBTIME reports for Oracle (based on xdbmonitoring schema)
prompt Copyright (c) 2016, 2025, XDBTIME Taras Guliak
prompt Version: 2025.02
prompt
prompt Snapshot Summary per Date
prompt

set verify off

SELECT 
    interval_date,
    MIN(min_snap_id) min_snap_id,
    MAX(max_snap_id) max_snap_id,
    TO_CHAR(MIN(begin_interval_time),'DD-MM-YYYY HH24:MI:SS') min_sample_time,
    TO_CHAR(MAX(end_interval_time),'DD-MM-YYYY HH24:MI:SS') max_sample_time,
    ROUND(sum(db_time)/1000000/60,2) db_time_in_minutes
FROM
(
    SELECT 
        s.startup_time,
        TRUNC(s.sample_time) interval_date,
        MIN(s.sample_id) min_snap_id,
        MAX(s.sample_id) max_snap_id,
        MIN(s.sample_time) begin_interval_time,
        MAX(s.sample_time) end_interval_time,
        max(stm.value),
        min(stm.value),
        max(stm.value) - min(stm.value) db_time
    FROM xdbmonitoring.tbl_snapshot s
        INNER JOIN xdbmonitoring.tbl_sys_time_model stm ON s.sample_id = stm.sample_id
    WHERE stm.stat_name = 'DB time'
    GROUP BY s.startup_time, TRUNC(s.sample_time)
)
GROUP BY interval_date
ORDER BY 1;
prompt
prompt Run @xdbmolistsnap.sql to get list of snapshots for particular date
prompt

set verify on