/*
    Copyright (c) 2016-2022 Taras Guliak XDBTIME
    All rights reserved.
    Version: 2022.01

    SQL script to show available snapshots in a database. Performance comparison report can be built based on ranges of snapshots

    Parameters:
        1. DBID
        2. Instance Number
        3. Last N hours - where you are looking for snapshots.
        4. Period duration in hours - where you are looking for snapshots.

    Example:
        SQL> xdbmolistsnap.sql
        Enter last N hours - where you are looking for snapshots: 27
        Enter duration in hours - where you are looking for snapshots: 4
        
        That means that we are looking for snapshots in range of dates [sysdate - 27/24, sysdate - 27/24 + 4/24]

        SQL> @xdbawrlistsnap.sql
        Enter DBID: 2216040323
        Enter Instance Number: 1
        Enter last N hours - where you are looking for snapshots: 2
        Enter duration in hours - where you are looking for snapshots: 1

                DBID    INSTANCE_NUMBER    SNAP_ID    BEGIN_INTERVAL_TIME
        _____________ __________________ __________ ______________________
           2216040323                  1       4960 08-05-2022 18:00:55
           2216040323                  1       4961 08-05-2022 18:15:55
           2216040323                  1       4962 08-05-2022 18:30:55
           2216040323                  1       4963 08-05-2022 18:45:55
*/

set verify off

accept dbid char prompt 'Enter DBID: '
accept instance_number char prompt 'Enter Instance Number: '
accept period_since char prompt 'Enter last N hours - where you are looking for snapshots: '
accept period_duration char prompt 'Enter duration in hours - where you are looking for snapshots: '

select &dbid dbid, &instance_number instance_number, snap_id, to_char(begin_interval_time,'DD-MM-YYYY HH24:MI:SS') begin_interval_time from cdb_hist_snapshot where dbid = &dbid and instance_number = &instance_number and begin_interval_time between (sysdate - (&period_since/24)) and (sysdate - (&period_since/24) + (&period_duration/24)) order by snap_id;

set verify on