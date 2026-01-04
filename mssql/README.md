# xdbtime Community Edition for SQL Server

[![Go](https://img.shields.io/badge/Go-1.21+-blue.svg)](https://golang.org)
[![License](https://img.shields.io/badge/License-BSD%203--Clause-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux-lightgrey.svg)]()

A comprehensive SQL Server performance analysis tool that leverages Query Store data to identify performance bottlenecks and track database performance trends over time.

## 🎯 What is xdbtime?

**xdbtime** is a command-line tool designed to help engineers **identify performance issues before they impact customers**. Whether in production or test environments, xdbtime provides detailed performance reports to establish baseline performance and track changes over time.

### Key Features

- 📊 **Period Reports** - Generate performance reports for specific time periods
- 🔍 **Performance Comparison** - Compare two time periods to identify regressions
- 📈 **Query Store Integration** - Built on SQL Server's Query Store for accurate metrics
- 🔐 **Flexible Authentication** - Support for both Azure AD and SQL authentication
- 🌐 **Rich HTML Reports** - Interactive reports with charts powered by D3.js
- 💾 **Download Execution Plans** - Download and analyze execution plans locally

### Community vs PRO Features

| Feature | Community | PRO |
|---------|-----------|-----|
| Period Reports (Single DB) | ✅ | ✅ |
| Comparison Reports | ✅ | ✅ |
| Execution Plan Export | ✅ | ✅ |
| Query Store Interval Browser | ✅ | ✅ |
| **Period Reports (All Databases)** | ❌ | ✅ |
| **Week-to-Week Comparison Reports** | ❌ | ✅ |

> **💡 Tip**: This Community Edition provides powerful single-database analysis capabilities. For multi-database reporting and automated week-to-week monitoring, consider upgrading to xdbtime PRO.

## 📋 Prerequisites

- **SQL Server** with Query Store enabled (default on Azure SQL Database)
- **Database permissions** with read access to Query Store views
- **Go 1.21+** (for building from source) or use pre-built binaries

> **📚 Learn more**: [Query Store documentation](https://learn.microsoft.com/en-us/sql/relational-databases/performance/monitoring-performance-by-using-the-query-store)

## 🚀 Quick Start

### Option 1: Download Pre-built Binary

1. **Download** the appropriate binary for your platform:
   - **macOS M chips**: `xdbtime`
   - **Linux**: `xdbtime-linux-amd64`
   - **Windows**: `xdbtime.exe`

2. **Set up authentication** (choose one):

   **For Azure AD authentication:**
   ```bash
   az login
   ```

   **For SQL Server authentication:**
   ```bash
   # Linux/macOS
   export DB_USER=your_username
   export DB_PASS=your_password

   # Windows
   set DB_USER=your_username
   set DB_PASS=your_password
   ```

3. **Navigate to the mssql directory and run the tool:**
   ```bash
   # Navigate to the mssql directory (required for templates and report output)
   cd mssql
   
   # macOS/Linux
   ./xdbtime

   # Windows PowerShell
   .\xdbtime.exe
   ```

> **⚠️ Important**: xdbtime must be run from the `mssql` directory to properly access report templates and save output files to the correct locations.

### Option 2: Build from Source

```bash
# Clone the repository
git clone https://github.com/xdbtime/xdbtime.git
cd xdbtime

# Build
go build -o xdbtime .

# Navigate to mssql directory and run
cd mssql
./xdbtime (or .\xdbtime.exe on Windows PowerShell)
```
## 🎮 User Interface

### Initial Connection

When you first launch xdbtime, you'll see:

```
xdbtime 2025.12 Community Edition for SQL Server
Database Performance Analysis & Comparison Tool

Copyright (c) 2016, 2026, Taras Guliak
Licensed under BSD 3-Clause License - see LICENSE file for details

You are not connected to any SQL Server yet.

Choose a connection option:

[a] Connect to SQL Server uzing AD authentication
[u] Connect to SQL Server uzing User/Password authentication
[e] Exit 
```

### Connection Process

**Azure AD Authentication:**
```bash
# Select option 'a'
Enter DB server name: myserver.database.windows.net
Enter DB port: 1433
Enter Database name: mydatabase
```

**SQL Server Authentication:**
```bash
# Select option 'u' (requires DB_USER and DB_PASS environment variables)
Enter DB server name: myserver.database.windows.net  
Enter DB port: 1433
Enter Database name: mydatabase
```

### Main Menu

Once connected, you'll access the main menu:

```
Current DB context:
Server   : myserver.database.windows.net
Database : mydatabase

Choose a menu item:
[s] Switch to another SQL Server
[l] List Query Store intervals
[p] Period report
[c] Compare report
[w] Week 2 Week report (PRO)
[d] Download Execution Plans
[e] Exit
```


## Main Menu

## 📖 Feature Guide

### 🔄 [s] Switch SQL Server Connection

Change your database connection without restarting the application:

- **[a]** Connect to different server with Azure AD
- **[u]** Connect to different server with SQL authentication  
- **[d]** Switch database on current server

### 📊 [l] Query Store Intervals Browser

Explore Query Store data to understand when database activity occurred:

**Summary View:**
```
Query Store intervals grouped by Date
-------------------------------------------------------------------------
Date          Min Interval ID    Max Interval ID    SQL Duration(minutes)
-------------------------------------------------------------------------
2025-12-02    79167              79167                             0
2025-12-03    79168              79263                             0
2025-12-04    79264              79359                             0
2025-12-05    79360              79455                             0
2025-12-06    79456              79551                             0
2025-12-07    79552              79647                             0
2025-12-08    79648              79743                            16
2025-12-09    79744              79839                            47
2025-12-10    79840              79935                            40
2025-12-11    79936              80031                            42
2025-12-12    80032              80127                            13
2025-12-13    80128              80223                             0
2025-12-14    80224              80319                             0
2025-12-15    80320              80415                             0
2025-12-16    80416              80511                             0
2025-12-17    80512              80607                             0
2025-12-18    80608              80703                             2
2025-12-19    80704              80799                             0
2025-12-20    80800              80895                             0
2025-12-21    80896              80991                             0
2025-12-22    80992              81087                             0
2025-12-23    81088              81183                             0
2025-12-24    81184              81279                             0
2025-12-25    81280              81375                             0
2025-12-26    81376              81471                             0
2025-12-27    81472              81567                             5
2025-12-28    81568              81663                             6
2025-12-29    81664              81759                             5
2025-12-30    81760              81855                             5
2025-12-31    81856              81951                             5
2026-01-01    81952              82047                             5
2026-01-02    82048              82105                             3
```

**Detailed View:** Enter date in YYYY-MM-DD format to drill down and see all Query Store intervals for any specific date to identify exact time periods for analysis.

```
Enter date to display Query Store intervals for that specific date (YYYY-MM-DD):
2025-12-11
Query Store Intervals for: 2025-12-11

Server   : myserver.database.windows.net
Database : mydatabase

-------------------------------------------------------------------------------------------
Start Time               End Time                 Max Interval ID     SQL Duration(minutes)
-------------------------------------------------------------------------------------------
2025-12-11 00:00         2025-12-11 00:15         79936                             0
2025-12-11 00:15         2025-12-11 00:30         79937                             0
2025-12-11 00:30         2025-12-11 00:45         79938                             0
2025-12-11 00:45         2025-12-11 01:00         79939                             0
2025-12-11 01:00         2025-12-11 01:15         79940                             0
2025-12-11 01:15         2025-12-11 01:30         79941                             0
2025-12-11 01:30         2025-12-11 01:45         79942                             0
2025-12-11 01:45         2025-12-11 02:00         79943                             0
2025-12-11 02:00         2025-12-11 02:15         79944                             0
2025-12-11 02:15         2025-12-11 02:30         79945                             0
2025-12-11 02:30         2025-12-11 02:45         79946                             0
2025-12-11 02:45         2025-12-11 03:00         79947                             0
2025-12-11 03:00         2025-12-11 03:15         79948                             0
2025-12-11 03:15         2025-12-11 03:30         79949                             0
2025-12-11 03:30         2025-12-11 03:45         79950                             0
2025-12-11 03:45         2025-12-11 04:00         79951                             0
2025-12-11 04:00         2025-12-11 04:15         79952                             0
2025-12-11 04:15         2025-12-11 04:30         79953                             0
2025-12-11 04:30         2025-12-11 04:45         79954                             0
2025-12-11 04:45         2025-12-11 05:00         79955                             0
2025-12-11 05:00         2025-12-11 05:15         79956                             0
2025-12-11 05:15         2025-12-11 05:30         79957                             0
2025-12-11 05:30         2025-12-11 05:45         79958                             0
2025-12-11 05:45         2025-12-11 06:00         79959                             0
2025-12-11 06:00         2025-12-11 06:15         79960                             0
2025-12-11 06:15         2025-12-11 06:30         79961                             0
2025-12-11 06:30         2025-12-11 06:45         79962                             0
2025-12-11 06:45         2025-12-11 07:00         79963                             0
2025-12-11 07:00         2025-12-11 07:15         79964                             0
2025-12-11 07:15         2025-12-11 07:30         79965                             0
2025-12-11 07:30         2025-12-11 07:45         79966                             0
2025-12-11 07:45         2025-12-11 08:00         79967                             0
2025-12-11 08:00         2025-12-11 08:15         79968                             0
2025-12-11 08:15         2025-12-11 08:30         79969                             0
2025-12-11 08:30         2025-12-11 08:45         79970                             0
2025-12-11 08:45         2025-12-11 09:00         79971                             0
2025-12-11 09:00         2025-12-11 09:15         79972                             1
2025-12-11 09:15         2025-12-11 09:30         79973                             4
2025-12-11 09:30         2025-12-11 09:45         79974                             3
2025-12-11 09:45         2025-12-11 10:00         79975                             4
2025-12-11 10:00         2025-12-11 10:15         79976                             3
2025-12-11 10:15         2025-12-11 10:30         79977                             3
2025-12-11 10:30         2025-12-11 10:45         79978                             0
2025-12-11 10:45         2025-12-11 11:00         79979                             0
2025-12-11 11:00         2025-12-11 11:15         79980                             4
2025-12-11 11:15         2025-12-11 11:30         79981                             4
2025-12-11 11:30         2025-12-11 11:45         79982                             0
2025-12-11 11:45         2025-12-11 12:00         79983                             0
2025-12-11 12:00         2025-12-11 12:15         79984                             2
2025-12-11 12:15         2025-12-11 12:30         79985                             4
2025-12-11 12:30         2025-12-11 12:45         79986                             3
2025-12-11 12:45         2025-12-11 13:00         79987                             0
2025-12-11 13:00         2025-12-11 13:15         79988                             0
2025-12-11 13:15         2025-12-11 13:30         79989                             0
2025-12-11 13:30         2025-12-11 13:45         79990                             0
2025-12-11 13:45         2025-12-11 14:00         79991                             0
2025-12-11 14:00         2025-12-11 14:15         79992                             0
2025-12-11 14:15         2025-12-11 14:30         79993                             0
2025-12-11 14:30         2025-12-11 14:45         79994                             0
2025-12-11 14:45         2025-12-11 15:00         79995                             0
2025-12-11 15:00         2025-12-11 15:15         79996                             0
2025-12-11 15:15         2025-12-11 15:30         79997                             0
2025-12-11 15:30         2025-12-11 15:45         79998                             0
2025-12-11 15:45         2025-12-11 16:00         79999                             0
2025-12-11 16:00         2025-12-11 16:15         80000                             0
2025-12-11 16:15         2025-12-11 16:30         80001                             0
2025-12-11 16:30         2025-12-11 16:45         80002                             0
2025-12-11 16:45         2025-12-11 17:00         80003                             0
2025-12-11 17:00         2025-12-11 17:15         80004                             0
2025-12-11 17:15         2025-12-11 17:30         80005                             1
2025-12-11 17:30         2025-12-11 17:45         80006                             2
2025-12-11 17:45         2025-12-11 18:00         80007                             1
2025-12-11 18:00         2025-12-11 18:15         80008                             0
2025-12-11 18:15         2025-12-11 18:30         80009                             0
2025-12-11 18:30         2025-12-11 18:45         80010                             0
2025-12-11 18:45         2025-12-11 19:00         80011                             0
2025-12-11 19:00         2025-12-11 19:15         80012                             0
2025-12-11 19:15         2025-12-11 19:30         80013                             0
2025-12-11 19:30         2025-12-11 19:45         80014                             0
2025-12-11 19:45         2025-12-11 20:00         80015                             0
2025-12-11 20:00         2025-12-11 20:15         80016                             0
2025-12-11 20:15         2025-12-11 20:30         80017                             0
2025-12-11 20:30         2025-12-11 20:45         80018                             0
2025-12-11 20:45         2025-12-11 21:00         80019                             0
2025-12-11 21:00         2025-12-11 21:15         80020                             0
2025-12-11 21:15         2025-12-11 21:30         80021                             0
2025-12-11 21:30         2025-12-11 21:45         80022                             0
2025-12-11 21:45         2025-12-11 22:00         80023                             0
2025-12-11 22:00         2025-12-11 22:15         80024                             0
2025-12-11 22:15         2025-12-11 22:30         80025                             0
2025-12-11 22:30         2025-12-11 22:45         80026                             0
2025-12-11 22:45         2025-12-11 23:00         80027                             0
2025-12-11 23:00         2025-12-11 23:15         80028                             0
2025-12-11 23:15         2025-12-11 23:30         80029                             0
2025-12-11 23:30         2025-12-11 23:45         80030                             0
2025-12-11 23:45         2025-12-12 00:00         80031                             0
```

### 📈 [p] Period Reports

Generate comprehensive performance reports for specific time periods:

**Available Options:**
- **[i]** Single DB - by Query Store Interval IDs  
- **[d]** Single DB - by Date/Time range
- **[a]** All Databases - by Date/Time range *(PRO feature)*

**Example Output:**
```
Report successfully written to: reports/report-mydatabase-20241004-1130-1200.html
```

### 🔍 [c] Comparison Reports  

Compare performance between two time periods to identify regressions:

**Available Options:**
- **[i]** Compare by Query Store Interval IDs
- **[d]** Compare by Date/Time ranges

**Use Cases:**
- Before/after deployment comparisons
- Peak vs off-peak analysis  
- Performance regression detection

### ⏰ [w] Week-to-Week Reports *(PRO Feature)*

*This feature requires xdbtime PRO. [Learn more about upgrading →]*

Automated weekly performance comparison reports ideal for:
- Production monitoring
- Trend analysis
- Regression detection

### 💾 [d] Export Execution Plans

Download SQL execution plans for detailed analysis:

**Available Options:**
- **[s]** Export single plan by Plan ID
- **[t]** Export TOP 20 plans by elapsed time for date range

**Output:** Plans saved as `.sqlplan` files to the `plans/` directory that can be opened in SQL Server Management Studio / Azure Data Studio / Visual Studio Code.

## 🛠️ Technical Details

### File Structure
```
xdbtime/
├── reports/          # Generated HTML reports  
├── plans/           # Downloaded execution plans
├── templates/       # Report templates
└── xdbtime          # Executable
```

### Report Content

Generated reports include:
- **Query performance metrics** (duration, CPU, reads, writes)
- **Interactive charts** showing trends over time
- **Top consuming queries** with drill-down capabilities  
- **Wait statistics** analysis
- **Plan comparison** for regression analysis

### Supported Platforms
- **Windows** (x64)
- **macOS** (Intel & Apple Silicon)
- **Linux** (x64)

## 📄 License

This project is licensed under the BSD 3-Clause License - see the [LICENSE](LICENSE) file for details.

---

**Made with ❤️ for the SQL Server community** | Copyright (c) 2016, 2026, Taras Guliak