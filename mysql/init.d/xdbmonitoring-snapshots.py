#   Copyright (c) 2016, 2025, XDBTIME Taras Guliak
#   All rights reserved.

def snapshots(session, args, options):

    print('')
    print('XDBTIME reports for MySQL')
    print('Copyright (c) 2016, 2025, XDBTIME Taras Guliak')
    print('Version: 2025.02')
    print('') 

    if (options.has_key('date')) and (options.has_key('time')):
        stmt_sql_text = ("select sample_date, max_sample_id, TIME_FORMAT(SEC_TO_TIME(wait_time_sec),'%Hh %im %ss') stmt_wait_time from ("
                         "select sample_date, min(sample_id) min_sample_id, max(sample_id) max_sample_id, round(sum(sum_timer_wait)/1000000000000,0) wait_time_sec from ("
                         "select sample_time sample_date, sample_id, sum(delta_timer_wait) sum_timer_wait from xdbmonitoring.tbl_events_statements_summary_global_by_event_name where sample_time >= STR_TO_DATE('"+options['date']+" "+options['time']+"', '%Y-%m-%d %H') and sample_time<ADDDATE(STR_TO_DATE('"+options['date']+" "+options['time']+"', '%Y-%m-%d %H'), INTERVAL 1 HOUR) group by sample_id, sample_time"
                         ") a GROUP BY sample_date"
                         ") b order by 1; ")
        result_statements = session.run_sql(stmt_sql_text)
        print("Snapshots as of ", options['date'],options['time'],"h")
        print("")
        print("Date                   Snapshot    Statement Wait Time")
        report = ["sample_date","max_sample_id","stmt_wait_time"]
        for row in result_statements.fetch_all():
            print(*row, sep = "      ")
    elif (options.has_key('date')):
        stmt_sql_text = ("select sample_date, min_sample_id, max_sample_id, TIME_FORMAT(SEC_TO_TIME(wait_time_sec),'%Hh %im %ss') stmt_wait_time from ("
                         "select sample_date, min(sample_id) min_sample_id, max(sample_id) max_sample_id, round(sum(sum_timer_wait)/1000000000000,0) wait_time_sec from ("
                         "select TIME_FORMAT(sample_time,'%H:00') sample_date, sample_id, sum(delta_timer_wait) sum_timer_wait from xdbmonitoring.tbl_events_statements_summary_global_by_event_name where sample_time >= STR_TO_DATE('"+options['date']+"', '%Y-%m-%d') and sample_time<ADDDATE(STR_TO_DATE('"+options['date']+"', '%Y-%m-%d'), INTERVAL 24 HOUR) group by sample_id, sample_time"
                         ") a GROUP BY sample_date"
                         ") b order by 1; ")
        result_statements = session.run_sql(stmt_sql_text)
        print("Snapshots as of ", options['date'])
        print("")
        print("Hour       Min    Max    Statement Wait Time")
        report = ["sample_date","min_sample_id","max_sample_id","stmt_wait_time"]
        for row in result_statements.fetch_all():
            print(*row, sep = "      ")
    else:
        print("Snapshots Summary")
        print("")
        print("Date            Min    Max    Statement Wait Time")
        stmt_sql_text = ("select sample_date, min_sample_id, max_sample_id, TIME_FORMAT(SEC_TO_TIME(wait_time_sec),'%Hh %im %ss') stmt_wait_time from ("
                         "select sample_date, min(sample_id) min_sample_id, max(sample_id) max_sample_id, round(sum(sum_timer_wait)/1000000000000,0) wait_time_sec from ("
                         "select DATE_FORMAT(sample_time,'%Y-%m-%d') sample_date, sample_id, sum(delta_timer_wait) sum_timer_wait from xdbmonitoring.tbl_events_statements_summary_global_by_event_name group by sample_id, sample_time"
                         ") a GROUP BY sample_date"
                         ") b order by 1; ")
        result_statements = session.run_sql(stmt_sql_text)
        report = ["sample_date","min_sample_id","max_sample_id","stmt_wait_time"]
        for row in result_statements.fetch_all():
            print(*row, sep = "      ")
        
    print("")   

shell.register_report(
    'snapshots',
    'list',
    snapshots,
    {
        'brief': 'Shows list available snapshots in xbdmonitoring schema.',
        'details': ['You need the SELECT privilege on xdbmonitoring.tbl_snapshot table.'],
        'options': [
            {
                'name': 'date',
                'brief': 'Snapshots for particular date.',
                'shortcut': 'd',
                'type': 'string'
            },
            {
                'name': 'time',
                'brief': 'Snapshots for particular hour.',
                'shortcut': 't',
                'type': 'string'
            }
        ],
        'argc': '0'
    }
)