# xdbtime
Set of tools to measure and compare performance on databases.

The main goal is to identify performance issues in production systems before they hit your customers and in test environments before they are released to production systems. Xdbtime tools and reports can help to set up processes to compare database performance in production databases periodically and in performance test environments before every release.

![alt test](oracle/images/image_readme_oracle.png)

**xdbtime reports** are designed to compare database performance metrics visually in a simple way. Graphical representation minimizes the time required to analyze the report. It starts from the high-level metrics like Database time and allows to go into details to find answers. You can classify your SQLs into groups that allow visually correlate changes in different SQL metrics. Conditional formatting attracts your attention to the main drivers. It does not require DBA knowledge to review database performance reports.

xdbtime can compare performance on Oracle and MySQL databases.

xdbtime supports Oracle 12c - 19c (XE, SE, EE, EE-HP, EE-EP) and MySQL 5.7, 8.0.x.

xdbtime offers the following products for Oracle and MySQL databases:
1. Period Comparison Report (to compare two periods of time on a single database) for Oracle databases
2. Performance status report for MySQL databases (based on MySQL Performance Schema)

xdbtime(pro) offers additionally the following products for Oracle and MySQL databases and are not covered by open-source license:
1. Period Comparison Report (to compare two periods of time on a single database) for MySQL databases
2. Test Comparison Report (to compare two test runs whose performance metrics were collected into separate database `XDBWAREHOUSE`) for Oracle and MySQL databases


xdbtime(pro) products can be integrated into your performance test pipelines.
Database performance metrics can be automatically collected after performance test runs and compared to the baseline.
Performance comparison report can be attached as an artifact to the performance test run and analyzed by engineers. 

It is recommended to compare performance in production databases week to week using Period Comparison Report to understand changes in performance over time and prevent potential issues.

More documentation and guidelines are provided in dedicated readme-files in `oracle` and `mysql` folders.