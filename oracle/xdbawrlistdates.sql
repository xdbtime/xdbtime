/*
    Copyright (c) 2016-2025 Taras Guliak XDBTIME
    All rights reserved.
    Version: 2025.02

    SQL script to show snapshot summary per date. 
    With @xdbawrlistsnap.sql you can get list of snapshots for particular date.
    Performance comparison report can be built based on ranges of snapshots.

    Parameters:
        1. DBID
        2. Instance Number

    Example:
        SQL> @xdbawrlistdates.sql

        XDBTIME reports for Oracle EE (with Diagnostic Pack)
        Copyright (c) 2016, 2025, XDBTIME Taras Guliak
        Version: 2025.02

        Snapshot Summary per DBID and Instance Number and Date

        Enter DBID: 2806000505
        Enter Instance Number: 1

                DBID    INSTANCE_NUMBER    INTERVAL_DATE    MIN_SNAP_ID    MAX_SNAP_ID       BEGIN_INTERVAL_TIME         END_INTERVAL_TIME    DB_TIME_IN_MINUTES
        _____________ __________________ ________________ ______________ ______________ _________________________ _________________________ _____________________
           2806000505                  1 31-JAN-23                 11497          11539 31-JAN-23 13.18.19.000    01-FEB-23 00.00.18.000                     11.4
           2806000505                  1 01-FEB-23                 11540          11635 01-FEB-23 00.00.18.000    02-FEB-23 00.00.46.300                     4.18
           2806000505                  1 02-FEB-23                 11636          11731 02-FEB-23 00.00.46.300    03-FEB-23 00.00.37.661                   177.82
           2806000505                  1 03-FEB-23                 11732          11815 03-FEB-23 00.00.37.661    03-FEB-23 21.00.03.076                     0.47


        Run @xdbawrlistsnap.sql to get list of snapshots for particular date
*/
set termout on;
set linesize 2100;
prompt
prompt XDBTIME reports for Oracle EE (with Diagnostic Pack)
prompt Copyright (c) 2016, 2025, XDBTIME Taras Guliak
prompt Version: 2025.02
prompt
prompt Snapshot Summary per DBID and Instance Number and Date
prompt

set verify off


accept dbid char prompt 'Enter DBID: '
accept instance_number char prompt 'Enter Instance Number: '

SELECT 
    dbid,
    instance_number,
    interval_date,
    MIN(min_snap_id) min_snap_id,
    MAX(max_snap_id) max_snap_id,
    TO_CHAR(MIN(begin_interval_time)) begin_interval_time,
    TO_CHAR(MAX(end_interval_time)) end_interval_time,
    ROUND(sum(db_time)/1000000/60,2) db_time_in_minutes
FROM
(
    SELECT 
        s.dbid,
        s.instance_number,
        s.startup_time,
        TRUNC(s.begin_interval_time) interval_date,
        MIN(s.snap_id) min_snap_id,
        MAX(s.snap_id) max_snap_id,
        MIN(s.begin_interval_time) begin_interval_time,
        MAX(s.end_interval_time) end_interval_time,
        max(stm.value),
        min(stm.value),
        max(stm.value) - min(stm.value) db_time
    FROM cdb_hist_snapshot s
        INNER JOIN cdb_hist_sys_time_model stm ON s.snap_id = stm.snap_id AND s.dbid = stm.dbid AND s.instance_number = stm.instance_number
    WHERE stm.stat_name = 'DB time'
        AND s.dbid = &dbid
        AND s.instance_number = &instance_number
    GROUP BY s.dbid, s.instance_number, s.startup_time, TRUNC(s.begin_interval_time)
)
GROUP BY dbid, instance_number, interval_date
ORDER BY 1,2,3;
prompt
prompt Run @xdbawrlistsnap.sql to get list of snapshots for particular date
prompt

set verify on
set linesize 78;