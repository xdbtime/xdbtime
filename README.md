# xdbtime Community Edition

[![License](https://img.shields.io/badge/License-BSD%203--Clause-green.svg)](LICENSE)
[![Database](https://img.shields.io/badge/Database-Oracle%20%7C%20MySQL%20%7C%20SQL%20Server-blue.svg)]()
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux-lightgrey.svg)]()

A comprehensive multi-database performance analysis suite that helps engineers identify performance bottlenecks and track database performance trends across Oracle, MySQL, and SQL Server environments.

## 🎯 What is xdbtime?

**xdbtime** is a powerful command-line toolkit designed to help engineers **identify performance issues before they impact customers**. Whether in production or test environments, xdbtime provides detailed performance reports with visual analytics to establish baseline performance and track changes over time.

![alt test](oracle/images/image_readme_oracle.png)

### 🚀 Key Benefits

- **🎯 Proactive Issue Detection** - Catch performance problems before they affect customers
- **📊 Visual Analytics** - Graphical reports that minimize analysis time
- **🔍 Drill-down Capability** - Start with high-level metrics, dive into details
- **🏷️ SQL Classification** - Group queries to correlate performance changes
- **⚡ No DB Expertise Required** - User-friendly reports accessible to all engineers
- **🔄 Trend Analysis** - Compare performance across different time periods

### 📈 Core Features

| Feature | Oracle | MySQL | SQL Server |
|---------|--------|-------|------------|
| **Period Comparison Reports** | ✅ | ✅ | ✅ |
| **Week 2 Week Comparison Reports** | ❌ | ❌ | ✅ |
| **Performance Test Comparison Reports** | ✅ | ✅ | ❌ |
| **Single Period Reports** | ❌ | ❌ | ✅ |

### Community vs PRO Features

| Feature | Community | PRO |
|---------|-----------|-----|
| **Period Comparison Reports** | ✅ | ✅* |
| **Week 2 Week Comparison Reports** | ❌ | ✅ |
| **Performance Test Comparison Reports** | ❌ | ✅ |
| **Single Period Reports** | ✅ | ✅* |

*\* Available for single database for SQL Server. Reports generation for all available databases in SQL Server requires PRO version*

> **💡 Tip**: The Community Edition provides powerful analysis capabilities for Oracle, MySQL and SQL Server. For Performance Test comparisons and test pipeline integration, consider upgrading to xdbtime PRO.

## 🗄️ Supported Databases

### Oracle Database
- **Versions**: 12c, 18c, 19c, 21c
- **Editions**: XE, SE, EE, EE-HP, EE-EP
- **Cloud**: Oracle Cloud Infrastructure (OCI)

### MySQL
- **Versions**: 5.7, 8.0+
- **Variants**: Community, Enterprise
- **Cloud**: Amazon Aurora MySQL

### SQL Server
- **Versions**: 2019+
- **Editions**: Express, Standard, Enterprise
- **Cloud**: Azure SQL Database, Azure SQL Managed Instance

## 📋 Prerequisites

Choose the appropriate section based on your database:

### For Oracle
- Oracle Database 12c+
- Read permissions on performance views
- Oracle client tools (SQL*Plus, SQLcl)

### For MySQL  
- MySQL 5.7+ with Performance Schema enabled
- MySQL Shell 8.0+ (for report generation)
- Read permissions on Performance Schema

### For SQL Server
- SQL Server 2019+ with Query Store enabled
- Read permissions on Query Store views
- Go 1.21+ (if building from source)

## 🚀 Quick Start

### Choose Your Database Platform

Select your database platform to get started:

#### 📊 SQL Server
```bash
# Navigate to SQL Server directory
cd mssql

# Run xdbtime executable (from mssql directory)
./xdbtime        # macOS M chips (for Linux amd64 use ./xdbtime-linux-amd64)
.\xdbtime.exe    # Windows PowerShell
```

#### 🐬 MySQL  
```bash
# Navigate to MySQL directory
cd mysql

# Setup MySQL Shell reports (executed once)
mkdir -p ~/.mysqlsh/init.d
cp init.d/xdbperformance-status.py ~/.mysqlsh/init.d
cp init.d/xdbmonitoring-snapshots.py ~/.mysqlsh/init.d
cp init.d/xdbmonitoring-compare.py ~/.mysqlsh/init.d

# Connect to DB instance and see available reports
mysqlsh user@mysql-host --py
\show

# Run report (example for performance status report)
\show performance
```

#### 🔶 Oracle
```bash
# Navigate to Oracle directory  
cd oracle

# Connect to DB instance
sql user@orcl

# for AWR-based performance comparison reports (recommended when AWR is available)
@xdbawrcompare.sql

# for XDBMONITORING-based performance comparison reports (when AWR is not available, XDBMONITORING schema must be created)
@xdbmocompare.sql
```

## 📖 Feature Overview

### 📈 Single Period Reports
Analyse performance during specific period of time to identify:
- CPU utilisation
- Top wait events
- Top resource-consuming queries

**Available for**: SQL Server ✅

### 📈 Period Comparison Reports
Compare database performance between two time periods to identify:
- Performance regressions after deployments
- Trending issues over time
- Resource utilization changes
- Query performance variations

**Available for**: Oracle ✅, MySQL ✅, SQL Server ✅

### 📊 Performance Status Reports for MySQL
Analyse cumulative performance metrics since MySQL instance startup:
- Global Status metrics
- File Summary
- Waits Summary
- Statements Summary
- Top resource-consuming queries

**Available for**: MySQL ✅

### ⏰ Performance Test Comparison Reports *(PRO Feature)*
Compare performance metrics between two performance tests runs:
- Compare test runs in CI/CD pipelines
- Baseline performance validation
- Automated regression detection
- Requires XDBWAREHOUSE schema to collect metrics from different performance test runs

**Available for**: Oracle ✅, MySQL ✅

### 🔍 Advanced Analytics
- **Visual drill-down reporting** from high-level to detailed metrics
- **Conditional formatting** to highlight performance drivers
- **SQL classification groups** for correlated analysis
- **Interactive charts** powered by D3.js

## 🛠️ Project Structure

```
xdbtime/
├── README.md           # This overview document
├── LICENSE             # BSD 3-Clause License
├── oracle/             # Oracle Database tools & reports
│   ├── README.md       # Oracle-specific documentation
│   ├── schemas/        # DDL scripts for XDBMONITORING schemas and XDBWAREHOUSE (PRO Feature) schemas
│   ├── reports/        # Generated HTML reports
│   └── ...
├── mysql/              # MySQL tools & reports  
│   ├── README.md       # MySQL-specific documentation
│   ├── schemas/        # DDL scripts for XDBMONITORING schemas and XDBWAREHOUSE (PRO Feature) schemas
│   ├── init.d/         # MySQL Shell reports - should be copied to ~/.mysqlsh/init.d
│   ├── reports/        # Generated HTML reports
│   ├── templates/      # HTML report templates
│   └── ...
└── mssql/              # SQL Server tools & reports
    ├── README.md       # SQL Server documentation
    ├── reports/        # Generated HTML reports
    ├── templates/      # HTML report templates
    ├── plans/          # Downloaded execution plans (*.sqlplan files)
    ├── xdbtime.exe     # Windows executable
    ├── xdbtime         # macOS M-chip executable (xdbtime-darwin-amd64 for Linux amd64)
    └── ...
```

## 📚 Documentation

Each database platform has detailed documentation:

- **[SQL Server Guide](mssql/README.md)** - Query Store analysis, period & comparison reports
- **[MySQL Guide](mysql/README.md)** - Performance Schema analysis, status reports  
- **[Oracle Guide](oracle/README.md)** - AWR-based period comparison reports

## 🔄 Recommended Workflows

### Production Monitoring
1. **Weekly comparisons** - Compare current week vs previous week
2. **Deployment validation** - Before/after performance analysis
3. **Trend monitoring** - Regular baseline establishment

### Test Environment
1. **Pre-release validation** - Performance regression testing
2. **Load test analysis** - Capacity planning validation
3. **CI/CD integration** - Automated performance gates *(PRO)*

## 📄 License

This project is licensed under the BSD 3-Clause License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support & Documentation

- **Issues**: Report bugs or request features via [GitHub Issues]
- **Discussions**: Join the community for questions and tips
- **Database-specific docs**: See individual README files in each database folder

---

**Made with ❤️ for the database community** | Copyright (c) 2016, 2026, Taras Guliak