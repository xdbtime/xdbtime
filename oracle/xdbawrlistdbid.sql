/*
    Copyright (c) 2016-2025 Taras Guliak XDBTIME
    All rights reserved.
    Version: 2025.02

    SQL script to show available DBIDs.
    With @xdbawrlistdates.sql you can get summary of snapshots grouped by date.
    With @xdbawrlistsnap.sql you can get list of snapshots for particular date.
    Performance comparison report can be built based on ranges of snapshots.

    Example:
        SQL> @xdbawrlistdbid.sql

        XDBTIME reports for Oracle EE (with Diagnostic Pack)
        Copyright (c) 2016, 2025, XDBTIME Taras Guliak
        Version: 2025.02

        Snapshot Summary per DBID and Instance Number


                DBID    INSTANCE_NUMBER    MIN_SNAP_ID    MAX_SNAP_ID       BEGIN_INTERVAL_TIME         END_INTERVAL_TIME    DB_TIME_IN_MINUTES
        _____________ __________________ ______________ ______________ _________________________ _________________________ _____________________
           2806000505                  1          11497          11816 31-JAN-23 13.18.19.000    03-FEB-23 21.15.03.419                   193.88


        Run @xdbawrlistdates.sql to get summary of snapshots grouped by date
*/
set termout on;
set linesize 2100;
prompt
prompt XDBTIME reports for Oracle EE (with Diagnostic Pack)
prompt Copyright (c) 2016, 2025, XDBTIME Taras Guliak
prompt Version: 2025.02
prompt
prompt Snapshot Summary per DBID and Instance Number
prompt

SELECT 
    dbid,
    instance_number,
    MIN(min_snap_id) min_snap_id,
    MAX(max_snap_id) max_snap_id,
    TO_CHAR(MIN(begin_interval_time)) begin_interval_time,
    TO_CHAR(MAX(end_interval_time)) end_interval_time,
    ROUND(sum(db_time)/1000000/60,2) db_time_in_minutes
FROM
(SELECT 
    s.dbid,
    s.instance_number,
    s.startup_time,
    MIN(s.snap_id) min_snap_id,
    MAX(s.snap_id) max_snap_id,
    MIN(s.begin_interval_time) begin_interval_time,
    MAX(s.end_interval_time) end_interval_time,
    MAX(stm.value),
    MIN(stm.value),
    MAX(stm.value) - MIN(stm.value) db_time
FROM cdb_hist_snapshot s
INNER JOIN cdb_hist_sys_time_model stm ON s.snap_id = stm.snap_id AND s.dbid = stm.dbid AND s.instance_number = stm.instance_number
WHERE stm.stat_name = 'DB time'
GROUP BY s.dbid, s.instance_number, s.startup_time)
GROUP BY dbid, instance_number;

prompt
prompt Run @xdbawrlistdates.sql to get summary of snapshots grouped by date
prompt
set linesize 78;
