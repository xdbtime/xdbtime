 -- filename: awrlistdbid.sql
 -- description: sql script to show available awr snapshots for particular dbid, instance_name for time frame between (sysdate - hrssince) and (sysdate - hrssince + hrsduration))
 -- parameters:
 --     1. DBID
 --     2. INSTANCE_NUMBER
 --     3. Last N hours - where you are looking for snapshots.
 --     4. Period duration in hours - where you are looking for snapshots.
 
 -- Example:
 --     SQL> @awrlistsnap.sql
 --     Enter DBID: 2185458275
 --     Enter Instance Number: 1
 --     Enter last N hours - where you are looking for snapshots: 27
 --     Enter duration in hours - where you are looking for snapshots: 4
 -- this means that we are looking for snapshots in range of dates [sysdate - 27/24, sysdate - 27/24 + 4/24]

set verify off

accept dbid char prompt 'Enter DBID: '
accept instance_number char prompt 'Enter Instance Number: '
accept period_since char prompt 'Enter last N hours - where you are looking for snapshots: '
accept period_duration char prompt 'Enter duration in hours - where you are looking for snapshots: '

select &dbid dbid, &instance_number instance_number, snap_id, to_char(begin_interval_time,'DD-MM-YYYY HH24:MI:SS') begin_interval_time from cdb_hist_snapshot where dbid = &dbid and instance_number = &instance_number and begin_interval_time between (sysdate - (&period_since/24)) and (sysdate - (&period_since/24) + (&period_duration/24)) order by snap_id;

set verify on