/*
    Copyright (c) 2016-2022 Taras Guliak XDBTIME
    All rights reserved.
    Version: 2022.01

    SQL script to show available snapshots in a database. Performance comparison report can be built based on ranges of snapshots

    Parameters:
        1. Last N hours - where you are looking for snapshots.
        2. Period duration in hours - where you are looking for snapshots.

    Example:
        SQL> xdbmolistsnap.sql
        Enter last N hours - where you are looking for snapshots: 27
        Enter duration in hours - where you are looking for snapshots: 4
        
        That means that we are looking for snapshots in range of dates [sysdate - 27/24, sysdate - 27/24 + 4/24]
*/

set verify off

accept period_since char prompt 'Enter last N hours - where you are looking for snapshots: '
accept period_duration char prompt 'Enter duration in hours - where you are looking for snapshots: '


select sample_id, to_char(sample_time,'DD-MM-YYYY HH24:MI:SS') sample_time from XDBMONITORING.tbl_snapshot where sample_time between (sysdate - (&period_since/24)) and (sysdate - (&period_since/24) + (&period_duration/24)) order by sample_id;

set verify on