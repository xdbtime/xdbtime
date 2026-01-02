package main

import (
	"bufio"
	"context"
	"database/sql"
	"fmt"
	"log"
	"os"

	"github.com/microsoft/go-mssqldb/azuread"
)

var db *sql.DB

var server = ""
var port = 1433
var database = ""
var username = ""
var password = ""
var adauth = 1

func main() {

	var menuItem string

	fmt.Printf("xdbtime 2025.12 Community Edition for SQL Server\n")
	fmt.Printf("Database Performance Analysis & Comparison Tool\n")
	fmt.Printf("\n")
	fmt.Printf("Copyright (c) 2016, 2026, Taras Guliak\n")
	fmt.Printf("Licensed under BSD 3-Clause License - see LICENSE file for details\n")
	fmt.Printf("\n")

	for {

	Start:

		if server == "" {

			var err error

			connectDBtext := fmt.Sprintf("\x1b[%dm%s\x1b[0m", 34, "You are not connected to any SQL Server yet.")
			fmt.Println(connectDBtext)

			menuItem = printDBConnectMenu()

			if menuItem == "e" {
				fmt.Printf("Bye! \n")
				break
			}

			switch menuItem {
			case "e":
				fmt.Printf("Bye! \n")
				os.Exit(3)
			case "a":
				db, err = connectDbActiveDirectory()

				if err != nil {
					fmt.Println("Failed to connect to SQL Server: ", err.Error())
					fmt.Println("")
					goto Start
				}

			case "u":
				db, err = connectDbUserPassword()

				if err != nil {
					fmt.Println("Failed to connect to SQL Server: ", err.Error())
					fmt.Println("")
					goto Start
				}

			default:
				fmt.Printf("Please select menu item. \n")
				goto Start
			}

			currentDbContextText := fmt.Sprintf("\x1b[%dm%s\x1b[0m", 34, "Current DB context:")
			fmt.Println(currentDbContextText)

			printCurrentDBContext()
		}

		menuItem = printMainMenu()

		if menuItem == "e" {
			fmt.Printf("Bye! \n")
			break
		}

		switch menuItem {
		case "s":

		switchDbLabel:

			var err error

			connectDBtext := fmt.Sprintf("\x1b[%dm%s\x1b[0m", 34, "Connecting to SQL Server")
			fmt.Println(connectDBtext)

			menuItem = printDBSwitchMenu()

			if menuItem == "e" {
				fmt.Printf("Bye! \n")
				break
			}

			switch menuItem {
			case "a":
				db.Close()

				server = ""
				database = ""
				username = ""
				password = ""

				db, err = connectDbActiveDirectory()

				if err != nil {
					fmt.Println("Failed to connect to SQL Server: ", err.Error())
					fmt.Println("")
					goto Start
				}
			case "u":
				db.Close()

				server = ""
				database = ""
				username = ""
				password = ""

				db, err = connectDbUserPassword()

				if err != nil {
					fmt.Println("Failed to connect to SQL Server: ", err.Error())
					fmt.Println("")
					goto Start
				}
			case "d":

				var dbDatabase string

				if server == "" {

					fmt.Println("You are not connected to any SQL Server yet. Please chose one of the first two options.")
					os.Exit(3)

				} else {

					db.Close()

					fmt.Println("Enter Database name:")
					fmt.Scanln(&dbDatabase)
					fmt.Println("")

					db, err = connectDbByDBname(server, port, dbDatabase)

					if err != nil {
						fmt.Println("Failed to connect to SQL Server: ", err.Error())
						fmt.Println("")
						goto Start
					}

				}

			default:
				fmt.Printf("Please select menu item. \n")
				goto switchDbLabel
			}

			currentDbContextText := fmt.Sprintf("\x1b[%dm%s\x1b[0m", 34, "Current DB context:")
			fmt.Println(currentDbContextText)

			printCurrentDBContext()

		case "l":

			var intervalDate string

			intervalSummaryCount, err := printIntervalSummary()

			if err != nil {
				log.Fatal("Error reading Snapshots: ", err.Error())
			}
			fmt.Printf("Read %d row(s) successfully.\n", intervalSummaryCount)

			fmt.Println("")
			fmt.Println("Enter date to display Query Store intervals for that specific date (YYYY-MM-DD):")
			fmt.Scanln(&intervalDate)

			intervalForDateCount, err := printIntervalsForDate(intervalDate)

			if err != nil {
				log.Fatal("Error reading Snapshots: ", err.Error())
			}

			fmt.Printf("Read %d row(s) successfully.\n", intervalForDateCount)

		case "p":

			for {

				menuItem = printPeriodReportMenu()

				if menuItem == "e" {
					fmt.Printf("Bye! \n")
					break
				}

				switch menuItem {
				case "i":

					var testrunStartIntervalId int
					var testrunEndIntervalId int
					var reportFileName string

					reportDBtext := fmt.Sprintf("\x1b[%dm%s\x1b[0m", 34, "Period report (by Query Store interval IDs)")
					fmt.Println(reportDBtext)

					fmt.Println("Enter Start Interval ID :")
					fmt.Scanf("%d\n", &testrunStartIntervalId)
					fmt.Println("")

					fmt.Println("Enter End Interval ID :")
					fmt.Scanf("%d\n", &testrunEndIntervalId)
					fmt.Println("")

					//Generate report
					reportFileName, err := generatePeriodReportByID(testrunStartIntervalId, testrunEndIntervalId)
					if err != nil {
						log.Fatal("Error generating report: ", err.Error())
					}

					fmt.Println("Report is successfully written to: " + reportFileName)

					menuItem = "e"

				case "d":

					var startIntervalId int
					var endIntervalId int

					reportDBtext := fmt.Sprintf("\x1b[%dm%s\x1b[0m", 34, "Period report (by dates)")
					fmt.Println(reportDBtext)

					fmt.Println("Enter Start Date (format yyyy-mm-dd hh:mi) (24-hour):")
					periodStartDate := bufio.NewScanner(os.Stdin)
					periodStartDate.Scan()
					err1 := periodStartDate.Err()
					if err1 != nil {
						log.Fatal(err1)
					}
					fmt.Println("")

					fmt.Println("Enter End   Date (format yyyy-mm-dd hh:mi) (24-hour):")
					periodEndDate := bufio.NewScanner(os.Stdin)
					periodEndDate.Scan()
					err2 := periodEndDate.Err()
					if err2 != nil {
						log.Fatal(err2)
					}
					fmt.Println("")

					startIntervalId, endIntervalId, err3 := getIntervalIdsByRange(periodStartDate.Text(), periodEndDate.Text())

					if err3 != nil {
						fmt.Println(err3.Error())
					} else if startIntervalId > 0 || endIntervalId > 0 {
						// Generate report
						reportFileName, err := generatePeriodReportByID(startIntervalId, endIntervalId)
						if err != nil {
							log.Fatal("Error generating report: ", err.Error())
						}

						fmt.Println("Report is successfully written to: " + reportFileName)
					}

					menuItem = "e"

				case "a":

					reportDBtext := fmt.Sprintf("\x1b[%dm%s\x1b[0m", 34, "Period report by dates (All DBs)")
					fmt.Println(reportDBtext)

					fmt.Printf("\n")
					fmt.Printf("This feature requires xdbtime PRO.\n")
					fmt.Printf("Visit https://xdbtime.com for upgrade information.\n")

					menuItem = "e"

				default:
					fmt.Printf("Please select menu item. \n")

				}

				if menuItem == "e" {
					break
				}
			}

		case "c":

			for {

				menuItem = printCompareReportMenu()

				if menuItem == "e" {
					fmt.Printf("Bye! \n")
					break
				}

				switch menuItem {
				case "i":

					var periodAStartIntervalId, periodAEndIntervalId, periodBStartIntervalId, periodBEndIntervalId int
					var reportFileName string

					compareDBtext := fmt.Sprintf("\x1b[%dm%s\x1b[0m", 34, "Comparison report (by intervals)")
					fmt.Println(compareDBtext)

					fmt.Println("First Period:: Enter Start Interval ID :")
					fmt.Scanf("%d\n", &periodAStartIntervalId)
					fmt.Println("")

					fmt.Println("First Period:: Enter End   Interval ID :")
					fmt.Scanf("%d\n", &periodAEndIntervalId)
					fmt.Println("")

					fmt.Println("Second Period:: Enter Start Interval ID :")
					fmt.Scanf("%d\n", &periodBStartIntervalId)
					fmt.Println("")

					fmt.Println("Second Period:: Enter End   Interval ID :")
					fmt.Scanf("%d\n", &periodBEndIntervalId)
					fmt.Println("")

					//Generate report
					reportFileName, err := generateComparisonReportByID(periodAStartIntervalId, periodAEndIntervalId, periodBStartIntervalId, periodBEndIntervalId)
					if err != nil {
						log.Fatal("Error generating report: ", err.Error())
					}

					fmt.Println("Report is successfully written to: " + reportFileName)

					menuItem = "e"

				case "d":

					reportDBtext := fmt.Sprintf("\x1b[%dm%s\x1b[0m", 34, "Comparison report (by dates)")
					fmt.Println(reportDBtext)

					fmt.Println("First Period:: Enter Start Date (format yyyy-mm-dd hh:mi) (24-hour):")
					periodAStartDate := bufio.NewScanner(os.Stdin)
					periodAStartDate.Scan()
					err1 := periodAStartDate.Err()
					if err1 != nil {
						log.Fatal(err1)
					}
					fmt.Println("")

					fmt.Println("First Period:: Enter End   Date (format yyyy-mm-dd hh:mi) (24-hour):")
					periodAEndDate := bufio.NewScanner(os.Stdin)
					periodAEndDate.Scan()
					err2 := periodAEndDate.Err()
					if err2 != nil {
						log.Fatal(err2)
					}
					fmt.Println("")

					fmt.Println("Second Period:: Enter Start Date (format yyyy-mm-dd hh:mi) (24-hour):")
					periodBStartDate := bufio.NewScanner(os.Stdin)
					periodBStartDate.Scan()
					err3 := periodBStartDate.Err()
					if err3 != nil {
						log.Fatal(err1)
					}
					fmt.Println("")

					fmt.Println("Second Period:: Enter End   Date (format yyyy-mm-dd hh:mi) (24-hour):")
					periodBEndDate := bufio.NewScanner(os.Stdin)
					periodBEndDate.Scan()
					err4 := periodBEndDate.Err()
					if err4 != nil {
						log.Fatal(err2)
					}
					fmt.Println("")

					periodAStartIntervalId, periodAEndIntervalId, err5 := getIntervalIdsByRange(periodAStartDate.Text(), periodAEndDate.Text())

					if err5 != nil {
						fmt.Println("Could not get intervals for Period A")
						fmt.Println(err5.Error())
					} else if periodAStartIntervalId > 0 || periodAEndIntervalId > 0 {

						periodBStartIntervalId, periodBEndIntervalId, err6 := getIntervalIdsByRange(periodBStartDate.Text(), periodBEndDate.Text())

						if err6 != nil {
							fmt.Println("Could not get intervals for Period B")
							fmt.Println(err6.Error())
						} else if periodBStartIntervalId > 0 || periodBEndIntervalId > 0 {

							//Generate report
							var reportFileName string

							reportFileName, err := generateComparisonReportByID(periodAStartIntervalId, periodAEndIntervalId, periodBStartIntervalId, periodBEndIntervalId)
							if err != nil {
								log.Fatal("Error generating report: ", err.Error())
							}

							fmt.Println("Report is successfully written to: " + reportFileName)
						}
					}

					menuItem = "e"

				default:
					fmt.Printf("Please select menu item. \n")

				}

				if menuItem == "e" {
					break
				}
			}

		case "w":

			for {

				menuItem = printW2WReportMenu()

				if menuItem == "e" {
					fmt.Printf("Bye! \n")
					break
				}

				switch menuItem {
				case "s":

					reportDBtext := fmt.Sprintf("\x1b[%dm%s\x1b[0m", 34, "Week 2 Week report - Single Database")
					fmt.Println(reportDBtext)

					fmt.Printf("\n")
					fmt.Printf("This feature requires xdbtime PRO.\n")
					fmt.Printf("Visit https://xdbtime.com for upgrade information.\n")

					menuItem = "e"

				case "a":

					reportDBtext := fmt.Sprintf("\x1b[%dm%s\x1b[0m", 34, "Week 2 Week report - All Databases")
					fmt.Println(reportDBtext)

					fmt.Printf("\n")
					fmt.Printf("This feature requires xdbtime PRO.\n")
					fmt.Printf("Visit https://xdbtime.com for upgrade information.\n")

					menuItem = "e"

				default:
					fmt.Printf("Please select menu item. \n")

				}

				if menuItem == "e" {
					break
				}
			}

		case "d":

			for {

				menuItem = printExportPlanMenu()

				if menuItem == "e" {
					fmt.Printf("Bye! \n")
					break
				}

				switch menuItem {
				case "s":

					var planId int
					var planFileName string

					reportDBtext := fmt.Sprintf("\x1b[%dm%s\x1b[0m", 34, "Exporting execution plan by Execution Plan ID")
					fmt.Println(reportDBtext)

					fmt.Println("Enter Execution Plan ID:")
					fmt.Scanf("%d\n", &planId)
					fmt.Println("")

					// Generate report
					planFileName, err := downloadPlanById(planId)
					if err != nil {
						log.Fatal("Error generating report: ", err.Error())
					}

					if planFileName == "" {
						fmt.Println("Execution plan was not found")
						menuItem = "s"
					} else {
						fmt.Println("Execution plan is successfully downloaded to: " + planFileName)
						menuItem = "e"
					}

				case "t":

					var planList []int
					var startIntervalId int
					var endIntervalId int

					reportDBtext := fmt.Sprintf("\x1b[%dm%s\x1b[0m", 34, "Exporting TOP 20 plans by Total Elapsed time")
					fmt.Println(reportDBtext)

					fmt.Println("Enter Start Date (format yyyy-mm-dd hh:mi) (24-hour):")
					periodStartDate := bufio.NewScanner(os.Stdin)
					periodStartDate.Scan()
					err1 := periodStartDate.Err()
					if err1 != nil {
						log.Fatal(err1)
					}
					fmt.Println("")

					fmt.Println("Enter End Date (format yyyy-mm-dd hh:mi) (24-hour):")
					periodEndDate := bufio.NewScanner(os.Stdin)
					periodEndDate.Scan()
					err2 := periodEndDate.Err()
					if err2 != nil {
						log.Fatal(err2)
					}
					fmt.Println("")

					startIntervalId, endIntervalId, err4 := getIntervalIdsByRange(periodStartDate.Text(), periodEndDate.Text())

					if err4 != nil {
						fmt.Println(err4.Error())
					} else if startIntervalId > 0 || endIntervalId > 0 {

						planList, _ = getExecutionPlanList(startIntervalId, endIntervalId)

						for i := 0; i < len(planList); i++ {

							// Generate report
							planFileName, err3 := downloadPlanById(planList[i])
							if err3 != nil {
								log.Fatal("Error generating report: ", err3.Error())
							}

							if planFileName == "" {
								fmt.Println("Execution plan was not found")
							} else {
								fmt.Println("Execution plan is successfully downloaded to: " + planFileName)
							}

							fmt.Println()

						}

					}

					menuItem = "e"

				default:
					fmt.Printf("Please select menu item. \n")

				}

				if menuItem == "e" {
					break
				}
			}

		default:
			fmt.Printf("Please select menu item [s,p,c,w,d,e]. \n")

		}
	}

}

func printMainMenu() string {

	var menuItem string

	fmt.Println("")

	// Menu
	colored := fmt.Sprintf("\x1b[%dm%s\x1b[0m", 34, "Choose a menu item:")
	fmt.Println(colored)

	fmt.Printf("\n")
	fmt.Printf("[s] Switch to another SQL Server\n")
	fmt.Printf("[l] List Query Store intervals\n")
	fmt.Printf("[p] Period report \n")
	fmt.Printf("[c] Compare report \n")
	fmt.Printf("[w] Week 2 Week report (PRO)\n")
	fmt.Printf("[d] Download Execution Plans \n")
	fmt.Printf("[e] Exit \n")
	fmt.Printf("\n")

	fmt.Scanln(&menuItem)
	fmt.Printf("\n")

	return menuItem
}

func printPeriodReportMenu() string {

	var menuItem string

	fmt.Println("")

	// Menu
	colored := fmt.Sprintf("\x1b[%dm%s\x1b[0m", 34, "Period Report menu")
	fmt.Println(colored)

	fmt.Printf("\n")
	fmt.Printf("[i] Single DB - by Interval parameters \n")
	fmt.Printf("[d] Single DB - by Date parameters \n")
	fmt.Printf("[a] All DBs - by Date parameters (PRO) \n")
	fmt.Printf("[e] Uper Menu \n")
	fmt.Printf("\n")

	fmt.Scanln(&menuItem)
	fmt.Printf("\n")

	return menuItem
}

func printCompareReportMenu() string {

	var menuItem string

	fmt.Println("")

	// Menu
	colored := fmt.Sprintf("\x1b[%dm%s\x1b[0m", 34, "Compare Report menu")
	fmt.Println(colored)

	fmt.Printf("\n")
	fmt.Printf("[i] Single DB - by Interval parameters \n")
	fmt.Printf("[d] Single DB - by Date parameters \n")
	fmt.Printf("[e] Upper Menu \n")
	fmt.Printf("\n")

	fmt.Scanln(&menuItem)
	fmt.Printf("\n")

	return menuItem
}

func printW2WReportMenu() string {

	var menuItem string

	fmt.Println("")

	// Menu
	colored := fmt.Sprintf("\x1b[%dm%s\x1b[0m", 34, "Week 2 Week Report menu")
	fmt.Println(colored)

	fmt.Printf("\n")
	fmt.Printf("This feature requires xdbtime PRO.\n")
	fmt.Printf("Visit https://xdbtime.com for upgrade information.\n")
	fmt.Printf("\n")
	fmt.Printf("[s] Single Database (PRO)\n")
	fmt.Printf("[a] All Databases (PRO)\n")
	fmt.Printf("[e] Upper Menu \n")
	fmt.Printf("\n")

	fmt.Scanln(&menuItem)
	fmt.Printf("\n")

	return menuItem
}

func printExportPlanMenu() string {

	var menuItem string

	fmt.Println("")

	// Menu
	colored := fmt.Sprintf("\x1b[%dm%s\x1b[0m", 34, "Export Execution Plan menu")
	fmt.Println(colored)

	fmt.Printf("\n")
	fmt.Printf("[s] Single Plan \n")
	fmt.Printf("[t] TOP 20 plans by Total Elapsed time by date \n")
	fmt.Printf("[e] Upper Menu \n")
	fmt.Printf("\n")

	fmt.Scanln(&menuItem)
	fmt.Printf("\n")

	return menuItem
}

func printDBConnectMenu() string {

	var menuItem string

	fmt.Println("")

	// Menu
	colored := fmt.Sprintf("\x1b[%dm%s\x1b[0m", 34, "Choose a connection option:")
	fmt.Println(colored)

	fmt.Printf("\n")
	fmt.Printf("[a] Connect to SQL Server uzing AD authentication\n")
	fmt.Printf("[u] Connect to SQL Server uzing User/Password authentication\n")
	fmt.Printf("[e] Exit \n")
	fmt.Printf("\n")

	fmt.Scanln(&menuItem)
	fmt.Printf("\n")

	return menuItem
}

func printDBSwitchMenu() string {

	var menuItem string

	fmt.Println("")

	// Menu
	colored := fmt.Sprintf("\x1b[%dm%s\x1b[0m", 34, "Choose a connection option:")
	fmt.Println(colored)

	fmt.Printf("\n")
	fmt.Printf("[a] Connect to SQL Server uzing AD authentication\n")
	fmt.Printf("[u] Connect to SQL Server uzing User/Password authentication\n")
	fmt.Printf("[d] Switch to another database on the same server\n")
	fmt.Printf("[e] Exit \n")
	fmt.Printf("\n")

	fmt.Scanln(&menuItem)
	fmt.Printf("\n")

	return menuItem
}

// Print Current Context
func printCurrentDBContext() int {

	fmt.Printf("\n")
	fmt.Printf("Server   : " + server + "\n")
	fmt.Printf("Database : " + database + "\n")
	fmt.Printf("\n")

	return 1
}

// connectDbActiveDirectory
func connectDbActiveDirectory() (*sql.DB, error) {

	var dbServer string
	var dbDatabase string
	var dbPort int

	colored := fmt.Sprintf("\x1b[%dm%s\x1b[0m", 34, "Active Directory authentication")
	fmt.Println(colored)
	fmt.Println("")

	fmt.Println("It may require running 'az login' before using xdbtime cli")
	fmt.Println("")

	fmt.Println("Enter DB server name:")
	fmt.Scanln(&dbServer)
	fmt.Println("")

	fmt.Println("Enter DB port:")
	fmt.Scanf("%d\n", &dbPort)
	fmt.Println("")

	fmt.Println("Enter Database name:")
	fmt.Scanln(&dbDatabase)
	fmt.Println("")

	// Build connection string
	connString := fmt.Sprintf("server=%s;port=%d;database=%s;fedauth=ActiveDirectoryDefault;", dbServer, dbPort, dbDatabase)

	var err error

	// Create connection pool
	db, err = sql.Open(azuread.DriverName, connString)

	if err != nil {

		server = ""
		database = ""
		username = ""
		password = ""

		log.Fatal("Error creating connection pool: ", err.Error())

		return db, err
	}

	ctx := context.Background()

	err = db.PingContext(ctx)

	if err != nil {

		server = ""
		database = ""
		username = ""
		password = ""

		return db, err
	}

	server = dbServer
	database = dbDatabase
	port = dbPort
	username = ""
	password = ""
	adauth = 1

	fmt.Printf("Successfully connected!\n\n")

	return db, err
}

// connectDbUserPassword
func connectDbUserPassword() (*sql.DB, error) {

	var dbServer string
	var dbDatabase string
	var dbPort int

	colored := fmt.Sprintf("\x1b[%dm%s\x1b[0m", 34, "User/Password authentication")
	fmt.Println(colored)
	fmt.Println("")

	envUsername := os.Getenv("DB_USER")
	envPassword := os.Getenv("DB_PASS")

	if envUsername == "" {

		fmt.Println("Username cannot be empty, please set environment variables DB_USER and DB_PASS first")
		fmt.Println("")

		fmt.Println("Examples:")
		fmt.Println("	for Linux  : export DB_USER=username ")
		fmt.Println("	             export DB_PASS=password ")
		fmt.Println("	for Windows: set DB_USER=username ")
		fmt.Println("	             set DB_PASS=password ")
		fmt.Println("")

		os.Exit(3)
	}

	fmt.Println("Enter DB server name:")
	fmt.Scanln(&dbServer)
	fmt.Println("")

	fmt.Println("Enter DB port:")
	fmt.Scanf("%d\n", &dbPort)
	fmt.Println("")

	fmt.Println("Enter Database name:")
	fmt.Scanln(&dbDatabase)
	fmt.Println("")

	connString := fmt.Sprintf("server=%s;user id=%s;password=%s;port=%d;database=%s", dbServer, envUsername, envPassword, dbPort, dbDatabase)

	var err error

	// Create connection pool
	db, err = sql.Open("sqlserver", connString)
	if err != nil {
		server = ""
		database = ""
		username = ""
		password = ""

		log.Fatal("Error creating connection pool: ", err.Error())
		return db, err
	}

	ctx := context.Background()

	err = db.PingContext(ctx)

	if err != nil {

		server = ""
		database = ""
		username = ""
		password = ""

		return db, err
	}

	fmt.Printf("Successfully connected!\n\n")

	server = dbServer
	database = dbDatabase
	port = dbPort
	username = envUsername
	password = envPassword
	adauth = 0

	return db, err
}

// connectDbActiveDirectory
func connectDbByDBname(dbServer string, dbPort int, dbDatabase string) (*sql.DB, error) {

	var connString string

	db.Close()

	switch adauth {
	case 0:
		connString = fmt.Sprintf("server=%s;user id=%s;password=%s;port=%d;database=%s", dbServer, username, password, dbPort, dbDatabase)
	case 1:
		connString = fmt.Sprintf("server=%s;port=%d;database=%s;fedauth=ActiveDirectoryDefault;", dbServer, dbPort, dbDatabase)

	default:
		connString = fmt.Sprintf("server=%s;port=%d;database=%s;fedauth=ActiveDirectoryDefault;", dbServer, dbPort, dbDatabase)
	}

	var err error

	// Create connection pool
	db, err = sql.Open(azuread.DriverName, connString)
	if err != nil {
		server = ""
		database = ""
		username = ""
		password = ""

		log.Fatal("Error creating connection pool: ", err.Error())
	}

	ctx := context.Background()

	err = db.PingContext(ctx)

	if err != nil {

		server = ""
		database = ""
		username = ""
		password = ""

		return db, err
	}

	fmt.Printf("Successfully connected!\n\n")

	server = dbServer
	database = dbDatabase
	port = dbPort

	return db, err
}

func printIntervalSummary() (int, error) {

	listIntervalsText := fmt.Sprintf("\x1b[%dm%s\x1b[0m", 34, "Query Store Intervals Summary")
	fmt.Println(listIntervalsText)

	ctx := context.Background()

	// Check if database is alive.
	err := db.PingContext(ctx)
	if err != nil {
		return -1, err
	}

	printCurrentDBContext()

	fmt.Printf("Query Store intervals grouped by Date\n")

	fmt.Printf("-------------------------------------------------------------------------\n")
	fmt.Printf("Date          Min Interval ID    Max Interval ID    SQL Duration(minutes)\n")
	fmt.Printf("-------------------------------------------------------------------------\n")

	tsql := fmt.Sprintf(`SELECT
							CAST(CAST(rsi.start_time AS DATE) AS CHAR(13)) cdate,
							CAST(min(rsi.runtime_stats_interval_id) as CHAR(18)) min_interval_id,
							CAST(max(rsi.runtime_stats_interval_id) as CHAR(18)) max_interval_id,
							RIGHT(REPLICATE(' ',16)+CAST(ROUND(SUM(ISNULL(count_executions,0)*ISNULL(avg_duration,0))/1000000/60,0) as VARCHAR(16)),16) duration
						FROM sys.query_store_runtime_stats_interval rsi
							LEFT JOIN sys.query_store_runtime_stats rs on rsi.runtime_stats_interval_id = rs.runtime_stats_interval_id
						GROUP BY CAST(rsi.start_time AS DATE) ORDER BY 1;`)

	// Execute query
	rows, err := db.QueryContext(ctx, tsql)
	if err != nil {
		return -1, err
	}

	defer rows.Close()

	var count int

	// Iterate through the result set.
	for rows.Next() {
		var cdate, min_interval_id, max_interval_id, duration string

		// Get values from row.
		err := rows.Scan(&cdate, &min_interval_id, &max_interval_id, &duration)
		if err != nil {
			return -1, err
		}

		fmt.Printf("%s %s %s %s\n", cdate, min_interval_id, max_interval_id, duration)
		count++
	}

	return count, nil
}

// Read Snapshot Date
func printIntervalsForDate(pIntervalDate string) (int, error) {

	listIntervalsText := fmt.Sprintf("\x1b[%dm%s\x1b[0m", 34, "Query Store Intervals for: "+pIntervalDate)
	fmt.Println(listIntervalsText)

	ctx := context.Background()

	// Check if database is alive.
	err := db.PingContext(ctx)
	if err != nil {
		return -1, err
	}

	printCurrentDBContext()

	fmt.Printf("\n")

	fmt.Printf("-------------------------------------------------------------------------------------------\n")
	fmt.Printf("Start Time               End Time                 Max Interval ID     SQL Duration(minutes)\n")
	fmt.Printf("-------------------------------------------------------------------------------------------\n")

	var tsql string = fmt.Sprintf(`SELECT
							CAST(CONVERT(VARCHAR(16), rsi.start_time,120) AS CHAR(24)) start_time,
							CAST(CONVERT(VARCHAR(16), rsi.end_time,120) AS CHAR(24)) end_time,
							CAST(MAX(rsi.runtime_stats_interval_id) as CHAR(18)) max_interval_id,
							RIGHT(REPLICATE(' ',16)+CAST(round(sum(isnull(count_executions,0)*isnull(avg_duration,0))/1000000/60,0) as VARCHAR(16)),16) duration
						FROM sys.query_store_runtime_stats_interval rsi
						LEFT JOIN sys.query_store_runtime_stats rs on rsi.runtime_stats_interval_id = rs.runtime_stats_interval_id
						WHERE rsi.end_time > CAST( (@intervalDateString) as DATETIME) AND rsi.start_time < DATEADD(day,1,CAST( (@intervalDateString) as DATETIME))
						GROUP BY CONVERT(VARCHAR(16), rsi.start_time,120), CONVERT(VARCHAR(16), rsi.end_time,120) ORDER BY 1;`)

	// Execute query
	rows, err := db.QueryContext(ctx, tsql, sql.Named("intervalDateString", pIntervalDate))
	if err != nil {
		return -1, err
	}

	defer rows.Close()

	var count int

	// Iterate through the result set.
	for rows.Next() {
		var start_time, end_time, max_interval_id, duration string

		// Get values from row.
		err := rows.Scan(&start_time, &end_time, &max_interval_id, &duration)
		if err != nil {
			return -1, err
		}

		fmt.Printf("%s %s %s %s\n", start_time, end_time, max_interval_id, duration)
		count++
	}

	return count, nil
}

func getIntervalIdsByRange(pDateTimeFromString string, pDateTimeToString string) (int, int, error) {

	var fromIntervalId int = 0
	var toIntervalId int = 0

	ctx := context.Background()

	// Check if database is alive.
	err := db.PingContext(ctx)
	if err != nil {
		return -1, -1, err
	}

	tsql_check_dates := `SELECT
			COUNT(1) is_valid 
			FROM (SELECT CAST(SUBSTRING(@dateTimeFromString,1,16) as DATETIME) dateFrom, CAST(SUBSTRING(@dateTimeToString,1,16) as DATETIME) dateTo) a 
			WHERE a.dateTo > a.dateFrom;`

	// Execute query
	rows_check_dates, err := db.QueryContext(ctx, tsql_check_dates, sql.Named("dateTimeFromString", pDateTimeFromString), sql.Named("dateTimeToString", pDateTimeToString))
	if err != nil {
		return -1, -1, err
	}

	defer rows_check_dates.Close()

	var checkDates int = 0

	// Iterate through the result set.
	for rows_check_dates.Next() {
		var is_valid int

		// Get values from row.
		err := rows_check_dates.Scan(&is_valid)
		if err != nil {
			return -1, -1, err
		}

		// fmt.Printf("%d\n", runtime_stats_interval_id)
		checkDates = is_valid
	}

	if checkDates == 0 {
		return -1, -1, fmt.Errorf("Invalid date range. Check date format (YYYY-MM-DD HH:MM). End Date must be greater than Start Date")
	} else {

		tsql_intervals := `SELECT
			COALESCE(min(runtime_stats_interval_id),0) min_interval_id,
			COALESCE(max(runtime_stats_interval_id),0) max_interval_id
			FROM
			(
				SELECT runtime_stats_interval_id
				FROM sys.query_store_runtime_stats_interval rsi
				WHERE rsi.start_time >= CAST(SUBSTRING(@dateTimeFromString,1,16) as DATETIME) 
					AND rsi.end_time < CAST(SUBSTRING(@dateTimeToString,1,16) as DATETIME)
				UNION
				SELECT runtime_stats_interval_id
				FROM sys.query_store_runtime_stats_interval rsi
				WHERE CAST(SUBSTRING(@dateTimeFromString,1,16) as DATETIME) >= rsi.start_time
				AND CAST(SUBSTRING(@dateTimeFromString,1,16) as DATETIME) < rsi.end_time
				UNION
				SELECT runtime_stats_interval_id
				FROM sys.query_store_runtime_stats_interval rsi
				WHERE CAST(SUBSTRING(@dateTimeToString,1,16) as DATETIME) > rsi.start_time
				AND CAST(SUBSTRING(@dateTimeToString,1,16) as DATETIME) <= rsi.end_time
			) a;`

		rows_intervals, err := db.QueryContext(ctx, tsql_intervals, sql.Named("dateTimeFromString", pDateTimeFromString), sql.Named("dateTimeToString", pDateTimeToString))
		if err != nil {
			return -1, -1, err
		}

		defer rows_intervals.Close()

		// Iterate through the result set.
		for rows_intervals.Next() {
			var min_interval_id int
			var max_interval_id int

			// Get values from row.
			err := rows_intervals.Scan(&min_interval_id, &max_interval_id)
			if err != nil {
				return -1, -1, err
			}

			fromIntervalId = min_interval_id
			toIntervalId = max_interval_id

			if fromIntervalId == 0 {
				return -1, -1, fmt.Errorf("No intervals found for the specified date range. Check available intervals from the main menu [l].")
			}
		}
	}

	return fromIntervalId, toIntervalId, err
}

func getExecutionPlanList(tr_start_interval_id int, tr_end_interval_id int) ([]int, error) {

	var err1, err2 error
	var count int
	var planArray []int

	ctx := context.Background()
	err1 = db.PingContext(ctx)

	// Check if database is alive.
	if err1 != nil {
		return nil, err1
	}

	stmtTop20PlanIDs := fmt.Sprintf(`SELECT TOP(20)
				rs.plan_id
			from sys.query_store_runtime_stats_interval rsi
			inner join sys.query_store_runtime_stats rs on rsi.runtime_stats_interval_id = rs.runtime_stats_interval_id
			inner join sys.query_store_plan p on rs.plan_id = p.plan_id
			inner join sys.query_store_query q on q.query_id = p.query_id
			where rsi.runtime_stats_interval_id >= @tr_start_interval_id and rsi.runtime_stats_interval_id <= @tr_end_interval_id
			group by rs.plan_id, p.query_plan_hash, q.query_id, q.query_hash
			order by round(sum(count_executions*avg_duration),0) desc;`)

	rows, err2 := db.QueryContext(ctx, stmtTop20PlanIDs, sql.Named("tr_start_interval_id", tr_start_interval_id), sql.Named("tr_end_interval_id", tr_end_interval_id))
	if err2 != nil {
		return nil, err2
	}

	defer rows.Close()

	// Iterate through the result set.
	for rows.Next() {
		var plan_id int

		// Get values from row.
		err := rows.Scan(&plan_id)
		if err != nil {
			return nil, err
		}

		count++
		planArray = append(planArray, plan_id)

	}

	return planArray, err2
}

func check(e error) {
	if e != nil {
		panic(e)
	}
}

// Generate Comparison Report by providing interval IDs
func generateComparisonReportByID(bl_start_interval_id int, bl_end_interval_id int, tr_start_interval_id int, tr_end_interval_id int) (string, error) {

	fmt.Println("Generating report ... ")

	headerFileContent, err := os.ReadFile("templates/mssql-xdbmonitoring-compare-header.html")
	if err != nil {
		fmt.Print(err)
	}

	footerFileContent, err := os.ReadFile("templates/mssql-xdbmonitoring-compare-footer.html")
	if err != nil {
		fmt.Print(err)
	}

	var fileName = fmt.Sprint("reports/mssql-xdbmo-compare-", database, "-", bl_start_interval_id, "-", bl_end_interval_id, "-vs-", tr_start_interval_id, "-", tr_end_interval_id, ".html")

	f := createFile(fileName)
	defer closeFile(f)

	n2, err := f.Write(headerFileContent)
	check(err)

	ctx := context.Background()

	// Check if database is alive.
	err1 := db.PingContext(ctx)
	if err1 != nil {
		return "", err1
	}

	stmtDbSummary := fmt.Sprintf(`SELECT CONCAT('+ "Period A,',@sqldbserver,',',@sqldbname,',',MIN(rsi.runtime_stats_interval_id),',',MAX(rsi.runtime_stats_interval_id),',',MIN(CONVERT(VARCHAR(16), start_time,120)),',',MAX(CONVERT(VARCHAR(16), end_time,120)),',',CONCAT(DATEDIFF(second, MIN(start_time), MAX(end_time))/60/60,' hour(s) ', DATEDIFF(second, DATEADD(second, (DATEDIFF(second, MIN(start_time), MAX(end_time))/60/60)*60*60, MIN(start_time)), MAX(end_time))/60, ' minute(s)'),'\n"') x from sys.query_store_runtime_stats_interval rsi where rsi.runtime_stats_interval_id >= @bl_start_interval_id and rsi.runtime_stats_interval_id <= @bl_end_interval_id union
		SELECT CONCAT('+ "Period B,',@sqldbserver,',',@sqldbname,',',MIN(rsi.runtime_stats_interval_id),',',MAX(rsi.runtime_stats_interval_id),',',MIN(CONVERT(VARCHAR(16), start_time,120)),',',MAX(CONVERT(VARCHAR(16), end_time,120)),',',CONCAT(DATEDIFF(second, MIN(start_time), MAX(end_time))/60/60,' hour(s) ', DATEDIFF(second, DATEADD(second, (DATEDIFF(second, MIN(start_time), MAX(end_time))/60/60)*60*60, MIN(start_time)), MAX(end_time))/60, ' minute(s)'),'\n"') x from sys.query_store_runtime_stats_interval rsi where rsi.runtime_stats_interval_id >= @tr_start_interval_id and rsi.runtime_stats_interval_id <= @tr_end_interval_id
		`)

	stmtSqlStatsTable := fmt.Sprintf(`with tr as (
		SELECT
			plan_id plan_id_t,
			query_plan_hash query_plan_hash_t,
			query_id query_id_t,
			query_hash query_hash_t,
			executions executions_t,
			duration duration_t,
			cpu_time cpu_time_t,
			logical_io_reads logical_io_reads_t,
			logical_io_writes logical_io_writes_t,
			physical_io_reads physical_io_reads_t,
			dop dop_t,
			query_max_used_memory query_max_used_memory_t,
			row_count row_count_t,
			num_physical_io_reads num_physical_io_reads_t,
			log_bytes_used log_bytes_used_t,
			tempdb_space_used tempdb_space_used_t,
			page_server_io_reads page_server_io_reads_t,
			IIF((duration - cpu_time)>0,(duration - cpu_time),0) wait_time_t,
			ROW_NUMBER() OVER (ORDER BY executions DESC) executions_r,
			ROW_NUMBER() OVER (ORDER BY duration DESC) duration_r,
			ROW_NUMBER() OVER (ORDER BY cpu_time DESC) cpu_time_r,
			ROW_NUMBER() OVER (ORDER BY logical_io_reads DESC) logical_io_reads_r,
			ROW_NUMBER() OVER (ORDER BY logical_io_writes DESC) logical_io_writes_r,
			ROW_NUMBER() OVER (ORDER BY physical_io_reads DESC) physical_io_reads_r,
			ROW_NUMBER() OVER (ORDER BY dop DESC) dop_r,
			ROW_NUMBER() OVER (ORDER BY query_max_used_memory DESC) query_max_used_memory_r,
			ROW_NUMBER() OVER (ORDER BY row_count DESC) row_count_r,
			ROW_NUMBER() OVER (ORDER BY num_physical_io_reads DESC) num_physical_io_reads_r,
			ROW_NUMBER() OVER (ORDER BY log_bytes_used DESC) log_bytes_used_r,
			ROW_NUMBER() OVER (ORDER BY tempdb_space_used DESC) tempdb_space_used_r,
			ROW_NUMBER() OVER (ORDER BY page_server_io_reads DESC) page_server_io_reads_r,
			ROW_NUMBER() OVER (ORDER BY IIF((duration - cpu_time)>0,(duration - cpu_time),0) DESC) wait_time_r,
			CAST(1. * executions / ISNULL(NULLIF(SUM(executions) OVER(),0),1) AS DECIMAL(5,2)) executions_s,
			CAST(1. * duration / ISNULL(NULLIF(SUM(duration) OVER(),0),1) AS DECIMAL(5,2)) duration_s,
			CAST(1. * cpu_time / ISNULL(NULLIF(SUM(cpu_time) OVER(),0),1) AS DECIMAL(5,2)) cpu_time_s,
			CAST(1. * logical_io_reads / ISNULL(NULLIF(SUM(logical_io_reads) OVER(),0),1) AS DECIMAL(5,2)) logical_io_reads_s,
			CAST(1. * logical_io_writes / ISNULL(NULLIF(SUM(logical_io_writes) OVER(),0),1) AS DECIMAL(5,2)) logical_io_writes_s,
			CAST(1. * physical_io_reads / ISNULL(NULLIF(SUM(physical_io_reads) OVER(),0),1) AS DECIMAL(5,2)) physical_io_reads_s,
			CAST(1. * dop / ISNULL(NULLIF(SUM(dop) OVER(),0),1) AS DECIMAL(5,2)) dop_s,
			CAST(1. * query_max_used_memory / ISNULL(NULLIF(SUM(query_max_used_memory) OVER(),0),1) AS DECIMAL(5,2)) query_max_used_memory_s,
			CAST(1. * row_count / ISNULL(NULLIF(SUM(row_count) OVER(),0),1) AS DECIMAL(5,2)) row_count_s,
			CAST(1. * num_physical_io_reads / ISNULL(NULLIF(SUM(num_physical_io_reads) OVER(),0),1) AS DECIMAL(5,2)) num_physical_io_reads_s,
			CAST(1. * log_bytes_used / ISNULL(NULLIF(SUM(log_bytes_used) OVER(),0),1) AS DECIMAL(5,2)) log_bytes_used_s,
			CAST(1. * tempdb_space_used / ISNULL(NULLIF(SUM(tempdb_space_used) OVER(),0),1) AS DECIMAL(5,2)) tempdb_space_used_s,
			CAST(1. * page_server_io_reads / ISNULL(NULLIF(SUM(page_server_io_reads) OVER(),0),1) AS DECIMAL(5,2)) page_server_io_reads_s,
			CAST(1. * IIF((duration - cpu_time)>0,(duration - cpu_time),0) / ISNULL(NULLIF(SUM(IIF((duration - cpu_time)>0,(duration - cpu_time),0)) OVER(),0),1) AS DECIMAL(5,2)) wait_time_s
			FROM
			(SELECT
				rs.plan_id,
				p.query_plan_hash,
				q.query_id,
				q.query_hash,
				sum(count_executions) executions, 
				round(sum(count_executions*avg_duration),0) duration, -- micro
				round(sum(count_executions*avg_cpu_time),0) cpu_time, -- micro
				round(sum(count_executions*avg_logical_io_reads),0) logical_io_reads, -- pages
				round(sum(count_executions*avg_logical_io_writes),0) logical_io_writes, -- pages
				round(sum(count_executions*avg_physical_io_reads),0) physical_io_reads, -- pages
				round(sum(count_executions*avg_dop),0) dop,
				round(sum(count_executions*avg_query_max_used_memory),0) query_max_used_memory, --pages
				round(sum(count_executions*avg_rowcount),0) row_count,
				round(sum(count_executions*avg_num_physical_io_reads),0) num_physical_io_reads,
				round(sum(count_executions*avg_log_bytes_used),0) log_bytes_used,
				round(sum(count_executions*avg_tempdb_space_used),0) tempdb_space_used,
				round(sum(count_executions*0),0) page_server_io_reads --avg_page_server_io_reads
			from sys.query_store_runtime_stats_interval rsi
			inner join sys.query_store_runtime_stats rs on rsi.runtime_stats_interval_id = rs.runtime_stats_interval_id
			inner join sys.query_store_plan p on rs.plan_id = p.plan_id
			inner join sys.query_store_query q on q.query_id = p.query_id
			where rsi.runtime_stats_interval_id >= @tr_start_interval_id and rsi.runtime_stats_interval_id <= @tr_end_interval_id
			group by rs.plan_id, p.query_plan_hash, q.query_id, q.query_hash) a
			)
			, br as (SELECT
			plan_id plan_id_b,
			query_plan_hash query_plan_hash_b,
			query_id query_id_b,
			query_hash query_hash_b,
			executions executions_b,
			duration duration_b,
			cpu_time cpu_time_b,
			logical_io_reads logical_io_reads_b,
			logical_io_writes logical_io_writes_b,
			physical_io_reads physical_io_reads_b,
			dop dop_b,
			query_max_used_memory query_max_used_memory_b,
			row_count row_count_b,
			num_physical_io_reads num_physical_io_reads_b,
			log_bytes_used log_bytes_used_b,
			tempdb_space_used tempdb_space_used_b,
			page_server_io_reads page_server_io_reads_b,
			IIF((duration - cpu_time)>0,(duration - cpu_time),0) wait_time_b
			FROM
			(SELECT
				rs.plan_id,
				p.query_plan_hash,
				q.query_id,
				q.query_hash,
				sum(count_executions) executions, 
				round(sum(count_executions*avg_duration),0) duration, -- micro
				round(sum(count_executions*avg_cpu_time),0) cpu_time, -- micro
				round(sum(count_executions*avg_logical_io_reads),0) logical_io_reads, -- pages
				round(sum(count_executions*avg_logical_io_writes),0) logical_io_writes, -- pages
				round(sum(count_executions*avg_physical_io_reads),0) physical_io_reads, -- pages
				round(sum(count_executions*avg_dop),0) dop,
				round(sum(count_executions*avg_query_max_used_memory),0) query_max_used_memory, --pages
				round(sum(count_executions*avg_rowcount),0) row_count,
				round(sum(count_executions*avg_num_physical_io_reads),0) num_physical_io_reads,
				round(sum(count_executions*avg_log_bytes_used),0) log_bytes_used,
				round(sum(count_executions*avg_tempdb_space_used),0) tempdb_space_used,
				round(sum(count_executions*0),0) page_server_io_reads --avg_page_server_io_reads
			from sys.query_store_runtime_stats_interval rsi
			inner join sys.query_store_runtime_stats rs on rsi.runtime_stats_interval_id = rs.runtime_stats_interval_id
			inner join sys.query_store_plan p on rs.plan_id = p.plan_id
			inner join sys.query_store_query q on q.query_id = p.query_id
			where rsi.runtime_stats_interval_id >= @bl_start_interval_id and rsi.runtime_stats_interval_id <= @bl_end_interval_id
			group by rs.plan_id, p.query_plan_hash, q.query_id, q.query_hash) a)
			, s as (select 0x5C832E8F5E5D3655 query_hash, 'sqlAlias' sql_type)
			, x as (SELECT case when s.query_hash is not null then s.sql_type
				when s.query_hash is null and br.query_hash_b is null then '(+) New'
				else 'Unclassified' end sql_type
			, tr.*, br.*
			FROM tr
			LEFT JOIN s  ON tr.query_hash_t=s.query_hash
			LEFT JOIN br ON tr.query_id_t=br.query_id_b AND tr.plan_id_t = br.plan_id_b)
			SELECT  CONCAT('+ "','EXECUTIONS,',executions_r,',',plan_id_t,',',CONVERT(VARCHAR(MAX), query_plan_hash_t, 1),',',query_id_t,',',CONVERT(VARCHAR(MAX), query_hash_t, 1),',',sql_type,','
			,executions_t,',',CAST(ROUND(duration_t/1000000,0) as BIGINT),',',CAST(ROUND(cpu_time_t/1000000,0) as BIGINT),',',CAST(ROUND(wait_time_t/1000000,0) as BIGINT),',',CAST(logical_io_reads_t as BIGINT),',',CAST(logical_io_writes_t as BIGINT),',',CAST(physical_io_reads_t as BIGINT),',',CAST(dop_t as BIGINT),',',CAST(query_max_used_memory_t as BIGINT),',',CAST(row_count_t as BIGINT),',',CAST(num_physical_io_reads_t as BIGINT),',',CAST(log_bytes_used_t as BIGINT),',',CAST(tempdb_space_used_t as BIGINT),',',CAST(page_server_io_reads_t as BIGINT),','
			,executions_b,',',CAST(ROUND(duration_b/1000000,0) as BIGINT),',',CAST(ROUND(cpu_time_b/1000000,0) as BIGINT),',',CAST(ROUND(wait_time_b/1000000,0) as BIGINT),',',CAST(logical_io_reads_b as BIGINT),',',CAST(logical_io_writes_b as BIGINT),',',CAST(physical_io_reads_b as BIGINT),',',CAST(dop_b as BIGINT),',',CAST(query_max_used_memory_b as BIGINT),',',CAST(row_count_b as BIGINT),',',CAST(num_physical_io_reads_b as BIGINT),',',CAST(log_bytes_used_b as BIGINT),',',CAST(tempdb_space_used_b as BIGINT),',',CAST(page_server_io_reads_b as BIGINT),','
			,executions_s,',',duration_s,',',cpu_time_s,',',wait_time_s,',',logical_io_reads_s,',',logical_io_writes_s,',',physical_io_reads_s,',',dop_s,',',query_max_used_memory_s,',',row_count_s,',',num_physical_io_reads_s,',',log_bytes_used_s,',',tempdb_space_used_s,',',page_server_io_reads_s,'\n"') from x where executions_r<=20 union
			SELECT  CONCAT('+ "','DURATION,',duration_r,',',plan_id_t,',',CONVERT(VARCHAR(MAX), query_plan_hash_t, 1),',',query_id_t,',',CONVERT(VARCHAR(MAX), query_hash_t, 1),',',sql_type,','
			,executions_t,',',CAST(ROUND(duration_t/1000000,0) as BIGINT),',',CAST(ROUND(cpu_time_t/1000000,0) as BIGINT),',',CAST(ROUND(wait_time_t/1000000,0) as BIGINT),',',CAST(logical_io_reads_t as BIGINT),',',CAST(logical_io_writes_t as BIGINT),',',CAST(physical_io_reads_t as BIGINT),',',CAST(dop_t as BIGINT),',',CAST(query_max_used_memory_t as BIGINT),',',CAST(row_count_t as BIGINT),',',CAST(num_physical_io_reads_t as BIGINT),',',CAST(log_bytes_used_t as BIGINT),',',CAST(tempdb_space_used_t as BIGINT),',',CAST(page_server_io_reads_t as BIGINT),','
			,executions_b,',',CAST(ROUND(duration_b/1000000,0) as BIGINT),',',CAST(ROUND(cpu_time_b/1000000,0) as BIGINT),',',CAST(ROUND(wait_time_b/1000000,0) as BIGINT),',',CAST(logical_io_reads_b as BIGINT),',',CAST(logical_io_writes_b as BIGINT),',',CAST(physical_io_reads_b as BIGINT),',',CAST(dop_b as BIGINT),',',CAST(query_max_used_memory_b as BIGINT),',',CAST(row_count_b as BIGINT),',',CAST(num_physical_io_reads_b as BIGINT),',',CAST(log_bytes_used_b as BIGINT),',',CAST(tempdb_space_used_b as BIGINT),',',CAST(page_server_io_reads_b as BIGINT),','
			,executions_s,',',duration_s,',',cpu_time_s,',',wait_time_s,',',logical_io_reads_s,',',logical_io_writes_s,',',physical_io_reads_s,',',dop_s,',',query_max_used_memory_s,',',row_count_s,',',num_physical_io_reads_s,',',log_bytes_used_s,',',tempdb_space_used_s,',',page_server_io_reads_s,'\n"') from x where duration_r<=20 union
			SELECT  CONCAT('+ "','CPU_TIME,',cpu_time_r,',',plan_id_t,',',CONVERT(VARCHAR(MAX), query_plan_hash_t, 1),',',query_id_t,',',CONVERT(VARCHAR(MAX), query_hash_t, 1),',',sql_type,','
			,executions_t,',',CAST(ROUND(duration_t/1000000,0) as BIGINT),',',CAST(ROUND(cpu_time_t/1000000,0) as BIGINT),',',CAST(ROUND(wait_time_t/1000000,0) as BIGINT),',',CAST(logical_io_reads_t as BIGINT),',',CAST(logical_io_writes_t as BIGINT),',',CAST(physical_io_reads_t as BIGINT),',',CAST(dop_t as BIGINT),',',CAST(query_max_used_memory_t as BIGINT),',',CAST(row_count_t as BIGINT),',',CAST(num_physical_io_reads_t as BIGINT),',',CAST(log_bytes_used_t as BIGINT),',',CAST(tempdb_space_used_t as BIGINT),',',CAST(page_server_io_reads_t as BIGINT),','
			,executions_b,',',CAST(ROUND(duration_b/1000000,0) as BIGINT),',',CAST(ROUND(cpu_time_b/1000000,0) as BIGINT),',',CAST(ROUND(wait_time_b/1000000,0) as BIGINT),',',CAST(logical_io_reads_b as BIGINT),',',CAST(logical_io_writes_b as BIGINT),',',CAST(physical_io_reads_b as BIGINT),',',CAST(dop_b as BIGINT),',',CAST(query_max_used_memory_b as BIGINT),',',CAST(row_count_b as BIGINT),',',CAST(num_physical_io_reads_b as BIGINT),',',CAST(log_bytes_used_b as BIGINT),',',CAST(tempdb_space_used_b as BIGINT),',',CAST(page_server_io_reads_b as BIGINT),','
			,executions_s,',',duration_s,',',cpu_time_s,',',wait_time_s,',',logical_io_reads_s,',',logical_io_writes_s,',',physical_io_reads_s,',',dop_s,',',query_max_used_memory_s,',',row_count_s,',',num_physical_io_reads_s,',',log_bytes_used_s,',',tempdb_space_used_s,',',page_server_io_reads_s,'\n"') from x where cpu_time_r<=20 union
			SELECT  CONCAT('+ "','WAIT_TIME,',wait_time_r,',',plan_id_t,',',CONVERT(VARCHAR(MAX), query_plan_hash_t, 1),',',query_id_t,',',CONVERT(VARCHAR(MAX), query_hash_t, 1),',',sql_type,','
			,executions_t,',',CAST(ROUND(duration_t/1000000,0) as BIGINT),',',CAST(ROUND(cpu_time_t/1000000,0) as BIGINT),',',CAST(ROUND(wait_time_t/1000000,0) as BIGINT),',',CAST(logical_io_reads_t as BIGINT),',',CAST(logical_io_writes_t as BIGINT),',',CAST(physical_io_reads_t as BIGINT),',',CAST(dop_t as BIGINT),',',CAST(query_max_used_memory_t as BIGINT),',',CAST(row_count_t as BIGINT),',',CAST(num_physical_io_reads_t as BIGINT),',',CAST(log_bytes_used_t as BIGINT),',',CAST(tempdb_space_used_t as BIGINT),',',CAST(page_server_io_reads_t as BIGINT),','
			,executions_b,',',CAST(ROUND(duration_b/1000000,0) as BIGINT),',',CAST(ROUND(cpu_time_b/1000000,0) as BIGINT),',',CAST(ROUND(wait_time_b/1000000,0) as BIGINT),',',CAST(logical_io_reads_b as BIGINT),',',CAST(logical_io_writes_b as BIGINT),',',CAST(physical_io_reads_b as BIGINT),',',CAST(dop_b as BIGINT),',',CAST(query_max_used_memory_b as BIGINT),',',CAST(row_count_b as BIGINT),',',CAST(num_physical_io_reads_b as BIGINT),',',CAST(log_bytes_used_b as BIGINT),',',CAST(tempdb_space_used_b as BIGINT),',',CAST(page_server_io_reads_b as BIGINT),','
			,executions_s,',',duration_s,',',cpu_time_s,',',wait_time_s,',',logical_io_reads_s,',',logical_io_writes_s,',',physical_io_reads_s,',',dop_s,',',query_max_used_memory_s,',',row_count_s,',',num_physical_io_reads_s,',',log_bytes_used_s,',',tempdb_space_used_s,',',page_server_io_reads_s,'\n"') from x where wait_time_r<=20 union
			SELECT  CONCAT('+ "','LOGICAL_IO_READS,',logical_io_reads_r,',',plan_id_t,',',CONVERT(VARCHAR(MAX), query_plan_hash_t, 1),',',query_id_t,',',CONVERT(VARCHAR(MAX), query_hash_t, 1),',',sql_type,','
			,executions_t,',',CAST(ROUND(duration_t/1000000,0) as BIGINT),',',CAST(ROUND(cpu_time_t/1000000,0) as BIGINT),',',CAST(ROUND(wait_time_t/1000000,0) as BIGINT),',',CAST(logical_io_reads_t as BIGINT),',',CAST(logical_io_writes_t as BIGINT),',',CAST(physical_io_reads_t as BIGINT),',',CAST(dop_t as BIGINT),',',CAST(query_max_used_memory_t as BIGINT),',',CAST(row_count_t as BIGINT),',',CAST(num_physical_io_reads_t as BIGINT),',',CAST(log_bytes_used_t as BIGINT),',',CAST(tempdb_space_used_t as BIGINT),',',CAST(page_server_io_reads_t as BIGINT),','
			,executions_b,',',CAST(ROUND(duration_b/1000000,0) as BIGINT),',',CAST(ROUND(cpu_time_b/1000000,0) as BIGINT),',',CAST(ROUND(wait_time_b/1000000,0) as BIGINT),',',CAST(logical_io_reads_b as BIGINT),',',CAST(logical_io_writes_b as BIGINT),',',CAST(physical_io_reads_b as BIGINT),',',CAST(dop_b as BIGINT),',',CAST(query_max_used_memory_b as BIGINT),',',CAST(row_count_b as BIGINT),',',CAST(num_physical_io_reads_b as BIGINT),',',CAST(log_bytes_used_b as BIGINT),',',CAST(tempdb_space_used_b as BIGINT),',',CAST(page_server_io_reads_b as BIGINT),','
			,executions_s,',',duration_s,',',cpu_time_s,',',wait_time_s,',',logical_io_reads_s,',',logical_io_writes_s,',',physical_io_reads_s,',',dop_s,',',query_max_used_memory_s,',',row_count_s,',',num_physical_io_reads_s,',',log_bytes_used_s,',',tempdb_space_used_s,',',page_server_io_reads_s,'\n"') from x where logical_io_reads_r<=20 union
			SELECT  CONCAT('+ "','LOGICAL_IO_WRITES,',logical_io_writes_r,',',plan_id_t,',',CONVERT(VARCHAR(MAX), query_plan_hash_t, 1),',',query_id_t,',',CONVERT(VARCHAR(MAX), query_hash_t, 1),',',sql_type,','
			,executions_t,',',CAST(ROUND(duration_t/1000000,0) as BIGINT),',',CAST(ROUND(cpu_time_t/1000000,0) as BIGINT),',',CAST(ROUND(wait_time_t/1000000,0) as BIGINT),',',CAST(logical_io_reads_t as BIGINT),',',CAST(logical_io_writes_t as BIGINT),',',CAST(physical_io_reads_t as BIGINT),',',CAST(dop_t as BIGINT),',',CAST(query_max_used_memory_t as BIGINT),',',CAST(row_count_t as BIGINT),',',CAST(num_physical_io_reads_t as BIGINT),',',CAST(log_bytes_used_t as BIGINT),',',CAST(tempdb_space_used_t as BIGINT),',',CAST(page_server_io_reads_t as BIGINT),','
			,executions_b,',',CAST(ROUND(duration_b/1000000,0) as BIGINT),',',CAST(ROUND(cpu_time_b/1000000,0) as BIGINT),',',CAST(ROUND(wait_time_b/1000000,0) as BIGINT),',',CAST(logical_io_reads_b as BIGINT),',',CAST(logical_io_writes_b as BIGINT),',',CAST(physical_io_reads_b as BIGINT),',',CAST(dop_b as BIGINT),',',CAST(query_max_used_memory_b as BIGINT),',',CAST(row_count_b as BIGINT),',',CAST(num_physical_io_reads_b as BIGINT),',',CAST(log_bytes_used_b as BIGINT),',',CAST(tempdb_space_used_b as BIGINT),',',CAST(page_server_io_reads_b as BIGINT),','
			,executions_s,',',duration_s,',',cpu_time_s,',',wait_time_s,',',logical_io_reads_s,',',logical_io_writes_s,',',physical_io_reads_s,',',dop_s,',',query_max_used_memory_s,',',row_count_s,',',num_physical_io_reads_s,',',log_bytes_used_s,',',tempdb_space_used_s,',',page_server_io_reads_s,'\n"') from x where logical_io_writes_r<=20 union
			SELECT  CONCAT('+ "','PHYSICAL_IO_READS,',physical_io_reads_r,',',plan_id_t,',',CONVERT(VARCHAR(MAX), query_plan_hash_t, 1),',',query_id_t,',',CONVERT(VARCHAR(MAX), query_hash_t, 1),',',sql_type,','
			,executions_t,',',CAST(ROUND(duration_t/1000000,0) as BIGINT),',',CAST(ROUND(cpu_time_t/1000000,0) as BIGINT),',',CAST(ROUND(wait_time_t/1000000,0) as BIGINT),',',CAST(logical_io_reads_t as BIGINT),',',CAST(logical_io_writes_t as BIGINT),',',CAST(physical_io_reads_t as BIGINT),',',CAST(dop_t as BIGINT),',',CAST(query_max_used_memory_t as BIGINT),',',CAST(row_count_t as BIGINT),',',CAST(num_physical_io_reads_t as BIGINT),',',CAST(log_bytes_used_t as BIGINT),',',CAST(tempdb_space_used_t as BIGINT),',',CAST(page_server_io_reads_t as BIGINT),','
			,executions_b,',',CAST(ROUND(duration_b/1000000,0) as BIGINT),',',CAST(ROUND(cpu_time_b/1000000,0) as BIGINT),',',CAST(ROUND(wait_time_b/1000000,0) as BIGINT),',',CAST(logical_io_reads_b as BIGINT),',',CAST(logical_io_writes_b as BIGINT),',',CAST(physical_io_reads_b as BIGINT),',',CAST(dop_b as BIGINT),',',CAST(query_max_used_memory_b as BIGINT),',',CAST(row_count_b as BIGINT),',',CAST(num_physical_io_reads_b as BIGINT),',',CAST(log_bytes_used_b as BIGINT),',',CAST(tempdb_space_used_b as BIGINT),',',CAST(page_server_io_reads_b as BIGINT),','
			,executions_s,',',duration_s,',',cpu_time_s,',',wait_time_s,',',logical_io_reads_s,',',logical_io_writes_s,',',physical_io_reads_s,',',dop_s,',',query_max_used_memory_s,',',row_count_s,',',num_physical_io_reads_s,',',log_bytes_used_s,',',tempdb_space_used_s,',',page_server_io_reads_s,'\n"') from x where physical_io_reads_r<=20 union
			SELECT  CONCAT('+ "','DOP,',dop_r,',',plan_id_t,',',CONVERT(VARCHAR(MAX), query_plan_hash_t, 1),',',query_id_t,',',CONVERT(VARCHAR(MAX), query_hash_t, 1),',',sql_type,','
			,executions_t,',',CAST(ROUND(duration_t/1000000,0) as BIGINT),',',CAST(ROUND(cpu_time_t/1000000,0) as BIGINT),',',CAST(ROUND(wait_time_t/1000000,0) as BIGINT),',',CAST(logical_io_reads_t as BIGINT),',',CAST(logical_io_writes_t as BIGINT),',',CAST(physical_io_reads_t as BIGINT),',',CAST(dop_t as BIGINT),',',CAST(query_max_used_memory_t as BIGINT),',',CAST(row_count_t as BIGINT),',',CAST(num_physical_io_reads_t as BIGINT),',',CAST(log_bytes_used_t as BIGINT),',',CAST(tempdb_space_used_t as BIGINT),',',CAST(page_server_io_reads_t as BIGINT),','
			,executions_b,',',CAST(ROUND(duration_b/1000000,0) as BIGINT),',',CAST(ROUND(cpu_time_b/1000000,0) as BIGINT),',',CAST(ROUND(wait_time_b/1000000,0) as BIGINT),',',CAST(logical_io_reads_b as BIGINT),',',CAST(logical_io_writes_b as BIGINT),',',CAST(physical_io_reads_b as BIGINT),',',CAST(dop_b as BIGINT),',',CAST(query_max_used_memory_b as BIGINT),',',CAST(row_count_b as BIGINT),',',CAST(num_physical_io_reads_b as BIGINT),',',CAST(log_bytes_used_b as BIGINT),',',CAST(tempdb_space_used_b as BIGINT),',',CAST(page_server_io_reads_b as BIGINT),','
			,executions_s,',',duration_s,',',cpu_time_s,',',wait_time_s,',',logical_io_reads_s,',',logical_io_writes_s,',',physical_io_reads_s,',',dop_s,',',query_max_used_memory_s,',',row_count_s,',',num_physical_io_reads_s,',',log_bytes_used_s,',',tempdb_space_used_s,',',page_server_io_reads_s,'\n"') from x where dop_r<=20 union
			SELECT  CONCAT('+ "','QUERY_MAX_USED_MEMORY,',query_max_used_memory_r,',',plan_id_t,',',CONVERT(VARCHAR(MAX), query_plan_hash_t, 1),',',query_id_t,',',CONVERT(VARCHAR(MAX), query_hash_t, 1),',',sql_type,','
			,executions_t,',',CAST(ROUND(duration_t/1000000,0) as BIGINT),',',CAST(ROUND(cpu_time_t/1000000,0) as BIGINT),',',CAST(ROUND(wait_time_t/1000000,0) as BIGINT),',',CAST(logical_io_reads_t as BIGINT),',',CAST(logical_io_writes_t as BIGINT),',',CAST(physical_io_reads_t as BIGINT),',',CAST(dop_t as BIGINT),',',CAST(query_max_used_memory_t as BIGINT),',',CAST(row_count_t as BIGINT),',',CAST(num_physical_io_reads_t as BIGINT),',',CAST(log_bytes_used_t as BIGINT),',',CAST(tempdb_space_used_t as BIGINT),',',CAST(page_server_io_reads_t as BIGINT),','
			,executions_b,',',CAST(ROUND(duration_b/1000000,0) as BIGINT),',',CAST(ROUND(cpu_time_b/1000000,0) as BIGINT),',',CAST(ROUND(wait_time_b/1000000,0) as BIGINT),',',CAST(logical_io_reads_b as BIGINT),',',CAST(logical_io_writes_b as BIGINT),',',CAST(physical_io_reads_b as BIGINT),',',CAST(dop_b as BIGINT),',',CAST(query_max_used_memory_b as BIGINT),',',CAST(row_count_b as BIGINT),',',CAST(num_physical_io_reads_b as BIGINT),',',CAST(log_bytes_used_b as BIGINT),',',CAST(tempdb_space_used_b as BIGINT),',',CAST(page_server_io_reads_b as BIGINT),','
			,executions_s,',',duration_s,',',cpu_time_s,',',wait_time_s,',',logical_io_reads_s,',',logical_io_writes_s,',',physical_io_reads_s,',',dop_s,',',query_max_used_memory_s,',',row_count_s,',',num_physical_io_reads_s,',',log_bytes_used_s,',',tempdb_space_used_s,',',page_server_io_reads_s,'\n"') from x where query_max_used_memory_r<=20 union
			SELECT  CONCAT('+ "','ROW_COUNT,',row_count_r,',',plan_id_t,',',CONVERT(VARCHAR(MAX), query_plan_hash_t, 1),',',query_id_t,',',CONVERT(VARCHAR(MAX), query_hash_t, 1),',',sql_type,','
			,executions_t,',',CAST(ROUND(duration_t/1000000,0) as BIGINT),',',CAST(ROUND(cpu_time_t/1000000,0) as BIGINT),',',CAST(ROUND(wait_time_t/1000000,0) as BIGINT),',',CAST(logical_io_reads_t as BIGINT),',',CAST(logical_io_writes_t as BIGINT),',',CAST(physical_io_reads_t as BIGINT),',',CAST(dop_t as BIGINT),',',CAST(query_max_used_memory_t as BIGINT),',',CAST(row_count_t as BIGINT),',',CAST(num_physical_io_reads_t as BIGINT),',',CAST(log_bytes_used_t as BIGINT),',',CAST(tempdb_space_used_t as BIGINT),',',CAST(page_server_io_reads_t as BIGINT),','
			,executions_b,',',CAST(ROUND(duration_b/1000000,0) as BIGINT),',',CAST(ROUND(cpu_time_b/1000000,0) as BIGINT),',',CAST(ROUND(wait_time_b/1000000,0) as BIGINT),',',CAST(logical_io_reads_b as BIGINT),',',CAST(logical_io_writes_b as BIGINT),',',CAST(physical_io_reads_b as BIGINT),',',CAST(dop_b as BIGINT),',',CAST(query_max_used_memory_b as BIGINT),',',CAST(row_count_b as BIGINT),',',CAST(num_physical_io_reads_b as BIGINT),',',CAST(log_bytes_used_b as BIGINT),',',CAST(tempdb_space_used_b as BIGINT),',',CAST(page_server_io_reads_b as BIGINT),','
			,executions_s,',',duration_s,',',cpu_time_s,',',wait_time_s,',',logical_io_reads_s,',',logical_io_writes_s,',',physical_io_reads_s,',',dop_s,',',query_max_used_memory_s,',',row_count_s,',',num_physical_io_reads_s,',',log_bytes_used_s,',',tempdb_space_used_s,',',page_server_io_reads_s,'\n"') from x where row_count_r<=20 union
			SELECT  CONCAT('+ "','NUM_PHYSICAL_IO_READS,',num_physical_io_reads_r,',',plan_id_t,',',CONVERT(VARCHAR(MAX), query_plan_hash_t, 1),',',query_id_t,',',CONVERT(VARCHAR(MAX), query_hash_t, 1),',',sql_type,','
			,executions_t,',',CAST(ROUND(duration_t/1000000,0) as BIGINT),',',CAST(ROUND(cpu_time_t/1000000,0) as BIGINT),',',CAST(ROUND(wait_time_t/1000000,0) as BIGINT),',',CAST(logical_io_reads_t as BIGINT),',',CAST(logical_io_writes_t as BIGINT),',',CAST(physical_io_reads_t as BIGINT),',',CAST(dop_t as BIGINT),',',CAST(query_max_used_memory_t as BIGINT),',',CAST(row_count_t as BIGINT),',',CAST(num_physical_io_reads_t as BIGINT),',',CAST(log_bytes_used_t as BIGINT),',',CAST(tempdb_space_used_t as BIGINT),',',CAST(page_server_io_reads_t as BIGINT),','
			,executions_b,',',CAST(ROUND(duration_b/1000000,0) as BIGINT),',',CAST(ROUND(cpu_time_b/1000000,0) as BIGINT),',',CAST(ROUND(wait_time_b/1000000,0) as BIGINT),',',CAST(logical_io_reads_b as BIGINT),',',CAST(logical_io_writes_b as BIGINT),',',CAST(physical_io_reads_b as BIGINT),',',CAST(dop_b as BIGINT),',',CAST(query_max_used_memory_b as BIGINT),',',CAST(row_count_b as BIGINT),',',CAST(num_physical_io_reads_b as BIGINT),',',CAST(log_bytes_used_b as BIGINT),',',CAST(tempdb_space_used_b as BIGINT),',',CAST(page_server_io_reads_b as BIGINT),','
			,executions_s,',',duration_s,',',cpu_time_s,',',wait_time_s,',',logical_io_reads_s,',',logical_io_writes_s,',',physical_io_reads_s,',',dop_s,',',query_max_used_memory_s,',',row_count_s,',',num_physical_io_reads_s,',',log_bytes_used_s,',',tempdb_space_used_s,',',page_server_io_reads_s,'\n"') from x where num_physical_io_reads_r<=20 union
			SELECT  CONCAT('+ "','LOG_BYTES_USED,',log_bytes_used_r,',',plan_id_t,',',CONVERT(VARCHAR(MAX), query_plan_hash_t, 1),',',query_id_t,',',CONVERT(VARCHAR(MAX), query_hash_t, 1),',',sql_type,','
			,executions_t,',',CAST(ROUND(duration_t/1000000,0) as BIGINT),',',CAST(ROUND(cpu_time_t/1000000,0) as BIGINT),',',CAST(ROUND(wait_time_t/1000000,0) as BIGINT),',',CAST(logical_io_reads_t as BIGINT),',',CAST(logical_io_writes_t as BIGINT),',',CAST(physical_io_reads_t as BIGINT),',',CAST(dop_t as BIGINT),',',CAST(query_max_used_memory_t as BIGINT),',',CAST(row_count_t as BIGINT),',',CAST(num_physical_io_reads_t as BIGINT),',',CAST(log_bytes_used_t as BIGINT),',',CAST(tempdb_space_used_t as BIGINT),',',CAST(page_server_io_reads_t as BIGINT),','
			,executions_b,',',CAST(ROUND(duration_b/1000000,0) as BIGINT),',',CAST(ROUND(cpu_time_b/1000000,0) as BIGINT),',',CAST(ROUND(wait_time_b/1000000,0) as BIGINT),',',CAST(logical_io_reads_b as BIGINT),',',CAST(logical_io_writes_b as BIGINT),',',CAST(physical_io_reads_b as BIGINT),',',CAST(dop_b as BIGINT),',',CAST(query_max_used_memory_b as BIGINT),',',CAST(row_count_b as BIGINT),',',CAST(num_physical_io_reads_b as BIGINT),',',CAST(log_bytes_used_b as BIGINT),',',CAST(tempdb_space_used_b as BIGINT),',',CAST(page_server_io_reads_b as BIGINT),','
			,executions_s,',',duration_s,',',cpu_time_s,',',wait_time_s,',',logical_io_reads_s,',',logical_io_writes_s,',',physical_io_reads_s,',',dop_s,',',query_max_used_memory_s,',',row_count_s,',',num_physical_io_reads_s,',',log_bytes_used_s,',',tempdb_space_used_s,',',page_server_io_reads_s,'\n"') from x where log_bytes_used_r<=20 union
			SELECT  CONCAT('+ "','TEMPDB_SPACE_USED,',tempdb_space_used_r,',',plan_id_t,',',CONVERT(VARCHAR(MAX), query_plan_hash_t, 1),',',query_id_t,',',CONVERT(VARCHAR(MAX), query_hash_t, 1),',',sql_type,','
			,executions_t,',',CAST(ROUND(duration_t/1000000,0) as BIGINT),',',CAST(ROUND(cpu_time_t/1000000,0) as BIGINT),',',CAST(ROUND(wait_time_t/1000000,0) as BIGINT),',',CAST(logical_io_reads_t as BIGINT),',',CAST(logical_io_writes_t as BIGINT),',',CAST(physical_io_reads_t as BIGINT),',',CAST(dop_t as BIGINT),',',CAST(query_max_used_memory_t as BIGINT),',',CAST(row_count_t as BIGINT),',',CAST(num_physical_io_reads_t as BIGINT),',',CAST(log_bytes_used_t as BIGINT),',',CAST(tempdb_space_used_t as BIGINT),',',CAST(page_server_io_reads_t as BIGINT),','
			,executions_b,',',CAST(ROUND(duration_b/1000000,0) as BIGINT),',',CAST(ROUND(cpu_time_b/1000000,0) as BIGINT),',',CAST(ROUND(wait_time_b/1000000,0) as BIGINT),',',CAST(logical_io_reads_b as BIGINT),',',CAST(logical_io_writes_b as BIGINT),',',CAST(physical_io_reads_b as BIGINT),',',CAST(dop_b as BIGINT),',',CAST(query_max_used_memory_b as BIGINT),',',CAST(row_count_b as BIGINT),',',CAST(num_physical_io_reads_b as BIGINT),',',CAST(log_bytes_used_b as BIGINT),',',CAST(tempdb_space_used_b as BIGINT),',',CAST(page_server_io_reads_b as BIGINT),','
			,executions_s,',',duration_s,',',cpu_time_s,',',wait_time_s,',',logical_io_reads_s,',',logical_io_writes_s,',',physical_io_reads_s,',',dop_s,',',query_max_used_memory_s,',',row_count_s,',',num_physical_io_reads_s,',',log_bytes_used_s,',',tempdb_space_used_s,',',page_server_io_reads_s,'\n"') from x where tempdb_space_used_r<=20 union
			SELECT  CONCAT('+ "','PAGE_SERVER_IO_READS,',page_server_io_reads_r,',',plan_id_t,',',CONVERT(VARCHAR(MAX), query_plan_hash_t, 1),',',query_id_t,',',CONVERT(VARCHAR(MAX), query_hash_t, 1),',',sql_type,','
			,executions_t,',',CAST(ROUND(duration_t/1000000,0) as BIGINT),',',CAST(ROUND(cpu_time_t/1000000,0) as BIGINT),',',CAST(ROUND(wait_time_t/1000000,0) as BIGINT),',',CAST(logical_io_reads_t as BIGINT),',',CAST(logical_io_writes_t as BIGINT),',',CAST(physical_io_reads_t as BIGINT),',',CAST(dop_t as BIGINT),',',CAST(query_max_used_memory_t as BIGINT),',',CAST(row_count_t as BIGINT),',',CAST(num_physical_io_reads_t as BIGINT),',',CAST(log_bytes_used_t as BIGINT),',',CAST(tempdb_space_used_t as BIGINT),',',CAST(page_server_io_reads_t as BIGINT),','
			,executions_b,',',CAST(ROUND(duration_b/1000000,0) as BIGINT),',',CAST(ROUND(cpu_time_b/1000000,0) as BIGINT),',',CAST(ROUND(wait_time_b/1000000,0) as BIGINT),',',CAST(logical_io_reads_b as BIGINT),',',CAST(logical_io_writes_b as BIGINT),',',CAST(physical_io_reads_b as BIGINT),',',CAST(dop_b as BIGINT),',',CAST(query_max_used_memory_b as BIGINT),',',CAST(row_count_b as BIGINT),',',CAST(num_physical_io_reads_b as BIGINT),',',CAST(log_bytes_used_b as BIGINT),',',CAST(tempdb_space_used_b as BIGINT),',',CAST(page_server_io_reads_b as BIGINT),','
			,executions_s,',',duration_s,',',cpu_time_s,',',wait_time_s,',',logical_io_reads_s,',',logical_io_writes_s,',',physical_io_reads_s,',',dop_s,',',query_max_used_memory_s,',',row_count_s,',',num_physical_io_reads_s,',',log_bytes_used_s,',',tempdb_space_used_s,',',page_server_io_reads_s,'\n"') from x where page_server_io_reads_r<=20
			`)

	stmtSqlStatsChart := fmt.Sprintf(`
	with tr as (
		SELECT
	plan_id plan_id_t,
	query_plan_hash query_plan_hash_t,
	query_id query_id_t,
	query_hash query_hash_t,
	executions executions_t,
	duration duration_t,
	cpu_time cpu_time_t,
	logical_io_reads logical_io_reads_t,
	logical_io_writes logical_io_writes_t,
	physical_io_reads physical_io_reads_t,
	dop dop_t,
	query_max_used_memory query_max_used_memory_t,
	row_count row_count_t,
	num_physical_io_reads num_physical_io_reads_t,
	log_bytes_used log_bytes_used_t,
	tempdb_space_used tempdb_space_used_t,
	page_server_io_reads page_server_io_reads_t,
	IIF((duration - cpu_time)>0,(duration - cpu_time),0) wait_time_t,
	ROW_NUMBER() OVER (ORDER BY executions DESC) executions_r,
	ROW_NUMBER() OVER (ORDER BY duration DESC) duration_r,
	ROW_NUMBER() OVER (ORDER BY cpu_time DESC) cpu_time_r,
	ROW_NUMBER() OVER (ORDER BY logical_io_reads DESC) logical_io_reads_r,
	ROW_NUMBER() OVER (ORDER BY logical_io_writes DESC) logical_io_writes_r,
	ROW_NUMBER() OVER (ORDER BY physical_io_reads DESC) physical_io_reads_r,
	ROW_NUMBER() OVER (ORDER BY dop DESC) dop_r,
	ROW_NUMBER() OVER (ORDER BY query_max_used_memory DESC) query_max_used_memory_r,
	ROW_NUMBER() OVER (ORDER BY row_count DESC) row_count_r,
	ROW_NUMBER() OVER (ORDER BY num_physical_io_reads DESC) num_physical_io_reads_r,
	ROW_NUMBER() OVER (ORDER BY log_bytes_used DESC) log_bytes_used_r,
	ROW_NUMBER() OVER (ORDER BY tempdb_space_used DESC) tempdb_space_used_r,
	ROW_NUMBER() OVER (ORDER BY page_server_io_reads DESC) page_server_io_reads_r,
	ROW_NUMBER() OVER (ORDER BY IIF((duration - cpu_time)>0,(duration - cpu_time),0) DESC) wait_time_r,
	CAST(1. * executions / ISNULL(NULLIF(SUM(executions) OVER(),0),1) AS DECIMAL(5,2)) executions_s,
	CAST(1. * duration / ISNULL(NULLIF(SUM(duration) OVER(),0),1) AS DECIMAL(5,2)) duration_s,
	CAST(1. * cpu_time / ISNULL(NULLIF(SUM(cpu_time) OVER(),0),1) AS DECIMAL(5,2)) cpu_time_s,
	CAST(1. * logical_io_reads / ISNULL(NULLIF(SUM(logical_io_reads) OVER(),0),1) AS DECIMAL(5,2)) logical_io_reads_s,
	CAST(1. * logical_io_writes / ISNULL(NULLIF(SUM(logical_io_writes) OVER(),0),1) AS DECIMAL(5,2)) logical_io_writes_s,
	CAST(1. * physical_io_reads / ISNULL(NULLIF(SUM(physical_io_reads) OVER(),0),1) AS DECIMAL(5,2)) physical_io_reads_s,
	CAST(1. * dop / ISNULL(NULLIF(SUM(dop) OVER(),0),1) AS DECIMAL(5,2)) dop_s,
	CAST(1. * query_max_used_memory / ISNULL(NULLIF(SUM(query_max_used_memory) OVER(),0),1) AS DECIMAL(5,2)) query_max_used_memory_s,
	CAST(1. * row_count / ISNULL(NULLIF(SUM(row_count) OVER(),0),1) AS DECIMAL(5,2)) row_count_s,
	CAST(1. * num_physical_io_reads / ISNULL(NULLIF(SUM(num_physical_io_reads) OVER(),0),1) AS DECIMAL(5,2)) num_physical_io_reads_s,
	CAST(1. * log_bytes_used / ISNULL(NULLIF(SUM(log_bytes_used) OVER(),0),1) AS DECIMAL(5,2)) log_bytes_used_s,
	CAST(1. * tempdb_space_used / ISNULL(NULLIF(SUM(tempdb_space_used) OVER(),0),1) AS DECIMAL(5,2)) tempdb_space_used_s,
	CAST(1. * page_server_io_reads / ISNULL(NULLIF(SUM(page_server_io_reads) OVER(),0),1) AS DECIMAL(5,2)) page_server_io_reads_s,
	CAST(1. * IIF((duration - cpu_time)>0,(duration - cpu_time),0) / ISNULL(NULLIF(SUM(IIF((duration - cpu_time)>0,(duration - cpu_time),0)) OVER(),0),1) AS DECIMAL(5,2)) wait_time_s
	FROM
	(SELECT
		rs.plan_id,
		p.query_plan_hash,
		q.query_id,
		q.query_hash,
		sum(count_executions) executions, 
		round(sum(count_executions*avg_duration),0) duration, -- micro
		round(sum(count_executions*avg_cpu_time),0) cpu_time, -- micro
		round(sum(count_executions*avg_logical_io_reads),0) logical_io_reads, -- pages
		round(sum(count_executions*avg_logical_io_writes),0) logical_io_writes, -- pages
		round(sum(count_executions*avg_physical_io_reads),0) physical_io_reads, -- pages
		round(sum(count_executions*avg_dop),0) dop,
		round(sum(count_executions*avg_query_max_used_memory),0) query_max_used_memory, --pages
		round(sum(count_executions*avg_rowcount),0) row_count,
		round(sum(count_executions*avg_num_physical_io_reads),0) num_physical_io_reads,
		round(sum(count_executions*avg_log_bytes_used),0) log_bytes_used,
		round(sum(count_executions*avg_tempdb_space_used),0) tempdb_space_used,
		round(sum(count_executions*0),0) page_server_io_reads --avg_page_server_io_reads
	from sys.query_store_runtime_stats_interval rsi
	inner join sys.query_store_runtime_stats rs on rsi.runtime_stats_interval_id = rs.runtime_stats_interval_id
	inner join sys.query_store_plan p on rs.plan_id = p.plan_id
	inner join sys.query_store_query q on q.query_id = p.query_id
	where rsi.runtime_stats_interval_id >= @tr_start_interval_id and rsi.runtime_stats_interval_id <= @tr_end_interval_id
	group by rs.plan_id, p.query_plan_hash, q.query_id, q.query_hash) a
	)
	, br as (SELECT
	plan_id plan_id_b,
	query_plan_hash query_plan_hash_b,
	query_id query_id_b,
	query_hash query_hash_b,
	executions executions_b,
	duration duration_b,
	cpu_time cpu_time_b,
	logical_io_reads logical_io_reads_b,
	logical_io_writes logical_io_writes_b,
	physical_io_reads physical_io_reads_b,
	dop dop_b,
	query_max_used_memory query_max_used_memory_b,
	row_count row_count_b,
	num_physical_io_reads num_physical_io_reads_b,
	log_bytes_used log_bytes_used_b,
	tempdb_space_used tempdb_space_used_b,
	page_server_io_reads page_server_io_reads_b,
	IIF((duration - cpu_time)>0,(duration - cpu_time),0) wait_time_b
	FROM
	(SELECT
		rs.plan_id,
		p.query_plan_hash,
		q.query_id,
		q.query_hash,
		sum(count_executions) executions, 
		round(sum(count_executions*avg_duration),0) duration, -- micro
		round(sum(count_executions*avg_cpu_time),0) cpu_time, -- micro
		round(sum(count_executions*avg_logical_io_reads),0) logical_io_reads, -- pages
		round(sum(count_executions*avg_logical_io_writes),0) logical_io_writes, -- pages
		round(sum(count_executions*avg_physical_io_reads),0) physical_io_reads, -- pages
		round(sum(count_executions*avg_dop),0) dop,
		round(sum(count_executions*avg_query_max_used_memory),0) query_max_used_memory, --pages
		round(sum(count_executions*avg_rowcount),0) row_count,
		round(sum(count_executions*avg_num_physical_io_reads),0) num_physical_io_reads,
		round(sum(count_executions*avg_log_bytes_used),0) log_bytes_used,
		round(sum(count_executions*avg_tempdb_space_used),0) tempdb_space_used,
		round(sum(count_executions*0),0) page_server_io_reads --avg_page_server_io_reads
	from sys.query_store_runtime_stats_interval rsi
	inner join sys.query_store_runtime_stats rs on rsi.runtime_stats_interval_id = rs.runtime_stats_interval_id
	inner join sys.query_store_plan p on rs.plan_id = p.plan_id
	inner join sys.query_store_query q on q.query_id = p.query_id
	where rsi.runtime_stats_interval_id >= @bl_start_interval_id and rsi.runtime_stats_interval_id <= @bl_end_interval_id
	group by rs.plan_id, p.query_plan_hash, q.query_id, q.query_hash) a)
	, s as (select 0x5C832E8F5E5D3655 query_hash, 'sqlAlias' sql_type)
	, x as (select
		case when br.query_hash_b is null then '0: New (+)'
		   when tr.query_hash_t is null then '0: Aged out (-)'
		   when s.query_hash is not null then s.sql_type
		   else '0: Unclassified' end sql_type
	, tr.*, br.*
	FROM tr
	LEFT JOIN s  ON tr.query_hash_t=s.query_hash
	LEFT JOIN br ON tr.query_id_t=br.query_id_b AND tr.plan_id_t = br.plan_id_b)
	SELECT CONCAT('+ "','SQL_TYPE,',sql_type,',',0,',',COUNT(1),'\n"') from x WHERE sql_type = '0: New (+)' GROUP BY sql_type UNION
	SELECT CONCAT('+ "','SQL_TYPE,',sql_type,',',COUNT(1),',',0,'\n"') from x WHERE sql_type = '0: Aged out (-)' GROUP BY sql_type UNION
	SELECT CONCAT('+ "','SQL_TYPE,',sql_type,',',COUNT(1),',',COUNT(1),'\n"') from x WHERE sql_type not in ('0: New (+)', '0: Aged out (-)') GROUP BY sql_type UNION
	SELECT CONCAT('+ "','EXECUTIONS,',sql_type,',',CAST(SUM(ISNULL(executions_b,0)) as BIGINT),',',CAST(SUM(ISNULL(executions_t,0)) as BIGINT),'\n"') from x GROUP BY sql_type UNION
	SELECT CONCAT('+ "','DURATION,',sql_type,',',CAST(ROUND(SUM(ISNULL(duration_b,0))/1000000,0) as BIGINT),',',CAST(ROUND(SUM(ISNULL(duration_t,0))/1000000,0) as BIGINT),'\n"') from x GROUP BY sql_type UNION
	SELECT CONCAT('+ "','CPU_TIME,',sql_type,',',CAST(ROUND(SUM(ISNULL(cpu_time_b,0))/1000000,0) as BIGINT),',',CAST(ROUND(SUM(ISNULL(cpu_time_t,0))/1000000,0) as BIGINT),'\n"') from x GROUP BY sql_type UNION
	SELECT CONCAT('+ "','WAIT_TIME,',sql_type,',',CAST(ROUND(SUM(ISNULL(wait_time_b,0))/1000000,0) as BIGINT),',',CAST(ROUND(SUM(ISNULL(wait_time_t,0))/1000000,0) as BIGINT),'\n"') from x GROUP BY sql_type UNION
	SELECT CONCAT('+ "','LOGICAL_IO_READS,',sql_type,',',CAST(SUM(ISNULL(logical_io_reads_b,0)) as BIGINT),',',CAST(SUM(ISNULL(logical_io_reads_t,0)) as BIGINT),'\n"') from x GROUP BY sql_type UNION
	SELECT CONCAT('+ "','LOGICAL_IO_WRITES,',sql_type,',',CAST(SUM(ISNULL(logical_io_writes_b,0)) as BIGINT),',',CAST(SUM(ISNULL(logical_io_writes_t,0)) as BIGINT),'\n"') from x GROUP BY sql_type UNION
	SELECT CONCAT('+ "','PHYSICAL_IO_READS,',sql_type,',',CAST(SUM(ISNULL(physical_io_reads_b,0)) as BIGINT),',',CAST(SUM(ISNULL(physical_io_reads_t,0)) as BIGINT),'\n"') from x GROUP BY sql_type UNION
	SELECT CONCAT('+ "','DOP,',sql_type,',',CAST(SUM(ISNULL(dop_b,0)) as BIGINT),',',CAST(SUM(ISNULL(dop_t,0)) as BIGINT),'\n"') from x GROUP BY sql_type UNION
	SELECT CONCAT('+ "','QUERY_MAX_USED_MEMORY,',sql_type,',',CAST(SUM(ISNULL(query_max_used_memory_b,0)) as BIGINT),',',CAST(SUM(ISNULL(query_max_used_memory_t,0)) as BIGINT),'\n"') from x GROUP BY sql_type UNION
	SELECT CONCAT('+ "','ROW_COUNT,',sql_type,',',CAST(SUM(ISNULL(row_count_b,0)) as BIGINT),',',CAST(SUM(ISNULL(row_count_t,0)) as BIGINT),'\n"') from x GROUP BY sql_type UNION
	SELECT CONCAT('+ "','NUM_PHYSICAL_IO_READS,',sql_type,',',CAST(SUM(ISNULL(num_physical_io_reads_b,0)) as BIGINT),',',CAST(SUM(ISNULL(num_physical_io_reads_t,0)) as BIGINT),'\n"') from x GROUP BY sql_type UNION
	SELECT CONCAT('+ "','LOG_BYTES_USED,',sql_type,',',CAST(SUM(ISNULL(log_bytes_used_b,0)) as BIGINT),',',CAST(SUM(ISNULL(log_bytes_used_t,0)) as BIGINT),'\n"') from x GROUP BY sql_type UNION
	SELECT CONCAT('+ "','TEMPDB_SPACE_USED,',sql_type,',',CAST(SUM(ISNULL(tempdb_space_used_b,0)) as BIGINT),',',CAST(SUM(ISNULL(tempdb_space_used_t,0)) as BIGINT),'\n"') from x GROUP BY sql_type UNION
	SELECT CONCAT('+ "','PAGE_SERVER_IO_READS,',sql_type,',',CAST(SUM(ISNULL(page_server_io_reads_b,0)) as BIGINT),',',CAST(SUM(ISNULL(page_server_io_reads_t,0)) as BIGINT),'\n"') from x GROUP BY sql_type
	`)

	stmtDbTimeTr := fmt.Sprintf(`
		with x as (
			select rsi.end_time , 'Other Wait Time' statistic_name,
				round(sum(total_query_wait_time_ms)/1000,1) total_time
			from sys.query_store_runtime_stats_interval rsi
			inner join sys.query_store_wait_stats ws on rsi.runtime_stats_interval_id = ws.runtime_stats_interval_id
			where rsi.runtime_stats_interval_id >= @tr_start_interval_id and rsi.runtime_stats_interval_id <= @tr_end_interval_id
			and ws.wait_category not in (6,11)
			group by rsi.end_time
			union
			select rsi.end_time , 'CPU' statistic_name,
				round(sum(count_executions*avg_cpu_time)/1000000,1) total_time
			from sys.query_store_runtime_stats_interval rsi
			inner join sys.query_store_runtime_stats rs on rsi.runtime_stats_interval_id = rs.runtime_stats_interval_id
			where rsi.runtime_stats_interval_id >= @tr_start_interval_id and rsi.runtime_stats_interval_id <= @tr_end_interval_id
			group by rsi.end_time
			union
			select rsi.end_time , 'Buffer IO' statistic_name,
				round(sum(total_query_wait_time_ms)/1000,1) total_time
			from sys.query_store_runtime_stats_interval rsi
			inner join sys.query_store_wait_stats ws on rsi.runtime_stats_interval_id = ws.runtime_stats_interval_id
			where rsi.runtime_stats_interval_id >= @tr_start_interval_id and rsi.runtime_stats_interval_id <= @tr_end_interval_id
			and ws.wait_category = 6
			group by rsi.end_time)
			select CONCAT('+ "',CONVERT(VARCHAR(16), end_time,120),',',statistic_name,',',CAST( total_time AS DECIMAL(20,1)) ,'\n"') from x
	`)

	stmtDbTimeBr := fmt.Sprintf(`
		with x as (
			select rsi.end_time , 'Other Wait Time' statistic_name,
				round(sum(total_query_wait_time_ms)/1000,1) total_time
			from sys.query_store_runtime_stats_interval rsi
			inner join sys.query_store_wait_stats ws on rsi.runtime_stats_interval_id = ws.runtime_stats_interval_id
			where rsi.runtime_stats_interval_id >= @bl_start_interval_id and rsi.runtime_stats_interval_id <= @bl_end_interval_id
			and ws.wait_category not in (6,11)
			group by rsi.end_time
			union
			select rsi.end_time , 'CPU' statistic_name,
				round(sum(count_executions*avg_cpu_time)/1000000,1) total_time
			from sys.query_store_runtime_stats_interval rsi
			inner join sys.query_store_runtime_stats rs on rsi.runtime_stats_interval_id = rs.runtime_stats_interval_id
			where rsi.runtime_stats_interval_id >= @bl_start_interval_id and rsi.runtime_stats_interval_id <= @bl_end_interval_id
			group by rsi.end_time
			union
			select rsi.end_time , 'Buffer IO' statistic_name,
				round(sum(total_query_wait_time_ms)/1000,1) total_time
			from sys.query_store_runtime_stats_interval rsi
			inner join sys.query_store_wait_stats ws on rsi.runtime_stats_interval_id = ws.runtime_stats_interval_id
			where rsi.runtime_stats_interval_id >= @bl_start_interval_id and rsi.runtime_stats_interval_id <= @bl_end_interval_id
			and ws.wait_category = 6
			group by rsi.end_time)
			select CONCAT('+ "',CONVERT(VARCHAR(16), end_time,120),',',statistic_name,',',CAST( total_time AS DECIMAL(20,1)) ,'\n"') from x
	`)

	stmtWaitEvents := fmt.Sprintf(`
		with mapping as (
			select 'CPU' wait_category_new union
			select 'Worker Thread' wait_category_new union
			select 'Lock' wait_category_new union
			select 'Latch' wait_category_new union
			select 'Buffer Latch' wait_category_new union
			select 'Buffer IO' wait_category_new union
			select 'Idle' wait_category_new union
			select 'Preemptive' wait_category_new union
			select 'Tran Log IO' wait_category_new union
			select 'Network IO' wait_category_new union
			select 'Memory' wait_category_new union
			select 'Other Disk IO' wait_category_new union
			select 'Other' wait_category_new)
			, br as (
				select wait_category_new, round(sum(total_query_wait_time_ms)/1000,1) total_time from
			(select rsi.end_time, wait_category, wait_category_desc, total_query_wait_time_ms, case when wait_category in (1,2,3,4,5,6,11,12,14,15,17,21) then wait_category_desc else 'Other' end wait_category_new
			from sys.query_store_runtime_stats_interval rsi
			inner join sys.query_store_wait_stats ws on rsi.runtime_stats_interval_id = ws.runtime_stats_interval_id
			where rsi.runtime_stats_interval_id >= @bl_start_interval_id and rsi.runtime_stats_interval_id <= @bl_end_interval_id) a
			group by wait_category_new
			)
			, tr as (
				select wait_category_new, round(sum(total_query_wait_time_ms)/1000,1) total_time from
			(select rsi.end_time, wait_category, wait_category_desc, total_query_wait_time_ms, case when wait_category in (1,2,3,4,5,6,11,12,14,15,17,21) then wait_category_desc else 'Other' end wait_category_new
			from sys.query_store_runtime_stats_interval rsi
			inner join sys.query_store_wait_stats ws on rsi.runtime_stats_interval_id = ws.runtime_stats_interval_id
			where rsi.runtime_stats_interval_id >= @tr_start_interval_id and rsi.runtime_stats_interval_id <= @tr_end_interval_id) a
			group by wait_category_new
			)
			SELECT CONCAT('+ "',m.wait_category_new,',',m.wait_category_new,',',CAST(ISNULL(br.total_time,0) as BIGINT),',',CAST(ISNULL(tr.total_time,0) as BIGINT),'\n"') from mapping m
			left join br on br.wait_category_new = m.wait_category_new
			left join tr on tr.wait_category_new = m.wait_category_new
	`)

	stmtSqlText := fmt.Sprintf(`
		with tr as (
			SELECT DISTINCT query_id_t, query_hash_t FROM 
			(SELECT
			plan_id plan_id_t,
			query_plan_hash query_plan_hash_t,
			query_id query_id_t,
			query_hash query_hash_t,
			executions executions_t,
			duration duration_t,
			cpu_time cpu_time_t,
			logical_io_reads logical_io_reads_t,
			logical_io_writes logical_io_writes_t,
			physical_io_reads physical_io_reads_t,
			dop dop_t,
			query_max_used_memory query_max_used_memory_t,
			row_count row_count_t,
			num_physical_io_reads num_physical_io_reads_t,
			log_bytes_used log_bytes_used_t,
			tempdb_space_used tempdb_space_used_t,
			page_server_io_reads page_server_io_reads_t,
			IIF((duration - cpu_time)>0,(duration - cpu_time),0) wait_time_t,
			ROW_NUMBER() OVER (ORDER BY executions DESC) executions_r,
			ROW_NUMBER() OVER (ORDER BY duration DESC) duration_r,
			ROW_NUMBER() OVER (ORDER BY cpu_time DESC) cpu_time_r,
			ROW_NUMBER() OVER (ORDER BY logical_io_reads DESC) logical_io_reads_r,
			ROW_NUMBER() OVER (ORDER BY logical_io_writes DESC) logical_io_writes_r,
			ROW_NUMBER() OVER (ORDER BY physical_io_reads DESC) physical_io_reads_r,
			ROW_NUMBER() OVER (ORDER BY dop DESC) dop_r,
			ROW_NUMBER() OVER (ORDER BY query_max_used_memory DESC) query_max_used_memory_r,
			ROW_NUMBER() OVER (ORDER BY row_count DESC) row_count_r,
			ROW_NUMBER() OVER (ORDER BY num_physical_io_reads DESC) num_physical_io_reads_r,
			ROW_NUMBER() OVER (ORDER BY log_bytes_used DESC) log_bytes_used_r,
			ROW_NUMBER() OVER (ORDER BY tempdb_space_used DESC) tempdb_space_used_r,
			ROW_NUMBER() OVER (ORDER BY page_server_io_reads DESC) page_server_io_reads_r,
			ROW_NUMBER() OVER (ORDER BY IIF((duration - cpu_time)>0,(duration - cpu_time),0) DESC) wait_time_r
			FROM
			(SELECT
				rs.plan_id,
				p.query_plan_hash,
				q.query_id,
				q.query_hash,
				sum(count_executions) executions, 
				round(sum(count_executions*avg_duration),0) duration, -- micro
				round(sum(count_executions*avg_cpu_time),0) cpu_time, -- micro
				round(sum(count_executions*avg_logical_io_reads),0) logical_io_reads, -- pages
				round(sum(count_executions*avg_logical_io_writes),0) logical_io_writes, -- pages
				round(sum(count_executions*avg_physical_io_reads),0) physical_io_reads, -- pages
				round(sum(count_executions*avg_dop),0) dop,
				round(sum(count_executions*avg_query_max_used_memory),0) query_max_used_memory, --pages
				round(sum(count_executions*avg_rowcount),0) row_count,
				round(sum(count_executions*avg_num_physical_io_reads),0) num_physical_io_reads,
				round(sum(count_executions*avg_log_bytes_used),0) log_bytes_used,
				round(sum(count_executions*avg_tempdb_space_used),0) tempdb_space_used,
				round(sum(count_executions*0),0) page_server_io_reads --avg_page_server_io_reads
			from sys.query_store_runtime_stats_interval rsi
			inner join sys.query_store_runtime_stats rs on rsi.runtime_stats_interval_id = rs.runtime_stats_interval_id
			inner join sys.query_store_plan p on rs.plan_id = p.plan_id
			inner join sys.query_store_query q on q.query_id = p.query_id
			where rsi.runtime_stats_interval_id >= @tr_start_interval_id and rsi.runtime_stats_interval_id <= @tr_end_interval_id
			group by rs.plan_id, p.query_plan_hash, q.query_id, q.query_hash) a
			) c
			WHERE (executions_r<=20 AND executions_t>0) OR
			(duration_r<=20 AND duration_t>0) OR
			(cpu_time_r<=20 AND cpu_time_t>0) OR
			(logical_io_reads_r<=20 AND logical_io_reads_t>0) OR
			(logical_io_writes_r<=20 AND logical_io_writes_t>0) OR
			(physical_io_reads_r<=20 AND physical_io_reads_t>0) OR
			(dop_r<=20 AND dop_t>0) OR
			(query_max_used_memory_r<=20 AND query_max_used_memory_t>0) OR
			(row_count_r<=20 AND row_count_t>0) OR
			(num_physical_io_reads_r<=20 AND num_physical_io_reads_t>0) OR
			(log_bytes_used_r<=20 AND log_bytes_used_t>0) OR
			(tempdb_space_used_r<=20 AND tempdb_space_used_t>0) OR
			(page_server_io_reads_r<=20 AND page_server_io_reads_t>0)
			)
			, s as (select 0x5C832E8F5E5D3655 query_hash, 'sqlAlias' sql_type)
			, x as (SELECT case when s.query_hash is not null then s.sql_type
				else 'Unclassified' end sql_type
			, tr.query_id_t, query_hash_t, query_sql_text
			FROM tr
			INNER JOIN sys.query_store_query q ON tr.query_id_t=q.query_id
			INNER JOIN sys.query_store_query_text t ON q.query_text_id=t.query_text_id
			LEFT JOIN s  ON tr.query_hash_t=s.query_hash
			)
			SELECT  CONCAT('+ "',CONVERT(VARCHAR(MAX), query_hash_t, 1),'!@#!',sql_type,'!@#!',SUBSTRING(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(query_sql_text, '!@#!', ''), CHAR(13), ''), CHAR(10), ''),'"',''),'\n',''),1,5000),'\n"') from x
	`)

	if _, err := f.WriteString("\n"); err != nil {
		log.Fatal(err)
	}

	// csvDbSummary

	if _, err := f.WriteString("csvDbSummary = csvDbSummary\n"); err != nil {
		log.Fatal(err)
	}

	rowsDbSummary, err := db.QueryContext(ctx, stmtDbSummary, sql.Named("sqldbserver", server), sql.Named("sqldbname", database), sql.Named("bl_start_interval_id", bl_start_interval_id), sql.Named("bl_end_interval_id", bl_end_interval_id), sql.Named("tr_start_interval_id", tr_start_interval_id), sql.Named("tr_end_interval_id", tr_end_interval_id))
	if err != nil {
		return "", err
	}

	defer rowsDbSummary.Close()

	// Iterate through the result set.
	for rowsDbSummary.Next() {
		var x string

		// Get values from row.
		err := rowsDbSummary.Scan(&x)
		if err != nil {
			return "", err
		}

		if _, err := f.WriteString(x + "\n"); err != nil {
			log.Fatal(err)
		}

	}

	if _, err := f.WriteString(";\n\n"); err != nil {
		log.Fatal(err)
	}

	// csvSqlStatsTable

	if _, err := f.WriteString("csvSqlStatsTable = csvSqlStatsTable\n"); err != nil {
		log.Fatal(err)
	}

	rowsSqlStatsTable, err := db.QueryContext(ctx, stmtSqlStatsTable, sql.Named("bl_start_interval_id", bl_start_interval_id), sql.Named("bl_end_interval_id", bl_end_interval_id), sql.Named("tr_start_interval_id", tr_start_interval_id), sql.Named("tr_end_interval_id", tr_end_interval_id))
	if err != nil {
		return "", err
	}

	defer rowsSqlStatsTable.Close()

	// Iterate through the result set.
	for rowsSqlStatsTable.Next() {
		var x string

		// Get values from row.
		err := rowsSqlStatsTable.Scan(&x)
		if err != nil {
			return "", err
		}

		if _, err := f.WriteString(x + "\n"); err != nil {
			log.Fatal(err)
		}

	}

	if _, err := f.WriteString(";\n\n"); err != nil {
		log.Fatal(err)
	}

	// csvSqlStatsChart

	if _, err := f.WriteString("csvSqlStatsChart = csvSqlStatsChart\n"); err != nil {
		log.Fatal(err)
	}

	rowsSqlStatsChart, err := db.QueryContext(ctx, stmtSqlStatsChart, sql.Named("bl_start_interval_id", bl_start_interval_id), sql.Named("bl_end_interval_id", bl_end_interval_id), sql.Named("tr_start_interval_id", tr_start_interval_id), sql.Named("tr_end_interval_id", tr_end_interval_id))
	if err != nil {
		return "", err
	}

	defer rowsSqlStatsChart.Close()

	// Iterate through the result set.
	for rowsSqlStatsChart.Next() {
		var x string

		// Get values from row.
		err := rowsSqlStatsChart.Scan(&x)
		if err != nil {
			return "", err
		}

		if _, err := f.WriteString(x + "\n"); err != nil {
			log.Fatal(err)
		}

	}

	if _, err := f.WriteString(";\n\n"); err != nil {
		log.Fatal(err)
	}

	// csvDbTimeTr

	if _, err := f.WriteString("csvDbTimeTr = csvDbTimeTr\n"); err != nil {
		log.Fatal(err)
	}

	rowsDbTimeTr, err := db.QueryContext(ctx, stmtDbTimeTr, sql.Named("bl_start_interval_id", bl_start_interval_id), sql.Named("bl_end_interval_id", bl_end_interval_id), sql.Named("tr_start_interval_id", tr_start_interval_id), sql.Named("tr_end_interval_id", tr_end_interval_id))
	if err != nil {
		return "", err
	}

	defer rowsDbTimeTr.Close()

	// Iterate through the result set.
	for rowsDbTimeTr.Next() {
		var x string

		// Get values from row.
		err := rowsDbTimeTr.Scan(&x)
		if err != nil {
			return "", err
		}

		if _, err := f.WriteString(x + "\n"); err != nil {
			log.Fatal(err)
		}

	}

	if _, err := f.WriteString(";\n\n"); err != nil {
		log.Fatal(err)
	}

	// csvDbTimeBr = csvDbTimeBr

	if _, err := f.WriteString("csvDbTimeBr = csvDbTimeBr\n"); err != nil {
		log.Fatal(err)
	}

	rowsDbTimeBr, err := db.QueryContext(ctx, stmtDbTimeBr, sql.Named("bl_start_interval_id", bl_start_interval_id), sql.Named("bl_end_interval_id", bl_end_interval_id), sql.Named("tr_start_interval_id", tr_start_interval_id), sql.Named("tr_end_interval_id", tr_end_interval_id))
	if err != nil {
		return "", err
	}

	defer rowsDbTimeBr.Close()

	// Iterate through the result set.
	for rowsDbTimeBr.Next() {
		var x string

		// Get values from row.
		err := rowsDbTimeBr.Scan(&x)
		if err != nil {
			return "", err
		}

		if _, err := f.WriteString(x + "\n"); err != nil {
			log.Fatal(err)
		}

	}

	if _, err := f.WriteString(";\n\n"); err != nil {
		log.Fatal(err)
	}

	// csvWaitEvents

	if _, err := f.WriteString("csvWaitEvents = csvWaitEvents\n"); err != nil {
		log.Fatal(err)
	}

	rowsWaitEvents, err := db.QueryContext(ctx, stmtWaitEvents, sql.Named("bl_start_interval_id", bl_start_interval_id), sql.Named("bl_end_interval_id", bl_end_interval_id), sql.Named("tr_start_interval_id", tr_start_interval_id), sql.Named("tr_end_interval_id", tr_end_interval_id))
	if err != nil {
		return "", err
	}

	defer rowsWaitEvents.Close()

	// Iterate through the result set.
	for rowsWaitEvents.Next() {
		var x string

		// Get values from row.
		err := rowsWaitEvents.Scan(&x)
		if err != nil {
			return "", err
		}

		if _, err := f.WriteString(x + "\n"); err != nil {
			log.Fatal(err)
		}

	}

	if _, err := f.WriteString(";\n\n"); err != nil {
		log.Fatal(err)
	}

	// csvSqlText

	if _, err := f.WriteString("csvSqlText = csvSqlText\n"); err != nil {
		log.Fatal(err)
	}

	rowsSqlText, err := db.QueryContext(ctx, stmtSqlText, sql.Named("bl_start_interval_id", bl_start_interval_id), sql.Named("bl_end_interval_id", bl_end_interval_id), sql.Named("tr_start_interval_id", tr_start_interval_id), sql.Named("tr_end_interval_id", tr_end_interval_id))
	if err != nil {
		return "", err
	}

	defer rowsSqlText.Close()

	// Iterate through the result set.
	for rowsSqlText.Next() {
		var x string

		// Get values from row.
		err := rowsSqlText.Scan(&x)
		if err != nil {
			return "", err
		}

		if _, err := f.WriteString(x + "\n"); err != nil {
			log.Fatal(err)
		}

	}

	if _, err := f.WriteString(";\n\n"); err != nil {
		log.Fatal(err)
	}

	n5, err := f.Write(footerFileContent)
	check(err)

	if n2+n5 <= n2 {
		fmt.Println("Report is successfully written to: " + fileName)
	}

	return fileName, err
}

// Generate Comparison Report by providing interval IDs
func generatePeriodReportByID(tr_start_interval_id int, tr_end_interval_id int) (string, error) {

	fmt.Println("Generating report ... ")

	headerFileContent, err := os.ReadFile("templates/mssql-xdbmonitoring-report-header.html")
	if err != nil {
		fmt.Print(err)
	}

	footerFileContent, err := os.ReadFile("templates/mssql-xdbmonitoring-report-footer.html")
	if err != nil {
		fmt.Print(err)
	}

	var fileName = fmt.Sprint("reports/mssql-xdbmo-report-", database, "-", tr_start_interval_id, "-", tr_end_interval_id, ".html")

	f := createFile(fileName)
	defer closeFile(f)

	n2, err := f.Write(headerFileContent)
	check(err)

	ctx := context.Background()

	// Check if database is alive.
	err1 := db.PingContext(ctx)
	if err1 != nil {
		return "", err1
	}

	stmtDbSummary := fmt.Sprintf(`SELECT CONCAT('+ "Period,',@sqldbserver,',',@sqldbname,',',MIN(rsi.runtime_stats_interval_id),',',MAX(rsi.runtime_stats_interval_id),',',MIN(CONVERT(VARCHAR(16), start_time,120)),',',MAX(CONVERT(VARCHAR(16), end_time,120)),',',CONCAT(DATEDIFF(second, MIN(start_time), MAX(end_time))/60/60,' hour(s) ', DATEDIFF(second, DATEADD(second, (DATEDIFF(second, MIN(start_time), MAX(end_time))/60/60)*60*60, MIN(start_time)), MAX(end_time))/60, ' minute(s)'),'\n"') x from sys.query_store_runtime_stats_interval rsi where rsi.runtime_stats_interval_id >= @tr_start_interval_id and rsi.runtime_stats_interval_id <= @tr_end_interval_id
		`)

	stmtSqlStatsTable := fmt.Sprintf(`with tr as (
		SELECT
			plan_id plan_id_t,
			query_plan_hash query_plan_hash_t,
			query_id query_id_t,
			query_hash query_hash_t,
			executions executions_t,
			duration duration_t,
			cpu_time cpu_time_t,
			logical_io_reads logical_io_reads_t,
			logical_io_writes logical_io_writes_t,
			physical_io_reads physical_io_reads_t,
			dop dop_t,
			query_max_used_memory query_max_used_memory_t,
			row_count row_count_t,
			num_physical_io_reads num_physical_io_reads_t,
			log_bytes_used log_bytes_used_t,
			tempdb_space_used tempdb_space_used_t,
			page_server_io_reads page_server_io_reads_t,
			IIF((duration - cpu_time)>0,(duration - cpu_time),0) wait_time_t,
			ROW_NUMBER() OVER (ORDER BY executions DESC) executions_r,
			ROW_NUMBER() OVER (ORDER BY duration DESC) duration_r,
			ROW_NUMBER() OVER (ORDER BY cpu_time DESC) cpu_time_r,
			ROW_NUMBER() OVER (ORDER BY logical_io_reads DESC) logical_io_reads_r,
			ROW_NUMBER() OVER (ORDER BY logical_io_writes DESC) logical_io_writes_r,
			ROW_NUMBER() OVER (ORDER BY physical_io_reads DESC) physical_io_reads_r,
			ROW_NUMBER() OVER (ORDER BY dop DESC) dop_r,
			ROW_NUMBER() OVER (ORDER BY query_max_used_memory DESC) query_max_used_memory_r,
			ROW_NUMBER() OVER (ORDER BY row_count DESC) row_count_r,
			ROW_NUMBER() OVER (ORDER BY num_physical_io_reads DESC) num_physical_io_reads_r,
			ROW_NUMBER() OVER (ORDER BY log_bytes_used DESC) log_bytes_used_r,
			ROW_NUMBER() OVER (ORDER BY tempdb_space_used DESC) tempdb_space_used_r,
			ROW_NUMBER() OVER (ORDER BY page_server_io_reads DESC) page_server_io_reads_r,
			ROW_NUMBER() OVER (ORDER BY IIF((duration - cpu_time)>0,(duration - cpu_time),0) DESC) wait_time_r,
			CAST(1. * executions / ISNULL(NULLIF(SUM(executions) OVER(),0),1) AS DECIMAL(5,2)) executions_s,
			CAST(1. * duration / ISNULL(NULLIF(SUM(duration) OVER(),0),1) AS DECIMAL(5,2)) duration_s,
			CAST(1. * cpu_time / ISNULL(NULLIF(SUM(cpu_time) OVER(),0),1) AS DECIMAL(5,2)) cpu_time_s,
			CAST(1. * logical_io_reads / ISNULL(NULLIF(SUM(logical_io_reads) OVER(),0),1) AS DECIMAL(5,2)) logical_io_reads_s,
			CAST(1. * logical_io_writes / ISNULL(NULLIF(SUM(logical_io_writes) OVER(),0),1) AS DECIMAL(5,2)) logical_io_writes_s,
			CAST(1. * physical_io_reads / ISNULL(NULLIF(SUM(physical_io_reads) OVER(),0),1) AS DECIMAL(5,2)) physical_io_reads_s,
			CAST(1. * dop / ISNULL(NULLIF(SUM(dop) OVER(),0),1) AS DECIMAL(5,2)) dop_s,
			CAST(1. * query_max_used_memory / ISNULL(NULLIF(SUM(query_max_used_memory) OVER(),0),1) AS DECIMAL(5,2)) query_max_used_memory_s,
			CAST(1. * row_count / ISNULL(NULLIF(SUM(row_count) OVER(),0),1) AS DECIMAL(5,2)) row_count_s,
			CAST(1. * num_physical_io_reads / ISNULL(NULLIF(SUM(num_physical_io_reads) OVER(),0),1) AS DECIMAL(5,2)) num_physical_io_reads_s,
			CAST(1. * log_bytes_used / ISNULL(NULLIF(SUM(log_bytes_used) OVER(),0),1) AS DECIMAL(5,2)) log_bytes_used_s,
			CAST(1. * tempdb_space_used / ISNULL(NULLIF(SUM(tempdb_space_used) OVER(),0),1) AS DECIMAL(5,2)) tempdb_space_used_s,
			CAST(1. * page_server_io_reads / ISNULL(NULLIF(SUM(page_server_io_reads) OVER(),0),1) AS DECIMAL(5,2)) page_server_io_reads_s,
			CAST(1. * IIF((duration - cpu_time)>0,(duration - cpu_time),0) / ISNULL(NULLIF(SUM(IIF((duration - cpu_time)>0,(duration - cpu_time),0)) OVER(),0),1) AS DECIMAL(5,2)) wait_time_s
			FROM
			(SELECT
				rs.plan_id,
				p.query_plan_hash,
				q.query_id,
				q.query_hash,
				sum(count_executions) executions, 
				round(sum(count_executions*avg_duration),0) duration, -- micro
				round(sum(count_executions*avg_cpu_time),0) cpu_time, -- micro
				round(sum(count_executions*avg_logical_io_reads),0) logical_io_reads, -- pages
				round(sum(count_executions*avg_logical_io_writes),0) logical_io_writes, -- pages
				round(sum(count_executions*avg_physical_io_reads),0) physical_io_reads, -- pages
				round(sum(count_executions*avg_dop),0) dop,
				round(sum(count_executions*avg_query_max_used_memory),0) query_max_used_memory, --pages
				round(sum(count_executions*avg_rowcount),0) row_count,
				round(sum(count_executions*avg_num_physical_io_reads),0) num_physical_io_reads,
				round(sum(count_executions*avg_log_bytes_used),0) log_bytes_used,
				round(sum(count_executions*avg_tempdb_space_used),0) tempdb_space_used,
				round(sum(count_executions*0),0) page_server_io_reads --avg_page_server_io_reads
			from sys.query_store_runtime_stats_interval rsi
			inner join sys.query_store_runtime_stats rs on rsi.runtime_stats_interval_id = rs.runtime_stats_interval_id
			inner join sys.query_store_plan p on rs.plan_id = p.plan_id
			inner join sys.query_store_query q on q.query_id = p.query_id
			where rsi.runtime_stats_interval_id >= @tr_start_interval_id and rsi.runtime_stats_interval_id <= @tr_end_interval_id
			group by rs.plan_id, p.query_plan_hash, q.query_id, q.query_hash) a
			)
			, s as (select 0x5C832E8F5E5D3655 query_hash, 'sqlAlias' sql_type)
			, x as (SELECT case when s.query_hash is not null then s.sql_type
				else 'Unclassified' end sql_type
			, tr.*
			FROM tr
			LEFT JOIN s  ON tr.query_hash_t=s.query_hash)
			SELECT  CONCAT('+ "','EXECUTIONS,',executions_r,',',plan_id_t,',',CONVERT(VARCHAR(MAX), query_plan_hash_t, 1),',',query_id_t,',',CONVERT(VARCHAR(MAX), query_hash_t, 1),',',sql_type,','
			,executions_t,',',CAST(ROUND(duration_t/1000000,0) as BIGINT),',',CAST(ROUND(cpu_time_t/1000000,0) as BIGINT),',',CAST(ROUND(wait_time_t/1000000,0) as BIGINT),',',CAST(logical_io_reads_t as BIGINT),',',CAST(logical_io_writes_t as BIGINT),',',CAST(physical_io_reads_t as BIGINT),',',CAST(dop_t as BIGINT),',',CAST(query_max_used_memory_t as BIGINT),',',CAST(row_count_t as BIGINT),',',CAST(num_physical_io_reads_t as BIGINT),',',CAST(log_bytes_used_t as BIGINT),',',CAST(tempdb_space_used_t as BIGINT),',',CAST(page_server_io_reads_t as BIGINT),','
			,executions_s,',',duration_s,',',cpu_time_s,',',wait_time_s,',',logical_io_reads_s,',',logical_io_writes_s,',',physical_io_reads_s,',',dop_s,',',query_max_used_memory_s,',',row_count_s,',',num_physical_io_reads_s,',',log_bytes_used_s,',',tempdb_space_used_s,',',page_server_io_reads_s,'\n"') from x where executions_r<=20 union
			SELECT  CONCAT('+ "','DURATION,',duration_r,',',plan_id_t,',',CONVERT(VARCHAR(MAX), query_plan_hash_t, 1),',',query_id_t,',',CONVERT(VARCHAR(MAX), query_hash_t, 1),',',sql_type,','
			,executions_t,',',CAST(ROUND(duration_t/1000000,0) as BIGINT),',',CAST(ROUND(cpu_time_t/1000000,0) as BIGINT),',',CAST(ROUND(wait_time_t/1000000,0) as BIGINT),',',CAST(logical_io_reads_t as BIGINT),',',CAST(logical_io_writes_t as BIGINT),',',CAST(physical_io_reads_t as BIGINT),',',CAST(dop_t as BIGINT),',',CAST(query_max_used_memory_t as BIGINT),',',CAST(row_count_t as BIGINT),',',CAST(num_physical_io_reads_t as BIGINT),',',CAST(log_bytes_used_t as BIGINT),',',CAST(tempdb_space_used_t as BIGINT),',',CAST(page_server_io_reads_t as BIGINT),','
			,executions_s,',',duration_s,',',cpu_time_s,',',wait_time_s,',',logical_io_reads_s,',',logical_io_writes_s,',',physical_io_reads_s,',',dop_s,',',query_max_used_memory_s,',',row_count_s,',',num_physical_io_reads_s,',',log_bytes_used_s,',',tempdb_space_used_s,',',page_server_io_reads_s,'\n"') from x where duration_r<=20 union
			SELECT  CONCAT('+ "','CPU_TIME,',cpu_time_r,',',plan_id_t,',',CONVERT(VARCHAR(MAX), query_plan_hash_t, 1),',',query_id_t,',',CONVERT(VARCHAR(MAX), query_hash_t, 1),',',sql_type,','
			,executions_t,',',CAST(ROUND(duration_t/1000000,0) as BIGINT),',',CAST(ROUND(cpu_time_t/1000000,0) as BIGINT),',',CAST(ROUND(wait_time_t/1000000,0) as BIGINT),',',CAST(logical_io_reads_t as BIGINT),',',CAST(logical_io_writes_t as BIGINT),',',CAST(physical_io_reads_t as BIGINT),',',CAST(dop_t as BIGINT),',',CAST(query_max_used_memory_t as BIGINT),',',CAST(row_count_t as BIGINT),',',CAST(num_physical_io_reads_t as BIGINT),',',CAST(log_bytes_used_t as BIGINT),',',CAST(tempdb_space_used_t as BIGINT),',',CAST(page_server_io_reads_t as BIGINT),','
			,executions_s,',',duration_s,',',cpu_time_s,',',wait_time_s,',',logical_io_reads_s,',',logical_io_writes_s,',',physical_io_reads_s,',',dop_s,',',query_max_used_memory_s,',',row_count_s,',',num_physical_io_reads_s,',',log_bytes_used_s,',',tempdb_space_used_s,',',page_server_io_reads_s,'\n"') from x where cpu_time_r<=20 union
			SELECT  CONCAT('+ "','WAIT_TIME,',wait_time_r,',',plan_id_t,',',CONVERT(VARCHAR(MAX), query_plan_hash_t, 1),',',query_id_t,',',CONVERT(VARCHAR(MAX), query_hash_t, 1),',',sql_type,','
			,executions_t,',',CAST(ROUND(duration_t/1000000,0) as BIGINT),',',CAST(ROUND(cpu_time_t/1000000,0) as BIGINT),',',CAST(ROUND(wait_time_t/1000000,0) as BIGINT),',',CAST(logical_io_reads_t as BIGINT),',',CAST(logical_io_writes_t as BIGINT),',',CAST(physical_io_reads_t as BIGINT),',',CAST(dop_t as BIGINT),',',CAST(query_max_used_memory_t as BIGINT),',',CAST(row_count_t as BIGINT),',',CAST(num_physical_io_reads_t as BIGINT),',',CAST(log_bytes_used_t as BIGINT),',',CAST(tempdb_space_used_t as BIGINT),',',CAST(page_server_io_reads_t as BIGINT),','
			,executions_s,',',duration_s,',',cpu_time_s,',',wait_time_s,',',logical_io_reads_s,',',logical_io_writes_s,',',physical_io_reads_s,',',dop_s,',',query_max_used_memory_s,',',row_count_s,',',num_physical_io_reads_s,',',log_bytes_used_s,',',tempdb_space_used_s,',',page_server_io_reads_s,'\n"') from x where wait_time_r<=20 union
			SELECT  CONCAT('+ "','LOGICAL_IO_READS,',logical_io_reads_r,',',plan_id_t,',',CONVERT(VARCHAR(MAX), query_plan_hash_t, 1),',',query_id_t,',',CONVERT(VARCHAR(MAX), query_hash_t, 1),',',sql_type,','
			,executions_t,',',CAST(ROUND(duration_t/1000000,0) as BIGINT),',',CAST(ROUND(cpu_time_t/1000000,0) as BIGINT),',',CAST(ROUND(wait_time_t/1000000,0) as BIGINT),',',CAST(logical_io_reads_t as BIGINT),',',CAST(logical_io_writes_t as BIGINT),',',CAST(physical_io_reads_t as BIGINT),',',CAST(dop_t as BIGINT),',',CAST(query_max_used_memory_t as BIGINT),',',CAST(row_count_t as BIGINT),',',CAST(num_physical_io_reads_t as BIGINT),',',CAST(log_bytes_used_t as BIGINT),',',CAST(tempdb_space_used_t as BIGINT),',',CAST(page_server_io_reads_t as BIGINT),','
			,executions_s,',',duration_s,',',cpu_time_s,',',wait_time_s,',',logical_io_reads_s,',',logical_io_writes_s,',',physical_io_reads_s,',',dop_s,',',query_max_used_memory_s,',',row_count_s,',',num_physical_io_reads_s,',',log_bytes_used_s,',',tempdb_space_used_s,',',page_server_io_reads_s,'\n"') from x where logical_io_reads_r<=20 union
			SELECT  CONCAT('+ "','LOGICAL_IO_WRITES,',logical_io_writes_r,',',plan_id_t,',',CONVERT(VARCHAR(MAX), query_plan_hash_t, 1),',',query_id_t,',',CONVERT(VARCHAR(MAX), query_hash_t, 1),',',sql_type,','
			,executions_t,',',CAST(ROUND(duration_t/1000000,0) as BIGINT),',',CAST(ROUND(cpu_time_t/1000000,0) as BIGINT),',',CAST(ROUND(wait_time_t/1000000,0) as BIGINT),',',CAST(logical_io_reads_t as BIGINT),',',CAST(logical_io_writes_t as BIGINT),',',CAST(physical_io_reads_t as BIGINT),',',CAST(dop_t as BIGINT),',',CAST(query_max_used_memory_t as BIGINT),',',CAST(row_count_t as BIGINT),',',CAST(num_physical_io_reads_t as BIGINT),',',CAST(log_bytes_used_t as BIGINT),',',CAST(tempdb_space_used_t as BIGINT),',',CAST(page_server_io_reads_t as BIGINT),','
			,executions_s,',',duration_s,',',cpu_time_s,',',wait_time_s,',',logical_io_reads_s,',',logical_io_writes_s,',',physical_io_reads_s,',',dop_s,',',query_max_used_memory_s,',',row_count_s,',',num_physical_io_reads_s,',',log_bytes_used_s,',',tempdb_space_used_s,',',page_server_io_reads_s,'\n"') from x where logical_io_writes_r<=20 union
			SELECT  CONCAT('+ "','PHYSICAL_IO_READS,',physical_io_reads_r,',',plan_id_t,',',CONVERT(VARCHAR(MAX), query_plan_hash_t, 1),',',query_id_t,',',CONVERT(VARCHAR(MAX), query_hash_t, 1),',',sql_type,','
			,executions_t,',',CAST(ROUND(duration_t/1000000,0) as BIGINT),',',CAST(ROUND(cpu_time_t/1000000,0) as BIGINT),',',CAST(ROUND(wait_time_t/1000000,0) as BIGINT),',',CAST(logical_io_reads_t as BIGINT),',',CAST(logical_io_writes_t as BIGINT),',',CAST(physical_io_reads_t as BIGINT),',',CAST(dop_t as BIGINT),',',CAST(query_max_used_memory_t as BIGINT),',',CAST(row_count_t as BIGINT),',',CAST(num_physical_io_reads_t as BIGINT),',',CAST(log_bytes_used_t as BIGINT),',',CAST(tempdb_space_used_t as BIGINT),',',CAST(page_server_io_reads_t as BIGINT),','
			,executions_s,',',duration_s,',',cpu_time_s,',',wait_time_s,',',logical_io_reads_s,',',logical_io_writes_s,',',physical_io_reads_s,',',dop_s,',',query_max_used_memory_s,',',row_count_s,',',num_physical_io_reads_s,',',log_bytes_used_s,',',tempdb_space_used_s,',',page_server_io_reads_s,'\n"') from x where physical_io_reads_r<=20 union
			SELECT  CONCAT('+ "','DOP,',dop_r,',',plan_id_t,',',CONVERT(VARCHAR(MAX), query_plan_hash_t, 1),',',query_id_t,',',CONVERT(VARCHAR(MAX), query_hash_t, 1),',',sql_type,','
			,executions_t,',',CAST(ROUND(duration_t/1000000,0) as BIGINT),',',CAST(ROUND(cpu_time_t/1000000,0) as BIGINT),',',CAST(ROUND(wait_time_t/1000000,0) as BIGINT),',',CAST(logical_io_reads_t as BIGINT),',',CAST(logical_io_writes_t as BIGINT),',',CAST(physical_io_reads_t as BIGINT),',',CAST(dop_t as BIGINT),',',CAST(query_max_used_memory_t as BIGINT),',',CAST(row_count_t as BIGINT),',',CAST(num_physical_io_reads_t as BIGINT),',',CAST(log_bytes_used_t as BIGINT),',',CAST(tempdb_space_used_t as BIGINT),',',CAST(page_server_io_reads_t as BIGINT),','
			,executions_s,',',duration_s,',',cpu_time_s,',',wait_time_s,',',logical_io_reads_s,',',logical_io_writes_s,',',physical_io_reads_s,',',dop_s,',',query_max_used_memory_s,',',row_count_s,',',num_physical_io_reads_s,',',log_bytes_used_s,',',tempdb_space_used_s,',',page_server_io_reads_s,'\n"') from x where dop_r<=20 union
			SELECT  CONCAT('+ "','QUERY_MAX_USED_MEMORY,',query_max_used_memory_r,',',plan_id_t,',',CONVERT(VARCHAR(MAX), query_plan_hash_t, 1),',',query_id_t,',',CONVERT(VARCHAR(MAX), query_hash_t, 1),',',sql_type,','
			,executions_t,',',CAST(ROUND(duration_t/1000000,0) as BIGINT),',',CAST(ROUND(cpu_time_t/1000000,0) as BIGINT),',',CAST(ROUND(wait_time_t/1000000,0) as BIGINT),',',CAST(logical_io_reads_t as BIGINT),',',CAST(logical_io_writes_t as BIGINT),',',CAST(physical_io_reads_t as BIGINT),',',CAST(dop_t as BIGINT),',',CAST(query_max_used_memory_t as BIGINT),',',CAST(row_count_t as BIGINT),',',CAST(num_physical_io_reads_t as BIGINT),',',CAST(log_bytes_used_t as BIGINT),',',CAST(tempdb_space_used_t as BIGINT),',',CAST(page_server_io_reads_t as BIGINT),','
			,executions_s,',',duration_s,',',cpu_time_s,',',wait_time_s,',',logical_io_reads_s,',',logical_io_writes_s,',',physical_io_reads_s,',',dop_s,',',query_max_used_memory_s,',',row_count_s,',',num_physical_io_reads_s,',',log_bytes_used_s,',',tempdb_space_used_s,',',page_server_io_reads_s,'\n"') from x where query_max_used_memory_r<=20 union
			SELECT  CONCAT('+ "','ROW_COUNT,',row_count_r,',',plan_id_t,',',CONVERT(VARCHAR(MAX), query_plan_hash_t, 1),',',query_id_t,',',CONVERT(VARCHAR(MAX), query_hash_t, 1),',',sql_type,','
			,executions_t,',',CAST(ROUND(duration_t/1000000,0) as BIGINT),',',CAST(ROUND(cpu_time_t/1000000,0) as BIGINT),',',CAST(ROUND(wait_time_t/1000000,0) as BIGINT),',',CAST(logical_io_reads_t as BIGINT),',',CAST(logical_io_writes_t as BIGINT),',',CAST(physical_io_reads_t as BIGINT),',',CAST(dop_t as BIGINT),',',CAST(query_max_used_memory_t as BIGINT),',',CAST(row_count_t as BIGINT),',',CAST(num_physical_io_reads_t as BIGINT),',',CAST(log_bytes_used_t as BIGINT),',',CAST(tempdb_space_used_t as BIGINT),',',CAST(page_server_io_reads_t as BIGINT),','
			,executions_s,',',duration_s,',',cpu_time_s,',',wait_time_s,',',logical_io_reads_s,',',logical_io_writes_s,',',physical_io_reads_s,',',dop_s,',',query_max_used_memory_s,',',row_count_s,',',num_physical_io_reads_s,',',log_bytes_used_s,',',tempdb_space_used_s,',',page_server_io_reads_s,'\n"') from x where row_count_r<=20 union
			SELECT  CONCAT('+ "','NUM_PHYSICAL_IO_READS,',num_physical_io_reads_r,',',plan_id_t,',',CONVERT(VARCHAR(MAX), query_plan_hash_t, 1),',',query_id_t,',',CONVERT(VARCHAR(MAX), query_hash_t, 1),',',sql_type,','
			,executions_t,',',CAST(ROUND(duration_t/1000000,0) as BIGINT),',',CAST(ROUND(cpu_time_t/1000000,0) as BIGINT),',',CAST(ROUND(wait_time_t/1000000,0) as BIGINT),',',CAST(logical_io_reads_t as BIGINT),',',CAST(logical_io_writes_t as BIGINT),',',CAST(physical_io_reads_t as BIGINT),',',CAST(dop_t as BIGINT),',',CAST(query_max_used_memory_t as BIGINT),',',CAST(row_count_t as BIGINT),',',CAST(num_physical_io_reads_t as BIGINT),',',CAST(log_bytes_used_t as BIGINT),',',CAST(tempdb_space_used_t as BIGINT),',',CAST(page_server_io_reads_t as BIGINT),','
			,executions_s,',',duration_s,',',cpu_time_s,',',wait_time_s,',',logical_io_reads_s,',',logical_io_writes_s,',',physical_io_reads_s,',',dop_s,',',query_max_used_memory_s,',',row_count_s,',',num_physical_io_reads_s,',',log_bytes_used_s,',',tempdb_space_used_s,',',page_server_io_reads_s,'\n"') from x where num_physical_io_reads_r<=20 union
			SELECT  CONCAT('+ "','LOG_BYTES_USED,',log_bytes_used_r,',',plan_id_t,',',CONVERT(VARCHAR(MAX), query_plan_hash_t, 1),',',query_id_t,',',CONVERT(VARCHAR(MAX), query_hash_t, 1),',',sql_type,','
			,executions_t,',',CAST(ROUND(duration_t/1000000,0) as BIGINT),',',CAST(ROUND(cpu_time_t/1000000,0) as BIGINT),',',CAST(ROUND(wait_time_t/1000000,0) as BIGINT),',',CAST(logical_io_reads_t as BIGINT),',',CAST(logical_io_writes_t as BIGINT),',',CAST(physical_io_reads_t as BIGINT),',',CAST(dop_t as BIGINT),',',CAST(query_max_used_memory_t as BIGINT),',',CAST(row_count_t as BIGINT),',',CAST(num_physical_io_reads_t as BIGINT),',',CAST(log_bytes_used_t as BIGINT),',',CAST(tempdb_space_used_t as BIGINT),',',CAST(page_server_io_reads_t as BIGINT),','
			,executions_s,',',duration_s,',',cpu_time_s,',',wait_time_s,',',logical_io_reads_s,',',logical_io_writes_s,',',physical_io_reads_s,',',dop_s,',',query_max_used_memory_s,',',row_count_s,',',num_physical_io_reads_s,',',log_bytes_used_s,',',tempdb_space_used_s,',',page_server_io_reads_s,'\n"') from x where log_bytes_used_r<=20 union
			SELECT  CONCAT('+ "','TEMPDB_SPACE_USED,',tempdb_space_used_r,',',plan_id_t,',',CONVERT(VARCHAR(MAX), query_plan_hash_t, 1),',',query_id_t,',',CONVERT(VARCHAR(MAX), query_hash_t, 1),',',sql_type,','
			,executions_t,',',CAST(ROUND(duration_t/1000000,0) as BIGINT),',',CAST(ROUND(cpu_time_t/1000000,0) as BIGINT),',',CAST(ROUND(wait_time_t/1000000,0) as BIGINT),',',CAST(logical_io_reads_t as BIGINT),',',CAST(logical_io_writes_t as BIGINT),',',CAST(physical_io_reads_t as BIGINT),',',CAST(dop_t as BIGINT),',',CAST(query_max_used_memory_t as BIGINT),',',CAST(row_count_t as BIGINT),',',CAST(num_physical_io_reads_t as BIGINT),',',CAST(log_bytes_used_t as BIGINT),',',CAST(tempdb_space_used_t as BIGINT),',',CAST(page_server_io_reads_t as BIGINT),','
			,executions_s,',',duration_s,',',cpu_time_s,',',wait_time_s,',',logical_io_reads_s,',',logical_io_writes_s,',',physical_io_reads_s,',',dop_s,',',query_max_used_memory_s,',',row_count_s,',',num_physical_io_reads_s,',',log_bytes_used_s,',',tempdb_space_used_s,',',page_server_io_reads_s,'\n"') from x where tempdb_space_used_r<=20 union
			SELECT  CONCAT('+ "','PAGE_SERVER_IO_READS,',page_server_io_reads_r,',',plan_id_t,',',CONVERT(VARCHAR(MAX), query_plan_hash_t, 1),',',query_id_t,',',CONVERT(VARCHAR(MAX), query_hash_t, 1),',',sql_type,','
			,executions_t,',',CAST(ROUND(duration_t/1000000,0) as BIGINT),',',CAST(ROUND(cpu_time_t/1000000,0) as BIGINT),',',CAST(ROUND(wait_time_t/1000000,0) as BIGINT),',',CAST(logical_io_reads_t as BIGINT),',',CAST(logical_io_writes_t as BIGINT),',',CAST(physical_io_reads_t as BIGINT),',',CAST(dop_t as BIGINT),',',CAST(query_max_used_memory_t as BIGINT),',',CAST(row_count_t as BIGINT),',',CAST(num_physical_io_reads_t as BIGINT),',',CAST(log_bytes_used_t as BIGINT),',',CAST(tempdb_space_used_t as BIGINT),',',CAST(page_server_io_reads_t as BIGINT),','
			,executions_s,',',duration_s,',',cpu_time_s,',',wait_time_s,',',logical_io_reads_s,',',logical_io_writes_s,',',physical_io_reads_s,',',dop_s,',',query_max_used_memory_s,',',row_count_s,',',num_physical_io_reads_s,',',log_bytes_used_s,',',tempdb_space_used_s,',',page_server_io_reads_s,'\n"') from x where page_server_io_reads_r<=20
			`)

	stmtSqlStatsChart := fmt.Sprintf(`
	with tr as (
		SELECT
	plan_id plan_id_t,
	query_plan_hash query_plan_hash_t,
	query_id query_id_t,
	query_hash query_hash_t,
	executions executions_t,
	duration duration_t,
	cpu_time cpu_time_t,
	logical_io_reads logical_io_reads_t,
	logical_io_writes logical_io_writes_t,
	physical_io_reads physical_io_reads_t,
	dop dop_t,
	query_max_used_memory query_max_used_memory_t,
	row_count row_count_t,
	num_physical_io_reads num_physical_io_reads_t,
	log_bytes_used log_bytes_used_t,
	tempdb_space_used tempdb_space_used_t,
	page_server_io_reads page_server_io_reads_t,
	IIF((duration - cpu_time)>0,(duration - cpu_time),0) wait_time_t,
	ROW_NUMBER() OVER (ORDER BY executions DESC) executions_r,
	ROW_NUMBER() OVER (ORDER BY duration DESC) duration_r,
	ROW_NUMBER() OVER (ORDER BY cpu_time DESC) cpu_time_r,
	ROW_NUMBER() OVER (ORDER BY logical_io_reads DESC) logical_io_reads_r,
	ROW_NUMBER() OVER (ORDER BY logical_io_writes DESC) logical_io_writes_r,
	ROW_NUMBER() OVER (ORDER BY physical_io_reads DESC) physical_io_reads_r,
	ROW_NUMBER() OVER (ORDER BY dop DESC) dop_r,
	ROW_NUMBER() OVER (ORDER BY query_max_used_memory DESC) query_max_used_memory_r,
	ROW_NUMBER() OVER (ORDER BY row_count DESC) row_count_r,
	ROW_NUMBER() OVER (ORDER BY num_physical_io_reads DESC) num_physical_io_reads_r,
	ROW_NUMBER() OVER (ORDER BY log_bytes_used DESC) log_bytes_used_r,
	ROW_NUMBER() OVER (ORDER BY tempdb_space_used DESC) tempdb_space_used_r,
	ROW_NUMBER() OVER (ORDER BY page_server_io_reads DESC) page_server_io_reads_r,
	ROW_NUMBER() OVER (ORDER BY IIF((duration - cpu_time)>0,(duration - cpu_time),0) DESC) wait_time_r,
	CAST(1. * executions / ISNULL(NULLIF(SUM(executions) OVER(),0),1) AS DECIMAL(5,2)) executions_s,
	CAST(1. * duration / ISNULL(NULLIF(SUM(duration) OVER(),0),1) AS DECIMAL(5,2)) duration_s,
	CAST(1. * cpu_time / ISNULL(NULLIF(SUM(cpu_time) OVER(),0),1) AS DECIMAL(5,2)) cpu_time_s,
	CAST(1. * logical_io_reads / ISNULL(NULLIF(SUM(logical_io_reads) OVER(),0),1) AS DECIMAL(5,2)) logical_io_reads_s,
	CAST(1. * logical_io_writes / ISNULL(NULLIF(SUM(logical_io_writes) OVER(),0),1) AS DECIMAL(5,2)) logical_io_writes_s,
	CAST(1. * physical_io_reads / ISNULL(NULLIF(SUM(physical_io_reads) OVER(),0),1) AS DECIMAL(5,2)) physical_io_reads_s,
	CAST(1. * dop / ISNULL(NULLIF(SUM(dop) OVER(),0),1) AS DECIMAL(5,2)) dop_s,
	CAST(1. * query_max_used_memory / ISNULL(NULLIF(SUM(query_max_used_memory) OVER(),0),1) AS DECIMAL(5,2)) query_max_used_memory_s,
	CAST(1. * row_count / ISNULL(NULLIF(SUM(row_count) OVER(),0),1) AS DECIMAL(5,2)) row_count_s,
	CAST(1. * num_physical_io_reads / ISNULL(NULLIF(SUM(num_physical_io_reads) OVER(),0),1) AS DECIMAL(5,2)) num_physical_io_reads_s,
	CAST(1. * log_bytes_used / ISNULL(NULLIF(SUM(log_bytes_used) OVER(),0),1) AS DECIMAL(5,2)) log_bytes_used_s,
	CAST(1. * tempdb_space_used / ISNULL(NULLIF(SUM(tempdb_space_used) OVER(),0),1) AS DECIMAL(5,2)) tempdb_space_used_s,
	CAST(1. * page_server_io_reads / ISNULL(NULLIF(SUM(page_server_io_reads) OVER(),0),1) AS DECIMAL(5,2)) page_server_io_reads_s,
	CAST(1. * IIF((duration - cpu_time)>0,(duration - cpu_time),0) / ISNULL(NULLIF(SUM(IIF((duration - cpu_time)>0,(duration - cpu_time),0)) OVER(),0),1) AS DECIMAL(5,2)) wait_time_s
	FROM
	(SELECT
		rs.plan_id,
		p.query_plan_hash,
		q.query_id,
		q.query_hash,
		sum(count_executions) executions, 
		round(sum(count_executions*avg_duration),0) duration, -- micro
		round(sum(count_executions*avg_cpu_time),0) cpu_time, -- micro
		round(sum(count_executions*avg_logical_io_reads),0) logical_io_reads, -- pages
		round(sum(count_executions*avg_logical_io_writes),0) logical_io_writes, -- pages
		round(sum(count_executions*avg_physical_io_reads),0) physical_io_reads, -- pages
		round(sum(count_executions*avg_dop),0) dop,
		round(sum(count_executions*avg_query_max_used_memory),0) query_max_used_memory, --pages
		round(sum(count_executions*avg_rowcount),0) row_count,
		round(sum(count_executions*avg_num_physical_io_reads),0) num_physical_io_reads,
		round(sum(count_executions*avg_log_bytes_used),0) log_bytes_used,
		round(sum(count_executions*avg_tempdb_space_used),0) tempdb_space_used,
		round(sum(count_executions*0),0) page_server_io_reads --avg_page_server_io_reads
	from sys.query_store_runtime_stats_interval rsi
	inner join sys.query_store_runtime_stats rs on rsi.runtime_stats_interval_id = rs.runtime_stats_interval_id
	inner join sys.query_store_plan p on rs.plan_id = p.plan_id
	inner join sys.query_store_query q on q.query_id = p.query_id
	where rsi.runtime_stats_interval_id >= @tr_start_interval_id and rsi.runtime_stats_interval_id <= @tr_end_interval_id
	group by rs.plan_id, p.query_plan_hash, q.query_id, q.query_hash) a
	)
	, s as (select 0x5C832E8F5E5D3655 query_hash, 'sqlAlias' sql_type)
	, x as (select
		case when s.query_hash is not null then s.sql_type
		   else '0: Unclassified' end sql_type
	, tr.*
	FROM tr
	LEFT JOIN s  ON tr.query_hash_t=s.query_hash)
	SELECT CONCAT('+ "','SQL_TYPE,',sql_type,',',COUNT(1),'\n"') from x WHERE sql_type not in ('0: New (+)', '0: Aged out (-)') GROUP BY sql_type UNION
	SELECT CONCAT('+ "','EXECUTIONS,',sql_type,',',CAST(SUM(ISNULL(executions_t,0)) as BIGINT),'\n"') from x GROUP BY sql_type UNION
	SELECT CONCAT('+ "','DURATION,',sql_type,',',CAST(ROUND(SUM(ISNULL(duration_t,0))/1000000,0) as BIGINT),'\n"') from x GROUP BY sql_type UNION
	SELECT CONCAT('+ "','CPU_TIME,',sql_type,',',CAST(ROUND(SUM(ISNULL(cpu_time_t,0))/1000000,0) as BIGINT),'\n"') from x GROUP BY sql_type UNION
	SELECT CONCAT('+ "','WAIT_TIME,',sql_type,',',CAST(ROUND(SUM(ISNULL(wait_time_t,0))/1000000,0) as BIGINT),'\n"') from x GROUP BY sql_type UNION
	SELECT CONCAT('+ "','LOGICAL_IO_READS,',sql_type,',',CAST(SUM(ISNULL(logical_io_reads_t,0)) as BIGINT),'\n"') from x GROUP BY sql_type UNION
	SELECT CONCAT('+ "','LOGICAL_IO_WRITES,',sql_type,',',CAST(SUM(ISNULL(logical_io_writes_t,0)) as BIGINT),'\n"') from x GROUP BY sql_type UNION
	SELECT CONCAT('+ "','PHYSICAL_IO_READS,',sql_type,',',CAST(SUM(ISNULL(physical_io_reads_t,0)) as BIGINT),'\n"') from x GROUP BY sql_type UNION
	SELECT CONCAT('+ "','DOP,',sql_type,',',CAST(SUM(ISNULL(dop_t,0)) as BIGINT),'\n"') from x GROUP BY sql_type UNION
	SELECT CONCAT('+ "','QUERY_MAX_USED_MEMORY,',sql_type,',',CAST(SUM(ISNULL(query_max_used_memory_t,0)) as BIGINT),'\n"') from x GROUP BY sql_type UNION
	SELECT CONCAT('+ "','ROW_COUNT,',sql_type,',',CAST(SUM(ISNULL(row_count_t,0)) as BIGINT),'\n"') from x GROUP BY sql_type UNION
	SELECT CONCAT('+ "','NUM_PHYSICAL_IO_READS,',sql_type,',',CAST(SUM(ISNULL(num_physical_io_reads_t,0)) as BIGINT),'\n"') from x GROUP BY sql_type UNION
	SELECT CONCAT('+ "','LOG_BYTES_USED,',sql_type,',',CAST(SUM(ISNULL(log_bytes_used_t,0)) as BIGINT),'\n"') from x GROUP BY sql_type UNION
	SELECT CONCAT('+ "','TEMPDB_SPACE_USED,',sql_type,',',CAST(SUM(ISNULL(tempdb_space_used_t,0)) as BIGINT),'\n"') from x GROUP BY sql_type UNION
	SELECT CONCAT('+ "','PAGE_SERVER_IO_READS,',sql_type,',',CAST(SUM(ISNULL(page_server_io_reads_t,0)) as BIGINT),'\n"') from x GROUP BY sql_type`)

	stmtDbTimeTr := fmt.Sprintf(`
		with x as (
			select rsi.end_time , 'Other Wait Time' statistic_name,
				round(sum(total_query_wait_time_ms)/1000,1) total_time
			from sys.query_store_runtime_stats_interval rsi
			inner join sys.query_store_wait_stats ws on rsi.runtime_stats_interval_id = ws.runtime_stats_interval_id
			where rsi.runtime_stats_interval_id >= @tr_start_interval_id and rsi.runtime_stats_interval_id <= @tr_end_interval_id
			and ws.wait_category not in (6,11)
			group by rsi.end_time
			union
			select rsi.end_time , 'CPU' statistic_name,
				round(sum(count_executions*avg_cpu_time)/1000000,1) total_time
			from sys.query_store_runtime_stats_interval rsi
			inner join sys.query_store_runtime_stats rs on rsi.runtime_stats_interval_id = rs.runtime_stats_interval_id
			where rsi.runtime_stats_interval_id >= @tr_start_interval_id and rsi.runtime_stats_interval_id <= @tr_end_interval_id
			group by rsi.end_time
			union
			select rsi.end_time , 'Buffer IO' statistic_name,
				round(sum(total_query_wait_time_ms)/1000,1) total_time
			from sys.query_store_runtime_stats_interval rsi
			inner join sys.query_store_wait_stats ws on rsi.runtime_stats_interval_id = ws.runtime_stats_interval_id
			where rsi.runtime_stats_interval_id >= @tr_start_interval_id and rsi.runtime_stats_interval_id <= @tr_end_interval_id
			and ws.wait_category = 6
			group by rsi.end_time)
			select CONCAT('+ "',CONVERT(VARCHAR(16), end_time,120),',',statistic_name,',',CAST( total_time AS DECIMAL(20,1)) ,'\n"') from x
	`)

	stmtWaitEvents := fmt.Sprintf(`
	with mapping as (
		select 'CPU' wait_category_new union
		select 'Worker Thread' wait_category_new union
		select 'Lock' wait_category_new union
		select 'Latch' wait_category_new union
		select 'Buffer Latch' wait_category_new union
		select 'Buffer IO' wait_category_new union
		select 'Idle' wait_category_new union
		select 'Preemptive' wait_category_new union
		select 'Tran Log IO' wait_category_new union
		select 'Network IO' wait_category_new union
		select 'Memory' wait_category_new union
		select 'Other Disk IO' wait_category_new union
		select 'Other' wait_category_new)
		, tr as (
			select wait_category_new, round(sum(total_query_wait_time_ms)/1000,1) total_time from
		(select rsi.end_time, wait_category, wait_category_desc, total_query_wait_time_ms, case when wait_category in (1,2,3,4,5,6,11,12,14,15,17,21) then wait_category_desc else 'Other' end wait_category_new
		from sys.query_store_runtime_stats_interval rsi
		inner join sys.query_store_wait_stats ws on rsi.runtime_stats_interval_id = ws.runtime_stats_interval_id
		where rsi.runtime_stats_interval_id >= @tr_start_interval_id and rsi.runtime_stats_interval_id <= @tr_end_interval_id) a
		group by wait_category_new
		)
		SELECT CONCAT('+ "',m.wait_category_new,',',m.wait_category_new,',',CAST(ISNULL(tr.total_time,0) as BIGINT),'\n"') from mapping m
		left join tr on tr.wait_category_new = m.wait_category_new
	`)

	stmtSqlText := fmt.Sprintf(`
		with tr as (
			SELECT DISTINCT query_id_t, query_hash_t FROM 
			(SELECT
			plan_id plan_id_t,
			query_plan_hash query_plan_hash_t,
			query_id query_id_t,
			query_hash query_hash_t,
			executions executions_t,
			duration duration_t,
			cpu_time cpu_time_t,
			logical_io_reads logical_io_reads_t,
			logical_io_writes logical_io_writes_t,
			physical_io_reads physical_io_reads_t,
			dop dop_t,
			query_max_used_memory query_max_used_memory_t,
			row_count row_count_t,
			num_physical_io_reads num_physical_io_reads_t,
			log_bytes_used log_bytes_used_t,
			tempdb_space_used tempdb_space_used_t,
			page_server_io_reads page_server_io_reads_t,
			IIF((duration - cpu_time)>0,(duration - cpu_time),0) wait_time_t,
			ROW_NUMBER() OVER (ORDER BY executions DESC) executions_r,
			ROW_NUMBER() OVER (ORDER BY duration DESC) duration_r,
			ROW_NUMBER() OVER (ORDER BY cpu_time DESC) cpu_time_r,
			ROW_NUMBER() OVER (ORDER BY logical_io_reads DESC) logical_io_reads_r,
			ROW_NUMBER() OVER (ORDER BY logical_io_writes DESC) logical_io_writes_r,
			ROW_NUMBER() OVER (ORDER BY physical_io_reads DESC) physical_io_reads_r,
			ROW_NUMBER() OVER (ORDER BY dop DESC) dop_r,
			ROW_NUMBER() OVER (ORDER BY query_max_used_memory DESC) query_max_used_memory_r,
			ROW_NUMBER() OVER (ORDER BY row_count DESC) row_count_r,
			ROW_NUMBER() OVER (ORDER BY num_physical_io_reads DESC) num_physical_io_reads_r,
			ROW_NUMBER() OVER (ORDER BY log_bytes_used DESC) log_bytes_used_r,
			ROW_NUMBER() OVER (ORDER BY tempdb_space_used DESC) tempdb_space_used_r,
			ROW_NUMBER() OVER (ORDER BY page_server_io_reads DESC) page_server_io_reads_r,
			ROW_NUMBER() OVER (ORDER BY IIF((duration - cpu_time)>0,(duration - cpu_time),0) DESC) wait_time_r
			FROM
			(SELECT
				rs.plan_id,
				p.query_plan_hash,
				q.query_id,
				q.query_hash,
				sum(count_executions) executions, 
				round(sum(count_executions*avg_duration),0) duration, -- micro
				round(sum(count_executions*avg_cpu_time),0) cpu_time, -- micro
				round(sum(count_executions*avg_logical_io_reads),0) logical_io_reads, -- pages
				round(sum(count_executions*avg_logical_io_writes),0) logical_io_writes, -- pages
				round(sum(count_executions*avg_physical_io_reads),0) physical_io_reads, -- pages
				round(sum(count_executions*avg_dop),0) dop,
				round(sum(count_executions*avg_query_max_used_memory),0) query_max_used_memory, --pages
				round(sum(count_executions*avg_rowcount),0) row_count,
				round(sum(count_executions*avg_num_physical_io_reads),0) num_physical_io_reads,
				round(sum(count_executions*avg_log_bytes_used),0) log_bytes_used,
				round(sum(count_executions*avg_tempdb_space_used),0) tempdb_space_used,
				round(sum(count_executions*0),0) page_server_io_reads --avg_page_server_io_reads
			from sys.query_store_runtime_stats_interval rsi
			inner join sys.query_store_runtime_stats rs on rsi.runtime_stats_interval_id = rs.runtime_stats_interval_id
			inner join sys.query_store_plan p on rs.plan_id = p.plan_id
			inner join sys.query_store_query q on q.query_id = p.query_id
			where rsi.runtime_stats_interval_id >= @tr_start_interval_id and rsi.runtime_stats_interval_id <= @tr_end_interval_id
			group by rs.plan_id, p.query_plan_hash, q.query_id, q.query_hash) a
			) c
			WHERE (executions_r<=20 AND executions_t>0) OR
			(duration_r<=20 AND duration_t>0) OR
			(cpu_time_r<=20 AND cpu_time_t>0) OR
			(logical_io_reads_r<=20 AND logical_io_reads_t>0) OR
			(logical_io_writes_r<=20 AND logical_io_writes_t>0) OR
			(physical_io_reads_r<=20 AND physical_io_reads_t>0) OR
			(dop_r<=20 AND dop_t>0) OR
			(query_max_used_memory_r<=20 AND query_max_used_memory_t>0) OR
			(row_count_r<=20 AND row_count_t>0) OR
			(num_physical_io_reads_r<=20 AND num_physical_io_reads_t>0) OR
			(log_bytes_used_r<=20 AND log_bytes_used_t>0) OR
			(tempdb_space_used_r<=20 AND tempdb_space_used_t>0) OR
			(page_server_io_reads_r<=20 AND page_server_io_reads_t>0)
			)
			, s as (select 0x5C832E8F5E5D3655 query_hash, 'sqlAlias' sql_type)
			, x as (SELECT case when s.query_hash is not null then s.sql_type
				else 'Unclassified' end sql_type
			, tr.query_id_t, query_hash_t, query_sql_text
			FROM tr
			INNER JOIN sys.query_store_query q ON tr.query_id_t=q.query_id
			INNER JOIN sys.query_store_query_text t ON q.query_text_id=t.query_text_id
			LEFT JOIN s  ON tr.query_hash_t=s.query_hash
			)
			SELECT  CONCAT('+ "',CONVERT(VARCHAR(MAX), query_hash_t, 1),'!@#!',sql_type,'!@#!',SUBSTRING(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(query_sql_text, '!@#!', ''), CHAR(13), ''), CHAR(10), ''),'"',''),'\n',''),1,5000),'\n"') from x
	`)

	writeFile(f, "\n")

	// csvDbSummary

	writeFile(f, "csvDbSummary = csvDbSummary\n")

	rowsDbSummary, err := db.QueryContext(ctx, stmtDbSummary, sql.Named("sqldbserver", server), sql.Named("sqldbname", database), sql.Named("tr_start_interval_id", tr_start_interval_id), sql.Named("tr_end_interval_id", tr_end_interval_id))
	if err != nil {
		println("Error csvDbSummary")
		return "", err
	}

	defer rowsDbSummary.Close()

	// Iterate through the result set.
	for rowsDbSummary.Next() {
		var x string

		// Get values from row.
		err := rowsDbSummary.Scan(&x)
		if err != nil {
			return "", err
		}

		writeFile(f, x+"\n")

	}

	writeFile(f, ";\n\n")

	// csvSqlStatsTable

	writeFile(f, "csvSqlStatsTable = csvSqlStatsTable\n")

	rowsSqlStatsTable, err := db.QueryContext(ctx, stmtSqlStatsTable, sql.Named("tr_start_interval_id", tr_start_interval_id), sql.Named("tr_end_interval_id", tr_end_interval_id))
	if err != nil {
		println("Error csvSqlStatsTable")
		return "", err
	}

	defer rowsSqlStatsTable.Close()

	// Iterate through the result set.
	for rowsSqlStatsTable.Next() {
		var x string

		// Get values from row.
		err := rowsSqlStatsTable.Scan(&x)
		if err != nil {
			return "", err
		}

		writeFile(f, x+"\n")

	}

	writeFile(f, ";\n\n")

	// csvSqlStatsChart

	writeFile(f, "csvSqlStatsChart = csvSqlStatsChart\n")

	rowsSqlStatsChart, err := db.QueryContext(ctx, stmtSqlStatsChart, sql.Named("tr_start_interval_id", tr_start_interval_id), sql.Named("tr_end_interval_id", tr_end_interval_id))
	if err != nil {
		println("Error csvSqlStatsChart")
		return "", err
	}

	defer rowsSqlStatsChart.Close()

	// Iterate through the result set.
	for rowsSqlStatsChart.Next() {
		var x string

		// Get values from row.
		err := rowsSqlStatsChart.Scan(&x)
		if err != nil {
			return "", err
		}

		writeFile(f, x+"\n")

	}

	writeFile(f, ";\n\n")

	// csvDbTimeTr

	writeFile(f, "csvDbTimeTr = csvDbTimeTr\n")

	rowsDbTimeTr, err := db.QueryContext(ctx, stmtDbTimeTr, sql.Named("tr_start_interval_id", tr_start_interval_id), sql.Named("tr_end_interval_id", tr_end_interval_id))
	if err != nil {
		println("Error csvDbTimeTr")
		return "", err
	}

	defer rowsDbTimeTr.Close()

	// Iterate through the result set.
	for rowsDbTimeTr.Next() {
		var x string

		// Get values from row.
		err := rowsDbTimeTr.Scan(&x)
		if err != nil {
			return "", err
		}

		writeFile(f, x+"\n")

	}

	writeFile(f, ";\n\n")

	// csvWaitEvents

	writeFile(f, "csvWaitEvents = csvWaitEvents\n")

	rowsWaitEvents, err := db.QueryContext(ctx, stmtWaitEvents, sql.Named("tr_start_interval_id", tr_start_interval_id), sql.Named("tr_end_interval_id", tr_end_interval_id))
	if err != nil {
		println("Error csvWaitEvents")
		return "", err
	}

	defer rowsWaitEvents.Close()

	// Iterate through the result set.
	for rowsWaitEvents.Next() {
		var x string

		// Get values from row.
		err := rowsWaitEvents.Scan(&x)
		if err != nil {
			return "", err
		}

		writeFile(f, x+"\n")

	}

	writeFile(f, ";\n\n")

	// csvSqlText

	writeFile(f, "csvSqlText = csvSqlText\n")

	rowsSqlText, err := db.QueryContext(ctx, stmtSqlText, sql.Named("tr_start_interval_id", tr_start_interval_id), sql.Named("tr_end_interval_id", tr_end_interval_id))
	if err != nil {
		println("Error csvSqlText")
		return "", err
	}

	defer rowsSqlText.Close()

	// Iterate through the result set.
	for rowsSqlText.Next() {
		var x string

		// Get values from row.
		err := rowsSqlText.Scan(&x)
		if err != nil {
			return "", err
		}

		writeFile(f, x+"\n")

	}

	writeFile(f, ";\n\n")

	n5, err := f.Write(footerFileContent)
	check(err)

	if n2+n5 <= n2 {
		fmt.Println("Report is written with errors to: " + fileName)
	}

	return fileName, nil
}

func downloadPlanById(pPlanId int) (string, error) {

	var rowCount int
	var fileName string

	fmt.Println("Downloading execution plan ... ")

	ctx := context.Background()

	// Check if database is alive.
	err1 := db.PingContext(ctx)
	if err1 != nil {
		return "", err1
	}

	stmtSqlPlan := `SELECT TOP(1) query_id, plan_id, query_plan FROM sys.query_store_plan where plan_id = @pPlanId`

	rowsSqlPlan, err := db.QueryContext(ctx, stmtSqlPlan, sql.Named("pPlanId", pPlanId))
	if err != nil {
		return "", err
	}

	defer rowsSqlPlan.Close()

	// Iterate through the result set.
	for rowsSqlPlan.Next() {

		var queryID int
		var planID int
		var queryPlanXml string

		// Get values from row.
		err := rowsSqlPlan.Scan(&queryID, &planID, &queryPlanXml)
		if err != nil {
			return "", err
		}

		rowCount = rowCount + 1

		fileName = fmt.Sprint("plans/", database, "-", queryID, "-", planID, ".sqlplan")

		f := createFile(fileName)
		defer closeFile(f)

		writeFile(f, queryPlanXml)

	}

	if rowCount > 0 {
		return fileName, err
	} else {
		return "", err
	}

}

func createFile(p string) *os.File {

	f, err := os.Create(p)
	if err != nil {
		panic(err)
	}
	return f
}

func writeFile(f *os.File, s string) {

	fmt.Fprintln(f, s)
}

func closeFile(f *os.File) {

	err := f.Close()
	if err != nil {
		fmt.Fprintf(os.Stderr, "error: %v\n", err)
		os.Exit(1)
	}
}
