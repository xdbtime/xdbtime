#   Copyright (c) 2016, 2025, XDBTIME Taras Guliak 
#   All rights reserved.

def compare(session, args):

    print('')
    print('XDBTIME reports for MySQL')
    print('Copyright (c) 2016, 2025, XDBTIME Taras Guliak')
    print('Version: 2025.02')
    print('')                                 

    isvalid = 1

    try:
        checkparam =  int(args[0]) + int(args[1]) +int(args[2]) + int(args[3])
    except ValueError:
        print("Only integer parameters are accepted.  Please provide valid snapshots.")
        print('Run "\show snapshots" to see available snapshots')
        isvalid = 0

    if isvalid == 1:

        stmt = " SELECT sample_id INTO @bl_start_sample_id FROM xdbmonitoring.tbl_snapshot WHERE sample_id = "+args[0]
        session.run_sql(stmt)
        
        stmt = " SELECT sample_id INTO @bl_finish_sample_id FROM xdbmonitoring.tbl_snapshot WHERE sample_id = "+args[1]
        session.run_sql(stmt)

        stmt = " SELECT sample_id INTO @tr_start_sample_id FROM xdbmonitoring.tbl_snapshot WHERE sample_id = "+args[2]
        session.run_sql(stmt)

        stmt = " SELECT sample_id INTO @tr_finish_sample_id FROM xdbmonitoring.tbl_snapshot WHERE sample_id = "+args[3]
        session.run_sql(stmt)

        stmt = " SELECT IFNULL(@bl_start_sample_id,0),  IFNULL(@bl_finish_sample_id,0), IFNULL(@tr_start_sample_id,0), IFNULL(@tr_finish_sample_id,0)"
        result_sql = session.run_sql(stmt)
        row = result_sql.fetch_one()

        if int(row[0])==0 or int(row[1])==0 or int(row[2])==0 or int(row[3])==0:
            print('Not valid input parameters: One of the snapshots does not exist.')
            print('     Baseline snapshot range [',row[0],',',row[1],']')
            print('     Test run snapshot range [',row[2],',',row[3],']')
            print('')
            print('Run "\show snapshots" to see available snapshots')
            isvalid = 0
        elif int(row[0])>=int(row[1]) or int(row[2])>=int(row[3]):    
            print('Not valid input parameters: One of the snapshot ranges is not valid.')
            print(' Finish snapshot id must be greater than start snapshot id')
            print('     Baseline snapshot range [',row[0],',',row[1],']')
            print('     Test run snapshot range [',row[2],',',row[3],']')
            print('')
            print('Run "\show snapshots" to see available snapshots')
            isvalid = 0

    if isvalid == 0:
        print('Report generation is interrupted.')
        print('')
        file_name = 'null'
    else:
        print('Creating MySQL Performance Period Comparison Report ...')

        session.start_transaction()
        
        stmt = "DELETE FROM xdbmonitoring.tbl_aggregated_digest_stats;"

        session.run_sql(stmt)

        stmt = ("insert into xdbmonitoring.tbl_aggregated_digest_stats "
                "( "
                    "digest_type, "
                    "schema_name_t, "
                    "digest_t, "
                    "count_star_t, "
                    "timer_wait_t, "
                    "lock_time_t, "
                    "errors_t, "
                    "warnings_t, "
                    "rows_affected_t, "
                    "rows_sent_t, "
                    "rows_examined_t, "
                    "created_tmp_disk_tables_t, "
                    "created_tmp_tables_t, "
                    "select_full_join_t, "
                    "select_full_range_join_t, "
                    "select_range_t, "
                    "select_range_check_t, "
                    "select_scan_t, "
                    "sort_merge_passes_t, "
                    "sort_range_t, "
                    "sort_rows_t, "
                    "sort_scan_t, "
                    "no_index_used_t, "
                    "no_good_index_used_t, "
                    "schema_name_b, "
                    "digest_b, "
                    "count_star_b, "
                    "timer_wait_b, "
                    "lock_time_b, "
                    "errors_b, "
                    "warnings_b, "
                    "rows_affected_b, "
                    "rows_sent_b, "
                    "rows_examined_b, "
                    "created_tmp_disk_tables_b, "
                    "created_tmp_tables_b, "
                    "select_full_join_b, "
                    "select_full_range_join_b, "
                    "select_range_b, "
                    "select_range_check_b, "
                    "select_scan_b, "
                    "sort_merge_passes_b, "
                    "sort_range_b, "
                    "sort_rows_b, "
                    "sort_scan_b, "
                    "no_index_used_b, "
                    "no_good_index_used_b "
                ") "
                "select  "
                "case when a.digest_b is null then '0: New (+)'  "
                "when a.digest_t is null then '0: Aged out (-)'  "
                "else schema_name_t end sql_type  "
                ", a.*  "
                "from "
                "(select * from  "
                "(select  "
                "ifnull(schema_name,'null') schema_name_t, "
                "digest digest_t, "
                "sum(delta_count_star)  sum_count_star_t, "
                "sum(delta_timer_wait) sum_timer_wait_t, "
                "sum(delta_lock_time) sum_lock_time_t, "
                "sum(delta_errors) sum_errors_t, "
                "sum(delta_warnings) sum_warnings_t, "
                "sum(delta_rows_affected) sum_rows_affected_t, "
                "sum(delta_rows_sent) sum_rows_sent_t, "
                "sum(delta_rows_examined) sum_rows_examined_t, "
                "sum(delta_created_tmp_disk_tables) sum_created_tmp_disk_tables_t, "
                "sum(delta_created_tmp_tables) sum_created_tmp_tables_t, "
                "sum(delta_select_full_join) sum_select_full_join_t, "
                "sum(delta_select_full_range_join) sum_select_full_range_join_t, "
                "sum(delta_select_range) sum_select_range_t, "
                "sum(delta_select_range_check) sum_select_range_check_t, "
                "sum(delta_select_scan) sum_select_scan_t, "
                "sum(delta_sort_merge_passes) sum_sort_merge_passes_t, "
                "sum(delta_sort_range) sum_sort_range_t, "
                "sum(delta_sort_rows) sum_sort_rows_t, "
                "sum(delta_sort_scan) sum_sort_scan_t, "
                "sum(delta_no_index_used) sum_no_index_used_t, "
                "sum(delta_no_good_index_used) sum_no_good_index_used_t "
                "from xdbmonitoring.tbl_events_statements_summary_by_digest  "
                "where sample_id between @tr_start_sample_id+1 and @tr_finish_sample_id  "
                "group by IFNULL(schema_name,'null'), digest) tr "
                "left join "
                "(select  "
                "ifnull(schema_name,'null') schema_name_b, "
                "digest digest_b, "
                "sum(delta_count_star)  sum_count_star_b, "
                "sum(delta_timer_wait) sum_timer_wait_b, "
                "sum(delta_lock_time) sum_lock_time_b, "
                "sum(delta_errors) sum_errors_b, "
                "sum(delta_warnings) sum_warnings_b, "
                "sum(delta_rows_affected) sum_rows_affected_b, "
                "sum(delta_rows_sent) sum_rows_sent_b, "
                "sum(delta_rows_examined) sum_rows_examined_b, "
                "sum(delta_created_tmp_disk_tables) sum_created_tmp_disk_tables_b, "
                "sum(delta_created_tmp_tables) sum_created_tmp_tables_b, "
                "sum(delta_select_full_join) sum_select_full_join_b, "
                "sum(delta_select_full_range_join) sum_select_full_range_join_b, "
                "sum(delta_select_range) sum_select_range_b, "
                "sum(delta_select_range_check) sum_select_range_check_b, "
                "sum(delta_select_scan) sum_select_scan_b, "
                "sum(delta_sort_merge_passes) sum_sort_merge_passes_b, "
                "sum(delta_sort_range) sum_sort_range_b, "
                "sum(delta_sort_rows) sum_sort_rows_b, "
                "sum(delta_sort_scan) sum_sort_scan_b, "
                "sum(delta_no_index_used) sum_no_index_used_b, "
                "sum(delta_no_good_index_used) sum_no_good_index_used_b  "
                "from xdbmonitoring.tbl_events_statements_summary_by_digest  "
                "where sample_id between @bl_start_sample_id+1 and @bl_finish_sample_id  "
                "group by IFNULL(schema_name,'null'), digest) bl on bl.schema_name_b = tr.schema_name_t and bl.digest_b = tr.digest_t "
                "union "
                "select * from  "
                "(select  "
                "ifnull(schema_name,'null') schema_name_t, "
                "digest digest_t, "
                "sum(delta_count_star)  sum_count_star_t, "
                "sum(delta_timer_wait) sum_timer_wait_t, "
                "sum(delta_lock_time) sum_lock_time_t, "
                "sum(delta_errors) sum_errors_t, "
                "sum(delta_warnings) sum_warnings_t, "
                "sum(delta_rows_affected) sum_rows_affected_t, "
                "sum(delta_rows_sent) sum_rows_sent_t, "
                "sum(delta_rows_examined) sum_rows_examined_t, "
                "sum(delta_created_tmp_disk_tables) sum_created_tmp_disk_tables_t, "
                "sum(delta_created_tmp_tables) sum_created_tmp_tables_t, "
                "sum(delta_select_full_join) sum_select_full_join_t, "
                "sum(delta_select_full_range_join) sum_select_full_range_join_t, "
                "sum(delta_select_range) sum_select_range_t, "
                "sum(delta_select_range_check) sum_select_range_check_t, "
                "sum(delta_select_scan) sum_select_scan_t, "
                "sum(delta_sort_merge_passes) sum_sort_merge_passes_t, "
                "sum(delta_sort_range) sum_sort_range_t, "
                "sum(delta_sort_rows) sum_sort_rows_t, "
                "sum(delta_sort_scan) sum_sort_scan_t, "
                "sum(delta_no_index_used) sum_no_index_used_t, "
                "sum(delta_no_good_index_used) sum_no_good_index_used_t "
                "from xdbmonitoring.tbl_events_statements_summary_by_digest  "
                "where sample_id between @tr_start_sample_id+1 and @tr_finish_sample_id  "
                "group by IFNULL(schema_name,'null'), digest) tr "
                "right join "
                "(select  "
                "ifnull(schema_name,'null') schema_name_b, "
                "digest digest_b, "
                "sum(delta_count_star)  sum_count_star_b, "
                "sum(delta_timer_wait) sum_timer_wait_b, "
                "sum(delta_lock_time) sum_lock_time_b, "
                "sum(delta_errors) sum_errors_b, "
                "sum(delta_warnings) sum_warnings_b, "
                "sum(delta_rows_affected) sum_rows_affected_b, "
                "sum(delta_rows_sent) sum_rows_sent_b, "
                "sum(delta_rows_examined) sum_rows_examined_b, "
                "sum(delta_created_tmp_disk_tables) sum_created_tmp_disk_tables_b, "
                "sum(delta_created_tmp_tables) sum_created_tmp_tables_b, "
                "sum(delta_select_full_join) sum_select_full_join_b, "
                "sum(delta_select_full_range_join) sum_select_full_range_join_b, "
                "sum(delta_select_range) sum_select_range_b, "
                "sum(delta_select_range_check) sum_select_range_check_b, "
                "sum(delta_select_scan) sum_select_scan_b, "
                "sum(delta_sort_merge_passes) sum_sort_merge_passes_b, "
                "sum(delta_sort_range) sum_sort_range_b, "
                "sum(delta_sort_rows) sum_sort_rows_b, "
                "sum(delta_sort_scan) sum_sort_scan_b, "
                "sum(delta_no_index_used) sum_no_index_used_b, "
                "sum(delta_no_good_index_used) sum_no_good_index_used_b  "
                "from xdbmonitoring.tbl_events_statements_summary_by_digest  "
                "where sample_id between @bl_start_sample_id+1 and @bl_finish_sample_id  "
                "group by IFNULL(schema_name,'null'), digest) bl on bl.schema_name_b = tr.schema_name_t and bl.digest_b = tr.digest_t) a "
                "left join (select '320d55da1cf7fb9acb38eb19c1dd22b6' digest, 'm:Autocommit' sql_type from dual) s on a.digest_t = s.digest; ")

        session.run_sql(stmt)

        stmt = ("update xdbmonitoring.tbl_aggregated_digest_stats set digest_type = 'other' where digest_type not in (select digest_type from (select digest_type, sum(timer_wait_t) from xdbmonitoring.tbl_aggregated_digest_stats group by digest_type order by 2 desc limit 14) a);")
        session.run_sql(stmt)

        #tbl_aggregated_digest_stats
        stmt_top_digest_type = ("select  CONCAT('+ \"',digest_type,'\\n\"') as x from (select digest_type, sum(timer_wait_t) from xdbmonitoring.tbl_aggregated_digest_stats group by digest_type order by 2 desc limit 14) a ;")

        #events_statements_summary_global_by_event_name
        stmt_statements = ("SELECT CONCAT('+ \"',wait_class,',',wait_event,',',bl_wait_time_seconds,',',tr_wait_time_seconds,'\\n\"') as x  "
                            "FROM (SELECT SUBSTRING(s.event_name,LOCATE('/',s.event_name,1)+1,LOCATE('/',s.event_name,LOCATE('/',s.event_name,1)+1)- LOCATE('/',s.event_name,1)-1) wait_class, SUBSTRING(s.event_name,LOCATE('/',s.event_name,LOCATE('/',s.event_name,1)+1)+1,LENGTH(s.event_name) - LOCATE('/',s.event_name,LOCATE('/',s.event_name,1)+1)) wait_event, ROUND(bl_timer_wait/1000000000000,0) bl_wait_time_seconds, ROUND(tr_timer_wait/1000000000000,0) tr_wait_time_seconds  "
                            "FROM (SELECT a.event_name, IFNULL(bl.delta_timer_wait,0) bl_timer_wait, IFNULL(tr.delta_timer_wait,0) tr_timer_wait  "
                            "FROM (SELECT distinct event_name, sum_timer_wait FROM xdbmonitoring.tbl_events_statements_summary_global_by_event_name where sample_id = @tr_finish_sample_id ORDER BY sum_timer_wait DESC LIMIT 15) a  "
                            "LEFT JOIN (SELECT event_name, sum(delta_timer_wait) delta_timer_wait FROM xdbmonitoring.tbl_events_statements_summary_global_by_event_name where sample_id > @bl_start_sample_id and sample_id <= @bl_finish_sample_id group by event_name) bl ON a.event_name = bl.event_name  "
                            "LEFT JOIN (SELECT event_name, sum(delta_timer_wait) delta_timer_wait FROM xdbmonitoring.tbl_events_statements_summary_global_by_event_name where sample_id > @tr_start_sample_id and sample_id <= @tr_finish_sample_id group by event_name) tr ON a.event_name = tr.event_name  "
                            "WHERE a.event_name!='wait/synch/cond/sql/COND_queue_state' ) s WHERE (ROUND(bl_timer_wait/100,0)+ROUND(bl_timer_wait/100,0))>0) b; ")

        #events_statements_summary_global_by_event_name
        stmt_statements_timeseries_bl = ("SELECT  CONCAT('+ \"',DATE_FORMAT(sample_time,'%d/%m/%Y %H:%i:%s'),',',wait_class,',',wait_time_seconds,'\\n\"') as x FROM ( "
                            "SELECT sample_time, wait_class, ROUND(sum(delta_timer_wait)/1000000000000,0) wait_time_seconds FROM "
                            "(SELECT sample_time, SUBSTRING(s.event_name,LOCATE('/',s.event_name,1)+1,LOCATE('/',s.event_name,LOCATE('/',s.event_name,1)+1)- LOCATE('/',s.event_name,1)-1) wait_class, SUBSTRING(s.event_name,LOCATE('/',s.event_name,LOCATE('/',s.event_name,1)+1)+1,LENGTH(s.event_name) - LOCATE('/',s.event_name,LOCATE('/',s.event_name,1)+1)) wait_event, delta_timer_wait FROM xdbmonitoring.tbl_events_statements_summary_global_by_event_name s WHERE event_name!='wait/synch/cond/sql/COND_queue_state' and sample_id between @bl_start_sample_id and @bl_finish_sample_id and delta_timer_wait>0) a "
                            "GROUP BY sample_time, wait_class ORDER BY sample_time, wait_class) b; ")

        #events_statements_summary_global_by_event_name
        stmt_statements_timeseries_tr = ("SELECT  CONCAT('+ \"',DATE_FORMAT(sample_time,'%d/%m/%Y %H:%i:%s'),',',wait_class,',',wait_time_seconds,'\\n\"') as x FROM ( "
                            "SELECT sample_time, wait_class, ROUND(sum(delta_timer_wait)/1000000000000,0) wait_time_seconds FROM "
                            "(SELECT sample_time, SUBSTRING(s.event_name,LOCATE('/',s.event_name,1)+1,LOCATE('/',s.event_name,LOCATE('/',s.event_name,1)+1)- LOCATE('/',s.event_name,1)-1) wait_class, SUBSTRING(s.event_name,LOCATE('/',s.event_name,LOCATE('/',s.event_name,1)+1)+1,LENGTH(s.event_name) - LOCATE('/',s.event_name,LOCATE('/',s.event_name,1)+1)) wait_event, delta_timer_wait FROM xdbmonitoring.tbl_events_statements_summary_global_by_event_name s WHERE event_name!='wait/synch/cond/sql/COND_queue_state' and sample_id between @tr_start_sample_id and @tr_finish_sample_id and delta_timer_wait>0) a "
                            "GROUP BY sample_time, wait_class ORDER BY sample_time, wait_class) b; ")                    
        

        #events_waits_summary_global_by_event_name
        stmt_waits =   ("SELECT CONCAT('+ \"',wait_class,',',wait_event,',',bl_wait_time_seconds,',',tr_wait_time_seconds,'\\n\"') as x "
                        "FROM (SELECT SUBSTRING(s.event_name,LOCATE('/',s.event_name,1)+1, IF(LOCATE('/',s.event_name,LOCATE('/',s.event_name,LOCATE('/',s.event_name,1)+1)+1) = 0,LENGTH(s.event_name),LOCATE('/',s.event_name,LOCATE('/',s.event_name,LOCATE('/',s.event_name,1)+1)+1)) - LOCATE('/',s.event_name,1)-1) wait_class, SUBSTRING(s.event_name,LOCATE('/',s.event_name,LOCATE('/',s.event_name,LOCATE('/',s.event_name,1)+1)+1)+1, LENGTH(s.event_name) - LOCATE('/',s.event_name,LOCATE('/',s.event_name,LOCATE('/',s.event_name,1)+1)+1)) wait_event, ROUND(bl_timer_wait/1000000000000,0) bl_wait_time_seconds, ROUND(tr_timer_wait/1000000000000,0) tr_wait_time_seconds "
                        "FROM "
                        "(SELECT a.event_name, IFNULL(bl.delta_timer_wait,0) bl_timer_wait, IFNULL(tr.delta_timer_wait,0) tr_timer_wait FROM (SELECT distinct event_name, sum_timer_wait FROM xdbmonitoring.tbl_events_waits_summary_global_by_event_name where sample_id = @tr_finish_sample_id ORDER BY sum_timer_wait DESC LIMIT 15) a "
                        "LEFT JOIN (SELECT event_name, sum(delta_timer_wait) delta_timer_wait FROM xdbmonitoring.tbl_events_waits_summary_global_by_event_name where sample_id > @bl_start_sample_id and sample_id <= @bl_finish_sample_id GROUP BY event_name) bl ON a.event_name = bl.event_name "
                        "LEFT JOIN (SELECT event_name, sum(delta_timer_wait) delta_timer_wait FROM xdbmonitoring.tbl_events_waits_summary_global_by_event_name where sample_id > @tr_start_sample_id and sample_id <= @tr_finish_sample_id GROUP BY event_name) tr ON a.event_name = tr.event_name "
                        "WHERE a.event_name!='wait/synch/cond/sql/COND_queue_state' ) s "
                        "WHERE event_name!='idle' and (ROUND(bl_timer_wait/1000000000000,0)+ROUND(bl_timer_wait/1000000000000,0))>0) b;")

        #events_statements_summary_global_by_event_name
        stmt_waits_timeseries_bl = ("SELECT  CONCAT('+ \"',DATE_FORMAT(sample_time,'%d/%m/%Y %H:%i:%s'),',',wait_class,',',wait_time_seconds,'\\n\"') as x FROM ( "
                            "SELECT sample_time, wait_class, ROUND(sum(delta_timer_wait)/1000000000000,0) wait_time_seconds FROM "
                            "(SELECT sample_time, SUBSTRING(s.event_name,LOCATE('/',s.event_name,1)+1, IF(LOCATE('/',s.event_name,LOCATE('/',s.event_name,LOCATE('/',s.event_name,1)+1)+1) = 0,LENGTH(s.event_name),LOCATE('/',s.event_name,LOCATE('/',s.event_name,LOCATE('/',s.event_name,1)+1)+1)) - LOCATE('/',s.event_name,1)-1) wait_class, SUBSTRING(s.event_name,LOCATE('/',s.event_name,LOCATE('/',s.event_name,LOCATE('/',s.event_name,1)+1)+1)+1, LENGTH(s.event_name) - LOCATE('/',s.event_name,LOCATE('/',s.event_name,LOCATE('/',s.event_name,1)+1)+1)) wait_event, delta_timer_wait FROM xdbmonitoring.tbl_events_waits_summary_global_by_event_name s WHERE event_name!='wait/synch/cond/sql/COND_queue_state' and event_name!='idle' and sample_id between @bl_start_sample_id and @bl_finish_sample_id and delta_timer_wait>0) a "
                            "GROUP BY sample_time, wait_class ORDER BY sample_time, wait_class) b where wait_time_seconds>0; ")
        
        #events_statements_summary_global_by_event_name
        stmt_waits_timeseries_tr = ("SELECT  CONCAT('+ \"',DATE_FORMAT(sample_time,'%d/%m/%Y %H:%i:%s'),',',wait_class,',',wait_time_seconds,'\\n\"') as x FROM ( "
                            "SELECT sample_time, wait_class, ROUND(sum(delta_timer_wait)/1000000000000,0) wait_time_seconds FROM "
                            "(SELECT sample_time, SUBSTRING(s.event_name,LOCATE('/',s.event_name,1)+1, IF(LOCATE('/',s.event_name,LOCATE('/',s.event_name,LOCATE('/',s.event_name,1)+1)+1) = 0,LENGTH(s.event_name),LOCATE('/',s.event_name,LOCATE('/',s.event_name,LOCATE('/',s.event_name,1)+1)+1)) - LOCATE('/',s.event_name,1)-1) wait_class, SUBSTRING(s.event_name,LOCATE('/',s.event_name,LOCATE('/',s.event_name,LOCATE('/',s.event_name,1)+1)+1)+1, LENGTH(s.event_name) - LOCATE('/',s.event_name,LOCATE('/',s.event_name,LOCATE('/',s.event_name,1)+1)+1)) wait_event, delta_timer_wait FROM xdbmonitoring.tbl_events_waits_summary_global_by_event_name s WHERE event_name!='wait/synch/cond/sql/COND_queue_state' and event_name!='idle' and sample_id between @tr_start_sample_id and @tr_finish_sample_id and delta_timer_wait>0) a "
                            "GROUP BY sample_time, wait_class ORDER BY sample_time, wait_class) b where wait_time_seconds>0; ")
        
        #events_stages_summary_global_by_event_name
        stmt_stages =  ("SELECT CONCAT('+ \"',wait_class,',',wait_event,',',bl_wait_time_seconds,',',tr_wait_time_seconds,'\\n\"') as x "
                        "FROM (SELECT SUBSTRING(s.event_name,LOCATE('/',s.event_name,1)+1,LOCATE('/',s.event_name,LOCATE('/',s.event_name,1)+1)- LOCATE('/',s.event_name,1)-1) wait_class, SUBSTRING(s.event_name,LOCATE('/',s.event_name,LOCATE('/',s.event_name,1)+1)+1,LENGTH(s.event_name) - LOCATE('/',s.event_name,LOCATE('/',s.event_name,1)+1)) wait_event, ROUND(bl_timer_wait/1000000000000,0) bl_wait_time_seconds, ROUND(tr_timer_wait/1000000000000,0) tr_wait_time_seconds "
                        "FROM "
                        "(SELECT a.event_name, IFNULL(bl.delta_timer_wait,0) bl_timer_wait, IFNULL(tr.delta_timer_wait,0) tr_timer_wait FROM (SELECT distinct event_name, sum_timer_wait FROM xdbmonitoring.tbl_events_stages_summary_global_by_event_name where sample_id = @tr_finish_sample_id ORDER BY sum_timer_wait DESC LIMIT 15 ) a "
                        "LEFT JOIN (SELECT event_name, sum(delta_timer_wait) delta_timer_wait FROM xdbmonitoring.tbl_events_stages_summary_global_by_event_name where sample_id > @bl_start_sample_id and sample_id <= @bl_finish_sample_id GROUP BY event_name) bl ON a.event_name = bl.event_name "
                        "LEFT JOIN (SELECT event_name, sum(delta_timer_wait) delta_timer_wait FROM xdbmonitoring.tbl_events_stages_summary_global_by_event_name where sample_id > @tr_start_sample_id and sample_id <= @tr_finish_sample_id GROUP BY event_name) tr ON a.event_name = tr.event_name "
                        "WHERE a.event_name!='wait/synch/cond/sql/COND_queue_state' ) s "
                        "WHERE (ROUND(bl_timer_wait/1000000000000,0)+ROUND(bl_timer_wait/1000000000000,0))>0) b;")
        #csvSqlStatsChartMySQL

        stmt_digest_charts =   ("SELECT CONCAT('+ \"','SQL_TYPE,',digest_type,',',0,',',COUNT(1),'\\n\"') as x from xdbmonitoring.tbl_aggregated_digest_stats WHERE digest_type = '0: New (+)' GROUP BY digest_type UNION "
                                "SELECT CONCAT('+ \"','SQL_TYPE,',digest_type,',',COUNT(1),',',0,'\\n\"') as x from xdbmonitoring.tbl_aggregated_digest_stats WHERE digest_type = '0: Aged out (-)' GROUP BY digest_type UNION "
                                "SELECT CONCAT('+ \"','SQL_TYPE,',digest_type,',',COUNT(1),',',COUNT(1),'\\n\"') as x from xdbmonitoring.tbl_aggregated_digest_stats WHERE digest_type not in ('0: New (+)', '0: Aged out (-)') GROUP BY digest_type UNION "
                                "SELECT CONCAT('+ \"','ERRORS,',digest_type,',',SUM(IFNULL(ERRORS_B,0)),',',SUM(IFNULL(ERRORS_T,0)),'\\n\"') as x from xdbmonitoring.tbl_aggregated_digest_stats GROUP BY digest_type UNION "
                                "SELECT CONCAT('+ \"','WARNINGS,',digest_type,',',SUM(IFNULL(WARNINGS_B,0)),',',SUM(IFNULL(WARNINGS_T,0)),'\\n\"') as x from xdbmonitoring.tbl_aggregated_digest_stats GROUP BY digest_type UNION "
                                "SELECT CONCAT('+ \"','ROWS_AFFECTED,',digest_type,',',SUM(IFNULL(ROWS_AFFECTED_B,0)),',',SUM(IFNULL(ROWS_AFFECTED_T,0)),'\\n\"') as x from xdbmonitoring.tbl_aggregated_digest_stats GROUP BY digest_type UNION "
                                "SELECT CONCAT('+ \"','ROWS_SENT,',digest_type,',',SUM(IFNULL(ROWS_SENT_B,0)),',',SUM(IFNULL(ROWS_SENT_T,0)),'\\n\"') as x from xdbmonitoring.tbl_aggregated_digest_stats GROUP BY digest_type UNION "
                                "SELECT CONCAT('+ \"','ROWS_EXAMINED,',digest_type,',',SUM(IFNULL(ROWS_EXAMINED_B,0)),',',SUM(IFNULL(ROWS_EXAMINED_T,0)),'\\n\"') as x from xdbmonitoring.tbl_aggregated_digest_stats GROUP BY digest_type UNION "
                                "SELECT CONCAT('+ \"','EXECUTIONS,',digest_type,',',SUM(IFNULL(COUNT_STAR_B,0)),',',SUM(IFNULL(COUNT_STAR_T,0)),'\\n\"') as x from xdbmonitoring.tbl_aggregated_digest_stats GROUP BY digest_type UNION "
                                "SELECT CONCAT('+ \"','CREATED_TMP_DISK_TABLES,',digest_type,',',SUM(IFNULL(CREATED_TMP_DISK_TABLES_B,0)),',',SUM(IFNULL(CREATED_TMP_DISK_TABLES_T,0)),'\\n\"') as x from xdbmonitoring.tbl_aggregated_digest_stats GROUP BY digest_type UNION "
                                "SELECT CONCAT('+ \"','CREATED_TMP_TABLES,',digest_type,',',SUM(IFNULL(CREATED_TMP_TABLES_B,0)),',',SUM(IFNULL(CREATED_TMP_TABLES_T,0)),'\\n\"') as x from xdbmonitoring.tbl_aggregated_digest_stats GROUP BY digest_type UNION "
                                "SELECT CONCAT('+ \"','SELECT_FULL_JOIN,',digest_type,',',SUM(IFNULL(SELECT_FULL_JOIN_B,0)),',',SUM(IFNULL(SELECT_FULL_JOIN_T,0)),'\\n\"') as x from xdbmonitoring.tbl_aggregated_digest_stats GROUP BY digest_type UNION "
                                "SELECT CONCAT('+ \"','SELECT_FULL_RANGE_JOIN,',digest_type,',',SUM(IFNULL(SELECT_FULL_RANGE_JOIN_B,0)),',',SUM(IFNULL(SELECT_FULL_RANGE_JOIN_T,0)),'\\n\"') as x from xdbmonitoring.tbl_aggregated_digest_stats GROUP BY digest_type UNION "
                                "SELECT CONCAT('+ \"','SELECT_RANGE,',digest_type,',',SUM(IFNULL(SELECT_RANGE_B,0)),',',SUM(IFNULL(SELECT_RANGE_T,0)),'\\n\"') as x from xdbmonitoring.tbl_aggregated_digest_stats GROUP BY digest_type UNION "
                                "SELECT CONCAT('+ \"','SELECT_RANGE_CHECK,',digest_type,',',SUM(IFNULL(SELECT_RANGE_CHECK_B,0)),',',SUM(IFNULL(SELECT_RANGE_CHECK_T,0)),'\\n\"') as x from xdbmonitoring.tbl_aggregated_digest_stats GROUP BY digest_type UNION "
                                "SELECT CONCAT('+ \"','SELECT_SCAN,',digest_type,',',SUM(IFNULL(SELECT_SCAN_B,0)),',',SUM(IFNULL(SELECT_SCAN_T,0)),'\\n\"') as x from xdbmonitoring.tbl_aggregated_digest_stats GROUP BY digest_type UNION "
                                "SELECT CONCAT('+ \"','SORT_MERGE_PASSES,',digest_type,',',SUM(IFNULL(SORT_MERGE_PASSES_B,0)),',',SUM(IFNULL(SORT_MERGE_PASSES_T,0)),'\\n\"') as x from xdbmonitoring.tbl_aggregated_digest_stats GROUP BY digest_type UNION "
                                "SELECT CONCAT('+ \"','SORT_RANGE,',digest_type,',',SUM(IFNULL(SORT_RANGE_B,0)),',',SUM(IFNULL(SORT_RANGE_T,0)),'\\n\"') as x from xdbmonitoring.tbl_aggregated_digest_stats GROUP BY digest_type UNION "
                                "SELECT CONCAT('+ \"','SORT_ROWS,',digest_type,',',SUM(IFNULL(SORT_ROWS_B,0)),',',SUM(IFNULL(SORT_ROWS_T,0)),'\\n\"') as x from xdbmonitoring.tbl_aggregated_digest_stats GROUP BY digest_type UNION "
                                "SELECT CONCAT('+ \"','SORT_SCAN,',digest_type,',',SUM(IFNULL(SORT_SCAN_B,0)),',',SUM(IFNULL(SORT_SCAN_T,0)),'\\n\"') as x from xdbmonitoring.tbl_aggregated_digest_stats GROUP BY digest_type UNION "
                                "SELECT CONCAT('+ \"','NO_INDEX_USED,',digest_type,',',SUM(IFNULL(NO_INDEX_USED_B,0)),',',SUM(IFNULL(NO_INDEX_USED_T,0)),'\\n\"') as x from xdbmonitoring.tbl_aggregated_digest_stats GROUP BY digest_type UNION "
                                "SELECT CONCAT('+ \"','NO_GOOD_INDEX_USED,',digest_type,',',SUM(IFNULL(NO_GOOD_INDEX_USED_B,0)),',',SUM(IFNULL(NO_GOOD_INDEX_USED_T,0)),'\\n\"') as x from xdbmonitoring.tbl_aggregated_digest_stats GROUP BY digest_type UNION "
                                "SELECT CONCAT('+ \"','TIMER_WAIT,',digest_type,',',(ROUND(SUM(IFNULL(TIMER_WAIT_B,0))/1000000000000,0)),',',(ROUND(SUM(IFNULL(TIMER_WAIT_T,0))/1000000000000,0)),'\\n\"') as x from xdbmonitoring.tbl_aggregated_digest_stats GROUP BY digest_type UNION "
                                "SELECT CONCAT('+ \"','LOCK_TIME,',digest_type,',',(ROUND(SUM(IFNULL(LOCK_TIME_B,0))/1000000000000,0)),',',(ROUND(SUM(IFNULL(LOCK_TIME_T,0))/1000000000000,0)),'\\n\"') as x from xdbmonitoring.tbl_aggregated_digest_stats GROUP BY digest_type;")
        #csvSqlStatsTableMySQL
        stmt_digest_tables =   ("SELECT a.col as x FROM (SELECT CONCAT('+ \"','SUM_LOCK_TIME,',IFNULL(digest_type,'null'),',',IFNULL(schema_name_t,'null'),',',IFNULL(digest_t,'null'),',',IFNULL(count_star_t,0),',',ROUND(IFNULL(timer_wait_t,0)/1000000000000,0),',',ROUND(IFNULL(lock_time_t,0)/1000000000000,0),',',IFNULL(errors_t,0),',',IFNULL(warnings_t,0),',',IFNULL(rows_affected_t,0),',',IFNULL(rows_sent_t,0),',',IFNULL(rows_examined_t,0),',',IFNULL(created_tmp_disk_tables_t,0),',',IFNULL(created_tmp_tables_t,0),',',IFNULL(select_full_join_t,0),',',IFNULL(select_full_range_join_t,0),',',IFNULL(select_range_t,0),',',IFNULL(select_range_check_t,0),',',IFNULL(select_scan_t,0),',',IFNULL(sort_merge_passes_t,0),',',IFNULL(sort_range_t,0),',',IFNULL(sort_rows_t,0),',',IFNULL(sort_scan_t,0),',',IFNULL(no_index_used_t,0),',',IFNULL(no_good_index_used_t,0),',',IFNULL(schema_name_b,'null'),',',IFNULL(digest_b,'null'),',',IFNULL(count_star_b,0),',',ROUND(IFNULL(timer_wait_b,0)/1000000000000,0),',',ROUND(IFNULL(lock_time_b,0)/1000000000000,0),',',IFNULL(errors_b,0),',',IFNULL(warnings_b,0),',',IFNULL(rows_affected_b,0),',',IFNULL(rows_sent_b,0),',',IFNULL(rows_examined_b,0),',',IFNULL(created_tmp_disk_tables_b,0),',',IFNULL(created_tmp_tables_b,0),',',IFNULL(select_full_join_b,0),',',IFNULL(select_full_range_join_b,0),',',IFNULL(select_range_b,0),',',IFNULL(select_range_check_b,0),',',IFNULL(select_scan_b,0),',',IFNULL(sort_merge_passes_b,0),',',IFNULL(sort_range_b,0),',',IFNULL(sort_rows_b,0),',',IFNULL(sort_scan_b,0),',',IFNULL(no_index_used_b,0),',',IFNULL(no_good_index_used_b,0),'\\n\"') as col from xdbmonitoring.tbl_aggregated_digest_stats x where IFNULL(LOCK_TIME_T,0)>0 ORDER BY  IFNULL(LOCK_TIME_T,0) DESC LIMIT 20) a UNION "
                                "SELECT a.col as x FROM (SELECT CONCAT('+ \"','SUM_ERRORS,',IFNULL(digest_type,'null'),',',IFNULL(schema_name_t,'null'),',',IFNULL(digest_t,'null'),',',IFNULL(count_star_t,0),',',ROUND(IFNULL(timer_wait_t,0)/1000000000000,0),',',ROUND(IFNULL(lock_time_t,0)/1000000000000,0),',',IFNULL(errors_t,0),',',IFNULL(warnings_t,0),',',IFNULL(rows_affected_t,0),',',IFNULL(rows_sent_t,0),',',IFNULL(rows_examined_t,0),',',IFNULL(created_tmp_disk_tables_t,0),',',IFNULL(created_tmp_tables_t,0),',',IFNULL(select_full_join_t,0),',',IFNULL(select_full_range_join_t,0),',',IFNULL(select_range_t,0),',',IFNULL(select_range_check_t,0),',',IFNULL(select_scan_t,0),',',IFNULL(sort_merge_passes_t,0),',',IFNULL(sort_range_t,0),',',IFNULL(sort_rows_t,0),',',IFNULL(sort_scan_t,0),',',IFNULL(no_index_used_t,0),',',IFNULL(no_good_index_used_t,0),',',IFNULL(schema_name_b,'null'),',',IFNULL(digest_b,'null'),',',IFNULL(count_star_b,0),',',ROUND(IFNULL(timer_wait_b,0)/1000000000000,0),',',ROUND(IFNULL(lock_time_b,0)/1000000000000,0),',',IFNULL(errors_b,0),',',IFNULL(warnings_b,0),',',IFNULL(rows_affected_b,0),',',IFNULL(rows_sent_b,0),',',IFNULL(rows_examined_b,0),',',IFNULL(created_tmp_disk_tables_b,0),',',IFNULL(created_tmp_tables_b,0),',',IFNULL(select_full_join_b,0),',',IFNULL(select_full_range_join_b,0),',',IFNULL(select_range_b,0),',',IFNULL(select_range_check_b,0),',',IFNULL(select_scan_b,0),',',IFNULL(sort_merge_passes_b,0),',',IFNULL(sort_range_b,0),',',IFNULL(sort_rows_b,0),',',IFNULL(sort_scan_b,0),',',IFNULL(no_index_used_b,0),',',IFNULL(no_good_index_used_b,0),'\\n\"') as col from xdbmonitoring.tbl_aggregated_digest_stats x where IFNULL(ERRORS_T,0)>0 ORDER BY  IFNULL(ERRORS_T,0) DESC LIMIT 20) a UNION "
                                "SELECT a.col as x FROM (SELECT CONCAT('+ \"','SUM_WARNINGS,',IFNULL(digest_type,'null'),',',IFNULL(schema_name_t,'null'),',',IFNULL(digest_t,'null'),',',IFNULL(count_star_t,0),',',ROUND(IFNULL(timer_wait_t,0)/1000000000000,0),',',ROUND(IFNULL(lock_time_t,0)/1000000000000,0),',',IFNULL(errors_t,0),',',IFNULL(warnings_t,0),',',IFNULL(rows_affected_t,0),',',IFNULL(rows_sent_t,0),',',IFNULL(rows_examined_t,0),',',IFNULL(created_tmp_disk_tables_t,0),',',IFNULL(created_tmp_tables_t,0),',',IFNULL(select_full_join_t,0),',',IFNULL(select_full_range_join_t,0),',',IFNULL(select_range_t,0),',',IFNULL(select_range_check_t,0),',',IFNULL(select_scan_t,0),',',IFNULL(sort_merge_passes_t,0),',',IFNULL(sort_range_t,0),',',IFNULL(sort_rows_t,0),',',IFNULL(sort_scan_t,0),',',IFNULL(no_index_used_t,0),',',IFNULL(no_good_index_used_t,0),',',IFNULL(schema_name_b,'null'),',',IFNULL(digest_b,'null'),',',IFNULL(count_star_b,0),',',ROUND(IFNULL(timer_wait_b,0)/1000000000000,0),',',ROUND(IFNULL(lock_time_b,0)/1000000000000,0),',',IFNULL(errors_b,0),',',IFNULL(warnings_b,0),',',IFNULL(rows_affected_b,0),',',IFNULL(rows_sent_b,0),',',IFNULL(rows_examined_b,0),',',IFNULL(created_tmp_disk_tables_b,0),',',IFNULL(created_tmp_tables_b,0),',',IFNULL(select_full_join_b,0),',',IFNULL(select_full_range_join_b,0),',',IFNULL(select_range_b,0),',',IFNULL(select_range_check_b,0),',',IFNULL(select_scan_b,0),',',IFNULL(sort_merge_passes_b,0),',',IFNULL(sort_range_b,0),',',IFNULL(sort_rows_b,0),',',IFNULL(sort_scan_b,0),',',IFNULL(no_index_used_b,0),',',IFNULL(no_good_index_used_b,0),'\\n\"') as col from xdbmonitoring.tbl_aggregated_digest_stats x where IFNULL(WARNINGS_T,0)>0 ORDER BY  IFNULL(WARNINGS_T,0) DESC LIMIT 20) a UNION "
                                "SELECT a.col as x FROM (SELECT CONCAT('+ \"','SUM_ROWS_AFFECTED,',IFNULL(digest_type,'null'),',',IFNULL(schema_name_t,'null'),',',IFNULL(digest_t,'null'),',',IFNULL(count_star_t,0),',',ROUND(IFNULL(timer_wait_t,0)/1000000000000,0),',',ROUND(IFNULL(lock_time_t,0)/1000000000000,0),',',IFNULL(errors_t,0),',',IFNULL(warnings_t,0),',',IFNULL(rows_affected_t,0),',',IFNULL(rows_sent_t,0),',',IFNULL(rows_examined_t,0),',',IFNULL(created_tmp_disk_tables_t,0),',',IFNULL(created_tmp_tables_t,0),',',IFNULL(select_full_join_t,0),',',IFNULL(select_full_range_join_t,0),',',IFNULL(select_range_t,0),',',IFNULL(select_range_check_t,0),',',IFNULL(select_scan_t,0),',',IFNULL(sort_merge_passes_t,0),',',IFNULL(sort_range_t,0),',',IFNULL(sort_rows_t,0),',',IFNULL(sort_scan_t,0),',',IFNULL(no_index_used_t,0),',',IFNULL(no_good_index_used_t,0),',',IFNULL(schema_name_b,'null'),',',IFNULL(digest_b,'null'),',',IFNULL(count_star_b,0),',',ROUND(IFNULL(timer_wait_b,0)/1000000000000,0),',',ROUND(IFNULL(lock_time_b,0)/1000000000000,0),',',IFNULL(errors_b,0),',',IFNULL(warnings_b,0),',',IFNULL(rows_affected_b,0),',',IFNULL(rows_sent_b,0),',',IFNULL(rows_examined_b,0),',',IFNULL(created_tmp_disk_tables_b,0),',',IFNULL(created_tmp_tables_b,0),',',IFNULL(select_full_join_b,0),',',IFNULL(select_full_range_join_b,0),',',IFNULL(select_range_b,0),',',IFNULL(select_range_check_b,0),',',IFNULL(select_scan_b,0),',',IFNULL(sort_merge_passes_b,0),',',IFNULL(sort_range_b,0),',',IFNULL(sort_rows_b,0),',',IFNULL(sort_scan_b,0),',',IFNULL(no_index_used_b,0),',',IFNULL(no_good_index_used_b,0),'\\n\"') as col from xdbmonitoring.tbl_aggregated_digest_stats x where IFNULL(ROWS_AFFECTED_T,0)>0 ORDER BY  IFNULL(ROWS_AFFECTED_T,0) DESC LIMIT 20) a UNION "
                                "SELECT a.col as x FROM (SELECT CONCAT('+ \"','SUM_ROWS_SENT,',IFNULL(digest_type,'null'),',',IFNULL(schema_name_t,'null'),',',IFNULL(digest_t,'null'),',',IFNULL(count_star_t,0),',',ROUND(IFNULL(timer_wait_t,0)/1000000000000,0),',',ROUND(IFNULL(lock_time_t,0)/1000000000000,0),',',IFNULL(errors_t,0),',',IFNULL(warnings_t,0),',',IFNULL(rows_affected_t,0),',',IFNULL(rows_sent_t,0),',',IFNULL(rows_examined_t,0),',',IFNULL(created_tmp_disk_tables_t,0),',',IFNULL(created_tmp_tables_t,0),',',IFNULL(select_full_join_t,0),',',IFNULL(select_full_range_join_t,0),',',IFNULL(select_range_t,0),',',IFNULL(select_range_check_t,0),',',IFNULL(select_scan_t,0),',',IFNULL(sort_merge_passes_t,0),',',IFNULL(sort_range_t,0),',',IFNULL(sort_rows_t,0),',',IFNULL(sort_scan_t,0),',',IFNULL(no_index_used_t,0),',',IFNULL(no_good_index_used_t,0),',',IFNULL(schema_name_b,'null'),',',IFNULL(digest_b,'null'),',',IFNULL(count_star_b,0),',',ROUND(IFNULL(timer_wait_b,0)/1000000000000,0),',',ROUND(IFNULL(lock_time_b,0)/1000000000000,0),',',IFNULL(errors_b,0),',',IFNULL(warnings_b,0),',',IFNULL(rows_affected_b,0),',',IFNULL(rows_sent_b,0),',',IFNULL(rows_examined_b,0),',',IFNULL(created_tmp_disk_tables_b,0),',',IFNULL(created_tmp_tables_b,0),',',IFNULL(select_full_join_b,0),',',IFNULL(select_full_range_join_b,0),',',IFNULL(select_range_b,0),',',IFNULL(select_range_check_b,0),',',IFNULL(select_scan_b,0),',',IFNULL(sort_merge_passes_b,0),',',IFNULL(sort_range_b,0),',',IFNULL(sort_rows_b,0),',',IFNULL(sort_scan_b,0),',',IFNULL(no_index_used_b,0),',',IFNULL(no_good_index_used_b,0),'\\n\"') as col from xdbmonitoring.tbl_aggregated_digest_stats x where IFNULL(ROWS_SENT_T,0)>0 ORDER BY  IFNULL(ROWS_SENT_T,0) DESC LIMIT 20) a UNION "
                                "SELECT a.col as x FROM (SELECT CONCAT('+ \"','SUM_ROWS_EXAMINED,',IFNULL(digest_type,'null'),',',IFNULL(schema_name_t,'null'),',',IFNULL(digest_t,'null'),',',IFNULL(count_star_t,0),',',ROUND(IFNULL(timer_wait_t,0)/1000000000000,0),',',ROUND(IFNULL(lock_time_t,0)/1000000000000,0),',',IFNULL(errors_t,0),',',IFNULL(warnings_t,0),',',IFNULL(rows_affected_t,0),',',IFNULL(rows_sent_t,0),',',IFNULL(rows_examined_t,0),',',IFNULL(created_tmp_disk_tables_t,0),',',IFNULL(created_tmp_tables_t,0),',',IFNULL(select_full_join_t,0),',',IFNULL(select_full_range_join_t,0),',',IFNULL(select_range_t,0),',',IFNULL(select_range_check_t,0),',',IFNULL(select_scan_t,0),',',IFNULL(sort_merge_passes_t,0),',',IFNULL(sort_range_t,0),',',IFNULL(sort_rows_t,0),',',IFNULL(sort_scan_t,0),',',IFNULL(no_index_used_t,0),',',IFNULL(no_good_index_used_t,0),',',IFNULL(schema_name_b,'null'),',',IFNULL(digest_b,'null'),',',IFNULL(count_star_b,0),',',ROUND(IFNULL(timer_wait_b,0)/1000000000000,0),',',ROUND(IFNULL(lock_time_b,0)/1000000000000,0),',',IFNULL(errors_b,0),',',IFNULL(warnings_b,0),',',IFNULL(rows_affected_b,0),',',IFNULL(rows_sent_b,0),',',IFNULL(rows_examined_b,0),',',IFNULL(created_tmp_disk_tables_b,0),',',IFNULL(created_tmp_tables_b,0),',',IFNULL(select_full_join_b,0),',',IFNULL(select_full_range_join_b,0),',',IFNULL(select_range_b,0),',',IFNULL(select_range_check_b,0),',',IFNULL(select_scan_b,0),',',IFNULL(sort_merge_passes_b,0),',',IFNULL(sort_range_b,0),',',IFNULL(sort_rows_b,0),',',IFNULL(sort_scan_b,0),',',IFNULL(no_index_used_b,0),',',IFNULL(no_good_index_used_b,0),'\\n\"') as col from xdbmonitoring.tbl_aggregated_digest_stats x where IFNULL(ROWS_EXAMINED_T,0)>0 ORDER BY  IFNULL(ROWS_EXAMINED_T,0) DESC LIMIT 20) a UNION "
                                "SELECT a.col as x FROM (SELECT CONCAT('+ \"','COUNT_STAR,',IFNULL(digest_type,'null'),',',IFNULL(schema_name_t,'null'),',',IFNULL(digest_t,'null'),',',IFNULL(count_star_t,0),',',ROUND(IFNULL(timer_wait_t,0)/1000000000000,0),',',ROUND(IFNULL(lock_time_t,0)/1000000000000,0),',',IFNULL(errors_t,0),',',IFNULL(warnings_t,0),',',IFNULL(rows_affected_t,0),',',IFNULL(rows_sent_t,0),',',IFNULL(rows_examined_t,0),',',IFNULL(created_tmp_disk_tables_t,0),',',IFNULL(created_tmp_tables_t,0),',',IFNULL(select_full_join_t,0),',',IFNULL(select_full_range_join_t,0),',',IFNULL(select_range_t,0),',',IFNULL(select_range_check_t,0),',',IFNULL(select_scan_t,0),',',IFNULL(sort_merge_passes_t,0),',',IFNULL(sort_range_t,0),',',IFNULL(sort_rows_t,0),',',IFNULL(sort_scan_t,0),',',IFNULL(no_index_used_t,0),',',IFNULL(no_good_index_used_t,0),',',IFNULL(schema_name_b,'null'),',',IFNULL(digest_b,'null'),',',IFNULL(count_star_b,0),',',ROUND(IFNULL(timer_wait_b,0)/1000000000000,0),',',ROUND(IFNULL(lock_time_b,0)/1000000000000,0),',',IFNULL(errors_b,0),',',IFNULL(warnings_b,0),',',IFNULL(rows_affected_b,0),',',IFNULL(rows_sent_b,0),',',IFNULL(rows_examined_b,0),',',IFNULL(created_tmp_disk_tables_b,0),',',IFNULL(created_tmp_tables_b,0),',',IFNULL(select_full_join_b,0),',',IFNULL(select_full_range_join_b,0),',',IFNULL(select_range_b,0),',',IFNULL(select_range_check_b,0),',',IFNULL(select_scan_b,0),',',IFNULL(sort_merge_passes_b,0),',',IFNULL(sort_range_b,0),',',IFNULL(sort_rows_b,0),',',IFNULL(sort_scan_b,0),',',IFNULL(no_index_used_b,0),',',IFNULL(no_good_index_used_b,0),'\\n\"') as col from xdbmonitoring.tbl_aggregated_digest_stats x where IFNULL(COUNT_STAR_T,0)>0 ORDER BY  IFNULL(COUNT_STAR_T,0) DESC LIMIT 20) a UNION "
                                "SELECT a.col as x FROM (SELECT CONCAT('+ \"','SUM_CREATED_TMP_DISK_TABLES,',IFNULL(digest_type,'null'),',',IFNULL(schema_name_t,'null'),',',IFNULL(digest_t,'null'),',',IFNULL(count_star_t,0),',',ROUND(IFNULL(timer_wait_t,0)/1000000000000,0),',',ROUND(IFNULL(lock_time_t,0)/1000000000000,0),',',IFNULL(errors_t,0),',',IFNULL(warnings_t,0),',',IFNULL(rows_affected_t,0),',',IFNULL(rows_sent_t,0),',',IFNULL(rows_examined_t,0),',',IFNULL(created_tmp_disk_tables_t,0),',',IFNULL(created_tmp_tables_t,0),',',IFNULL(select_full_join_t,0),',',IFNULL(select_full_range_join_t,0),',',IFNULL(select_range_t,0),',',IFNULL(select_range_check_t,0),',',IFNULL(select_scan_t,0),',',IFNULL(sort_merge_passes_t,0),',',IFNULL(sort_range_t,0),',',IFNULL(sort_rows_t,0),',',IFNULL(sort_scan_t,0),',',IFNULL(no_index_used_t,0),',',IFNULL(no_good_index_used_t,0),',',IFNULL(schema_name_b,'null'),',',IFNULL(digest_b,'null'),',',IFNULL(count_star_b,0),',',ROUND(IFNULL(timer_wait_b,0)/1000000000000,0),',',ROUND(IFNULL(lock_time_b,0)/1000000000000,0),',',IFNULL(errors_b,0),',',IFNULL(warnings_b,0),',',IFNULL(rows_affected_b,0),',',IFNULL(rows_sent_b,0),',',IFNULL(rows_examined_b,0),',',IFNULL(created_tmp_disk_tables_b,0),',',IFNULL(created_tmp_tables_b,0),',',IFNULL(select_full_join_b,0),',',IFNULL(select_full_range_join_b,0),',',IFNULL(select_range_b,0),',',IFNULL(select_range_check_b,0),',',IFNULL(select_scan_b,0),',',IFNULL(sort_merge_passes_b,0),',',IFNULL(sort_range_b,0),',',IFNULL(sort_rows_b,0),',',IFNULL(sort_scan_b,0),',',IFNULL(no_index_used_b,0),',',IFNULL(no_good_index_used_b,0),'\\n\"') as col from xdbmonitoring.tbl_aggregated_digest_stats x where IFNULL(CREATED_TMP_DISK_TABLES_T,0)>0 ORDER BY  IFNULL(CREATED_TMP_DISK_TABLES_T,0) DESC LIMIT 20) a UNION "
                                "SELECT a.col as x FROM (SELECT CONCAT('+ \"','SUM_CREATED_TMP_TABLES,',IFNULL(digest_type,'null'),',',IFNULL(schema_name_t,'null'),',',IFNULL(digest_t,'null'),',',IFNULL(count_star_t,0),',',ROUND(IFNULL(timer_wait_t,0)/1000000000000,0),',',ROUND(IFNULL(lock_time_t,0)/1000000000000,0),',',IFNULL(errors_t,0),',',IFNULL(warnings_t,0),',',IFNULL(rows_affected_t,0),',',IFNULL(rows_sent_t,0),',',IFNULL(rows_examined_t,0),',',IFNULL(created_tmp_disk_tables_t,0),',',IFNULL(created_tmp_tables_t,0),',',IFNULL(select_full_join_t,0),',',IFNULL(select_full_range_join_t,0),',',IFNULL(select_range_t,0),',',IFNULL(select_range_check_t,0),',',IFNULL(select_scan_t,0),',',IFNULL(sort_merge_passes_t,0),',',IFNULL(sort_range_t,0),',',IFNULL(sort_rows_t,0),',',IFNULL(sort_scan_t,0),',',IFNULL(no_index_used_t,0),',',IFNULL(no_good_index_used_t,0),',',IFNULL(schema_name_b,'null'),',',IFNULL(digest_b,'null'),',',IFNULL(count_star_b,0),',',ROUND(IFNULL(timer_wait_b,0)/1000000000000,0),',',ROUND(IFNULL(lock_time_b,0)/1000000000000,0),',',IFNULL(errors_b,0),',',IFNULL(warnings_b,0),',',IFNULL(rows_affected_b,0),',',IFNULL(rows_sent_b,0),',',IFNULL(rows_examined_b,0),',',IFNULL(created_tmp_disk_tables_b,0),',',IFNULL(created_tmp_tables_b,0),',',IFNULL(select_full_join_b,0),',',IFNULL(select_full_range_join_b,0),',',IFNULL(select_range_b,0),',',IFNULL(select_range_check_b,0),',',IFNULL(select_scan_b,0),',',IFNULL(sort_merge_passes_b,0),',',IFNULL(sort_range_b,0),',',IFNULL(sort_rows_b,0),',',IFNULL(sort_scan_b,0),',',IFNULL(no_index_used_b,0),',',IFNULL(no_good_index_used_b,0),'\\n\"') as col from xdbmonitoring.tbl_aggregated_digest_stats x where IFNULL(CREATED_TMP_TABLES_T,0)>0 ORDER BY  IFNULL(CREATED_TMP_TABLES_T,0) DESC LIMIT 20) a UNION "
                                "SELECT a.col as x FROM (SELECT CONCAT('+ \"','SUM_SELECT_FULL_JOIN,',IFNULL(digest_type,'null'),',',IFNULL(schema_name_t,'null'),',',IFNULL(digest_t,'null'),',',IFNULL(count_star_t,0),',',ROUND(IFNULL(timer_wait_t,0)/1000000000000,0),',',ROUND(IFNULL(lock_time_t,0)/1000000000000,0),',',IFNULL(errors_t,0),',',IFNULL(warnings_t,0),',',IFNULL(rows_affected_t,0),',',IFNULL(rows_sent_t,0),',',IFNULL(rows_examined_t,0),',',IFNULL(created_tmp_disk_tables_t,0),',',IFNULL(created_tmp_tables_t,0),',',IFNULL(select_full_join_t,0),',',IFNULL(select_full_range_join_t,0),',',IFNULL(select_range_t,0),',',IFNULL(select_range_check_t,0),',',IFNULL(select_scan_t,0),',',IFNULL(sort_merge_passes_t,0),',',IFNULL(sort_range_t,0),',',IFNULL(sort_rows_t,0),',',IFNULL(sort_scan_t,0),',',IFNULL(no_index_used_t,0),',',IFNULL(no_good_index_used_t,0),',',IFNULL(schema_name_b,'null'),',',IFNULL(digest_b,'null'),',',IFNULL(count_star_b,0),',',ROUND(IFNULL(timer_wait_b,0)/1000000000000,0),',',ROUND(IFNULL(lock_time_b,0)/1000000000000,0),',',IFNULL(errors_b,0),',',IFNULL(warnings_b,0),',',IFNULL(rows_affected_b,0),',',IFNULL(rows_sent_b,0),',',IFNULL(rows_examined_b,0),',',IFNULL(created_tmp_disk_tables_b,0),',',IFNULL(created_tmp_tables_b,0),',',IFNULL(select_full_join_b,0),',',IFNULL(select_full_range_join_b,0),',',IFNULL(select_range_b,0),',',IFNULL(select_range_check_b,0),',',IFNULL(select_scan_b,0),',',IFNULL(sort_merge_passes_b,0),',',IFNULL(sort_range_b,0),',',IFNULL(sort_rows_b,0),',',IFNULL(sort_scan_b,0),',',IFNULL(no_index_used_b,0),',',IFNULL(no_good_index_used_b,0),'\\n\"') as col from xdbmonitoring.tbl_aggregated_digest_stats x where IFNULL(SELECT_FULL_JOIN_T,0)>0 ORDER BY  IFNULL(SELECT_FULL_JOIN_T,0) DESC LIMIT 20) a UNION "
                                "SELECT a.col as x FROM (SELECT CONCAT('+ \"','SUM_TIMER_WAIT,',IFNULL(digest_type,'null'),',',IFNULL(schema_name_t,'null'),',',IFNULL(digest_t,'null'),',',IFNULL(count_star_t,0),',',ROUND(IFNULL(timer_wait_t,0)/1000000000000,0),',',ROUND(IFNULL(lock_time_t,0)/1000000000000,0),',',IFNULL(errors_t,0),',',IFNULL(warnings_t,0),',',IFNULL(rows_affected_t,0),',',IFNULL(rows_sent_t,0),',',IFNULL(rows_examined_t,0),',',IFNULL(created_tmp_disk_tables_t,0),',',IFNULL(created_tmp_tables_t,0),',',IFNULL(select_full_join_t,0),',',IFNULL(select_full_range_join_t,0),',',IFNULL(select_range_t,0),',',IFNULL(select_range_check_t,0),',',IFNULL(select_scan_t,0),',',IFNULL(sort_merge_passes_t,0),',',IFNULL(sort_range_t,0),',',IFNULL(sort_rows_t,0),',',IFNULL(sort_scan_t,0),',',IFNULL(no_index_used_t,0),',',IFNULL(no_good_index_used_t,0),',',IFNULL(schema_name_b,'null'),',',IFNULL(digest_b,'null'),',',IFNULL(count_star_b,0),',',ROUND(IFNULL(timer_wait_b,0)/1000000000000,0),',',ROUND(IFNULL(lock_time_b,0)/1000000000000,0),',',IFNULL(errors_b,0),',',IFNULL(warnings_b,0),',',IFNULL(rows_affected_b,0),',',IFNULL(rows_sent_b,0),',',IFNULL(rows_examined_b,0),',',IFNULL(created_tmp_disk_tables_b,0),',',IFNULL(created_tmp_tables_b,0),',',IFNULL(select_full_join_b,0),',',IFNULL(select_full_range_join_b,0),',',IFNULL(select_range_b,0),',',IFNULL(select_range_check_b,0),',',IFNULL(select_scan_b,0),',',IFNULL(sort_merge_passes_b,0),',',IFNULL(sort_range_b,0),',',IFNULL(sort_rows_b,0),',',IFNULL(sort_scan_b,0),',',IFNULL(no_index_used_b,0),',',IFNULL(no_good_index_used_b,0),'\\n\"') as col from xdbmonitoring.tbl_aggregated_digest_stats x where IFNULL(TIMER_WAIT_T,0)>0 ORDER BY  IFNULL(TIMER_WAIT_T,0) DESC LIMIT 20) a UNION "
                                "SELECT a.col as x FROM (SELECT CONCAT('+ \"','SUM_SELECT_FULL_RANGE_JOIN,',IFNULL(digest_type,'null'),',',IFNULL(schema_name_t,'null'),',',IFNULL(digest_t,'null'),',',IFNULL(count_star_t,0),',',ROUND(IFNULL(timer_wait_t,0)/1000000000000,0),',',ROUND(IFNULL(lock_time_t,0)/1000000000000,0),',',IFNULL(errors_t,0),',',IFNULL(warnings_t,0),',',IFNULL(rows_affected_t,0),',',IFNULL(rows_sent_t,0),',',IFNULL(rows_examined_t,0),',',IFNULL(created_tmp_disk_tables_t,0),',',IFNULL(created_tmp_tables_t,0),',',IFNULL(select_full_join_t,0),',',IFNULL(select_full_range_join_t,0),',',IFNULL(select_range_t,0),',',IFNULL(select_range_check_t,0),',',IFNULL(select_scan_t,0),',',IFNULL(sort_merge_passes_t,0),',',IFNULL(sort_range_t,0),',',IFNULL(sort_rows_t,0),',',IFNULL(sort_scan_t,0),',',IFNULL(no_index_used_t,0),',',IFNULL(no_good_index_used_t,0),',',IFNULL(schema_name_b,'null'),',',IFNULL(digest_b,'null'),',',IFNULL(count_star_b,0),',',ROUND(IFNULL(timer_wait_b,0)/1000000000000,0),',',ROUND(IFNULL(lock_time_b,0)/1000000000000,0),',',IFNULL(errors_b,0),',',IFNULL(warnings_b,0),',',IFNULL(rows_affected_b,0),',',IFNULL(rows_sent_b,0),',',IFNULL(rows_examined_b,0),',',IFNULL(created_tmp_disk_tables_b,0),',',IFNULL(created_tmp_tables_b,0),',',IFNULL(select_full_join_b,0),',',IFNULL(select_full_range_join_b,0),',',IFNULL(select_range_b,0),',',IFNULL(select_range_check_b,0),',',IFNULL(select_scan_b,0),',',IFNULL(sort_merge_passes_b,0),',',IFNULL(sort_range_b,0),',',IFNULL(sort_rows_b,0),',',IFNULL(sort_scan_b,0),',',IFNULL(no_index_used_b,0),',',IFNULL(no_good_index_used_b,0),'\\n\"') as col from xdbmonitoring.tbl_aggregated_digest_stats x where IFNULL(SELECT_FULL_RANGE_JOIN_T,0)>0 ORDER BY  IFNULL(SELECT_FULL_RANGE_JOIN_T,0) DESC LIMIT 20) a UNION "
                                "SELECT a.col as x FROM (SELECT CONCAT('+ \"','SUM_SELECT_RANGE,',IFNULL(digest_type,'null'),',',IFNULL(schema_name_t,'null'),',',IFNULL(digest_t,'null'),',',IFNULL(count_star_t,0),',',ROUND(IFNULL(timer_wait_t,0)/1000000000000,0),',',ROUND(IFNULL(lock_time_t,0)/1000000000000,0),',',IFNULL(errors_t,0),',',IFNULL(warnings_t,0),',',IFNULL(rows_affected_t,0),',',IFNULL(rows_sent_t,0),',',IFNULL(rows_examined_t,0),',',IFNULL(created_tmp_disk_tables_t,0),',',IFNULL(created_tmp_tables_t,0),',',IFNULL(select_full_join_t,0),',',IFNULL(select_full_range_join_t,0),',',IFNULL(select_range_t,0),',',IFNULL(select_range_check_t,0),',',IFNULL(select_scan_t,0),',',IFNULL(sort_merge_passes_t,0),',',IFNULL(sort_range_t,0),',',IFNULL(sort_rows_t,0),',',IFNULL(sort_scan_t,0),',',IFNULL(no_index_used_t,0),',',IFNULL(no_good_index_used_t,0),',',IFNULL(schema_name_b,'null'),',',IFNULL(digest_b,'null'),',',IFNULL(count_star_b,0),',',ROUND(IFNULL(timer_wait_b,0)/1000000000000,0),',',ROUND(IFNULL(lock_time_b,0)/1000000000000,0),',',IFNULL(errors_b,0),',',IFNULL(warnings_b,0),',',IFNULL(rows_affected_b,0),',',IFNULL(rows_sent_b,0),',',IFNULL(rows_examined_b,0),',',IFNULL(created_tmp_disk_tables_b,0),',',IFNULL(created_tmp_tables_b,0),',',IFNULL(select_full_join_b,0),',',IFNULL(select_full_range_join_b,0),',',IFNULL(select_range_b,0),',',IFNULL(select_range_check_b,0),',',IFNULL(select_scan_b,0),',',IFNULL(sort_merge_passes_b,0),',',IFNULL(sort_range_b,0),',',IFNULL(sort_rows_b,0),',',IFNULL(sort_scan_b,0),',',IFNULL(no_index_used_b,0),',',IFNULL(no_good_index_used_b,0),'\\n\"') as col from xdbmonitoring.tbl_aggregated_digest_stats x where IFNULL(SELECT_RANGE_T,0)>0 ORDER BY  IFNULL(SELECT_RANGE_T,0) DESC LIMIT 20) a UNION "
                                "SELECT a.col as x FROM (SELECT CONCAT('+ \"','SUM_SELECT_RANGE_CHECK,',IFNULL(digest_type,'null'),',',IFNULL(schema_name_t,'null'),',',IFNULL(digest_t,'null'),',',IFNULL(count_star_t,0),',',ROUND(IFNULL(timer_wait_t,0)/1000000000000,0),',',ROUND(IFNULL(lock_time_t,0)/1000000000000,0),',',IFNULL(errors_t,0),',',IFNULL(warnings_t,0),',',IFNULL(rows_affected_t,0),',',IFNULL(rows_sent_t,0),',',IFNULL(rows_examined_t,0),',',IFNULL(created_tmp_disk_tables_t,0),',',IFNULL(created_tmp_tables_t,0),',',IFNULL(select_full_join_t,0),',',IFNULL(select_full_range_join_t,0),',',IFNULL(select_range_t,0),',',IFNULL(select_range_check_t,0),',',IFNULL(select_scan_t,0),',',IFNULL(sort_merge_passes_t,0),',',IFNULL(sort_range_t,0),',',IFNULL(sort_rows_t,0),',',IFNULL(sort_scan_t,0),',',IFNULL(no_index_used_t,0),',',IFNULL(no_good_index_used_t,0),',',IFNULL(schema_name_b,'null'),',',IFNULL(digest_b,'null'),',',IFNULL(count_star_b,0),',',ROUND(IFNULL(timer_wait_b,0)/1000000000000,0),',',ROUND(IFNULL(lock_time_b,0)/1000000000000,0),',',IFNULL(errors_b,0),',',IFNULL(warnings_b,0),',',IFNULL(rows_affected_b,0),',',IFNULL(rows_sent_b,0),',',IFNULL(rows_examined_b,0),',',IFNULL(created_tmp_disk_tables_b,0),',',IFNULL(created_tmp_tables_b,0),',',IFNULL(select_full_join_b,0),',',IFNULL(select_full_range_join_b,0),',',IFNULL(select_range_b,0),',',IFNULL(select_range_check_b,0),',',IFNULL(select_scan_b,0),',',IFNULL(sort_merge_passes_b,0),',',IFNULL(sort_range_b,0),',',IFNULL(sort_rows_b,0),',',IFNULL(sort_scan_b,0),',',IFNULL(no_index_used_b,0),',',IFNULL(no_good_index_used_b,0),'\\n\"') as col from xdbmonitoring.tbl_aggregated_digest_stats x where IFNULL(SELECT_RANGE_CHECK_T,0)>0 ORDER BY  IFNULL(SELECT_RANGE_CHECK_T,0) DESC LIMIT 20) a UNION "
                                "SELECT a.col as x FROM (SELECT CONCAT('+ \"','SUM_SELECT_SCAN,',IFNULL(digest_type,'null'),',',IFNULL(schema_name_t,'null'),',',IFNULL(digest_t,'null'),',',IFNULL(count_star_t,0),',',ROUND(IFNULL(timer_wait_t,0)/1000000000000,0),',',ROUND(IFNULL(lock_time_t,0)/1000000000000,0),',',IFNULL(errors_t,0),',',IFNULL(warnings_t,0),',',IFNULL(rows_affected_t,0),',',IFNULL(rows_sent_t,0),',',IFNULL(rows_examined_t,0),',',IFNULL(created_tmp_disk_tables_t,0),',',IFNULL(created_tmp_tables_t,0),',',IFNULL(select_full_join_t,0),',',IFNULL(select_full_range_join_t,0),',',IFNULL(select_range_t,0),',',IFNULL(select_range_check_t,0),',',IFNULL(select_scan_t,0),',',IFNULL(sort_merge_passes_t,0),',',IFNULL(sort_range_t,0),',',IFNULL(sort_rows_t,0),',',IFNULL(sort_scan_t,0),',',IFNULL(no_index_used_t,0),',',IFNULL(no_good_index_used_t,0),',',IFNULL(schema_name_b,'null'),',',IFNULL(digest_b,'null'),',',IFNULL(count_star_b,0),',',ROUND(IFNULL(timer_wait_b,0)/1000000000000,0),',',ROUND(IFNULL(lock_time_b,0)/1000000000000,0),',',IFNULL(errors_b,0),',',IFNULL(warnings_b,0),',',IFNULL(rows_affected_b,0),',',IFNULL(rows_sent_b,0),',',IFNULL(rows_examined_b,0),',',IFNULL(created_tmp_disk_tables_b,0),',',IFNULL(created_tmp_tables_b,0),',',IFNULL(select_full_join_b,0),',',IFNULL(select_full_range_join_b,0),',',IFNULL(select_range_b,0),',',IFNULL(select_range_check_b,0),',',IFNULL(select_scan_b,0),',',IFNULL(sort_merge_passes_b,0),',',IFNULL(sort_range_b,0),',',IFNULL(sort_rows_b,0),',',IFNULL(sort_scan_b,0),',',IFNULL(no_index_used_b,0),',',IFNULL(no_good_index_used_b,0),'\\n\"') as col from xdbmonitoring.tbl_aggregated_digest_stats x where IFNULL(SELECT_SCAN_T,0)>0 ORDER BY  IFNULL(SELECT_SCAN_T,0) DESC LIMIT 20) a UNION "
                                "SELECT a.col as x FROM (SELECT CONCAT('+ \"','SUM_SORT_MERGE_PASSES,',IFNULL(digest_type,'null'),',',IFNULL(schema_name_t,'null'),',',IFNULL(digest_t,'null'),',',IFNULL(count_star_t,0),',',ROUND(IFNULL(timer_wait_t,0)/1000000000000,0),',',ROUND(IFNULL(lock_time_t,0)/1000000000000,0),',',IFNULL(errors_t,0),',',IFNULL(warnings_t,0),',',IFNULL(rows_affected_t,0),',',IFNULL(rows_sent_t,0),',',IFNULL(rows_examined_t,0),',',IFNULL(created_tmp_disk_tables_t,0),',',IFNULL(created_tmp_tables_t,0),',',IFNULL(select_full_join_t,0),',',IFNULL(select_full_range_join_t,0),',',IFNULL(select_range_t,0),',',IFNULL(select_range_check_t,0),',',IFNULL(select_scan_t,0),',',IFNULL(sort_merge_passes_t,0),',',IFNULL(sort_range_t,0),',',IFNULL(sort_rows_t,0),',',IFNULL(sort_scan_t,0),',',IFNULL(no_index_used_t,0),',',IFNULL(no_good_index_used_t,0),',',IFNULL(schema_name_b,'null'),',',IFNULL(digest_b,'null'),',',IFNULL(count_star_b,0),',',ROUND(IFNULL(timer_wait_b,0)/1000000000000,0),',',ROUND(IFNULL(lock_time_b,0)/1000000000000,0),',',IFNULL(errors_b,0),',',IFNULL(warnings_b,0),',',IFNULL(rows_affected_b,0),',',IFNULL(rows_sent_b,0),',',IFNULL(rows_examined_b,0),',',IFNULL(created_tmp_disk_tables_b,0),',',IFNULL(created_tmp_tables_b,0),',',IFNULL(select_full_join_b,0),',',IFNULL(select_full_range_join_b,0),',',IFNULL(select_range_b,0),',',IFNULL(select_range_check_b,0),',',IFNULL(select_scan_b,0),',',IFNULL(sort_merge_passes_b,0),',',IFNULL(sort_range_b,0),',',IFNULL(sort_rows_b,0),',',IFNULL(sort_scan_b,0),',',IFNULL(no_index_used_b,0),',',IFNULL(no_good_index_used_b,0),'\\n\"') as col from xdbmonitoring.tbl_aggregated_digest_stats x where IFNULL(SORT_MERGE_PASSES_T,0)>0 ORDER BY  IFNULL(SORT_MERGE_PASSES_T,0) DESC LIMIT 20) a UNION "
                                "SELECT a.col as x FROM (SELECT CONCAT('+ \"','SUM_SORT_RANGE,',IFNULL(digest_type,'null'),',',IFNULL(schema_name_t,'null'),',',IFNULL(digest_t,'null'),',',IFNULL(count_star_t,0),',',ROUND(IFNULL(timer_wait_t,0)/1000000000000,0),',',ROUND(IFNULL(lock_time_t,0)/1000000000000,0),',',IFNULL(errors_t,0),',',IFNULL(warnings_t,0),',',IFNULL(rows_affected_t,0),',',IFNULL(rows_sent_t,0),',',IFNULL(rows_examined_t,0),',',IFNULL(created_tmp_disk_tables_t,0),',',IFNULL(created_tmp_tables_t,0),',',IFNULL(select_full_join_t,0),',',IFNULL(select_full_range_join_t,0),',',IFNULL(select_range_t,0),',',IFNULL(select_range_check_t,0),',',IFNULL(select_scan_t,0),',',IFNULL(sort_merge_passes_t,0),',',IFNULL(sort_range_t,0),',',IFNULL(sort_rows_t,0),',',IFNULL(sort_scan_t,0),',',IFNULL(no_index_used_t,0),',',IFNULL(no_good_index_used_t,0),',',IFNULL(schema_name_b,'null'),',',IFNULL(digest_b,'null'),',',IFNULL(count_star_b,0),',',ROUND(IFNULL(timer_wait_b,0)/1000000000000,0),',',ROUND(IFNULL(lock_time_b,0)/1000000000000,0),',',IFNULL(errors_b,0),',',IFNULL(warnings_b,0),',',IFNULL(rows_affected_b,0),',',IFNULL(rows_sent_b,0),',',IFNULL(rows_examined_b,0),',',IFNULL(created_tmp_disk_tables_b,0),',',IFNULL(created_tmp_tables_b,0),',',IFNULL(select_full_join_b,0),',',IFNULL(select_full_range_join_b,0),',',IFNULL(select_range_b,0),',',IFNULL(select_range_check_b,0),',',IFNULL(select_scan_b,0),',',IFNULL(sort_merge_passes_b,0),',',IFNULL(sort_range_b,0),',',IFNULL(sort_rows_b,0),',',IFNULL(sort_scan_b,0),',',IFNULL(no_index_used_b,0),',',IFNULL(no_good_index_used_b,0),'\\n\"') as col from xdbmonitoring.tbl_aggregated_digest_stats x where IFNULL(SORT_RANGE_T,0)>0 ORDER BY  IFNULL(SORT_RANGE_T,0) DESC LIMIT 20) a UNION "
                                "SELECT a.col as x FROM (SELECT CONCAT('+ \"','SUM_SORT_ROWS,',IFNULL(digest_type,'null'),',',IFNULL(schema_name_t,'null'),',',IFNULL(digest_t,'null'),',',IFNULL(count_star_t,0),',',ROUND(IFNULL(timer_wait_t,0)/1000000000000,0),',',ROUND(IFNULL(lock_time_t,0)/1000000000000,0),',',IFNULL(errors_t,0),',',IFNULL(warnings_t,0),',',IFNULL(rows_affected_t,0),',',IFNULL(rows_sent_t,0),',',IFNULL(rows_examined_t,0),',',IFNULL(created_tmp_disk_tables_t,0),',',IFNULL(created_tmp_tables_t,0),',',IFNULL(select_full_join_t,0),',',IFNULL(select_full_range_join_t,0),',',IFNULL(select_range_t,0),',',IFNULL(select_range_check_t,0),',',IFNULL(select_scan_t,0),',',IFNULL(sort_merge_passes_t,0),',',IFNULL(sort_range_t,0),',',IFNULL(sort_rows_t,0),',',IFNULL(sort_scan_t,0),',',IFNULL(no_index_used_t,0),',',IFNULL(no_good_index_used_t,0),',',IFNULL(schema_name_b,'null'),',',IFNULL(digest_b,'null'),',',IFNULL(count_star_b,0),',',ROUND(IFNULL(timer_wait_b,0)/1000000000000,0),',',ROUND(IFNULL(lock_time_b,0)/1000000000000,0),',',IFNULL(errors_b,0),',',IFNULL(warnings_b,0),',',IFNULL(rows_affected_b,0),',',IFNULL(rows_sent_b,0),',',IFNULL(rows_examined_b,0),',',IFNULL(created_tmp_disk_tables_b,0),',',IFNULL(created_tmp_tables_b,0),',',IFNULL(select_full_join_b,0),',',IFNULL(select_full_range_join_b,0),',',IFNULL(select_range_b,0),',',IFNULL(select_range_check_b,0),',',IFNULL(select_scan_b,0),',',IFNULL(sort_merge_passes_b,0),',',IFNULL(sort_range_b,0),',',IFNULL(sort_rows_b,0),',',IFNULL(sort_scan_b,0),',',IFNULL(no_index_used_b,0),',',IFNULL(no_good_index_used_b,0),'\\n\"') as col from xdbmonitoring.tbl_aggregated_digest_stats x where IFNULL(SORT_ROWS_T,0)>0 ORDER BY  IFNULL(SORT_ROWS_T,0) DESC LIMIT 20) a UNION "
                                "SELECT a.col as x FROM (SELECT CONCAT('+ \"','SUM_SORT_SCAN,',IFNULL(digest_type,'null'),',',IFNULL(schema_name_t,'null'),',',IFNULL(digest_t,'null'),',',IFNULL(count_star_t,0),',',ROUND(IFNULL(timer_wait_t,0)/1000000000000,0),',',ROUND(IFNULL(lock_time_t,0)/1000000000000,0),',',IFNULL(errors_t,0),',',IFNULL(warnings_t,0),',',IFNULL(rows_affected_t,0),',',IFNULL(rows_sent_t,0),',',IFNULL(rows_examined_t,0),',',IFNULL(created_tmp_disk_tables_t,0),',',IFNULL(created_tmp_tables_t,0),',',IFNULL(select_full_join_t,0),',',IFNULL(select_full_range_join_t,0),',',IFNULL(select_range_t,0),',',IFNULL(select_range_check_t,0),',',IFNULL(select_scan_t,0),',',IFNULL(sort_merge_passes_t,0),',',IFNULL(sort_range_t,0),',',IFNULL(sort_rows_t,0),',',IFNULL(sort_scan_t,0),',',IFNULL(no_index_used_t,0),',',IFNULL(no_good_index_used_t,0),',',IFNULL(schema_name_b,'null'),',',IFNULL(digest_b,'null'),',',IFNULL(count_star_b,0),',',ROUND(IFNULL(timer_wait_b,0)/1000000000000,0),',',ROUND(IFNULL(lock_time_b,0)/1000000000000,0),',',IFNULL(errors_b,0),',',IFNULL(warnings_b,0),',',IFNULL(rows_affected_b,0),',',IFNULL(rows_sent_b,0),',',IFNULL(rows_examined_b,0),',',IFNULL(created_tmp_disk_tables_b,0),',',IFNULL(created_tmp_tables_b,0),',',IFNULL(select_full_join_b,0),',',IFNULL(select_full_range_join_b,0),',',IFNULL(select_range_b,0),',',IFNULL(select_range_check_b,0),',',IFNULL(select_scan_b,0),',',IFNULL(sort_merge_passes_b,0),',',IFNULL(sort_range_b,0),',',IFNULL(sort_rows_b,0),',',IFNULL(sort_scan_b,0),',',IFNULL(no_index_used_b,0),',',IFNULL(no_good_index_used_b,0),'\\n\"') as col from xdbmonitoring.tbl_aggregated_digest_stats x where IFNULL(SORT_SCAN_T,0)>0 ORDER BY  IFNULL(SORT_SCAN_T,0) DESC LIMIT 20) a UNION "
                                "SELECT a.col as x FROM (SELECT CONCAT('+ \"','SUM_NO_INDEX_USED,',IFNULL(digest_type,'null'),',',IFNULL(schema_name_t,'null'),',',IFNULL(digest_t,'null'),',',IFNULL(count_star_t,0),',',ROUND(IFNULL(timer_wait_t,0)/1000000000000,0),',',ROUND(IFNULL(lock_time_t,0)/1000000000000,0),',',IFNULL(errors_t,0),',',IFNULL(warnings_t,0),',',IFNULL(rows_affected_t,0),',',IFNULL(rows_sent_t,0),',',IFNULL(rows_examined_t,0),',',IFNULL(created_tmp_disk_tables_t,0),',',IFNULL(created_tmp_tables_t,0),',',IFNULL(select_full_join_t,0),',',IFNULL(select_full_range_join_t,0),',',IFNULL(select_range_t,0),',',IFNULL(select_range_check_t,0),',',IFNULL(select_scan_t,0),',',IFNULL(sort_merge_passes_t,0),',',IFNULL(sort_range_t,0),',',IFNULL(sort_rows_t,0),',',IFNULL(sort_scan_t,0),',',IFNULL(no_index_used_t,0),',',IFNULL(no_good_index_used_t,0),',',IFNULL(schema_name_b,'null'),',',IFNULL(digest_b,'null'),',',IFNULL(count_star_b,0),',',ROUND(IFNULL(timer_wait_b,0)/1000000000000,0),',',ROUND(IFNULL(lock_time_b,0)/1000000000000,0),',',IFNULL(errors_b,0),',',IFNULL(warnings_b,0),',',IFNULL(rows_affected_b,0),',',IFNULL(rows_sent_b,0),',',IFNULL(rows_examined_b,0),',',IFNULL(created_tmp_disk_tables_b,0),',',IFNULL(created_tmp_tables_b,0),',',IFNULL(select_full_join_b,0),',',IFNULL(select_full_range_join_b,0),',',IFNULL(select_range_b,0),',',IFNULL(select_range_check_b,0),',',IFNULL(select_scan_b,0),',',IFNULL(sort_merge_passes_b,0),',',IFNULL(sort_range_b,0),',',IFNULL(sort_rows_b,0),',',IFNULL(sort_scan_b,0),',',IFNULL(no_index_used_b,0),',',IFNULL(no_good_index_used_b,0),'\\n\"') as col from xdbmonitoring.tbl_aggregated_digest_stats x where IFNULL(NO_INDEX_USED_T,0)>0 ORDER BY  IFNULL(NO_INDEX_USED_T,0) DESC LIMIT 20) a UNION "
                                "SELECT a.col as x FROM (SELECT CONCAT('+ \"','SUM_NO_GOOD_INDEX_USED,',IFNULL(digest_type,'null'),',',IFNULL(schema_name_t,'null'),',',IFNULL(digest_t,'null'),',',IFNULL(count_star_t,0),',',ROUND(IFNULL(timer_wait_t,0)/1000000000000,0),',',ROUND(IFNULL(lock_time_t,0)/1000000000000,0),',',IFNULL(errors_t,0),',',IFNULL(warnings_t,0),',',IFNULL(rows_affected_t,0),',',IFNULL(rows_sent_t,0),',',IFNULL(rows_examined_t,0),',',IFNULL(created_tmp_disk_tables_t,0),',',IFNULL(created_tmp_tables_t,0),',',IFNULL(select_full_join_t,0),',',IFNULL(select_full_range_join_t,0),',',IFNULL(select_range_t,0),',',IFNULL(select_range_check_t,0),',',IFNULL(select_scan_t,0),',',IFNULL(sort_merge_passes_t,0),',',IFNULL(sort_range_t,0),',',IFNULL(sort_rows_t,0),',',IFNULL(sort_scan_t,0),',',IFNULL(no_index_used_t,0),',',IFNULL(no_good_index_used_t,0),',',IFNULL(schema_name_b,'null'),',',IFNULL(digest_b,'null'),',',IFNULL(count_star_b,0),',',ROUND(IFNULL(timer_wait_b,0)/1000000000000,0),',',ROUND(IFNULL(lock_time_b,0)/1000000000000,0),',',IFNULL(errors_b,0),',',IFNULL(warnings_b,0),',',IFNULL(rows_affected_b,0),',',IFNULL(rows_sent_b,0),',',IFNULL(rows_examined_b,0),',',IFNULL(created_tmp_disk_tables_b,0),',',IFNULL(created_tmp_tables_b,0),',',IFNULL(select_full_join_b,0),',',IFNULL(select_full_range_join_b,0),',',IFNULL(select_range_b,0),',',IFNULL(select_range_check_b,0),',',IFNULL(select_scan_b,0),',',IFNULL(sort_merge_passes_b,0),',',IFNULL(sort_range_b,0),',',IFNULL(sort_rows_b,0),',',IFNULL(sort_scan_b,0),',',IFNULL(no_index_used_b,0),',',IFNULL(no_good_index_used_b,0),'\\n\"') as col from xdbmonitoring.tbl_aggregated_digest_stats x where IFNULL(NO_GOOD_INDEX_USED_T,0)>0 ORDER BY  IFNULL(NO_GOOD_INDEX_USED_T,0) DESC LIMIT 20) a ;")

        #csvSQLText
        stmt_sql_text = ("SELECT DISTINCT CONCAT('+ \"',digest,'!@#!',SUBSTRING(DIGEST_TEXT,1,2000),'\\n\"') FROM xdbmonitoring.tbl_digest_text where digest in (select distinct digest_t from xdbmonitoring.tbl_aggregated_digest_stats where timer_wait_t > 0 or count_star_t > 0)")

        #csvGlobalStatus
        stmt_global_status = ("SELECT CONCAT('+ \"',t.variable_name,',',b.variable_value,',',t.variable_value,'\\n\"') FROM "
                                "(select variable_name,  max(CAST(variable_value AS UNSIGNED)) - min(CAST(variable_value AS UNSIGNED)) variable_value from xdbmonitoring.tbl_global_status where sample_id between @tr_start_sample_id and @tr_finish_sample_id and variable_value REGEXP '^-?[0-9]+$' group by variable_name) t "
                                "left join (select variable_name,  max(CAST(variable_value AS UNSIGNED)) - min(CAST(variable_value AS UNSIGNED)) variable_value from xdbmonitoring.tbl_global_status where sample_id between @bl_start_sample_id and @bl_finish_sample_id and variable_value REGEXP '^-?[0-9]+$' group by variable_name) b on t.variable_name = b.variable_name; ")

        #csvDBSummary
        stmt_db_summary = "SELECT CONCAT('+ \"',@@hostname,',',@@transaction_isolation,',',@@innodb_buffer_pool_size,',',@@version,',',@@version_comment,',',@@version_compile_os,',',@@version_compile_machine,',',TIME_FORMAT(SEC_TO_TIME(VARIABLE_VALUE ),'%Hh %im %ss'),',',DATE_FORMAT(SYSDATE(), '%d %b %Y %H:%i:%s'),'\\n\"') FROM performance_schema.global_status WHERE VARIABLE_NAME='Uptime';"

        stmt_db_summary = ("SELECT CONCAT('+ \"Baseline,',MIN(SAMPLE_ID),',',MAX(SAMPLE_ID),',',MIN(SAMPLE_TIME),',',MAX(SAMPLE_TIME),',',TIME_FORMAT(SEC_TO_TIME(TIMESTAMPDIFF(second,MIN(SAMPLE_TIME),MAX(SAMPLE_TIME) )),'%Hh %im %ss'),'\\n\"') from xdbmonitoring.tbl_snapshot where sample_id in  (@bl_start_sample_id, @bl_finish_sample_id) union "
                        "SELECT CONCAT('+ \"Test Run,',MIN(SAMPLE_ID),',',MAX(SAMPLE_ID),',',MIN(SAMPLE_TIME),',',MAX(SAMPLE_TIME),',',TIME_FORMAT(SEC_TO_TIME(TIMESTAMPDIFF(second,MIN(SAMPLE_TIME),MAX(SAMPLE_TIME) )),'%Hh %im %ss'),'\\n\"') from xdbmonitoring.tbl_snapshot where sample_id in  (@tr_start_sample_id, @tr_finish_sample_id);")



        stmt_file_name = "select CONCAT('./reports/mysql-xdbmo-compare-',@@hostname,'-',@bl_start_sample_id,'-',@bl_finish_sample_id,'vs',@tr_start_sample_id,'-',@tr_finish_sample_id,'.html');"
        result_file_name = session.run_sql(stmt_file_name)
        row = result_file_name.fetch_one()
        file_name = row[0]
        
        
        header = footer = ""

        with open('./templates/mysql-xdbmonitoring-compare-header.html') as fh:
            header = fh.read()

        with open('./templates/mysql-xdbmonitoring-compare-footer.html') as ff:
            footer = ff.read()    

        with open(file_name, 'w') as f:
            f.write(header)
            
            result_top_digest_type = session.run_sql(stmt_top_digest_type)
            f.write("%s\n" % "csvTopDigestType = csvTopDigestType")
            for row in result_top_digest_type.fetch_all():
                f.write("%s\n" % str(repr(row[0])[1:-1]))
            f.write("%s\n" % ";")
            result_stmt_statements_timeseries_bl = session.run_sql(stmt_statements_timeseries_bl)
            f.write("%s\n" % "csvStmtTsBr = csvStmtTsBr")
            for row in result_stmt_statements_timeseries_bl.fetch_all():
                f.write("%s\n" % str(repr(row[0])[1:-1]))
            f.write("%s\n" % ";")
            result_stmt_statements_timeseries_tr = session.run_sql(stmt_statements_timeseries_tr)
            f.write("%s\n" % "csvStmtTsTr = csvStmtTsTr")
            for row in result_stmt_statements_timeseries_tr.fetch_all():
                f.write("%s\n" % str(repr(row[0])[1:-1]))
            f.write("%s\n" % ";")
            result_stmt_waits_timeseries_bl = session.run_sql(stmt_waits_timeseries_bl)
            f.write("%s\n" % "csvWaitsTsBr = csvWaitsTsBr")
            for row in result_stmt_waits_timeseries_bl.fetch_all():
                f.write("%s\n" % str(repr(row[0])[1:-1]))
            f.write("%s\n" % ";")
            result_stmt_waits_timeseries_tr = session.run_sql(stmt_waits_timeseries_tr)
            f.write("%s\n" % "csvWaitsTsTr = csvWaitsTsTr")
            for row in result_stmt_waits_timeseries_tr.fetch_all():
                f.write("%s\n" % str(repr(row[0])[1:-1]))
            f.write("%s\n" % ";")
            result_statements = session.run_sql(stmt_statements)
            f.write("%s\n" % "csvStatementsSummaryMySQL = csvStatementsSummaryMySQL")
            for row in result_statements.fetch_all():
                f.write("%s\n" % str(repr(row[0])[1:-1]))
            f.write("%s\n" % ";")
            result_waits = session.run_sql(stmt_waits)
            f.write("%s\n" % "csvWaitsSummaryMySQL = csvWaitsSummaryMySQL")    
            for row in result_waits.fetch_all():
                f.write("%s\n" % str(repr(row[0])[1:-1]))
            f.write("%s\n" % ";")
            result_stages = session.run_sql(stmt_stages)
            f.write("%s\n" % "csvStagesSummaryMySQL = csvStagesSummaryMySQL")    
            for row in result_stages.fetch_all():
                f.write("%s\n" % str(repr(row[0])[1:-1]))
            f.write("%s\n" % ";")
            result_digest_charts = session.run_sql(stmt_digest_charts)
            f.write("%s\n" % "csvSqlStatsChartMySQL = csvSqlStatsChartMySQL")    
            for row in result_digest_charts.fetch_all():
                f.write("%s\n" % str(repr(row[0])[1:-1]))
            f.write("%s\n" % ";")
            result_digest_tables = session.run_sql(stmt_digest_tables)
            f.write("%s\n" % "csvSqlStatsTableMySQL = csvSqlStatsTableMySQL")    
            for row in result_digest_tables.fetch_all():
                f.write("%s\n" % str(repr(row[0])[1:-1]))
            f.write("%s\n" % ";")
            result_db_summary = session.run_sql(stmt_db_summary)
            f.write("%s\n" % "csvDbSummary = csvDbSummary")    
            for row in result_db_summary.fetch_all():
                f.write("%s\n" % str(repr(row[0])[1:-1]))
            f.write("%s\n" % ";")
            result_sql_text = session.run_sql(stmt_sql_text)
            f.write("%s\n" % "csvSQLText = csvSQLText")    
            for row in result_sql_text.fetch_all():
                f.write("%s\n" % str(repr(row[0])[1:-1]))
            f.write("%s\n" % ";")
            result_global_status = session.run_sql(stmt_global_status)
            f.write("%s\n" % "csvGlobalStatus = csvGlobalStatus")    
            for row in result_global_status.fetch_all():
                f.write("%s\n" % str(repr(row[0])[1:-1]))
            f.write("%s\n" % ";")

            f.write(footer)    

        f.close()

        print('Report is written to: '+file_name)

    session.rollback()

    print('')

    return file_name

shell.register_report(
    'compare',
    'print',
    compare,
    {
        'brief': 'Generates Database performance comparison report for MySQL. It compares two periods in a databases and generates HTML file.',
        'details': ['You need the SELECT privilege on xbdmonitoring schema '
                    + 'and INSERT, DELETE, UPDATE on `xdbmonitoring`.`tbl_aggregated_digest_stats` table. '
                    + 'xdbmo user must have these permisions. '
                    + 'Please provide 4 integer parameters (2 ranges of snapshots). '
                    + 'Example: "\show compare 50 60 110 130" will compare two periods. The first period range is [50,60] and the second period range [110 130]. ' 
                    + 'Use "\show snapshots" to see available snapshots. ' ],
        'argc': '4'
    }
)