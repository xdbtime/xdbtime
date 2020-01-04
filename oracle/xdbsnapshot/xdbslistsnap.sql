 -- filename: xdbslistsnap.sql
 -- description: sql script to show available awr snapshots for time frame between (sysdate - period_since) and (sysdate - hrssince + period_duration))
 -- parameters:
 --     1. Last N hours - where you are looking for snapshots.
 --     2. Period duration in hours - where you are looking for snapshots.
 
 -- Example:
 --     SQL> @xdbslistsnap.sql
 --     Enter last N hours - where you are looking for snapshots: 27
 --     Enter duration in hours - where you are looking for snapshots: 4
 -- this means that we are looking for snapshots in range of dates [sysdate - 27/24, sysdate - 27/24 + 4/24]

set verify off

accept period_since char prompt 'Enter last N hours - where you are looking for snapshots: '
accept period_duration char prompt 'Enter duration in hours - where you are looking for snapshots: '


select sample_id, to_char(sample_time,'DD-MM-YYYY HH24:MI:SS') sample_time from xdbsnapshot.tbl_snapshot where sample_time between (sysdate - (&period_since/24)) and (sysdate - (&period_since/24) + (&period_duration/24)) order by sample_id;

set verify on