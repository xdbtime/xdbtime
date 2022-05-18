/*
    Copyright (c) 2016-2022 Taras Guliak XDBTIME
    All rights reserved.
    Version: 2022.01

    SQL script to show available DBIDs.

    Example:
        SQL> @xdbawrlistdbid.sql

                DBID    INSTANCE_NUMBER         MIN_BEGIN_TIME           MAX_END_TIME
        _____________ __________________ ______________________ ______________________
           2216040323                  1    04-05-2022 09:37:57    08-05-2022 19:45:57
*/

select dbid, instance_number, to_char(min(begin_interval_time),'DD-MM-YYYY HH24:MI:SS') min_begin_time, to_char(max(end_interval_time),'DD-MM-YYYY HH24:MI:SS') max_end_time  from cdb_hist_snapshot group by dbid, instance_number;
