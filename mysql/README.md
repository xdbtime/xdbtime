# xdbtime for MySQL

Set of tools to measure and compare database performance on MySQL databases.

The main goal is to identify performance issues in production systems before they impact your customers and in test environments before they are released to production systems. Xdbtime tools and reports can help to set up processes to compare database performance in production databases periodically and in performance test environments before every release.

![alt test](images/image_readme_mysql.png)

xdbtime for MySQL offers two products:
- Performance status report for MySQL databases (based on MySQL Performance Schema)
- Period comparison report - to compare two periods of time on a single MySQL database instance

xdbtime(pro) additionally offers one product (not covered by open-source license):
- Test comparison report - to compare two test runs. Performance metrics from these test runs were collected and stored in a separate database using xdbtime.

xdbtime for MySQL supports MySQL 5.7, MySQL 8.0, and Amazon Aurora MySQL.

## xdbtime for MySQL - Performance Status Report

Performance Status Report is designed to give performance overview of MySQL database based on data available in Performance Schema.

xdbtime reports are user-defined MySQL Shell reports written in Python language that create a report in HTML format.
Reports are using HTML, CSS, JS, and D3 libraries to build charts.

### Initial setup

1. Make sure PERFORMANCE SCHEMA (https://dev.mysql.com/doc/refman/8.0/en/performance-schema-quick-start.html) is enabled in MySQL Instance.

Use the following commands to check it:
```
SHOW VARIABLES LIKE 'performance_schema';
```

2. Install MySQL Shell https://dev.mysql.com/doc/mysql-shell/8.0/en/;

3. Checkout xdbtime project
```
git clone https://github.com/xdbtime/xdbtime.git
```

4. Create `init.d` folder for MySQL Shell report if it does not exist:

```
mkdir -p ~/.mysqlsh/init.d
```

3. Go to `xdbtime/mysql` folder. This is the working folder to generate MySQL reports:

```
cd xdbtime/mysql
```

4. Copy the `xdbperformance-status.py` report into the MySQL Shell Reports folder:

```
cp init.d/xdbperformance-status.py ~/.mysqlsh/init.d
```

5. Start MySQL Shell in Python mode and check available reports

```
mysqlsh --py
```

6. And check available reports

```
\show
```

Make sure that the following report is available: `performance`.

### How to use

1. Make sure you are in  `xdbtime/mysql` folder. Reports are generated from this folder and stored in the reports folder

2. Use MySQL Shell to connect to a target MySQL instance with user that has read permissions to the Performance Schema.

```
mysqlsh user@exampledb --py
```

3. Create performance status report `\show performance`. The report will be written in the `reports` folder.

```
 MySQL  127.0.0.1:3306 ssl  Py > \show performance

XDBTIME reports for MySQL
Copyright (c) 2016, 2025, XDBTIME Taras Guliak
Version: 2025.02

Creating MySQL Performance Summary Report ...
Report is written to: ./reports/mysql-xdbperf-status-ip-127-0-0-1-2022-05-18-20-21-55.html

Report should return a dictionary.
```

You can open the report directly from the command line: just press the Command button and click on the report link.

## xdbtime for MySQL - Period Comparison Report

Period Comparison Report is designed to compare 2 periods of time on the same database instance.

xdbtime reports are user-defined MySQL Shell reports written in Python language that create a report in HTML format.
Reports are using HTML, CSS, JS, and D3 libraries to build charts.

Period comparison reports are based on the `XDBMONITORING` schema which periodically creates snapshots of data from the MySQL Performance Schema.

`XDBMONITORING` schema contains tables, stored procedures, and events.
Tables persist data from the MySQL Performance Schema periodically collected by stored procedures from the MySQL Performance Schema called by events.

### Initial setup

Checkout xdbtime project
```
git clone https://github.com/xdbtime/xdbtime.git
```

Install `XDBMONITORING` schema on every MySQL instance where you plan to compare performance:

1. Make sure PERFORMANCE SCHEMA (https://dev.mysql.com/doc/refman/8.0/en/performance-schema-quick-start.html) and EVENT SCHEDULER (https://dev.mysql.com/doc/refman/8.0/en/events-configuration.html) are enabled in MySQL Instance.

Use the following commands to check it:
```
SHOW VARIABLES LIKE 'performance_schema';
SHOW VARIABLES LIKE 'event_scheduler';
```
2. Go to the following folder with `XDBMONITORING` schema
```
$ cd xdbtimepro/mysql/schemas/xdbmonitoring/create
```
3. Open `xdbmonitoring.sql` file and set new passwords (lines 320 and 324). 
4. Modify periodicity of collection of snapshots and active threads if required (lines 785 and 792).
5. Specify details of the current database (name, data sets, application version), so later, when you compare test runs, this info is available.
5. Login as root user into MySQL instance and execute `xdbmonitoring.sql` file
6. Check whether snapshots are collected
```
select * from xdbmonitoring.tbl_snapshot;
```



Setup MySQL Shell to be able to generate xdbtime reports.

1. Install MySQL Shell https://dev.mysql.com/doc/mysql-shell/8.0/en/;

2. Create `init.d` folder for MySQL Shell report if it does not exist:

```
$ mkdir -p ~/.mysqlsh/init.d
```

3. Go to `xdbtimepro/mysql/init.d` folder:

```
$ cd ../../../init.d
```

4. Copy reports into the MySQL Shell Reports folder:

```
$ cp xdbmonitoring-compare.py ~/.mysqlsh/init.d
$ cp xdbmonitoring-snapshots.py ~/.mysqlsh/init.d
```

5. Start MySQL Shell in Python mode and check available reports

```
$ mysqlsh --py

\show
```

Make sure that the following reports are available: `snapshots` and `compare`.

### How to use

1. Go to `mysql` folder. Reports are generated from this folder and stored in the Reports folder

```
$ cd xdbtimepro/mysql
```

2. Use MySQL Shell to connect to a target MySQL instance that has `XDBMONITORING` schema deployed.

```
mysqlsh xdbmo@exampledb --py
```

2. Identify time periods you want to compare. You can use `snapshots` report to overview snapshots.

Run `\show snapshots` to see all available snapshots grouped by Date and showing total Statement Wait Time

```
 MySQL  127.0.0.1:3306 ssl  Py > \show snapshots

XDBTIME reports for MySQL
Copyright (c) 2016, 2022, XDBTIME Taras Guliak
Version: 2022.01

Snapshots Summary

Date            Min        Max        Statement Wait Time
2022-04-01      10883      10978      00h 28m 36s
2022-04-02      10979      11074      00h 29m 47s
2022-04-03      11075      11170      00h 28m 31s
2022-04-04      11171      11266      00h 28m 41s
2022-04-05      11267      11362      00h 28m 29s
2022-04-06      11363      11458      00h 28m 33s
2022-04-07      11459      11554      00h 28m 27s
2022-04-08      11555      11650      00h 28m 35s
2022-04-09      11651      11746      00h 28m 34s
2022-04-10      11747      11842      00h 28m 44s
2022-04-11      11843      11938      00h 29m 19s
2022-04-12      11939      12034      00h 45m 44s
2022-04-13      12035      12130      01h 06m 00s
2022-04-14      12131      12226      00h 56m 05s
2022-04-15      12227      12304      01h 04m 59s

Report should return a dictionary.
```

Run `\show snapshots -d 2022-04-15` to see all available snapshots for a particular date grouped by Hour and showing total Statement Wait Time:

```
 MySQL  127.0.0.1:3306 ssl  Py > \show snapshots -d 2022-04-15

XDBTIME reports for MySQL
Copyright (c) 2016, 2022, XDBTIME Taras Guliak
Version: 2022.01

Snapshots as of  2022-04-15

Hour       Min        Max        Statement Wait Time
00:00      12227      12230      00h 02m 16s
01:00      12231      12234      00h 01m 09s
02:00      12235      12238      00h 01m 08s
03:00      12239      12242      00h 01m 07s
04:00      12243      12246      00h 01m 08s
05:00      12247      12250      00h 01m 09s
06:00      12251      12254      00h 01m 09s
07:00      12255      12258      00h 01m 08s
08:00      12259      12262      00h 18m 56s
09:00      12263      12266      00h 16m 51s
10:00      12267      12270      00h 01m 09s
11:00      12271      12274      00h 01m 10s
12:00      12275      12278      00h 01m 07s
13:00      12279      12282      00h 09m 02s
14:00      12283      12286      00h 01m 19s
15:00      12287      12290      00h 01m 08s
16:00      12291      12294      00h 01m 08s
17:00      12295      12298      00h 01m 09s
18:00      12299      12302      00h 01m 13s
19:00      12303      12304      00h 00m 34s

Report should return a dictionary.
```

Run `\show snapshots -d 2022-04-15 -t 08:00` to see all available snapshots for a particular hour:

```
 MySQL  127.0.0.1:3306 ssl  Py > \show snapshots -d 2022-04-15 -t 08:00

XDBTIME reports for MySQL
Copyright (c) 2016, 2022, XDBTIME Taras Guliak
Version: 2022.01

Snapshots as of  2022-04-15 08:00 h

Date                   Snapshot    Statement Wait Time
2022-04-15 08:07:54      12259      00h 00m 16s
2022-04-15 08:22:54      12260      00h 00m 17s
2022-04-15 08:37:54      12261      00h 00m 17s
2022-04-15 08:52:54      12262      00h 18m 06s

Report should return a dictionary.
```

Define two periods of time you would like to compare. Each period has its start and end snapshot. 

3. Create performance comparison report `\show compare`. It requires 4 parameters: start and end time for the first period of time, start and end time for the second period of time. The report will be written in the `reports` folder.

```
 MySQL  127.0.0.1:3306 ssl  Py > \show compare 12087 12088 12088 12089

XDBTIME reports for MySQL
Copyright (c) 2016, 2022, XDBTIME Taras Guliak
Version: 2022.01

Creating MySQL Performance Period Comparison Report ...
Report is written to: ./reports/mysql-xdbmo-compare-ip-127-0-0-1-12087-12088vs12088-12089.html

Report should return a dictionary.
```

You can open the report directly from the command line: just press the Command button and click on the report link.
