/*
 -- XDBTIME - Database Performance - Period Comparison Report (for XE and SE editions with no AWR pack)
 -- Copyright (c) 2016, 2020, XDBTIME.  All rights reserved.
 -- filename: xdbtimeorclxdbs.sql


 -- description: SQL script to generate Database Performance Comparison report for Oracle
 -- database: Oracle 12c-19c Express and Standard Editions (for single instance only).
 -- how to use: 
 -- 	connect to pdb database. Privileges are required to access XDBSNAPSHOT scheme and gv$ views
 -- 	provide 8 parameters. Two time periods with 4 parameters each:
 --			1. Baseline: START_SNAP_ID 
 --			2. Baseline: END_SNAP_ID
 --			3. Test run: START_SNAP_ID 
 --			4. Test run: END_SNAP_ID
 -- how does it work: SQL file spools into HTML file (HTML, CSS, JS, D3). D3 Copyright 2010-2017 Mike Bostock https://github.com/d3/d3/blob/master/LICENSE
 -- 				  You can use xdbslistsnap.sql to list snapshots 
 -- example: 
	-- -- SQL> @xdbtimeorclxdbs.sql
	-- -- Enter parameters for Baseline
	-- -- Baseline: Enter Start Snapshot ID: 1743
	-- -- Baseline: Enter End Snapshot ID: 1755
	-- -- Enter parameters for Test Run
	-- -- Test Run: Enter Start Snapshot ID: 1732
	-- -- Test Run: Enter End Snapshot ID: 1740
	-- -- Baseline:
	-- -- Range of samples: [1743,1755]
	-- -- Range of time   : [04/01/2020 12:31,04/01/2020 13:31]
	-- -- Test Run:
	-- -- Range of samples: [1732,1740]
	-- -- Range of time   : [04/01/2020 11:36,04/01/2020 12:16]
	-- -- Report is running ...
	-- -- Report is written to /Users/xdbtime/Reports/XDBT_1434084074_FETZ1POD_1743to1755vs1732to1740.html
*/
set echo off;
set pages 0;
set veri off;
set feedback off;
set heading off;
set linesize 2100;
set trimspool on;
set termout off;
set echo off heading on underline on;
column start_time new_value start_time;
column finish_time new_value finish_time;
column file_name new_value file_name;
column html_name new_value html_name;
column test_run_id_br new_value test_run_id_br;
column test_run_id_tr new_value test_run_id_tr;
column start_sample_id_br new_value start_sample_id_br;
column finish_sample_id_br new_value finish_sample_id_br;
column start_sample_time_br new_value start_sample_time_br;
column finish_sample_time_br new_value finish_sample_time_br;
column start_sample_id_tr new_value start_sample_id_tr;
column finish_sample_id_tr new_value finish_sample_id_tr;
column start_sample_time_tr new_value start_sample_time_tr;
column finish_sample_time_tr new_value finish_sample_time_tr;
define report_destination_folder = '/Users/'

set termout on;
prompt Enter parameters for Baseline
accept blstartsnap char prompt 'Baseline: Enter Start Snapshot ID: '
accept blendsnap char prompt 'Baseline: Enter End Snapshot ID: '

prompt Enter parameters for Test Run
accept trstartsnap char prompt 'Test Run: Enter Start Snapshot ID: '
accept trendsnap char prompt 'Test Run: Enter End Snapshot ID: '
set termout off;

select sample_id start_sample_id_br from XDBSNAPSHOT.tbl_snapshot where sample_id = &blstartsnap;
select sample_id finish_sample_id_br from XDBSNAPSHOT.tbl_snapshot where sample_id = &blendsnap;
select sample_id start_sample_id_tr from XDBSNAPSHOT.tbl_snapshot where sample_id = &trstartsnap;
select sample_id finish_sample_id_tr from XDBSNAPSHOT.tbl_snapshot where sample_id = &trendsnap;
select TO_CHAR(sample_time,'DD/MM/YYYY HH24:MI') start_sample_time_br from XDBSNAPSHOT.tbl_snapshot where sample_id = &start_sample_id_br;
select TO_CHAR(sample_time,'DD/MM/YYYY HH24:MI') finish_sample_time_br from XDBSNAPSHOT.tbl_snapshot where sample_id = &finish_sample_id_br;
select TO_CHAR(sample_time,'DD/MM/YYYY HH24:MI') start_sample_time_tr from XDBSNAPSHOT.tbl_snapshot where sample_id = &start_sample_id_tr;
select TO_CHAR(sample_time,'DD/MM/YYYY HH24:MI') finish_sample_time_tr from XDBSNAPSHOT.tbl_snapshot where sample_id = &finish_sample_id_tr;

select '&report_destination_folder'||'XDBT_'||to_char(dbid)||'_'||name||'_'||'&start_sample_id_br'||'to'||'&finish_sample_id_br'||'vs'||'&start_sample_id_tr'||'to'||'&finish_sample_id_tr'||'.html' file_name, 'DB_Perf_'||to_char(dbid)||'_'||name||'_'||'&start_sample_id_br'||'to'||'&finish_sample_id_br'||'vs'||'&start_sample_id_tr'||'to'||'&finish_sample_id_tr' html_name from v$database;

set termout on;
prompt Baseline:
prompt Range of samples: [&start_sample_id_br,&finish_sample_id_br]
prompt Range of time   : [&start_sample_time_br,&finish_sample_time_br]
prompt Test Run:
prompt Range of samples: [&start_sample_id_tr,&finish_sample_id_tr]
prompt Range of time   : [&start_sample_time_tr,&finish_sample_time_tr]
prompt Report is running ...
set termout off;
spool &file_name;
prompt  <!DOCTYPE html>
prompt  <html lang="en">
prompt  <head>
prompt    <meta charset="UTF-8">
prompt    <meta name="viewport" content="width=device-width, initial-scale=1.0">
prompt    <meta http-equiv="X-UA-Compatible" content="ie=edge">
set define off;
prompt    <title>xdbtime &mdash; Oracle</title>
prompt    <link rel="shortcut icon" href="https://www.xdbtime.com/images/favicon.png">
prompt    <link href="https://fonts.googleapis.com/css?family=Lato&display=swap" rel="stylesheet">
set define on;
prompt    <style>
prompt        @media print {body {-webkit-print-color-adjust:exact;}}
prompt
prompt        body {
prompt          color: #333;;
prompt          margin: 0;;
prompt        }
prompt
prompt        .main-wrapper {
prompt          max-width: 100rem;;
prompt          margin: auto;;
prompt        }
prompt
prompt        main {
prompt        border-width: 1px 0;;
prompt        border-style: solid;;
prompt        }
prompt
prompt        h2 {
prompt        margin: 0;;
prompt        }
prompt
prompt        main > div + h2 {
prompt        border-top: 1px solid;;
prompt        }
prompt
prompt        h2 button {
prompt        all: inherit;;
prompt        border: 0;;
prompt        display: flex;;
prompt        justify-content: space-between;;
prompt        width: 100%;;
prompt        padding: 0.5em 0;;
prompt        }
prompt
prompt        h2 button:focus svg {
prompt        outline: 1px solid;;
prompt        }
prompt
prompt        button svg {
prompt        height: 1em;;
prompt        margin-left: 0.5em;;
prompt        }
prompt
prompt        [aria-expanded="true"].vert {
prompt        display: none;;
prompt        }
prompt
prompt        [aria-expanded] rect {
prompt        fill: currentColor;;
prompt        }
prompt
prompt        html {
prompt            font-family: 'Lato', sans-serif;;
prompt
prompt        }
prompt
prompt        * {
prompt        box-sizing: border-box;;
prompt        }
prompt
prompt        .chartColorDark {fill:#444;}
prompt        .chartColorLight {fill:#999;}
prompt        text {fill:#999;}
prompt        .axis path,
prompt        .axis line {
prompt        fill: none;;
prompt        stroke: #999;;
prompt        }
prompt
prompt        path.domain {
prompt        stroke: none;;
prompt        }
prompt
prompt        .axis-grid line {
prompt          stroke: rgba(0, 0, 0, 0.103);;
prompt        }
prompt
prompt        .y .tick line {
prompt        stroke: #ddd;;
prompt        }
prompt
prompt        table {
prompt        font-size: 12px;;
prompt        /* width:80%; */
prompt        }
prompt        td {
prompt        border-bottom: 0.5px solid #ddd;;
prompt        }
prompt        th {
prompt        font-weight: bold;;
prompt        background-color: #999;;
prompt        color: white;;
prompt        }
prompt        tr:hover {
prompt        background-color: #f5f5f5;;
prompt        }
prompt        .header {
prompt          background: #65a1ac;;
prompt          /* font-weight: bold; */
prompt          color: white;;
prompt          position: fixed;;
prompt          top: 0;;
prompt          width: 100%;;
prompt          padding: 12px;;
prompt        }
prompt        </style>
prompt
prompt  </head>
prompt  <body>
prompt    <header class="header">
prompt    <a href="https://www.xdbtime.com">  
prompt    	<img src="https://www.xdbtime.com/images/logo-white.png" alt="" height="25" /> 
prompt    </a>
prompt    </header>
prompt    <div class="main-wrapper" id="main-wrapper">
prompt
prompt
prompt      <h1>Database Performance Comparison Report</h1>
prompt      <h5>for Oracle 12c - 19c XE/SE editions (based on xdbsnapshot schema)</h5>
prompt      <div id="chartMain">  </div>
prompt      <main>
prompt        <h2>
prompt          <button aria-expanded="false" >
prompt            System Time Model
prompt            <svg aria-hidden="true" focusable="false" viewBox="0 0 10 10">
prompt              <rect class="vert" height="8" width="2" y="1" x="4"/>
prompt              <rect height="2" width="8" y="4" x="1"/>
prompt            </svg>
prompt          </button>
prompt        </h2>
prompt        <div id="chartSysTimeModel" hidden>
prompt          <p>System Time Model table data is based on v$sys_time_model view </p>
prompt        </div>
prompt        <h2>
prompt          <button aria-expanded="false" >
prompt            Database Time
prompt            <svg aria-hidden="true" focusable="false" viewBox="0 0 10 10">
prompt              <rect class="vert" height="8" width="2" y="1" x="4"/>
prompt              <rect height="2" width="8" y="4" x="1"/>
prompt            </svg>
prompt          </button>
prompt        </h2>
prompt        <div id="chartDbTime" hidden>
prompt          <p>Database Time charts are based on v$sys_time_model view (DB Time, CPU Time) and v$sysstat view (User IO wait time). Other Waits are calculated as difference between DB Time, DB CPU and User IO Time </p>
prompt        </div>
prompt        <h2>
prompt          <button aria-expanded="false" >
prompt            Wait Classes
prompt            <svg aria-hidden="true" focusable="false" viewBox="0 0 10 10">
prompt              <rect class="vert" height="8" width="2" y="1" x="4"/>
prompt              <rect height="2" width="8" y="4" x="1"/>
prompt            </svg>
prompt          </button>
prompt        </h2>
prompt        <div id="chartWaitClasses" hidden>
prompt          <p>Wait Classes charts are based on v$system_event view  </p>
prompt        </div>
prompt        <h2>
prompt          <button aria-expanded="false" >
prompt            Active Session History
prompt            <svg aria-hidden="true" focusable="false" viewBox="0 0 10 10">
prompt              <rect class="vert" height="8" width="2" y="1" x="4"/>
prompt              <rect height="2" width="8" y="4" x="1"/>
prompt            </svg>
prompt          </button>
prompt        </h2>
prompt        <div id="chartAsh" hidden>
prompt          <p>Active Session History is based on v$session view </p>
prompt        </div>
prompt        <h2>
prompt          <button aria-expanded="false" >
prompt            SQL statistics charts
prompt            <svg aria-hidden="true" focusable="false" viewBox="0 0 10 10">
prompt              <rect class="vert" height="8" width="2" y="1" x="4"/>
prompt              <rect height="2" width="8" y="4" x="1"/>
prompt            </svg>
prompt          </button>
prompt        </h2>
prompt        <div id="chartSqlStatCharts" hidden>
prompt          <p>SQL Statistics charts are based on v$sqlstats view. SQL statistics are grouped by SQL_ID and execution plan. SQL classification is based on SQL_ID. There are 3 default classes: Aged Out, New and Unclassified. </p>
prompt        </div>
prompt        <h2>
prompt          <button aria-expanded="false" >
prompt            SQL Statistics tables
prompt            <svg aria-hidden="true" focusable="false" viewBox="0 0 10 10">
prompt              <rect class="vert" height="8" width="2" y="1" x="4"/>
prompt              <rect height="2" width="8" y="4" x="1"/>
prompt            </svg>
prompt          </button>
prompt        </h2>
prompt        <div id="chartSqlStatTables" hidden>
prompt          <p>SQL statistics tables are based on v$sqlstats view.SQL statistics are grouped by SQL_ID and execution plan. SQL classification is based on SQL_ID. There are 3 default classes: Aged Out, New and Unclassified. </p>
prompt        </div>
prompt        <h2>
prompt          <button aria-expanded="false" >
prompt            System Statistics
prompt            <svg aria-hidden="true" focusable="false" viewBox="0 0 10 10">
prompt              <rect class="vert" height="8" width="2" y="1" x="4"/>
prompt              <rect height="2" width="8" y="4" x="1"/>
prompt            </svg>
prompt          </button>
prompt        </h2>
prompt        <div id="chartSysStat" hidden>
prompt          <p>System Statistics are based on v$sysstat view </p>
prompt        </div>
prompt        <h2>
prompt          <button aria-expanded="false" >
prompt            SQL Text
prompt            <svg aria-hidden="true" focusable="false" viewBox="0 0 10 10">
prompt              <rect class="vert" height="8" width="2" y="1" x="4"/>
prompt              <rect height="2" width="8" y="4" x="1"/>
prompt            </svg>
prompt          </button>
prompt        </h2>
prompt        <div id="chartSqlText" hidden>
prompt          <p>SQL text is based on TBL_SQL_TEXT </p>
prompt        </div>
prompt      </main>
prompt    </div>
prompt    </body>
prompt    </html>
prompt
prompt
prompt    <script src="https://d3js.org/d3.v4.js"></script>
prompt    <script src="https://d3js.org/d3-scale-chromatic.v1.min.js"></script>
prompt  <script type="text/javascript">
prompt
prompt  const getWrapperWidth = () => {
prompt    const wr = document.getElementById('main-wrapper');;
prompt    return wr.getBoundingClientRect().width;;
prompt  }
prompt
prompt  // Header
prompt  const header = document.querySelector('.header');;
prompt  const headerHeight = header.getBoundingClientRect().height;;
prompt  const preHeader = document.createElement('div');;
prompt  preHeader.style.height = headerHeight + 'px';;
prompt  document.body.prepend(preHeader);;
prompt
prompt  window.addEventListener('resize', () => {
prompt      console.log(getWrapperWidth());;
prompt      // TODO: renderAllComponents
prompt  });;
prompt
prompt  const headings = document.querySelectorAll('h2');;
prompt
prompt  headings.forEach(h => {
prompt    let btn = h.querySelector('button');;
prompt    let target = h.nextElementSibling;;
prompt
prompt    btn.onclick = () => {
prompt      let expanded = btn.getAttribute('aria-expanded') === 'true';;
prompt
prompt      btn.setAttribute('aria-expanded',!expanded);;
prompt      target.hidden = expanded;;
prompt    }
prompt  });;
prompt
prompt
prompt  var totalCpu = 0;;
prompt  var totalUserIO = 0;;
prompt  var totalOther = 0;;
prompt
prompt  var dbTimeParse = function (startTime, endTime, dbTimeInputData) {
prompt
prompt  var dbTimeArray = [];;
prompt
prompt  totalCpu = 0;;
prompt  totalUserIO = 0;;
prompt  totalOther = 0;;
prompt
prompt  if (dbTimeInputData.length > 0) {
prompt
prompt  var i1 = 0;;
prompt
prompt  var w1 = 0;;
prompt  var w2 = 0;;
prompt  var w3 = 0;;
prompt
prompt  var myObj = {date: startTime
prompt  , 'DB CPU': w1
prompt  , 'User I/O': w3
prompt  , 'Other': w2 - w3 - w1
prompt  , total: w2
prompt  }
prompt  dbTimeArray.push(myObj);;
prompt
prompt  startTime = dbTimeInputData[i1].date;;
prompt
prompt  while ((startTime <= endTime) &&(dbTimeInputData.length > i1))
prompt  {
prompt  while ((dbTimeInputData.length > i1) &&(dbTimeInputData[i1].date.getTime() === startTime.getTime()))
prompt  {
prompt  switch (dbTimeInputData[i1].key)
prompt  {
prompt  case "DB CPU": w1 = dbTimeInputData[i1].value; break;;
prompt  case "DB Time": w2 = dbTimeInputData[i1].value; break;;
prompt  case "User I/O": w3 = dbTimeInputData[i1].value; break;;
prompt  }
prompt  i1 = i1 + 1;;
prompt  }
prompt  var myObj = {date: startTime
prompt  , 'DB CPU': w1
prompt  , 'User I/O': w3
prompt  , 'Other': w2 - w3 - w1
prompt  , total: w2
prompt  }
prompt  dbTimeArray.push(myObj);;
prompt
prompt  totalCpu += w1;;
prompt  totalUserIO += w3;;
prompt  totalOther += w2 - w3 - w1;;
prompt
prompt  w1 = 0;;
prompt  w2 = 0;;
prompt  w3 = 0;;
prompt
prompt
prompt
prompt  if (dbTimeInputData.length > i1) {
prompt  startTime = dbTimeInputData[i1].date;;
prompt  }
prompt
prompt
prompt  }
prompt  }
prompt  return dbTimeArray
prompt  }
prompt
prompt  var ashParse = function (startTime, endTime, ashInputData) {
prompt
prompt  var ashArray = [];;
prompt
prompt  if (ashInputData.length > 0) {
prompt
prompt  var i1 = 0;;
prompt
prompt  var w1 = 0;;
prompt  var w2 = 0;;
prompt  var w3 = 0;;
prompt  var w4 = 0;;
prompt  var w5 = 0;;
prompt  var w6 = 0;;
prompt  var w7 = 0;;
prompt  var w8 = 0;;
prompt  var w9 = 0;;
prompt  var w10 = 0;;
prompt  var w11 = 0;;
prompt  var w12 = 0;;
prompt  var w13 = 0;;
prompt
prompt  startTime = ashInputData[i1].date;;
prompt
prompt  while ((startTime <= endTime) &&(ashInputData.length > i1))
prompt  {
prompt  while ((ashInputData.length > i1) &&(ashInputData[i1].date.getTime() === startTime.getTime()))
prompt  {
prompt  switch (ashInputData[i1].key)
prompt  {
prompt  case "CPU": w1 = ashInputData[i1].value; break;;
prompt  case "Scheduler": w2 = ashInputData[i1].value; break;;
prompt  case "User I/O": w3 = ashInputData[i1].value; break;;
prompt  case "System I/O": w4 = ashInputData[i1].value; break;;
prompt  case "Concurrency": w5 = ashInputData[i1].value; break;;
prompt  case "Application": w6 = ashInputData[i1].value; break;;
prompt  case "Commit": w7 = ashInputData[i1].value; break;;
prompt  case "Configuration": w8 = ashInputData[i1].value; break;;
prompt  case "Administrative": w9 = ashInputData[i1].value; break;;
prompt  case "Network": w10 = ashInputData[i1].value; break;;
prompt  case "Queueing": w11 = ashInputData[i1].value; break;;
prompt  case "Cluster": w12 = ashInputData[i1].value; break;;
prompt  case "Other": w13 = ashInputData[i1].value; break;;
prompt  }
prompt  i1 = i1 + 1;;
prompt  }
prompt  var myObj = {date: startTime
prompt  , CPU: w1
prompt  , Scheduler: w2
prompt  , 'User I/O': w3
prompt  , 'System I/O': w4
prompt  , Concurrency: w5
prompt  , Application: w6
prompt  , Commit: w7
prompt  , Configuration: w8
prompt  , Administrative: w9
prompt  , Network: w10
prompt  , Queueing: w11
prompt  , Cluster: w12
prompt  , Other: w13
prompt
prompt
prompt  , total: w1+w2+w3+w4+w5+w6+w7+w8+w9+w10+w11+w12+w13
prompt  }
prompt  ashArray.push(myObj);;
prompt
prompt  var w1 = 0;;
prompt  var w2 = 0;;
prompt  var w3 = 0;;
prompt  var w4 = 0;;
prompt  var w5 = 0;;
prompt  var w6 = 0;;
prompt  var w7 = 0;;
prompt  var w8 = 0;;
prompt  var w9 = 0;;
prompt  var w10 = 0;;
prompt  var w11 = 0;;
prompt  var w12 = 0;;
prompt  var w13 = 0;;
prompt
prompt  if (ashInputData.length > i1) {
prompt  startTime = ashInputData[i1].date;;
prompt  }
prompt
prompt
prompt  }
prompt  }
prompt  return ashArray
prompt  }
prompt
prompt
prompt
prompt  var svgStackedAreaDraw = function (svgWidth, svgHeight, inpArray, svgObjName, withLegend, chartTitle, chartSubTitle, minDate, maxDate, maxX, pKeys, pColors, pAxisName) {
prompt  var margin = {top: 100, right: 100, bottom: 30, left: 40},
prompt  width = svgWidth - margin.left - margin.right,
prompt  height = svgHeight - margin.top - margin.bottom;;
prompt  var x = d3.scaleTime().range([0, width]),
prompt  y = d3.scaleLinear().range([height, 0]),
prompt  z = pColors;;
prompt
prompt  var stack = d3.stack();;
prompt
prompt  var area = d3.area()
prompt  .x(function(d, i){ return x(d.data.date);})
prompt  .y0(function(d) {return y(d[0]); })
prompt  .y1(function(d) {return y(d[1]); })
prompt  .curve(d3.curveMonotoneX);;
prompt
prompt  y.domain([0, maxX]).nice();;
prompt  z.domain(pKeys);;
prompt  stack.keys(pKeys);;
prompt
prompt  var svgStackedArea = d3.select(svgObjName).append("svg")
prompt  .attr("width", width + margin.left + margin.right)
prompt  .attr("height", height + margin.top + margin.bottom);;
prompt
prompt  var g = svgStackedArea.append("g")
prompt  .attr("transform", "translate(" + margin.left + "," + margin.top + ")");;
prompt
prompt  x.domain([minDate, maxDate]);;
prompt
prompt  g.append("g")
prompt    .attr("class", "axis-grid")
prompt    .call(d3.axisLeft(y).tickSize(-width).tickFormat('').ticks(10));;
prompt
prompt  var layer = g.selectAll(".layer")
prompt  .data(stack(inpArray))
prompt  .enter().append("g")
prompt  .attr("class", "layer");;
prompt  layer.append("path")
prompt  .attr("class","area")
prompt  .style("fill", function(d) {return z(d.key);})
prompt  .attr("d", area);;
prompt  g.append("g")
prompt  .attr("class", "axis axis--x")
prompt  .attr("transform", "translate(0, " + height +")")
prompt  .call(d3.axisBottom(x));;
prompt  g.append("g")
prompt  .attr("class", "axis axis--y")
prompt  .call(d3.axisLeft(y).ticks(null, "s"));;
prompt  g.append("g")
prompt  .attr("class", "axis")
prompt  .call(d3.axisLeft(y).ticks(null, "s"))
prompt  .append("text")
prompt  .attr("x", 2)
prompt  .attr("y", y(y.ticks().pop()) + 0.5)
prompt  .attr("dy", "0.32em")
prompt  .attr("class", "chartColorLight")
prompt  .attr("text-anchor", "start")
prompt  .text(pAxisName);;
prompt  g.append("text")
prompt  .attr("x", 0 )
prompt  .attr("y", 0 - (margin.top / 2))
prompt  .attr("text-anchor", "left")
prompt  .attr("class", "chartColorDark")
prompt  .style("font-size","26px")
prompt  .text(chartTitle);;
prompt
prompt  g.append("text")
prompt  .attr("x", 0 )
prompt  .attr("y", 0 - (margin.top / 4))
prompt  .attr("text-anchor", "left")
prompt  .style("font-size","12px")
prompt  .text(chartSubTitle);;
prompt
prompt  if (withLegend == 1) {
prompt  var legend = g.append("g")
prompt  .attr("font-size","10px")
prompt  .attr("text-anchor", "begin")
prompt  .selectAll("g")
prompt  .data(pKeys.slice().reverse())
prompt  .enter().append("g")
prompt  .attr("transform", function(d, i) {return "translate(0," + i * 20 + ")";});;
prompt  legend.append("rect")
prompt  .attr("x", width+15)
prompt  .attr("width", 13)
prompt  .attr("height", 13)
prompt  .attr("fill", z);;
prompt  legend.append("text")
prompt  .attr("x", width + 36)
prompt  .attr("y", 6.5)
prompt  .attr("dy", "0.32em")
prompt  .text(function(d) {return d; });;
prompt
prompt  }
prompt  return svgStackedArea;;
prompt  }
prompt
prompt
prompt  var svgBarChartDraw = function (svgWidth, svgHeight, statName, svgObjName, pColors, chartName, axisName) {
prompt  var margin = {top: 100, right: 20, bottom: 30, left: 40},
prompt  width = svgWidth - margin.left - margin.right,
prompt  height = svgHeight - margin.top - margin.bottom;;
prompt
prompt  var x = d3.scaleBand()
prompt  .rangeRound([0, width-200])
prompt  .paddingInner(0.05)
prompt  .align(0.1);;
prompt  var y = d3.scaleLinear().rangeRound([height, 0]);;
prompt  var z = pColors;;
prompt
prompt  var barChartData = statName;;
prompt  var keys = barChartData.columns;;
prompt
prompt
prompt  var stack = d3.stack();;
prompt
prompt  var area = d3.area()
prompt  .x(function(d, i){ return x(d.data.date);})
prompt  .y0(function(d) {return y(d[0]); })
prompt  .y1(function(d) {return y(d[1]); })
prompt  .curve(d3.curveMonotoneX)
prompt  ;;
prompt
prompt  x.domain(barChartData.map(function(d) {return d.series; }));;
prompt  y.domain([0, 1.05*d3.max(barChartData, function(d) {return d.total; } )]).nice();;
prompt  z.domain(keys);;
prompt
prompt
prompt  var svgBarChart = d3.select(svgObjName).append("svg")
prompt  .attr("width", width + margin.left + margin.right)
prompt  .attr("height", height + margin.top + margin.bottom);;
prompt
prompt  var g = svgBarChart.append("g")
prompt  .attr("transform", "translate(" + margin.left + "," + margin.top + ")");;
prompt
prompt
prompt
prompt  g.append("g")
prompt  .selectAll("g")
prompt  .data(d3.stack().keys(keys)(barChartData))
prompt  .enter().append("g")
prompt  .attr("fill", function(d) {return z(d.key); })
prompt  .selectAll("rect")
prompt  .data(function(d) {return d;})
prompt  .enter().append("rect")
prompt  .attr("x", function(d) {return x(d.data.series); })
prompt  .attr("y", function(d) {return y(d[1]); })
prompt  .attr("height", function(d) { return y(d[0]) - y(d[1]); })
prompt  .attr("width", x.bandwidth());;
prompt
prompt  g.append("g")
prompt  .attr("class", "axis")
prompt  .attr("transform", "translate(0, " + height +")")
prompt  .call(d3.axisBottom(x));;
prompt
prompt
prompt  g.append("g")
prompt  .attr("class", "axis")
prompt  .call(d3.axisLeft(y).ticks(null, "s"))
prompt  .append("text")
prompt  .attr("x", 2)
prompt  .attr("y", y(y.ticks().pop()) + 0.5)
prompt  .attr("dy", "0.32em")
prompt  .attr("fill", "#000")
prompt  .attr("text-anchor", "start")
prompt  .text(axisName);;
prompt  g.append("text")
prompt  .attr("x", 0 )
prompt  .attr("y", 0 - (margin.top / 2))
prompt  .attr("text-anchor", "left")
prompt  .attr("class", "chartColorDark")
prompt  .style("font-size","26px")
prompt  .text(chartName);;
prompt  var legend = g.append("g")
prompt  .attr("font-size","10px")
prompt  .attr("text-anchor", "begin")
prompt  .selectAll("g")
prompt  .data(keys.slice().reverse())
prompt  .enter().append("g")
prompt  .attr("transform", function(d, i) {return "translate(0," + i * 20 + ")";});;
prompt  legend.append("rect")
prompt  .attr("x", width-180)
prompt  .attr("width", 13)
prompt  .attr("height", 13)
prompt  .attr("fill", z);;
prompt  legend.append("text")
prompt  .attr("x", width - 160)
prompt  .attr("y", 6.5)
prompt  .attr("dy", "0.32em")
prompt  .text(function(d) {return d; });;
prompt
prompt  return svgBarChart;;
prompt  }
prompt
prompt  function getMaxDiffSqlStat(statName) {
prompt  var maxValue = d3.max(sqlStats[statName], function(d) {return d3.max([0,d[sqlStatsTableDetails[statName]["colDiff"]]]);});;
prompt  if (maxValue == 0) {return 0.01} else {return maxValue;}
prompt  }
prompt
prompt  function getMinDiffSqlStat(statName) {
prompt  var minValue = d3.min(sqlStats[statName], function(d) {return d3.min([d[sqlStatsTableDetails[statName]["colDiff"]],0]);});;
prompt  if (minValue == 0) {return 0.01} else {return minValue}
prompt  }
prompt
prompt  function sqlTableSummaryText(statName) {
prompt  var outputString = percentFormat(d3.sum(sqlStats[statName], function(d) {return d[sqlStatsTableDetails[statName]["colShare"]];})) + " of " + sqlStatsTableDetails[statName]["description"] + " is covered by TOP " +
prompt  timeFormat(d3.max(sqlStats[statName], function(d) {return d["RANK"];})) + " SQLs found in v$sqlstat view. ";;
prompt
prompt  if (d3.sum(sqlStats[statName], function(d) {return d[sqlStatsTableDetails[statName]["colDiff"]];}) > 0)
prompt  {
prompt  outputString = outputString + sqlStatsTableDetails[statName]["description"] + " (TOP " + timeFormat(d3.max(sqlStats[statName], function(d) {return d["RANK"];})) + " SQLs) has been increased by "
prompt  + outputFormat(sqlStatsTableDetails[statName]["colDiff"], d3.sum(sqlStats[statName], function(d) {return d[sqlStatsTableDetails[statName]["colDiff"]];})) + " units (from "
prompt  + outputFormat(sqlStatsTableDetails[statName]["colDiff"], d3.sum(sqlStats[statName], function(d) {return d[sqlStatsTableDetails[statName]["colBaseline"]];})) + " to "
prompt  + outputFormat(sqlStatsTableDetails[statName]["colDiff"], d3.sum(sqlStats[statName], function(d) {return d[sqlStatsTableDetails[statName]["colTestrun"]];})) + " ).";;
prompt  return outputString;;
prompt  }
prompt  else
prompt  {
prompt  outputString = outputString + sqlStatsTableDetails[statName]["description"] + " (TOP " + timeFormat(d3.max(sqlStats[statName], function(d) {return d["RANK"];})) + " SQLs) has been decreased by "
prompt  + outputFormat(sqlStatsTableDetails[statName]["colDiff"], -1 * d3.sum(sqlStats[statName], function(d) {return d[sqlStatsTableDetails[statName]["colDiff"]];})) + " units (from "
prompt  + outputFormat(sqlStatsTableDetails[statName]["colDiff"], d3.sum(sqlStats[statName], function(d) {return d[sqlStatsTableDetails[statName]["colBaseline"]];})) + " to "
prompt  + outputFormat(sqlStatsTableDetails[statName]["colDiff"], d3.sum(sqlStats[statName], function(d) {return d[sqlStatsTableDetails[statName]["colTestrun"]];})) + " ).";;
prompt  return outputString;;
prompt  }
prompt  }
prompt
prompt
prompt
prompt
prompt  function getColspan(pcolumn) {
prompt  if (sqlStatsHeaderColspan2.includes(pcolumn)) {return 2;};;
prompt  if (sqlStatsHeaderColspan3.includes(pcolumn)) {return 3;};;
prompt  if (sqlStatsHeaderColspan4.includes(pcolumn)) {return 4;};;
prompt  if (sqlStatsHeaderColspan7.includes(pcolumn)) {return 7;};;
prompt  return 1;;
prompt  }
prompt
prompt  function drawTable(screenWidth, data, columns, header1, header2, tableName, svgName, summaryText, tableDescription) {
prompt
prompt
prompt  d3.select(svgName)
prompt  .append('svg')
prompt  .attr('width', screenWidth)
prompt  .attr('height', 50)
prompt  .append('g')
prompt  .attr("transform", "translate(" + 0 + "," + 0 + ")")
prompt  .append('text')
prompt  .attr('x', 20)
prompt  .attr('y', 40)
prompt  .attr("text-anchor", "mid")
prompt  .attr("font-size","18px")
prompt  .attr("font-weight", "bold")
prompt  .attr("class", "chartColorDark")
prompt  .text(tableName);;
prompt  d3.select(svgName)
prompt  .append('svg')
prompt  .attr('width', screenWidth)
prompt  .attr('height', 10)
prompt  .append('g')
prompt  .attr("transform", "translate(" + 0 + "," + 0 + ")")
prompt  .append('text')
prompt  .attr('x', 10)
prompt  .attr('y', 8)
prompt  .attr("text-anchor", "mid")
prompt  .attr("font-size","10px")
prompt  .attr("font-weight", "bold")
prompt  .attr("class", "chartColorGrey")
prompt  .text(tableDescription);;
prompt  var table = d3.select(svgName).append("table"),
prompt  thead = table.append("thead"),
prompt  tbody = table.append("tbody");;
prompt  thead.append("tr")
prompt  .selectAll("th")
prompt  .data(header1)
prompt  .enter()
prompt  .append("th")
prompt  .attr("colspan", function(column) { return getColspan(column); })
prompt  .attr("rowspan", function(column) { return getColspan(column) === 1 ? 2 : 1; })
prompt  .text(function(column) { return column; });;
prompt  thead.append("tr")
prompt  .selectAll("th")
prompt  .data(header2)
prompt  .enter()
prompt  .append("th")
prompt  .text(function(column) { return column; });;
prompt
prompt
prompt
prompt  var rows = tbody.selectAll("tr")
prompt  .data(data)
prompt  .enter()
prompt  .append("tr");;
prompt  var cells = rows.selectAll("td")
prompt  .data(function(row) {return columns.map(function(column) {
prompt  return {column: column,
prompt  value: row[column]
prompt  };});})
prompt  .enter()
prompt  .append("td")
prompt  .text(function(d) { return outputFormat(d.column,d.value); });;
prompt  table.selectAll("tbody tr")
prompt  .sort(function(a, b) {return d3.ascending(a.RANK, b.RANK); });;
prompt
prompt  d3.select(svgName)
prompt  .append('svg')
prompt  .attr('width', screenWidth)
prompt  .attr('height', 40)
prompt  .append('g')
prompt  .attr("transform", "translate(" + 0 + "," + 0 + ")")
prompt  .append('text')
prompt  .attr('x', 20)
prompt  .attr('y', 20)
prompt  .attr("text-anchor", "mid")
prompt  .attr("font-size","12px")
prompt  .attr("class", "chartColorDark")
prompt  .text(summaryText);;
prompt  return table;;
prompt  }
prompt
prompt  function outputFormat(pcolumn, pvalue) {
prompt  if (timeFormatArray.includes(pcolumn)) {if (pvalue > 999) {return execFormat(+pvalue);} else {return timeFormat(+pvalue);}};;
prompt  if (execFormatArray.includes(pcolumn)) {return execFormat(+pvalue);};;
prompt  if (percentFormatArray.includes(pcolumn)) {return percentFormat(+pvalue);};;
prompt  return pvalue;;
prompt  }
prompt
prompt  function drawAllObjects(pScreenWidth)
prompt  {
prompt    svgStackedAreaDraw(pScreenWidth,380,dbTimeArrayBr,"#chartDbTime",1,"Baseline", startTimeBr.toLocaleString('en-us', date_output), startTimeBr,finishTimeBr,maxDbTimeValue, dbTimeKeys, dbTimeColors,"Seconds");;
prompt    svgStackedAreaDraw(pScreenWidth,380,dbTimeArrayTr,"#chartDbTime",1,"Test run", startTimeTr.toLocaleString('en-us', date_output), startTimeTr,finishTimeTr,maxDbTimeValue, dbTimeKeys, dbTimeColors,"Seconds");;
prompt
prompt    svgStackedAreaDraw(pScreenWidth,380,ashArrayBr,"#chartAsh",1,"Baseline", ashStartTimeBr.toLocaleString('en-us', date_output), ashStartTimeBr,ashFinishTimeBr,maxDbSessionCount, ashKeys, ashColors,"DB sessions");;
prompt    svgStackedAreaDraw(pScreenWidth,380,ashArrayTr,"#chartAsh",1,"Testrun", ashStartTimeTr.toLocaleString('en-us', date_output), ashStartTimeTr,ashFinishTimeTr,maxDbSessionCount, ashKeys, ashColors,"DB sessions");;
prompt
prompt    if (waitClassGroups["DB Time"].columns) svgBarChartDraw(400,450,waitClassGroups["DB Time"],"#chartMain",dbTimeColors,"DB Time", "Seconds");;
prompt    if (waitClassGroups["Wait Classes"].columns) svgBarChartDraw(400,450,waitClassGroups["Wait Classes"],"#chartMain",waitClassColors,"Wait Classes","Seconds");;
prompt
prompt
prompt    ["Scheduler","User I/O","System I/O","Concurrency","Application","Commit","Configuration","Administrative","Network","Queueing","Cluster","Other"].forEach(function(d) {
prompt    if (waitClassGroups[d].columns) svgBarChartDraw(400,450,waitClassGroups[d],"#chartWaitClasses",cat20Colors,d,"Seconds");;
prompt
prompt    });;
prompt
prompt    sqlStatsChartDetails.forEach(function(d) {
prompt    svgBarChartDraw(400,450,sqlStatsGroups[d.chartId],"#chartSqlStatCharts",cat20Colors,d.chartName,d.axisName);;
prompt    });;
prompt
prompt    sqlStatsTables.forEach(function(d) {
prompt    var tempTable = drawTable(pScreenWidth,sqlStats[d],sqlStatsCols[d],sqlStatsColsHeader1[d],sqlStatsColsHeader2[d],sqlStatsTableDetails[d]["name"],"#chartSqlStatTables",sqlTableSummaryText(d),tableDescriptionText);;
prompt    sqlStatsTables[d] = tempTable;;
prompt    });;
prompt
prompt    var sysTimeModelTable = drawTable(pScreenWidth,sqlStats["SYS_TIME_MODEL"],sqlStatsCols["SYS_TIME_MODEL"],sqlStatsColsHeader1["SYS_TIME_MODEL"],sqlStatsColsHeader2["SYS_TIME_MODEL"],sqlStatsTableDetails["SYS_TIME_MODEL"]["name"],"#chartSysTimeModel","",tableDescriptionText);;
prompt
prompt    var dbSummaryTable = drawTable(pScreenWidth,sqlStats["DB_SUMMARY"],sqlStatsCols["DB_SUMMARY"],sqlStatsColsHeader1["DB_SUMMARY"],sqlStatsColsHeader2["DB_SUMMARY"],sqlStatsTableDetails["DB_SUMMARY"]["name"],"#chartMain","","");;
prompt
prompt    var sqlTextTable = drawTable(pScreenWidth,sqlStats["SQL_TEXT"],sqlStatsCols["SQL_TEXT"],sqlStatsColsHeader1["SQL_TEXT"],sqlStatsColsHeader2["SQL_TEXT"],sqlStatsTableDetails["SQL_TEXT"]["name"],"#chartSqlText","","");;
prompt
prompt    var sysStatTable = drawTable(pScreenWidth,sqlStats["SYS_STAT"],sqlStatsCols["SYS_STAT"],sqlStatsColsHeader1["SYS_STAT"],sqlStatsColsHeader2["SYS_STAT"],sqlStatsTableDetails["SYS_STAT"]["name"],"#chartSysStat","",tableDescriptionText);;
prompt
prompt    sqlStatsTables.forEach(function(x) {
prompt    sqlStatsTables[x].selectAll('td:nth-child(8)').style("background-color", function(d){if(+d.value > 0) {return colorInterpolateRed((+d.value)/getMaxDiffSqlStat(x)/2);} else {return colorInterpolateGreen((+d.value)/getMinDiffSqlStat(x)/2);};});;
prompt    sqlStatsTables[x].selectAll('td:nth-child(12)').style("background-color", function(d){return colorScale((+d.value))});;
prompt    });;
prompt
prompt
prompt    sysStatTable.selectAll('td:nth-child(8)').style("background-color", function(d){return colorScale((+d.value))});;
prompt    sysTimeModelTable.selectAll('td:nth-child(6)').style("background-color", function(d){return colorScale((+d.value))});;
prompt  }
prompt
prompt
prompt  var csvDbTime = "date,key,value\n"
prompt  ;;
prompt  var csvAshBr = "date,key,value\n"
select '+ "'||to_char(sample_time,'DD/MM/YYYY HH24:MI:SS')||','||wait_class||','||TO_CHAR(cnt,'FM9999')||'\n"' FROM
(SELECT
	sample_time,
	NVL(WAIT_CLASS,'CPU') wait_class,
	COUNT(*) cnt
FROM
	XDBSNAPSHOT.tbl_ash
WHERE
	sample_time BETWEEN TO_DATE('&start_sample_time_br', 'DD/MM/YYYY HH24:MI:SS') AND TO_DATE('&finish_sample_time_br', 'DD/MM/YYYY HH24:MI:SS')
GROUP BY
	sample_time,
	NVL(WAIT_CLASS,'CPU')
ORDER BY 1,2);
prompt  ;;
prompt
prompt  var csvAshTr = "date,key,value\n"
select '+ "'||to_char(sample_time,'DD/MM/YYYY HH24:MI:SS')||','||wait_class||','||TO_CHAR(cnt,'FM9999')||'\n"' FROM
(SELECT
	sample_time,
	NVL(WAIT_CLASS,'CPU') wait_class,
	COUNT(*) cnt
FROM
	XDBSNAPSHOT.tbl_ash
WHERE
	sample_time BETWEEN TO_DATE('&start_sample_time_tr', 'DD/MM/YYYY HH24:MI:SS') AND TO_DATE('&finish_sample_time_tr', 'DD/MM/YYYY HH24:MI:SS')
GROUP BY
	sample_time,
	NVL(WAIT_CLASS,'CPU')
ORDER BY 1,2);
prompt  ;;
prompt   var csvDbTimeBr = "date,key,value\n"
select '+ "'||to_char(sample_time,'DD/MM/YYYY HH24:MI')||','||DECODE(stat_name,'user I/O wait time','User I/O','DB CPU','DB CPU','DB time','DB Time')||','||TO_CHAR(ROUND((value-prev_value)/1000000,1),'FM99999999999.99')||'\n"' from
(select sample_id, sample_time, stat_name, value, lag(value, 1, 0) over (partition by stat_name order by stat_name, sample_time) prev_value
from XDBSNAPSHOT.tbl_sys_time_model ss
where stat_name in ('DB time','DB CPU')
and sample_id between &start_sample_id_br and &finish_sample_id_br
union
select sample_id, sample_time, name stat_name, value*10000, (lag(value, 1, 0) over (partition by name order by name, sample_time))*10000 prev_value
from XDBSNAPSHOT.tbl_sysstat ss
where name in ('user I/O wait time')
and sample_id between &start_sample_id_br and &finish_sample_id_br
)
where prev_value!=0
order by sample_time, stat_name;
prompt ;;
prompt   var csvDbTimeTr = "date,key,value\n"
select '+ "'||to_char(sample_time,'DD/MM/YYYY HH24:MI')||','||DECODE(stat_name,'user I/O wait time','User I/O','DB CPU','DB CPU','DB time','DB Time')||','||TO_CHAR(ROUND((value-prev_value)/1000000,1),'FM99999999999.99')||'\n"' from
(select sample_id, sample_time, stat_name, value, lag(value, 1, 0) over (partition by stat_name order by stat_name, sample_time) prev_value
from XDBSNAPSHOT.tbl_sys_time_model ss
where stat_name in ('DB time','DB CPU')
and sample_id between &start_sample_id_tr and &finish_sample_id_tr
union
select sample_id, sample_time, name stat_name, value*10000, (lag(value, 1, 0) over (partition by name order by name, sample_time))*10000 prev_value
from XDBSNAPSHOT.tbl_sysstat ss
where name in ('user I/O wait time')
and sample_id between &start_sample_id_tr and &finish_sample_id_tr
)
where prev_value!=0
order by sample_time, stat_name;
prompt ;;
prompt var csvWaitEvents = "wait_class,wait_event,tst_before,tst_after\n"
with br as (
select en.wait_class, en.name, ROUND((NVL(ef.time_waited_micro,0) - NVL(es.time_waited_micro,0))/1000000,1) time_delta_min  from v$event_name en
left join (select wait_class, event, time_waited_micro from XDBSNAPSHOT.tbl_system_event where sample_id = &start_sample_id_br) es ON en.wait_class = es.wait_class AND en.name = es.event
left join (select wait_class, event, time_waited_micro from XDBSNAPSHOT.tbl_system_event where sample_id = &finish_sample_id_br) ef ON en.wait_class = ef.wait_class AND en.name = ef.event
where ROUND((NVL(ef.time_waited_micro,0) - NVL(es.time_waited_micro,0))/1000000,1) > 0)
, tr as (
select en.wait_class, en.name, ROUND((NVL(ef.time_waited_micro,0) - NVL(es.time_waited_micro,0))/1000000,1) time_delta_min  from v$event_name en
left join (select wait_class, event, time_waited_micro from XDBSNAPSHOT.tbl_system_event where sample_id = &start_sample_id_tr) es ON en.wait_class = es.wait_class AND en.name = es.event
left join (select wait_class, event, time_waited_micro from XDBSNAPSHOT.tbl_system_event where sample_id = &finish_sample_id_tr) ef ON en.wait_class = ef.wait_class AND en.name = ef.event
where ROUND((NVL(ef.time_waited_micro,0) - NVL(es.time_waited_micro,0))/1000000,1) > 0)
select '+ "'||en.wait_class||','||en.name||','||TO_CHAR(BR.TIME_DELTA_MIN,'FM9999999999.99')||','||TO_CHAR(TR.TIME_DELTA_MIN,'FM9999999999.99')||'\n"' from v$event_name en
left join br ON br.wait_class = en.wait_class AND br.name = en.name
left join tr ON tr.wait_class = en.wait_class AND tr.name = en.name
WHERE NVL(br.time_delta_min,0)>0 OR NVL(tr.time_delta_min,0)>0
order by en.wait_class asc, tr.TIME_DELTA_MIN desc;
prompt ;;
prompt
prompt var csvSqlStatsTable = "STATISTIC,RANK,SQL_ID,PLAN_HASH_VALUE,SQL_TYPE,PARSE_CALLS_T,DISK_READS_T,DIRECT_WRITES_T,BUFFER_GETS_T,ROWS_PROCESSED_T,FETCHES_T,EXECUTIONS_T,PX_SERVERS_EXECUTIONS_T,END_OF_FETCH_COUNT_T,CPU_TIME_T,ELAPSED_TIME_T,APPLICATION_WAIT_TIME_T,CONCURRENCY_WAIT_TIME_T,CLUSTER_WAIT_TIME_T,USER_IO_WAIT_TIME_T,PLSQL_EXEC_TIME_T,JAVA_EXEC_TIME_T,OTHER_WAIT_TIME_T,SORTS_T,LOADS_T,INVALIDATIONS_T,PHYSICAL_READ_REQUESTS_T,PHYSICAL_READ_BYTES_T,PHYSICAL_WRITE_REQUESTS_T,PHYSICAL_WRITE_BYTES_T,IO_INTERCONNECT_BYTES_T,PARSE_CALLS_B,DISK_READS_B,DIRECT_WRITES_B,BUFFER_GETS_B,ROWS_PROCESSED_B,FETCHES_B,EXECUTIONS_B,PX_SERVERS_EXECUTIONS_B,END_OF_FETCH_COUNT_B,CPU_TIME_B,ELAPSED_TIME_B,APPLICATION_WAIT_TIME_B,CONCURRENCY_WAIT_TIME_B,CLUSTER_WAIT_TIME_B,USER_IO_WAIT_TIME_B,PLSQL_EXEC_TIME_B,JAVA_EXEC_TIME_B,OTHER_WAIT_TIME_B,SORTS_B,LOADS_B,INVALIDATIONS_B,PHYSICAL_READ_REQUESTS_B,PHYSICAL_READ_BYTES_B,PHYSICAL_WRITE_REQUESTS_B,PHYSICAL_WRITE_BYTES_B,IO_INTERCONNECT_BYTES_B,PARSE_CALLS_S,DISK_READS_S,DIRprompt  ECT_WRITES_S,BUFFER_GETS_S,ROWS_PROCESSED_S,FETCHES_S,EXECUTIONS_S,PX_SERVERS_EXECUTIONS_S,END_OF_FETCH_COUNT_S,CPU_TIME_S,ELAPSED_TIME_S,APPLICATION_WAIT_TIME_S,CONCURRENCY_WAIT_TIME_S,CLUSTER_WAIT_TIME_S,USER_IO_WAIT_TIME_S,PLSQL_EXEC_TIME_S,JAVA_EXEC_TIME_S,OTHER_WAIT_TIME_S,SORTS_S,LOADS_S,INVALIDATIONS_S,PHYSICAL_READ_REQUESTS_S,PHYSICAL_READ_BYTES_S,PHYSICAL_WRITE_REQUESTS_S,PHYSICAL_WRITE_BYTES_S,IO_INTERCONNECT_BYTES_S\n"
with tr as (
SELECT
SQL_ID SQL_ID_T,
PLAN_HASH_VALUE PLAN_HASH_VALUE_T,
PARSE_CALLS PARSE_CALLS_T,
DISK_READS DISK_READS_T,
DIRECT_WRITES DIRECT_WRITES_T,
BUFFER_GETS BUFFER_GETS_T,
ROWS_PROCESSED ROWS_PROCESSED_T,
FETCHES FETCHES_T,
EXECUTIONS EXECUTIONS_T,
PX_SERVERS_EXECUTIONS PX_SERVERS_EXECUTIONS_T,
END_OF_FETCH_COUNT END_OF_FETCH_COUNT_T,
CPU_TIME CPU_TIME_T,
ELAPSED_TIME ELAPSED_TIME_T,
APPLICATION_WAIT_TIME APPLICATION_WAIT_TIME_T,
CONCURRENCY_WAIT_TIME CONCURRENCY_WAIT_TIME_T,
CLUSTER_WAIT_TIME CLUSTER_WAIT_TIME_T,
USER_IO_WAIT_TIME USER_IO_WAIT_TIME_T,
PLSQL_EXEC_TIME PLSQL_EXEC_TIME_T,
JAVA_EXEC_TIME JAVA_EXEC_TIME_T,
(ELAPSED_TIME - CPU_TIME - APPLICATION_WAIT_TIME - CONCURRENCY_WAIT_TIME - CLUSTER_WAIT_TIME - USER_IO_WAIT_TIME) OTHER_WAIT_TIME_T,
SORTS SORTS_T,
LOADS LOADS_T,
INVALIDATIONS INVALIDATIONS_T,
PHYSICAL_READ_REQUESTS PHYSICAL_READ_REQUESTS_T,
PHYSICAL_READ_BYTES PHYSICAL_READ_BYTES_T,
PHYSICAL_WRITE_REQUESTS PHYSICAL_WRITE_REQUESTS_T,
PHYSICAL_WRITE_BYTES PHYSICAL_WRITE_BYTES_T,
IO_INTERCONNECT_BYTES IO_INTERCONNECT_BYTES_T,
ROW_NUMBER() OVER (ORDER BY PARSE_CALLS DESC) PARSE_CALLS_R,
ROW_NUMBER() OVER (ORDER BY DISK_READS DESC) DISK_READS_R,
ROW_NUMBER() OVER (ORDER BY DIRECT_WRITES DESC) DIRECT_WRITES_R,
ROW_NUMBER() OVER (ORDER BY BUFFER_GETS DESC) BUFFER_GETS_R,
ROW_NUMBER() OVER (ORDER BY ROWS_PROCESSED DESC) ROWS_PROCESSED_R,
ROW_NUMBER() OVER (ORDER BY FETCHES DESC) FETCHES_R,
ROW_NUMBER() OVER (ORDER BY EXECUTIONS DESC) EXECUTIONS_R,
ROW_NUMBER() OVER (ORDER BY PX_SERVERS_EXECUTIONS DESC) PX_SERVERS_EXECUTIONS_R,
ROW_NUMBER() OVER (ORDER BY END_OF_FETCH_COUNT DESC) END_OF_FETCH_COUNT_R,
ROW_NUMBER() OVER (ORDER BY CPU_TIME DESC) CPU_TIME_R,
ROW_NUMBER() OVER (ORDER BY ELAPSED_TIME DESC) ELAPSED_TIME_R,
ROW_NUMBER() OVER (ORDER BY APPLICATION_WAIT_TIME DESC) APPLICATION_WAIT_TIME_R,
ROW_NUMBER() OVER (ORDER BY CONCURRENCY_WAIT_TIME DESC) CONCURRENCY_WAIT_TIME_R,
ROW_NUMBER() OVER (ORDER BY CLUSTER_WAIT_TIME DESC) CLUSTER_WAIT_TIME_R,
ROW_NUMBER() OVER (ORDER BY USER_IO_WAIT_TIME DESC) USER_IO_WAIT_TIME_R,
ROW_NUMBER() OVER (ORDER BY PLSQL_EXEC_TIME DESC) PLSQL_EXEC_TIME_R,
ROW_NUMBER() OVER (ORDER BY JAVA_EXEC_TIME DESC) JAVA_EXEC_TIME_R,
ROW_NUMBER() OVER (ORDER BY (ELAPSED_TIME - CPU_TIME - APPLICATION_WAIT_TIME - CONCURRENCY_WAIT_TIME - CLUSTER_WAIT_TIME - USER_IO_WAIT_TIME) DESC) OTHER_WAIT_TIME_R,
ROW_NUMBER() OVER (ORDER BY SORTS DESC) SORTS_R,
ROW_NUMBER() OVER (ORDER BY LOADS DESC) LOADS_R,
ROW_NUMBER() OVER (ORDER BY INVALIDATIONS DESC) INVALIDATIONS_R,
ROW_NUMBER() OVER (ORDER BY PHYSICAL_READ_REQUESTS DESC) PHYSICAL_READ_REQUESTS_R,
ROW_NUMBER() OVER (ORDER BY PHYSICAL_READ_BYTES DESC) PHYSICAL_READ_BYTES_R,
ROW_NUMBER() OVER (ORDER BY PHYSICAL_WRITE_REQUESTS DESC) PHYSICAL_WRITE_REQUESTS_R,
ROW_NUMBER() OVER (ORDER BY PHYSICAL_WRITE_BYTES DESC) PHYSICAL_WRITE_BYTES_R,
ROW_NUMBER() OVER (ORDER BY IO_INTERCONNECT_BYTES DESC) IO_INTERCONNECT_BYTES_R,
ROUND(NVL(RATIO_TO_REPORT(PARSE_CALLS) OVER (),0),2) PARSE_CALLS_S,
ROUND(NVL(RATIO_TO_REPORT(DISK_READS) OVER (),0),2) DISK_READS_S,
ROUND(NVL(RATIO_TO_REPORT(DIRECT_WRITES) OVER (),0),2) DIRECT_WRITES_S,
ROUND(NVL(RATIO_TO_REPORT(BUFFER_GETS) OVER (),0),2) BUFFER_GETS_S,
ROUND(NVL(RATIO_TO_REPORT(ROWS_PROCESSED) OVER (),0),2) ROWS_PROCESSED_S,
ROUND(NVL(RATIO_TO_REPORT(FETCHES) OVER (),0),2) FETCHES_S,
ROUND(NVL(RATIO_TO_REPORT(EXECUTIONS) OVER (),0),2) EXECUTIONS_S,
ROUND(NVL(RATIO_TO_REPORT(PX_SERVERS_EXECUTIONS) OVER (),0),2) PX_SERVERS_EXECUTIONS_S,
ROUND(NVL(RATIO_TO_REPORT(END_OF_FETCH_COUNT) OVER (),0),2) END_OF_FETCH_COUNT_S,
ROUND(NVL(RATIO_TO_REPORT(CPU_TIME) OVER (),0),2) CPU_TIME_S,
ROUND(NVL(RATIO_TO_REPORT(ELAPSED_TIME) OVER (),0),2) ELAPSED_TIME_S,
ROUND(NVL(RATIO_TO_REPORT(APPLICATION_WAIT_TIME) OVER (),0),2) APPLICATION_WAIT_TIME_S,
ROUND(NVL(RATIO_TO_REPORT(CONCURRENCY_WAIT_TIME) OVER (),0),2) CONCURRENCY_WAIT_TIME_S,
ROUND(NVL(RATIO_TO_REPORT(CLUSTER_WAIT_TIME) OVER (),0),2) CLUSTER_WAIT_TIME_S,
ROUND(NVL(RATIO_TO_REPORT(USER_IO_WAIT_TIME) OVER (),0),2) USER_IO_WAIT_TIME_S,
ROUND(NVL(RATIO_TO_REPORT(PLSQL_EXEC_TIME) OVER (),0),2) PLSQL_EXEC_TIME_S,
ROUND(NVL(RATIO_TO_REPORT(JAVA_EXEC_TIME) OVER (),0),2) JAVA_EXEC_TIME_S,
ROUND(NVL(RATIO_TO_REPORT((ELAPSED_TIME - CPU_TIME - APPLICATION_WAIT_TIME - CONCURRENCY_WAIT_TIME - CLUSTER_WAIT_TIME - USER_IO_WAIT_TIME)) OVER (),0),2) OTHER_WAIT_TIME_S,
ROUND(NVL(RATIO_TO_REPORT(SORTS) OVER (),0),2) SORTS_S,
ROUND(NVL(RATIO_TO_REPORT(LOADS) OVER (),0),2) LOADS_S,
ROUND(NVL(RATIO_TO_REPORT(INVALIDATIONS) OVER (),0),2) INVALIDATIONS_S,
ROUND(NVL(RATIO_TO_REPORT(PHYSICAL_READ_REQUESTS) OVER (),0),2) PHYSICAL_READ_REQUESTS_S,
ROUND(NVL(RATIO_TO_REPORT(PHYSICAL_READ_BYTES) OVER (),0),2) PHYSICAL_READ_BYTES_S,
ROUND(NVL(RATIO_TO_REPORT(PHYSICAL_WRITE_REQUESTS) OVER (),0),2) PHYSICAL_WRITE_REQUESTS_S,
ROUND(NVL(RATIO_TO_REPORT(PHYSICAL_WRITE_BYTES) OVER (),0),2) PHYSICAL_WRITE_BYTES_S,
ROUND(NVL(RATIO_TO_REPORT(IO_INTERCONNECT_BYTES) OVER (),0),2) IO_INTERCONNECT_BYTES_S
FROM
(SELECT
SQL_ID,
PLAN_HASH_VALUE,
SUM(NVL(DELTA_PARSE_CALLS,0)) PARSE_CALLS,
SUM(NVL(DELTA_DISK_READS,0)) DISK_READS,
SUM(NVL(DELTA_DIRECT_WRITES,0)) DIRECT_WRITES,
SUM(NVL(DELTA_BUFFER_GETS,0)) BUFFER_GETS,
SUM(NVL(DELTA_ROWS_PROCESSED,0)) ROWS_PROCESSED,
SUM(NVL(DELTA_FETCH_COUNT,0)) FETCHES,
SUM(NVL(DELTA_EXECUTION_COUNT,0)) EXECUTIONS,
SUM(NVL(DELTA_PX_SERVERS_EXECUTIONS,0)) PX_SERVERS_EXECUTIONS,
SUM(NVL(DELTA_END_OF_FETCH_COUNT,0)) END_OF_FETCH_COUNT,
SUM(NVL(DELTA_CPU_TIME,0)) CPU_TIME,
SUM(NVL(DELTA_ELAPSED_TIME,0)) ELAPSED_TIME,
SUM(NVL(DELTA_APPLICATION_WAIT_TIME,0)) APPLICATION_WAIT_TIME,
SUM(NVL(DELTA_CONCURRENCY_TIME,0)) CONCURRENCY_WAIT_TIME,
SUM(NVL(DELTA_CLUSTER_WAIT_TIME,0)) CLUSTER_WAIT_TIME,
SUM(NVL(DELTA_USER_IO_WAIT_TIME,0)) USER_IO_WAIT_TIME,
SUM(NVL(DELTA_PLSQL_EXEC_TIME,0)) PLSQL_EXEC_TIME,
SUM(NVL(DELTA_JAVA_EXEC_TIME,0)) JAVA_EXEC_TIME,
SUM(NVL(DELTA_SORTS,0)) SORTS,
SUM(NVL(DELTA_LOADS,0)) LOADS,
SUM(NVL(DELTA_INVALIDATIONS,0)) INVALIDATIONS,
SUM(NVL(DELTA_PHYSICAL_READ_REQUESTS,0)) PHYSICAL_READ_REQUESTS,
SUM(NVL(DELTA_PHYSICAL_READ_BYTES,0)) PHYSICAL_READ_BYTES,
SUM(NVL(DELTA_PHYSICAL_WRITE_REQUESTS,0)) PHYSICAL_WRITE_REQUESTS,
SUM(NVL(DELTA_PHYSICAL_WRITE_BYTES,0)) PHYSICAL_WRITE_BYTES,
SUM(NVL(DELTA_IO_INTERCONNECT_BYTES,0)) IO_INTERCONNECT_BYTES
FROM XDBSNAPSHOT.TBL_SQLSTATS
WHERE sample_id between &start_sample_id_tr+1 and &finish_sample_id_tr
GROUP BY SQL_ID,PLAN_HASH_VALUE))
, br as (
SELECT
SQL_ID SQL_ID_B,
PLAN_HASH_VALUE PLAN_HASH_VALUE_B,
PARSE_CALLS PARSE_CALLS_B,
DISK_READS DISK_READS_B,
DIRECT_WRITES DIRECT_WRITES_B,
BUFFER_GETS BUFFER_GETS_B,
ROWS_PROCESSED ROWS_PROCESSED_B,
FETCHES FETCHES_B,
EXECUTIONS EXECUTIONS_B,
PX_SERVERS_EXECUTIONS PX_SERVERS_EXECUTIONS_B,
END_OF_FETCH_COUNT END_OF_FETCH_COUNT_B,
CPU_TIME CPU_TIME_B,
ELAPSED_TIME ELAPSED_TIME_B,
APPLICATION_WAIT_TIME APPLICATION_WAIT_TIME_B,
CONCURRENCY_WAIT_TIME CONCURRENCY_WAIT_TIME_B,
CLUSTER_WAIT_TIME CLUSTER_WAIT_TIME_B,
USER_IO_WAIT_TIME USER_IO_WAIT_TIME_B,
PLSQL_EXEC_TIME PLSQL_EXEC_TIME_B,
JAVA_EXEC_TIME JAVA_EXEC_TIME_B,
(ELAPSED_TIME - CPU_TIME - APPLICATION_WAIT_TIME - CONCURRENCY_WAIT_TIME - CLUSTER_WAIT_TIME - USER_IO_WAIT_TIME) OTHER_WAIT_TIME_B,
SORTS SORTS_B,
LOADS LOADS_B,
INVALIDATIONS INVALIDATIONS_B,
PHYSICAL_READ_REQUESTS PHYSICAL_READ_REQUESTS_B,
PHYSICAL_READ_BYTES PHYSICAL_READ_BYTES_B,
PHYSICAL_WRITE_REQUESTS PHYSICAL_WRITE_REQUESTS_B,
PHYSICAL_WRITE_BYTES PHYSICAL_WRITE_BYTES_B,
IO_INTERCONNECT_BYTES IO_INTERCONNECT_BYTES_B
FROM
(SELECT
SQL_ID,
PLAN_HASH_VALUE,
SUM(NVL(DELTA_PARSE_CALLS,0)) PARSE_CALLS,
SUM(NVL(DELTA_DISK_READS,0)) DISK_READS,
SUM(NVL(DELTA_DIRECT_WRITES,0)) DIRECT_WRITES,
SUM(NVL(DELTA_BUFFER_GETS,0)) BUFFER_GETS,
SUM(NVL(DELTA_ROWS_PROCESSED,0)) ROWS_PROCESSED,
SUM(NVL(DELTA_FETCH_COUNT,0)) FETCHES,
SUM(NVL(DELTA_EXECUTION_COUNT,0)) EXECUTIONS,
SUM(NVL(DELTA_PX_SERVERS_EXECUTIONS,0)) PX_SERVERS_EXECUTIONS,
SUM(NVL(DELTA_END_OF_FETCH_COUNT,0)) END_OF_FETCH_COUNT,
SUM(NVL(DELTA_CPU_TIME,0)) CPU_TIME,
SUM(NVL(DELTA_ELAPSED_TIME,0)) ELAPSED_TIME,
SUM(NVL(DELTA_APPLICATION_WAIT_TIME,0)) APPLICATION_WAIT_TIME,
SUM(NVL(DELTA_CONCURRENCY_TIME,0)) CONCURRENCY_WAIT_TIME,
SUM(NVL(DELTA_CLUSTER_WAIT_TIME,0)) CLUSTER_WAIT_TIME,
SUM(NVL(DELTA_USER_IO_WAIT_TIME,0)) USER_IO_WAIT_TIME,
SUM(NVL(DELTA_PLSQL_EXEC_TIME,0)) PLSQL_EXEC_TIME,
SUM(NVL(DELTA_JAVA_EXEC_TIME,0)) JAVA_EXEC_TIME,
SUM(NVL(DELTA_SORTS,0)) SORTS,
SUM(NVL(DELTA_LOADS,0)) LOADS,
SUM(NVL(DELTA_INVALIDATIONS,0)) INVALIDATIONS,
SUM(NVL(DELTA_PHYSICAL_READ_REQUESTS,0)) PHYSICAL_READ_REQUESTS,
SUM(NVL(DELTA_PHYSICAL_READ_BYTES,0)) PHYSICAL_READ_BYTES,
SUM(NVL(DELTA_PHYSICAL_WRITE_REQUESTS,0)) PHYSICAL_WRITE_REQUESTS,
SUM(NVL(DELTA_PHYSICAL_WRITE_BYTES,0)) PHYSICAL_WRITE_BYTES,
SUM(NVL(DELTA_IO_INTERCONNECT_BYTES,0)) IO_INTERCONNECT_BYTES
FROM XDBSNAPSHOT.TBL_SQLSTATS
WHERE sample_id between &start_sample_id_br+1 and &finish_sample_id_br
GROUP BY SQL_ID,PLAN_HASH_VALUE))
, s as (select 'c6n9vdhjkgg1j' sql_id, 'AWR' sql_type from dual union
select '0109cw056m96y' sql_id, 'AWR' sql_type from dual union
select '2ckav84qvrjg9' sql_id, 'AWR' sql_type from dual union
select '40ppuqwqk6brb' sql_id, 'AWR' sql_type from dual union
select '4ndwnvfsu3ufm' sql_id, 'AWR' sql_type from dual union
select '94m7y1a60jg2n' sql_id, 'AWR' sql_type from dual union
select 'cv61hcs3xkh0a' sql_id, 'Contacts' sql_type from dual union
select 'dy8u5zsmdzgks' sql_id, 'Contacts' sql_type from dual union
select '4rdq6x27bkwvf' sql_id, 'Contacts' sql_type from dual union
select 'f5ypgtcjkbf95' sql_id, 'Contacts' sql_type from dual union
select 'cfmjqnfaqngnu' sql_id, 'Contacts' sql_type from dual union
select 'danzt0bdrra93' sql_id, 'Contacts' sql_type from dual union
select '58d9aa28z0jzp' sql_id, 'Contacts' sql_type from dual union
select 'crft2sr0yzpr9' sql_id, 'Contacts' sql_type from dual union
select '4h0y82y0dwnwa' sql_id, 'Contacts' sql_type from dual union
select '2qfwmd4vbcbcg' sql_id, 'Contacts' sql_type from dual union
select '9m685urx5th2d' sql_id, 'Contacts' sql_type from dual union
select '8hk24xhz2qg78' sql_id, 'Contacts' sql_type from dual union
select '9vb1xsjvm5gdc' sql_id, 'Contacts' sql_type from dual union
select '8jrxbk6add2qd' sql_id, 'Contacts' sql_type from dual union
select 'cg16vntgj3k15' sql_id, 'Contacts' sql_type from dual union
select '1uw85c8c5kr8w' sql_id, 'Contacts' sql_type from dual union
select '3fw4absn88h38' sql_id, 'Contacts' sql_type from dual union
select '2wv3tx7qq38k8' sql_id, 'Contacts' sql_type from dual union
select 'gyvrtfjs7j05x' sql_id, 'Contacts' sql_type from dual union
select '8jrxbk6add2qd' sql_id, 'Contacts' sql_type from dual union
select 'f5ypgtcjkbf95' sql_id, 'Contacts' sql_type from dual union
select 'ax9jn9ypdjmk7' sql_id, 'Contacts' sql_type from dual union
select '9vb1xsjvm5gdc' sql_id, 'Contacts' sql_type from dual union
select 'ax9jn9ypdjmk7' sql_id, 'Contacts' sql_type from dual union
select '7sx5p1ug5ag12' sql_id, 'sys' sql_type from dual union
select '63cnhugxhmakh' sql_id, 'BB User' sql_type from dual union
select '7umy6juhzw766' sql_id, 'sys' sql_type from dual union
select 'cumxzt4usubs3' sql_id, 'Access Control' sql_type from dual union
select '5uun7vdkpktg4' sql_id, 'Access Control' sql_type from dual union
select '6msa3cfw970b3' sql_id, 'sys' sql_type from dual union
select 'gnhkshx7g60h8' sql_id, 'Arrangement' sql_type from dual union
select '8uh6xphq54kh0' sql_id, 'sys' sql_type from dual union
select '1p5grz1gs7fjq' sql_id, 'sys' sql_type from dual union
select 'ct2g3h4c98fp4' sql_id, 'sys' sql_type from dual union
select '5wwkp7spyq2fn' sql_id, 'sys' sql_type from dual union
select '37846778azhd6' sql_id, 'Payment' sql_type from dual union
select '27by5yrm0buq1' sql_id, 'Arrangement' sql_type from dual union
select '93xubhsjvgyfp' sql_id, 'Payment' sql_type from dual union
select 'b0cq5rsrh71vw' sql_id, 'Payment' sql_type from dual union
select '65c65nng8tkdt' sql_id, 'Payment' sql_type from dual union
select '6qz82dptj0qr7' sql_id, 'sys' sql_type from dual union
select '3un99a0zwp4vd' sql_id, 'sys' sql_type from dual union
select '7nuw4xwrnuwxq' sql_id, 'sys' sql_type from dual union
select 'axa03uqckxg9t' sql_id, 'Payment' sql_type from dual union
select '96m2bmmjg33gj' sql_id, 'Payment' sql_type from dual union
select 'g66md6muf0mb3' sql_id, 'Payment' sql_type from dual union
select '9g485acn2n30m' sql_id, 'sys' sql_type from dual union
select '21dsn7a9w4tyr' sql_id, 'Access Control' sql_type from dual union
select '9d2hmk8gy0r44' sql_id, 'Access Control' sql_type from dual union
select '2czz7mv2r6xqx' sql_id, 'Access Control' sql_type from dual union
select '7ytfq31vb7u32' sql_id, 'Access Control' sql_type from dual union
select '8gsfhmjtw00w0' sql_id, 'Arrangement' sql_type from dual union
select '9rfqm06xmuwu0' sql_id, 'sys' sql_type from dual union
select 'fny4dtx31y1zp' sql_id, 'Payment' sql_type from dual union
select '8wksn7rs3x23f' sql_id, 'sys' sql_type from dual union
select '7fwum1yuknrsh' sql_id, 'sys' sql_type from dual union
select 'gd28w82ct6rva' sql_id, 'sys' sql_type from dual union
select 'fq3f1vdv581ds' sql_id, 'sys' sql_type from dual union
select '86kwhy1f0bttn' sql_id, 'sys' sql_type from dual union
select '2tkw12w5k68vd' sql_id, 'sys' sql_type from dual union
select 'a6ygk0r9s5xuj' sql_id, 'sys' sql_type from dual union
select '622ufbrgvxdc7' sql_id, 'sys' sql_type from dual union
select '7u49y06aqxg1s' sql_id, 'sys' sql_type from dual union
select 'f0h5rpzmhju11' sql_id, 'sys' sql_type from dual union
select '73y7sjsqhzm6t' sql_id, 'rds' sql_type from dual union
select 'b3v25sg2hrsrv' sql_id, 'rds' sql_type from dual union
select 'gp1dhz5jffc0f' sql_id, 'Payment' sql_type from dual union
select '1y8d34phk5wq5' sql_id, 'Payment' sql_type from dual union
select '0m6rqhsrrq5g8' sql_id, 'Payment' sql_type from dual union
select '277b2d3au6ukw' sql_id, 'Payment' sql_type from dual union
select '3nzv2smdzzbsf' sql_id, 'sys' sql_type from dual union
select '6qj7bn8hvc7ph' sql_id, 'Arrangement' sql_type from dual union
select 'c4cr75ud9ujvg' sql_id, 'sys' sql_type from dual union
select '3h0a0h5srz9t9' sql_id, 'sys' sql_type from dual union
select 'fuws5bqghb2qh' sql_id, 'sys' sql_type from dual union
select '679x4qggryd2v' sql_id, 'sys' sql_type from dual union
select 'ca6tq9wk5wakf' sql_id, 'sys' sql_type from dual union
select 'bayq8637hww90' sql_id, 'sys' sql_type from dual union
select '7k3py88s25w9w' sql_id, 'rds' sql_type from dual union
select '0zg5scs7brcfg' sql_id, 'sys' sql_type from dual union
select '7rhmtdnh02uq6' sql_id, 'sys' sql_type from dual union
select '4xvhbr5835v9r' sql_id, 'other' sql_type from dual union
select '3y1nk3vthv2hj' sql_id, 'other' sql_type from dual union
select '26xzgnyjsfwpa' sql_id, 'other' sql_type from dual union
select '8jdvgmwjshhgd' sql_id, 'other' sql_type from dual union
select '9xkk4svdm8gw6' sql_id, 'other' sql_type from dual union
select 'fxfzwt2y20tdm' sql_id, 'sys' sql_type from dual union
select '80z99fv2c3j4c' sql_id, 'other' sql_type from dual union
select '0fmb19vjgk8d9' sql_id, 'Payment' sql_type from dual union
select '8fk98540xbfcb' sql_id, 'sys' sql_type from dual union
select '60bwp9x9jc0dy' sql_id, 'sys' sql_type from dual union
select '5pvg4869ju1y0' sql_id, 'other' sql_type from dual union
select 'a9dgdvgmbwcwm' sql_id, 'other' sql_type from dual union
select 'fcbh6d0cbmmca' sql_id, 'sys' sql_type from dual union
select '14dsy1hg4057q' sql_id, 'Payment' sql_type from dual union
select '5r8sf8qp40tj1' sql_id, 'sys' sql_type from dual union
select '4phvdvx32a3mf' sql_id, 'sys' sql_type from dual union
select '98n7q1kq9p5a7' sql_id, 'sys' sql_type from dual union
select '1kz16yhs993h2' sql_id, 'sys' sql_type from dual union
select 'b3s1x9zqrvzvc' sql_id, 'sys' sql_type from dual union
select '0v3dvmc22qnam' sql_id, 'sys' sql_type from dual union
select 'dma0vxbwh325p' sql_id, 'sys' sql_type from dual union
select '1h3hsh6y85ty8' sql_id, 'sys' sql_type from dual union
select 'gm9t6ycmb1yu6' sql_id, 'sys' sql_type from dual union
select 'gqp6kd8xbjkvv' sql_id, 'Payment' sql_type from dual union
select '7kmbrw7q8hn4g' sql_id, 'sys' sql_type from dual union
select '0qbzfjt00pbsx' sql_id, 'sys' sql_type from dual union
select '2ygnt73ck3jk8' sql_id, 'sys' sql_type from dual union
select 'b9c6ffh8tc71f' sql_id, 'sys' sql_type from dual union
select '00zqy3yd0r3p3' sql_id, 'sys' sql_type from dual union
select '2jhah7b46j8m1' sql_id, 'sys' sql_type from dual union
select '3j02ckjb0j3hh' sql_id, 'Access Control' sql_type from dual union
select '1zjccx5tkctb1' sql_id, 'Contacts' sql_type from dual union
select '11st4yznxdj3r' sql_id, 'Contacts' sql_type from dual union
select '0qjwxgbsgg9d1' sql_id, 'Contacts' sql_type from dual union
select '9f7z8cc1cmaxx' sql_id, 'Contacts' sql_type from dual union
select '7fxn85xbb04u1' sql_id, 'Access Control' sql_type from dual union
select 'b899gb63y1kav' sql_id, 'CX6' sql_type from dual union
select '34ttdsp2rn9x0' sql_id, 'CX6' sql_type from dual union
select '3mp90hzdswcqb' sql_id, 'CX6' sql_type from dual union
select 'f9rkhg3pwsp50' sql_id, 'Access Control' sql_type from dual union
select 'faft02rqhk2f0' sql_id, 'CX6' sql_type from dual union
select '00afbbc4bk0tc' sql_id, 'BB User' sql_type from dual union
select '3kzydt3r6q224' sql_id, 'CX6' sql_type from dual union
select 'gykmypgdujmam' sql_id, 'Arrangement' sql_type from dual union
select 'azcp0rpx81gf4' sql_id, 'CX6' sql_type from dual union
select '2ur6uh0f11ard' sql_id, 'CX6' sql_type from dual union
select 'ayt5z7acz1001' sql_id, 'CX6' sql_type from dual union
select 'ct45cc74j14un' sql_id, 'CX6' sql_type from dual union
select 'cnfy6j57fyxy5' sql_id, 'Arrangement' sql_type from dual union
select 'gjmr4dnw3yk82' sql_id, 'Access Control' sql_type from dual union
select '56pfkggymym2p' sql_id, 'CX6' sql_type from dual union
select '5txdc2rqwymck' sql_id, 'CX6' sql_type from dual union
select '5va2qknrnqmfc' sql_id, 'CX6' sql_type from dual union
select '5v69hhf3wvtv5' sql_id, 'CX6' sql_type from dual union
select 'cv3453453rydr' sql_id, 'Arrangement' sql_type from dual union
select 'fv2hjgzsbzv9q' sql_id, 'CX6' sql_type from dual union
select 'b8u6d0awybfs8' sql_id, 'CX6' sql_type from dual union
select '3b177g5msmt5v' sql_id, 'CX6' sql_type from dual union
select '6fav4yc54mt6m' sql_id, 'CX6' sql_type from dual union
select '6drwfd9mybm7m' sql_id, 'Arrangement' sql_type from dual union
select '7gtvc55fsvtd3' sql_id, 'CX6' sql_type from dual union
select '1pza3j4133942' sql_id, 'CX6' sql_type from dual union
select '94dv5f3hg4r8u' sql_id, 'Transactions' sql_type from dual union
select '3wxtkjmb7x8yq' sql_id, 'Transactions' sql_type from dual union
select '8tv1uka27xn8m' sql_id, 'Transactions' sql_type from dual union
select '6mjw9haua9ngg' sql_id, 'Transactions' sql_type from dual union
select 'f42sm56xp5x66' sql_id, 'Transactions' sql_type from dual union
select 'bxkaqmz1yf01z' sql_id, 'Transactions' sql_type from dual union
select '92cqxt4cyab0h' sql_id, 'Transactions' sql_type from dual union
select '00yms5xqwycqv' sql_id, 'Transactions' sql_type from dual union
select '1yn5xsrs82g20' sql_id, 'Transactions' sql_type from dual union
select '53xc07dtu2wm2' sql_id, 'Transactions' sql_type from dual union
select 'cx84mma9prk5m' sql_id, 'Transactions' sql_type from dual union
select 'ggkarwqs78jn7' sql_id, 'Payment' sql_type from dual union
select '53wx4ak7x9ah9' sql_id, 'Payment' sql_type from dual union
select '778dr3qavbxfk' sql_id, 'Payment' sql_type from dual union
select '5gtpvwg82fy41' sql_id, 'Payment' sql_type from dual union
select '02aadxg67pksv' sql_id, 'Payment' sql_type from dual union
select '6svsd0xvj2u2v' sql_id, 'Payment' sql_type from dual union
select 'auuz1u18j9w5x' sql_id, 'Payment' sql_type from dual union
select '4pdp35mr2fb61' sql_id, 'Payment' sql_type from dual union
select '7u71x647vz56s' sql_id, 'Payment' sql_type from dual union
select '1cba2zkbtt6fu' sql_id, 'Payment' sql_type from dual union
select '8wgsw60wxf930' sql_id, 'Payment' sql_type from dual union
select 'bb7yjnp1hst56' sql_id, 'Payment' sql_type from dual union
select 'bb9m2g03azvga' sql_id, 'Payment' sql_type from dual union
select 'g1yq5vdhgk06z' sql_id, 'Payment' sql_type from dual union
select '9c9xt6vpg45vy' sql_id, 'Payment' sql_type from dual union
select '0r1tn59zuh68w' sql_id, 'Payment' sql_type from dual union
select '1dmtfuc74441q' sql_id, 'Payment' sql_type from dual union
select 'byaqpnh2gyqpy' sql_id, 'Payment' sql_type from dual union
select '4shxww12dmat5' sql_id, 'Payment' sql_type from dual union
select '3wbmvtaqf8g6h' sql_id, 'Payment' sql_type from dual union
select 'dqtk7ftf90mwu' sql_id, 'Payment' sql_type from dual union
select 'fc71r4rh4p949' sql_id, 'Payment' sql_type from dual union
select 'bgzhgynxp2pm7' sql_id, 'Payment' sql_type from dual union
select '4suxbg3vjhd9u' sql_id, 'Payment' sql_type from dual union
select 'gy309816j1kbx' sql_id, 'Payment' sql_type from dual union
select '66198wmmyrmqr' sql_id, 'Payment' sql_type from dual union
select 'ggkarwqs78jn7' sql_id, 'Payment' sql_type from dual union
select 'fkyc9wy38vwf' sql_id, 'Access Control (APR)' sql_type from dual union
select 'dpgwfw8fvzxfk' sql_id, 'Approvals' sql_type from dual union
select '5q8zu8x491f0t' sql_id, 'Access Control (APR)' sql_type from dual union
select '1t79hxzxm9sjv' sql_id, 'Approvals' sql_type from dual union
select 'f1u78k5tq0xq7' sql_id, 'Access Control (APR)' sql_type from dual union
select 'f0cjmxm6azh5t' sql_id, 'Approvals' sql_type from dual union
select '83a8a9ka93195' sql_id, 'Access Control (APR)' sql_type from dual union
select '09g380c5b1qj9' sql_id, 'Access Control (APR)' sql_type from dual union
select '89vpbbhqxm2ax' sql_id, 'Approvals' sql_type from dual union
select '5xbqwzs9xcbb1' sql_id, 'Access Control (APR)' sql_type from dual union
select 'f46npwj4x4ytr' sql_id, 'Access Control (APR)' sql_type from dual union
select '4zbm5v7yk1878' sql_id, 'Access Control (APR)' sql_type from dual union
select '8tnv5mds95tzz' sql_id, 'Access Control (APR)' sql_type from dual union
select 'fvqmd33zx5p04' sql_id, 'Access Control (APR)' sql_type from dual union
select '0h4z2wy0vyqrt' sql_id, 'Approvals' sql_type from dual union
select '53wzjtnjxqsyj' sql_id, 'Access Control (APR)' sql_type from dual union
select 'a1t7q7nncvwdf' sql_id, 'Access Control (APR)' sql_type from dual union
select 'c1rj3byg33twq' sql_id, 'Approvals' sql_type from dual union
select 'gx1yas2tkt2yr' sql_id, 'Approvals' sql_type from dual union
select '4pg4b91b5r61b' sql_id, 'Approvals' sql_type from dual union
select 'f2215uv1c6kt9' sql_id, 'Approvals' sql_type from dual union
select 'fuq5jcn7z9m7p' sql_id, 'Arrangement (APR)' sql_type from dual union
select '5gfvdpc83n286' sql_id, 'Payments (APR)' sql_type from dual union
select 'az8ucsb10tg5x' sql_id, 'Payments (APR)' sql_type from dual union
select '7bn0wjjww5yzk' sql_id, 'Payments (APR)' sql_type from dual union
select '0pmj8h3gq2bfb' sql_id, 'Payments (APR)' sql_type from dual union
select '5y20xcatfh7sh' sql_id, 'Approvals' sql_type from dual union
select '4rrm51bug5cuc' sql_id, 'Approvals' sql_type from dual union
select '367bj7upgacfw' sql_id, 'Approvals' sql_type from dual union
select '46zhgrcsfg9f8' sql_id, 'Approvals' sql_type from dual union
select '3j24bjsypjxah' sql_id, 'Approvals' sql_type from dual union
select '8dkfwqtkrjzr4' sql_id, 'Approvals' sql_type from dual union
select '5uzft0uq2wpkz' sql_id, 'Approvals' sql_type from dual union
select 'bm1fvy9t4xuvd' sql_id, 'Approvals' sql_type from dual union
select '7whr9khcc88h4' sql_id, 'Approvals' sql_type from dual union
select '3cu2p8q1kcfys' sql_id, 'Approvals' sql_type from dual union
select '7dtmzstfug6m8' sql_id, 'Approvals' sql_type from dual union
select 'avv5zrjvhd3xj' sql_id, 'Approvals' sql_type from dual union
select '5a0uz59p6u5v9' sql_id, 'Approvals' sql_type from dual union
select '39kpwxnravmh2' sql_id, 'Approvals' sql_type from dual union
select '4f3hzj35ytskm' sql_id, 'Approvals' sql_type from dual union
select 'cd9hwu9pcrh5z' sql_id, 'Approvals' sql_type from dual union
select 'csuj198tns39c' sql_id, 'Approvals' sql_type from dual union
select 'cs5gahs0j7ghw' sql_id, 'Approvals' sql_type from dual union
select '71484v5m1t013' sql_id, 'Approvals' sql_type from dual union
select '72utgkwstrxwx' sql_id, 'Approvals' sql_type from dual union
select 'ffkyc9wy38vwf' sql_id, 'Access Control (APR)' sql_type from dual union
select 'bpjhfj17bng4u' sql_id, 'Arrangement' sql_type from dual union
select 'an3wz0xm0rfk1' sql_id, 'Transactions' sql_type from dual union
select 'bvbv768a84myc' sql_id, 'Audit' sql_type from dual union
select '683bt8z9j8sru' sql_id, 'Audit' sql_type from dual union
select '1pga15vgv0kgt' sql_id, 'CX6' sql_type from dual union
select '4pjpcqmtbhhsu' sql_id, 'CX6' sql_type from dual union
select '5hqps6h0h4wcd' sql_id, 'Transactions' sql_type from dual union
select '5npzvxnd9m0nd' sql_id, 'Transactions' sql_type from dual union
select 'b8g6j3q0tnm9y' sql_id, 'CX6' sql_type from dual union
select 'bn81tpsm5ssu0' sql_id, 'CX6' sql_type from dual union
select 'fuhf1vtfzraf3' sql_id, 'Transactions' sql_type from dual union
select '84z7f9dfytvpc' sql_id, 'Transactions' sql_type from dual union
select '6t2wbzjps5b0v' sql_id, 'Transactions' sql_type from dual union
select '8f5zf904md4kk' sql_id, 'Arrangement' sql_type from dual union
select '711q0yw1cfz1m' sql_id, 'Arrangement' sql_type from dual union
select 'f775m0fn4hxgn' sql_id, 'BB User' sql_type from dual union
select '2nmgnxcbnup2x' sql_id, 'Arrangement' sql_type from dual union
select '0u8yjjuwbx2x0' sql_id, 'Access Control' sql_type from dual union
select '05s98hk89sg18' sql_id, 'Access Control' sql_type from dual union
select '4g2qwacu3ynj6' sql_id, 'Arrangement' sql_type from dual union
select '5v3mah5g1pr9h' sql_id, 'Arrangement' sql_type from dual union
select '9nbwu4r9k129x' sql_id, 'Access Control' sql_type from dual union
select 'a64ku5gv1phy5' sql_id, 'Access Control' sql_type from dual union
select '4wz2ukp0dd360' sql_id, 'Arrangement' sql_type from dual union
select 'fdjhhwksyuka9' sql_id, 'Arrangement' sql_type from dual union
select 'ghh8hxkkdj3h0' sql_id, 'Arrangement' sql_type from dual union
select 'f4mq3mngkppxu' sql_id, 'Access Control' sql_type from dual union
select 'am0h1xmwzq1h1' sql_id, 'Limits' sql_type from dual union
select '09p6jj81vv4q1' sql_id, 'Arrangement' sql_type from dual union
select '87y5ptm5my924' sql_id, 'Payment' sql_type from dual union
select '2j4j1mstp70b5' sql_id, 'Payment' sql_type from dual union
select 'fdw5qg82c2atp' sql_id, 'Access Control' sql_type from dual union
select '058kt9szy52y0' sql_id, 'Limits' sql_type from dual union
select '3bg74kbda1f2y' sql_id, 'Payment' sql_type from dual union
select 'fdu6hwm81gj3b' sql_id, 'Limits' sql_type from dual union
select 'bjnx2s7tmzryd' sql_id, 'Payment' sql_type from dual union
select '9mvaxd1pyddjv' sql_id, 'Payment' sql_type from dual)
, x as (SELECT case when s.sql_id is not null then s.sql_type
       when s.sql_id is null and br.sql_id_b is null then '(+) New'
       else 'Unclassified' end sql_type
, tr.*, br.*
FROM tr
LEFT JOIN s  ON tr.sql_id_t=s.sql_id
LEFT JOIN br ON tr.sql_id_t=br.sql_id_b AND tr.plan_hash_value_t = br.plan_hash_value_b)
SELECT '+ "'||'PARSE_CALLS,'||PARSE_CALLS_R||','||SQL_ID_T||','||PLAN_HASH_VALUE_T||','||SQL_TYPE||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_T,0),0))||','||TO_CHAR(ROUND(NVL(DISK_READS_T,0),0))||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_T,0),0))||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_T,0),0))||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_T,0),0))||','||TO_CHAR(ROUND(NVL(FETCHES_T,0),0))||','||TO_CHAR(ROUND(NVL(EXECUTIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_T,0),0))||','||TO_CHAR(ROUND(NVL(CPU_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(SORTS_T,0),0))||','||TO_CHAR(ROUND(NVL(LOADS_T,0),0))||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_B,0),0))||','||TO_CHAR(ROUND(NVL(DISK_READS_B,0),0))||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_B,0),0))||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_B,0),0))||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_B,0),0))||','||TO_CHAR(ROUND(NVL(FETCHES_B,0),0))||','||TO_CHAR(ROUND(NVL(EXECUTIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_B,0),0))||','||TO_CHAR(ROUND(NVL(CPU_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(SORTS_B,0),0))||','||TO_CHAR(ROUND(NVL(LOADS_B,0),0))||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(DISK_READS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(FETCHES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(EXECUTIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CPU_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(SORTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(LOADS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_S,0),2),'FM9999.99')||'\n"' from x where PARSE_CALLS_R<=20 UNION
SELECT '+ "'||'DISK_READS,'||DISK_READS_R||','||SQL_ID_T||','||PLAN_HASH_VALUE_T||','||SQL_TYPE||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_T,0),0))||','||TO_CHAR(ROUND(NVL(DISK_READS_T,0),0))||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_T,0),0))||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_T,0),0))||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_T,0),0))||','||TO_CHAR(ROUND(NVL(FETCHES_T,0),0))||','||TO_CHAR(ROUND(NVL(EXECUTIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_T,0),0))||','||TO_CHAR(ROUND(NVL(CPU_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(SORTS_T,0),0))||','||TO_CHAR(ROUND(NVL(LOADS_T,0),0))||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_B,0),0))||','||TO_CHAR(ROUND(NVL(DISK_READS_B,0),0))||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_B,0),0))||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_B,0),0))||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_B,0),0))||','||TO_CHAR(ROUND(NVL(FETCHES_B,0),0))||','||TO_CHAR(ROUND(NVL(EXECUTIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_B,0),0))||','||TO_CHAR(ROUND(NVL(CPU_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(SORTS_B,0),0))||','||TO_CHAR(ROUND(NVL(LOADS_B,0),0))||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(DISK_READS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(FETCHES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(EXECUTIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CPU_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(SORTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(LOADS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_S,0),2),'FM9999.99')||'\n"' from x where DISK_READS_R<=20 UNION
SELECT '+ "'||'DIRECT_WRITES,'||DIRECT_WRITES_R||','||SQL_ID_T||','||PLAN_HASH_VALUE_T||','||SQL_TYPE||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_T,0),0))||','||TO_CHAR(ROUND(NVL(DISK_READS_T,0),0))||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_T,0),0))||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_T,0),0))||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_T,0),0))||','||TO_CHAR(ROUND(NVL(FETCHES_T,0),0))||','||TO_CHAR(ROUND(NVL(EXECUTIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_T,0),0))||','||TO_CHAR(ROUND(NVL(CPU_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(SORTS_T,0),0))||','||TO_CHAR(ROUND(NVL(LOADS_T,0),0))||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_B,0),0))||','||TO_CHAR(ROUND(NVL(DISK_READS_B,0),0))||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_B,0),0))||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_B,0),0))||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_B,0),0))||','||TO_CHAR(ROUND(NVL(FETCHES_B,0),0))||','||TO_CHAR(ROUND(NVL(EXECUTIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_B,0),0))||','||TO_CHAR(ROUND(NVL(CPU_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(SORTS_B,0),0))||','||TO_CHAR(ROUND(NVL(LOADS_B,0),0))||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(DISK_READS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(FETCHES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(EXECUTIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CPU_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(SORTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(LOADS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_S,0),2),'FM9999.99')||'\n"' from x where DIRECT_WRITES_R<=20 UNION
SELECT '+ "'||'BUFFER_GETS,'||BUFFER_GETS_R||','||SQL_ID_T||','||PLAN_HASH_VALUE_T||','||SQL_TYPE||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_T,0),0))||','||TO_CHAR(ROUND(NVL(DISK_READS_T,0),0))||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_T,0),0))||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_T,0),0))||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_T,0),0))||','||TO_CHAR(ROUND(NVL(FETCHES_T,0),0))||','||TO_CHAR(ROUND(NVL(EXECUTIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_T,0),0))||','||TO_CHAR(ROUND(NVL(CPU_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(SORTS_T,0),0))||','||TO_CHAR(ROUND(NVL(LOADS_T,0),0))||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_B,0),0))||','||TO_CHAR(ROUND(NVL(DISK_READS_B,0),0))||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_B,0),0))||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_B,0),0))||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_B,0),0))||','||TO_CHAR(ROUND(NVL(FETCHES_B,0),0))||','||TO_CHAR(ROUND(NVL(EXECUTIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_B,0),0))||','||TO_CHAR(ROUND(NVL(CPU_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(SORTS_B,0),0))||','||TO_CHAR(ROUND(NVL(LOADS_B,0),0))||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(DISK_READS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(FETCHES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(EXECUTIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CPU_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(SORTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(LOADS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_S,0),2),'FM9999.99')||'\n"' from x where BUFFER_GETS_R<=20 UNION
SELECT '+ "'||'ROWS_PROCESSED,'||ROWS_PROCESSED_R||','||SQL_ID_T||','||PLAN_HASH_VALUE_T||','||SQL_TYPE||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_T,0),0))||','||TO_CHAR(ROUND(NVL(DISK_READS_T,0),0))||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_T,0),0))||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_T,0),0))||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_T,0),0))||','||TO_CHAR(ROUND(NVL(FETCHES_T,0),0))||','||TO_CHAR(ROUND(NVL(EXECUTIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_T,0),0))||','||TO_CHAR(ROUND(NVL(CPU_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(SORTS_T,0),0))||','||TO_CHAR(ROUND(NVL(LOADS_T,0),0))||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_B,0),0))||','||TO_CHAR(ROUND(NVL(DISK_READS_B,0),0))||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_B,0),0))||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_B,0),0))||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_B,0),0))||','||TO_CHAR(ROUND(NVL(FETCHES_B,0),0))||','||TO_CHAR(ROUND(NVL(EXECUTIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_B,0),0))||','||TO_CHAR(ROUND(NVL(CPU_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(SORTS_B,0),0))||','||TO_CHAR(ROUND(NVL(LOADS_B,0),0))||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(DISK_READS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(FETCHES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(EXECUTIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CPU_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(SORTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(LOADS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_S,0),2),'FM9999.99')||'\n"' from x where ROWS_PROCESSED_R<=20 UNION
SELECT '+ "'||'FETCHES,'||FETCHES_R||','||SQL_ID_T||','||PLAN_HASH_VALUE_T||','||SQL_TYPE||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_T,0),0))||','||TO_CHAR(ROUND(NVL(DISK_READS_T,0),0))||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_T,0),0))||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_T,0),0))||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_T,0),0))||','||TO_CHAR(ROUND(NVL(FETCHES_T,0),0))||','||TO_CHAR(ROUND(NVL(EXECUTIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_T,0),0))||','||TO_CHAR(ROUND(NVL(CPU_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(SORTS_T,0),0))||','||TO_CHAR(ROUND(NVL(LOADS_T,0),0))||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_B,0),0))||','||TO_CHAR(ROUND(NVL(DISK_READS_B,0),0))||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_B,0),0))||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_B,0),0))||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_B,0),0))||','||TO_CHAR(ROUND(NVL(FETCHES_B,0),0))||','||TO_CHAR(ROUND(NVL(EXECUTIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_B,0),0))||','||TO_CHAR(ROUND(NVL(CPU_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(SORTS_B,0),0))||','||TO_CHAR(ROUND(NVL(LOADS_B,0),0))||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(DISK_READS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(FETCHES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(EXECUTIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CPU_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(SORTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(LOADS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_S,0),2),'FM9999.99')||'\n"' from x where FETCHES_R<=20 UNION
SELECT '+ "'||'EXECUTIONS,'||EXECUTIONS_R||','||SQL_ID_T||','||PLAN_HASH_VALUE_T||','||SQL_TYPE||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_T,0),0))||','||TO_CHAR(ROUND(NVL(DISK_READS_T,0),0))||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_T,0),0))||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_T,0),0))||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_T,0),0))||','||TO_CHAR(ROUND(NVL(FETCHES_T,0),0))||','||TO_CHAR(ROUND(NVL(EXECUTIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_T,0),0))||','||TO_CHAR(ROUND(NVL(CPU_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(SORTS_T,0),0))||','||TO_CHAR(ROUND(NVL(LOADS_T,0),0))||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_B,0),0))||','||TO_CHAR(ROUND(NVL(DISK_READS_B,0),0))||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_B,0),0))||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_B,0),0))||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_B,0),0))||','||TO_CHAR(ROUND(NVL(FETCHES_B,0),0))||','||TO_CHAR(ROUND(NVL(EXECUTIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_B,0),0))||','||TO_CHAR(ROUND(NVL(CPU_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(SORTS_B,0),0))||','||TO_CHAR(ROUND(NVL(LOADS_B,0),0))||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(DISK_READS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(FETCHES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(EXECUTIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CPU_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(SORTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(LOADS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_S,0),2),'FM9999.99')||'\n"' from x where EXECUTIONS_R<=20 UNION
SELECT '+ "'||'PX_SERVERS_EXECUTIONS,'||PX_SERVERS_EXECUTIONS_R||','||SQL_ID_T||','||PLAN_HASH_VALUE_T||','||SQL_TYPE||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_T,0),0))||','||TO_CHAR(ROUND(NVL(DISK_READS_T,0),0))||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_T,0),0))||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_T,0),0))||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_T,0),0))||','||TO_CHAR(ROUND(NVL(FETCHES_T,0),0))||','||TO_CHAR(ROUND(NVL(EXECUTIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_T,0),0))||','||TO_CHAR(ROUND(NVL(CPU_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(SORTS_T,0),0))||','||TO_CHAR(ROUND(NVL(LOADS_T,0),0))||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_B,0),0))||','||TO_CHAR(ROUND(NVL(DISK_READS_B,0),0))||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_B,0),0))||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_B,0),0))||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_B,0),0))||','||TO_CHAR(ROUND(NVL(FETCHES_B,0),0))||','||TO_CHAR(ROUND(NVL(EXECUTIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_B,0),0))||','||TO_CHAR(ROUND(NVL(CPU_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(SORTS_B,0),0))||','||TO_CHAR(ROUND(NVL(LOADS_B,0),0))||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(DISK_READS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(FETCHES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(EXECUTIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CPU_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(SORTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(LOADS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_S,0),2),'FM9999.99')||'\n"' from x where PX_SERVERS_EXECUTIONS_R<=20 UNION
SELECT '+ "'||'END_OF_FETCH_COUNT,'||END_OF_FETCH_COUNT_R||','||SQL_ID_T||','||PLAN_HASH_VALUE_T||','||SQL_TYPE||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_T,0),0))||','||TO_CHAR(ROUND(NVL(DISK_READS_T,0),0))||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_T,0),0))||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_T,0),0))||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_T,0),0))||','||TO_CHAR(ROUND(NVL(FETCHES_T,0),0))||','||TO_CHAR(ROUND(NVL(EXECUTIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_T,0),0))||','||TO_CHAR(ROUND(NVL(CPU_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(SORTS_T,0),0))||','||TO_CHAR(ROUND(NVL(LOADS_T,0),0))||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_B,0),0))||','||TO_CHAR(ROUND(NVL(DISK_READS_B,0),0))||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_B,0),0))||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_B,0),0))||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_B,0),0))||','||TO_CHAR(ROUND(NVL(FETCHES_B,0),0))||','||TO_CHAR(ROUND(NVL(EXECUTIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_B,0),0))||','||TO_CHAR(ROUND(NVL(CPU_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(SORTS_B,0),0))||','||TO_CHAR(ROUND(NVL(LOADS_B,0),0))||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(DISK_READS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(FETCHES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(EXECUTIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CPU_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(SORTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(LOADS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_S,0),2),'FM9999.99')||'\n"' from x where END_OF_FETCH_COUNT_R<=20 UNION
SELECT '+ "'||'CPU_TIME,'||CPU_TIME_R||','||SQL_ID_T||','||PLAN_HASH_VALUE_T||','||SQL_TYPE||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_T,0),0))||','||TO_CHAR(ROUND(NVL(DISK_READS_T,0),0))||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_T,0),0))||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_T,0),0))||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_T,0),0))||','||TO_CHAR(ROUND(NVL(FETCHES_T,0),0))||','||TO_CHAR(ROUND(NVL(EXECUTIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_T,0),0))||','||TO_CHAR(ROUND(NVL(CPU_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(SORTS_T,0),0))||','||TO_CHAR(ROUND(NVL(LOADS_T,0),0))||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_B,0),0))||','||TO_CHAR(ROUND(NVL(DISK_READS_B,0),0))||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_B,0),0))||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_B,0),0))||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_B,0),0))||','||TO_CHAR(ROUND(NVL(FETCHES_B,0),0))||','||TO_CHAR(ROUND(NVL(EXECUTIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_B,0),0))||','||TO_CHAR(ROUND(NVL(CPU_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(SORTS_B,0),0))||','||TO_CHAR(ROUND(NVL(LOADS_B,0),0))||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(DISK_READS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(FETCHES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(EXECUTIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CPU_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(SORTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(LOADS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_S,0),2),'FM9999.99')||'\n"' from x where CPU_TIME_R<=20 UNION
SELECT '+ "'||'ELAPSED_TIME,'||ELAPSED_TIME_R||','||SQL_ID_T||','||PLAN_HASH_VALUE_T||','||SQL_TYPE||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_T,0),0))||','||TO_CHAR(ROUND(NVL(DISK_READS_T,0),0))||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_T,0),0))||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_T,0),0))||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_T,0),0))||','||TO_CHAR(ROUND(NVL(FETCHES_T,0),0))||','||TO_CHAR(ROUND(NVL(EXECUTIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_T,0),0))||','||TO_CHAR(ROUND(NVL(CPU_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(SORTS_T,0),0))||','||TO_CHAR(ROUND(NVL(LOADS_T,0),0))||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_B,0),0))||','||TO_CHAR(ROUND(NVL(DISK_READS_B,0),0))||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_B,0),0))||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_B,0),0))||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_B,0),0))||','||TO_CHAR(ROUND(NVL(FETCHES_B,0),0))||','||TO_CHAR(ROUND(NVL(EXECUTIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_B,0),0))||','||TO_CHAR(ROUND(NVL(CPU_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(SORTS_B,0),0))||','||TO_CHAR(ROUND(NVL(LOADS_B,0),0))||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(DISK_READS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(FETCHES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(EXECUTIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CPU_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(SORTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(LOADS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_S,0),2),'FM9999.99')||'\n"' from x where ELAPSED_TIME_R<=20 UNION
SELECT '+ "'||'APPLICATION_WAIT_TIME,'||APPLICATION_WAIT_TIME_R||','||SQL_ID_T||','||PLAN_HASH_VALUE_T||','||SQL_TYPE||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_T,0),0))||','||TO_CHAR(ROUND(NVL(DISK_READS_T,0),0))||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_T,0),0))||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_T,0),0))||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_T,0),0))||','||TO_CHAR(ROUND(NVL(FETCHES_T,0),0))||','||TO_CHAR(ROUND(NVL(EXECUTIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_T,0),0))||','||TO_CHAR(ROUND(NVL(CPU_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(SORTS_T,0),0))||','||TO_CHAR(ROUND(NVL(LOADS_T,0),0))||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_B,0),0))||','||TO_CHAR(ROUND(NVL(DISK_READS_B,0),0))||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_B,0),0))||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_B,0),0))||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_B,0),0))||','||TO_CHAR(ROUND(NVL(FETCHES_B,0),0))||','||TO_CHAR(ROUND(NVL(EXECUTIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_B,0),0))||','||TO_CHAR(ROUND(NVL(CPU_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(SORTS_B,0),0))||','||TO_CHAR(ROUND(NVL(LOADS_B,0),0))||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(DISK_READS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(FETCHES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(EXECUTIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CPU_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(SORTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(LOADS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_S,0),2),'FM9999.99')||'\n"' from x where APPLICATION_WAIT_TIME_R<=20 UNION
SELECT '+ "'||'CONCURRENCY_WAIT_TIME,'||CONCURRENCY_WAIT_TIME_R||','||SQL_ID_T||','||PLAN_HASH_VALUE_T||','||SQL_TYPE||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_T,0),0))||','||TO_CHAR(ROUND(NVL(DISK_READS_T,0),0))||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_T,0),0))||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_T,0),0))||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_T,0),0))||','||TO_CHAR(ROUND(NVL(FETCHES_T,0),0))||','||TO_CHAR(ROUND(NVL(EXECUTIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_T,0),0))||','||TO_CHAR(ROUND(NVL(CPU_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(SORTS_T,0),0))||','||TO_CHAR(ROUND(NVL(LOADS_T,0),0))||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_B,0),0))||','||TO_CHAR(ROUND(NVL(DISK_READS_B,0),0))||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_B,0),0))||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_B,0),0))||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_B,0),0))||','||TO_CHAR(ROUND(NVL(FETCHES_B,0),0))||','||TO_CHAR(ROUND(NVL(EXECUTIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_B,0),0))||','||TO_CHAR(ROUND(NVL(CPU_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(SORTS_B,0),0))||','||TO_CHAR(ROUND(NVL(LOADS_B,0),0))||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(DISK_READS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(FETCHES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(EXECUTIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CPU_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(SORTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(LOADS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_S,0),2),'FM9999.99')||'\n"' from x where CONCURRENCY_WAIT_TIME_R<=20 UNION
SELECT '+ "'||'CLUSTER_WAIT_TIME,'||CLUSTER_WAIT_TIME_R||','||SQL_ID_T||','||PLAN_HASH_VALUE_T||','||SQL_TYPE||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_T,0),0))||','||TO_CHAR(ROUND(NVL(DISK_READS_T,0),0))||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_T,0),0))||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_T,0),0))||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_T,0),0))||','||TO_CHAR(ROUND(NVL(FETCHES_T,0),0))||','||TO_CHAR(ROUND(NVL(EXECUTIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_T,0),0))||','||TO_CHAR(ROUND(NVL(CPU_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(SORTS_T,0),0))||','||TO_CHAR(ROUND(NVL(LOADS_T,0),0))||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_B,0),0))||','||TO_CHAR(ROUND(NVL(DISK_READS_B,0),0))||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_B,0),0))||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_B,0),0))||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_B,0),0))||','||TO_CHAR(ROUND(NVL(FETCHES_B,0),0))||','||TO_CHAR(ROUND(NVL(EXECUTIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_B,0),0))||','||TO_CHAR(ROUND(NVL(CPU_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(SORTS_B,0),0))||','||TO_CHAR(ROUND(NVL(LOADS_B,0),0))||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(DISK_READS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(FETCHES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(EXECUTIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CPU_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(SORTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(LOADS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_S,0),2),'FM9999.99')||'\n"' from x where CLUSTER_WAIT_TIME_R<=20 UNION
SELECT '+ "'||'USER_IO_WAIT_TIME,'||USER_IO_WAIT_TIME_R||','||SQL_ID_T||','||PLAN_HASH_VALUE_T||','||SQL_TYPE||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_T,0),0))||','||TO_CHAR(ROUND(NVL(DISK_READS_T,0),0))||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_T,0),0))||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_T,0),0))||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_T,0),0))||','||TO_CHAR(ROUND(NVL(FETCHES_T,0),0))||','||TO_CHAR(ROUND(NVL(EXECUTIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_T,0),0))||','||TO_CHAR(ROUND(NVL(CPU_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(SORTS_T,0),0))||','||TO_CHAR(ROUND(NVL(LOADS_T,0),0))||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_B,0),0))||','||TO_CHAR(ROUND(NVL(DISK_READS_B,0),0))||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_B,0),0))||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_B,0),0))||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_B,0),0))||','||TO_CHAR(ROUND(NVL(FETCHES_B,0),0))||','||TO_CHAR(ROUND(NVL(EXECUTIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_B,0),0))||','||TO_CHAR(ROUND(NVL(CPU_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(SORTS_B,0),0))||','||TO_CHAR(ROUND(NVL(LOADS_B,0),0))||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(DISK_READS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(FETCHES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(EXECUTIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CPU_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(SORTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(LOADS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_S,0),2),'FM9999.99')||'\n"' from x where USER_IO_WAIT_TIME_R<=20 UNION
SELECT '+ "'||'PLSQL_EXEC_TIME,'||PLSQL_EXEC_TIME_R||','||SQL_ID_T||','||PLAN_HASH_VALUE_T||','||SQL_TYPE||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_T,0),0))||','||TO_CHAR(ROUND(NVL(DISK_READS_T,0),0))||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_T,0),0))||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_T,0),0))||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_T,0),0))||','||TO_CHAR(ROUND(NVL(FETCHES_T,0),0))||','||TO_CHAR(ROUND(NVL(EXECUTIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_T,0),0))||','||TO_CHAR(ROUND(NVL(CPU_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(SORTS_T,0),0))||','||TO_CHAR(ROUND(NVL(LOADS_T,0),0))||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_B,0),0))||','||TO_CHAR(ROUND(NVL(DISK_READS_B,0),0))||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_B,0),0))||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_B,0),0))||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_B,0),0))||','||TO_CHAR(ROUND(NVL(FETCHES_B,0),0))||','||TO_CHAR(ROUND(NVL(EXECUTIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_B,0),0))||','||TO_CHAR(ROUND(NVL(CPU_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(SORTS_B,0),0))||','||TO_CHAR(ROUND(NVL(LOADS_B,0),0))||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(DISK_READS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(FETCHES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(EXECUTIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CPU_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(SORTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(LOADS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_S,0),2),'FM9999.99')||'\n"' from x where PLSQL_EXEC_TIME_R<=20 UNION
SELECT '+ "'||'JAVA_EXEC_TIME,'||JAVA_EXEC_TIME_R||','||SQL_ID_T||','||PLAN_HASH_VALUE_T||','||SQL_TYPE||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_T,0),0))||','||TO_CHAR(ROUND(NVL(DISK_READS_T,0),0))||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_T,0),0))||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_T,0),0))||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_T,0),0))||','||TO_CHAR(ROUND(NVL(FETCHES_T,0),0))||','||TO_CHAR(ROUND(NVL(EXECUTIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_T,0),0))||','||TO_CHAR(ROUND(NVL(CPU_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(SORTS_T,0),0))||','||TO_CHAR(ROUND(NVL(LOADS_T,0),0))||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_B,0),0))||','||TO_CHAR(ROUND(NVL(DISK_READS_B,0),0))||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_B,0),0))||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_B,0),0))||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_B,0),0))||','||TO_CHAR(ROUND(NVL(FETCHES_B,0),0))||','||TO_CHAR(ROUND(NVL(EXECUTIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_B,0),0))||','||TO_CHAR(ROUND(NVL(CPU_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(SORTS_B,0),0))||','||TO_CHAR(ROUND(NVL(LOADS_B,0),0))||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(DISK_READS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(FETCHES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(EXECUTIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CPU_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(SORTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(LOADS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_S,0),2),'FM9999.99')||'\n"' from x where JAVA_EXEC_TIME_R<=20 UNION
SELECT '+ "'||'SORTS,'||SORTS_R||','||SQL_ID_T||','||PLAN_HASH_VALUE_T||','||SQL_TYPE||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_T,0),0))||','||TO_CHAR(ROUND(NVL(DISK_READS_T,0),0))||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_T,0),0))||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_T,0),0))||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_T,0),0))||','||TO_CHAR(ROUND(NVL(FETCHES_T,0),0))||','||TO_CHAR(ROUND(NVL(EXECUTIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_T,0),0))||','||TO_CHAR(ROUND(NVL(CPU_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(SORTS_T,0),0))||','||TO_CHAR(ROUND(NVL(LOADS_T,0),0))||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_B,0),0))||','||TO_CHAR(ROUND(NVL(DISK_READS_B,0),0))||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_B,0),0))||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_B,0),0))||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_B,0),0))||','||TO_CHAR(ROUND(NVL(FETCHES_B,0),0))||','||TO_CHAR(ROUND(NVL(EXECUTIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_B,0),0))||','||TO_CHAR(ROUND(NVL(CPU_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(SORTS_B,0),0))||','||TO_CHAR(ROUND(NVL(LOADS_B,0),0))||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(DISK_READS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(FETCHES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(EXECUTIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CPU_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(SORTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(LOADS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_S,0),2),'FM9999.99')||'\n"' from x where SORTS_R<=20 UNION
SELECT '+ "'||'LOADS,'||LOADS_R||','||SQL_ID_T||','||PLAN_HASH_VALUE_T||','||SQL_TYPE||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_T,0),0))||','||TO_CHAR(ROUND(NVL(DISK_READS_T,0),0))||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_T,0),0))||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_T,0),0))||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_T,0),0))||','||TO_CHAR(ROUND(NVL(FETCHES_T,0),0))||','||TO_CHAR(ROUND(NVL(EXECUTIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_T,0),0))||','||TO_CHAR(ROUND(NVL(CPU_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(SORTS_T,0),0))||','||TO_CHAR(ROUND(NVL(LOADS_T,0),0))||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_B,0),0))||','||TO_CHAR(ROUND(NVL(DISK_READS_B,0),0))||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_B,0),0))||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_B,0),0))||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_B,0),0))||','||TO_CHAR(ROUND(NVL(FETCHES_B,0),0))||','||TO_CHAR(ROUND(NVL(EXECUTIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_B,0),0))||','||TO_CHAR(ROUND(NVL(CPU_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(SORTS_B,0),0))||','||TO_CHAR(ROUND(NVL(LOADS_B,0),0))||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(DISK_READS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(FETCHES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(EXECUTIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CPU_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(SORTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(LOADS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_S,0),2),'FM9999.99')||'\n"' from x where LOADS_R<=20 UNION
SELECT '+ "'||'INVALIDATIONS,'||INVALIDATIONS_R||','||SQL_ID_T||','||PLAN_HASH_VALUE_T||','||SQL_TYPE||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_T,0),0))||','||TO_CHAR(ROUND(NVL(DISK_READS_T,0),0))||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_T,0),0))||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_T,0),0))||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_T,0),0))||','||TO_CHAR(ROUND(NVL(FETCHES_T,0),0))||','||TO_CHAR(ROUND(NVL(EXECUTIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_T,0),0))||','||TO_CHAR(ROUND(NVL(CPU_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(SORTS_T,0),0))||','||TO_CHAR(ROUND(NVL(LOADS_T,0),0))||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_B,0),0))||','||TO_CHAR(ROUND(NVL(DISK_READS_B,0),0))||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_B,0),0))||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_B,0),0))||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_B,0),0))||','||TO_CHAR(ROUND(NVL(FETCHES_B,0),0))||','||TO_CHAR(ROUND(NVL(EXECUTIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_B,0),0))||','||TO_CHAR(ROUND(NVL(CPU_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(SORTS_B,0),0))||','||TO_CHAR(ROUND(NVL(LOADS_B,0),0))||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(DISK_READS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(FETCHES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(EXECUTIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CPU_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(SORTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(LOADS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_S,0),2),'FM9999.99')||'\n"' from x where INVALIDATIONS_R<=20 UNION
SELECT '+ "'||'PHYSICAL_READ_REQUESTS,'||PHYSICAL_READ_REQUESTS_R||','||SQL_ID_T||','||PLAN_HASH_VALUE_T||','||SQL_TYPE||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_T,0),0))||','||TO_CHAR(ROUND(NVL(DISK_READS_T,0),0))||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_T,0),0))||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_T,0),0))||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_T,0),0))||','||TO_CHAR(ROUND(NVL(FETCHES_T,0),0))||','||TO_CHAR(ROUND(NVL(EXECUTIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_T,0),0))||','||TO_CHAR(ROUND(NVL(CPU_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(SORTS_T,0),0))||','||TO_CHAR(ROUND(NVL(LOADS_T,0),0))||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_B,0),0))||','||TO_CHAR(ROUND(NVL(DISK_READS_B,0),0))||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_B,0),0))||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_B,0),0))||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_B,0),0))||','||TO_CHAR(ROUND(NVL(FETCHES_B,0),0))||','||TO_CHAR(ROUND(NVL(EXECUTIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_B,0),0))||','||TO_CHAR(ROUND(NVL(CPU_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(SORTS_B,0),0))||','||TO_CHAR(ROUND(NVL(LOADS_B,0),0))||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(DISK_READS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(FETCHES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(EXECUTIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CPU_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(SORTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(LOADS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_S,0),2),'FM9999.99')||'\n"' from x where PHYSICAL_READ_REQUESTS_R<=20 UNION
SELECT '+ "'||'PHYSICAL_READ_BYTES,'||PHYSICAL_READ_BYTES_R||','||SQL_ID_T||','||PLAN_HASH_VALUE_T||','||SQL_TYPE||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_T,0),0))||','||TO_CHAR(ROUND(NVL(DISK_READS_T,0),0))||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_T,0),0))||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_T,0),0))||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_T,0),0))||','||TO_CHAR(ROUND(NVL(FETCHES_T,0),0))||','||TO_CHAR(ROUND(NVL(EXECUTIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_T,0),0))||','||TO_CHAR(ROUND(NVL(CPU_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(SORTS_T,0),0))||','||TO_CHAR(ROUND(NVL(LOADS_T,0),0))||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_B,0),0))||','||TO_CHAR(ROUND(NVL(DISK_READS_B,0),0))||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_B,0),0))||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_B,0),0))||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_B,0),0))||','||TO_CHAR(ROUND(NVL(FETCHES_B,0),0))||','||TO_CHAR(ROUND(NVL(EXECUTIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_B,0),0))||','||TO_CHAR(ROUND(NVL(CPU_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(SORTS_B,0),0))||','||TO_CHAR(ROUND(NVL(LOADS_B,0),0))||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(DISK_READS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(FETCHES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(EXECUTIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CPU_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(SORTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(LOADS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_S,0),2),'FM9999.99')||'\n"' from x where PHYSICAL_READ_BYTES_R<=20 UNION
SELECT '+ "'||'PHYSICAL_WRITE_REQUESTS,'||PHYSICAL_WRITE_REQUESTS_R||','||SQL_ID_T||','||PLAN_HASH_VALUE_T||','||SQL_TYPE||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_T,0),0))||','||TO_CHAR(ROUND(NVL(DISK_READS_T,0),0))||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_T,0),0))||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_T,0),0))||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_T,0),0))||','||TO_CHAR(ROUND(NVL(FETCHES_T,0),0))||','||TO_CHAR(ROUND(NVL(EXECUTIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_T,0),0))||','||TO_CHAR(ROUND(NVL(CPU_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(SORTS_T,0),0))||','||TO_CHAR(ROUND(NVL(LOADS_T,0),0))||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_B,0),0))||','||TO_CHAR(ROUND(NVL(DISK_READS_B,0),0))||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_B,0),0))||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_B,0),0))||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_B,0),0))||','||TO_CHAR(ROUND(NVL(FETCHES_B,0),0))||','||TO_CHAR(ROUND(NVL(EXECUTIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_B,0),0))||','||TO_CHAR(ROUND(NVL(CPU_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(SORTS_B,0),0))||','||TO_CHAR(ROUND(NVL(LOADS_B,0),0))||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(DISK_READS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(FETCHES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(EXECUTIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CPU_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(SORTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(LOADS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_S,0),2),'FM9999.99')||'\n"' from x where PHYSICAL_WRITE_REQUESTS_R<=20 UNION
SELECT '+ "'||'PHYSICAL_WRITE_BYTES,'||PHYSICAL_WRITE_BYTES_R||','||SQL_ID_T||','||PLAN_HASH_VALUE_T||','||SQL_TYPE||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_T,0),0))||','||TO_CHAR(ROUND(NVL(DISK_READS_T,0),0))||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_T,0),0))||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_T,0),0))||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_T,0),0))||','||TO_CHAR(ROUND(NVL(FETCHES_T,0),0))||','||TO_CHAR(ROUND(NVL(EXECUTIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_T,0),0))||','||TO_CHAR(ROUND(NVL(CPU_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(SORTS_T,0),0))||','||TO_CHAR(ROUND(NVL(LOADS_T,0),0))||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_B,0),0))||','||TO_CHAR(ROUND(NVL(DISK_READS_B,0),0))||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_B,0),0))||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_B,0),0))||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_B,0),0))||','||TO_CHAR(ROUND(NVL(FETCHES_B,0),0))||','||TO_CHAR(ROUND(NVL(EXECUTIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_B,0),0))||','||TO_CHAR(ROUND(NVL(CPU_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(SORTS_B,0),0))||','||TO_CHAR(ROUND(NVL(LOADS_B,0),0))||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(DISK_READS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(FETCHES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(EXECUTIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CPU_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(SORTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(LOADS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_S,0),2),'FM9999.99')||'\n"' from x where PHYSICAL_WRITE_BYTES_R<=20 UNION
SELECT '+ "'||'IO_INTERCONNECT_BYTES,'||IO_INTERCONNECT_BYTES_R||','||SQL_ID_T||','||PLAN_HASH_VALUE_T||','||SQL_TYPE||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_T,0),0))||','||TO_CHAR(ROUND(NVL(DISK_READS_T,0),0))||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_T,0),0))||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_T,0),0))||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_T,0),0))||','||TO_CHAR(ROUND(NVL(FETCHES_T,0),0))||','||TO_CHAR(ROUND(NVL(EXECUTIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_T,0),0))||','||TO_CHAR(ROUND(NVL(CPU_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(SORTS_T,0),0))||','||TO_CHAR(ROUND(NVL(LOADS_T,0),0))||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_B,0),0))||','||TO_CHAR(ROUND(NVL(DISK_READS_B,0),0))||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_B,0),0))||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_B,0),0))||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_B,0),0))||','||TO_CHAR(ROUND(NVL(FETCHES_B,0),0))||','||TO_CHAR(ROUND(NVL(EXECUTIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_B,0),0))||','||TO_CHAR(ROUND(NVL(CPU_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(SORTS_B,0),0))||','||TO_CHAR(ROUND(NVL(LOADS_B,0),0))||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(DISK_READS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(FETCHES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(EXECUTIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CPU_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(SORTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(LOADS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_S,0),2),'FM9999.99')||'\n"' from x where IO_INTERCONNECT_BYTES_R<=20 UNION
SELECT '+ "'||'OTHER_WAIT_TIME,'||OTHER_WAIT_TIME_R||','||SQL_ID_T||','||PLAN_HASH_VALUE_T||','||SQL_TYPE||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_T,0),0))||','||TO_CHAR(ROUND(NVL(DISK_READS_T,0),0))||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_T,0),0))||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_T,0),0))||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_T,0),0))||','||TO_CHAR(ROUND(NVL(FETCHES_T,0),0))||','||TO_CHAR(ROUND(NVL(EXECUTIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_T,0),0))||','||TO_CHAR(ROUND(NVL(CPU_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_T/1000000,0),0))||','||TO_CHAR(ROUND(NVL(SORTS_T,0),0))||','||TO_CHAR(ROUND(NVL(LOADS_T,0),0))||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_T,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_T,0),0))||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_B,0),0))||','||TO_CHAR(ROUND(NVL(DISK_READS_B,0),0))||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_B,0),0))||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_B,0),0))||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_B,0),0))||','||TO_CHAR(ROUND(NVL(FETCHES_B,0),0))||','||TO_CHAR(ROUND(NVL(EXECUTIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_B,0),0))||','||TO_CHAR(ROUND(NVL(CPU_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_B/1000000,0),0))||','||TO_CHAR(ROUND(NVL(SORTS_B,0),0))||','||TO_CHAR(ROUND(NVL(LOADS_B,0),0))||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_B,0),0))||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_B,0),0))||','||TO_CHAR(ROUND(NVL(PARSE_CALLS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(DISK_READS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(DIRECT_WRITES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(BUFFER_GETS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(ROWS_PROCESSED_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(FETCHES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(EXECUTIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PX_SERVERS_EXECUTIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(END_OF_FETCH_COUNT_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CPU_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(ELAPSED_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(APPLICATION_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CONCURRENCY_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(CLUSTER_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(USER_IO_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PLSQL_EXEC_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(JAVA_EXEC_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(OTHER_WAIT_TIME_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(SORTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(LOADS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(INVALIDATIONS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_REQUESTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_READ_BYTES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_REQUESTS_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(PHYSICAL_WRITE_BYTES_S,0),2),'FM9999.99')||','||TO_CHAR(ROUND(NVL(IO_INTERCONNECT_BYTES_S,0),2),'FM9999.99')||'\n"' from x where OTHER_WAIT_TIME_R<=20
;
prompt ;;
prompt
prompt  var csvSysTimeModel = "RANK,STAT_NAME,SYS_TIME_MODEL_BR,SYS_TIME_MODEL_TR\n"
WITH dic as
(SELECT 'DB time' name, 1 rnk, 1 lvl FROM DUAL UNION
SELECT 'DB CPU' name, 2 rnk, 2 lvl FROM DUAL UNION
SELECT 'connection management call elapsed time' name, 3 rnk, 2 lvl FROM DUAL UNION
SELECT 'sequence load elapsed time' name, 4 rnk, 2 lvl FROM DUAL UNION
SELECT 'sql execute elapsed time' name, 5 rnk, 2 lvl FROM DUAL UNION
SELECT 'parse time elapsed' name, 6 rnk, 2 lvl FROM DUAL UNION
SELECT 'hard parse elapsed time' name, 7 rnk, 3 lvl FROM DUAL UNION
SELECT 'hard parse (sharing criteria) elapsed time' name, 8 rnk, 4 lvl FROM DUAL UNION
SELECT 'hard parse (bind mismatch) elapsed time' name, 9 rnk, 5 lvl FROM DUAL UNION
SELECT 'failed parse elapsed time' name, 10 rnk, 3 lvl FROM DUAL UNION
SELECT 'failed parse (out of shared memory) elapsed time' name, 11 rnk, 4 lvl FROM DUAL UNION
SELECT 'PL/SQL execution elapsed time' name, 12 rnk, 2 lvl FROM DUAL UNION
SELECT 'inbound PL/SQL rpc elapsed time' name, 13 rnk, 2 lvl FROM DUAL UNION
SELECT 'PL/SQL compilation elapsed time' name, 14 rnk, 2 lvl FROM DUAL UNION
SELECT 'Java execution elapsed time' name, 15 rnk, 2 lvl FROM DUAL UNION
SELECT 'background elapsed time' name, 16 rnk, 1 lvl FROM DUAL UNION
SELECT 'background cpu time' name, 17 rnk, 2 lvl FROM DUAL)
, tr as (select stat_name, max(value)-min(value) value from XDBSNAPSHOT.TBL_SYS_TIME_MODEL where sample_id between &start_sample_id_tr and &finish_sample_id_tr group by stat_name)
, br as (select stat_name, max(value)-min(value) value from XDBSNAPSHOT.TBL_SYS_TIME_MODEL where sample_id between &start_sample_id_br and &finish_sample_id_br group by stat_name)
SELECT '+ "'||TO_CHAR(dic.rnk)||','||lpad('_',3*lvl-3,'_')||dic.name||','||TO_CHAR(ROUND(NVL(br.value,0)/1000000,0))||','||TO_CHAR(ROUND(NVL(tr.value,0)/1000000,0))||'\n"'  FROM dic
LEFT JOIN tr ON dic.name = tr.stat_name
LEFT JOIN br ON dic.name = br.stat_name
ORDER BY dic.rnk
;
prompt ;;
prompt
prompt var csvDbSummary = "RUNID,DBID,DBNAME,CREATED,LOG_MODE,PLATFORM_NAME,INSTANCE_NUMBER,INSTANCE_NAME,HOST_NAME,VERSION,STARTUP_TIME,STATUS,START_SNAP,END_SNAP,START_TIME,END_TIME\n"
select
'+ "Baseline,'||TO_CHAR(d.dbid)||','||d.name||','||to_char(d.created,'DD.MM.YYYY HH24:MI:SS')||','||d.log_mode||','||d.platform_name||','||TO_CHAR(i.instance_number)||','||i.instance_name||','||i.host_name||','||i.version||','||to_char(i.startup_time,'DD.MM.YYYY HH24:MI:SS')||','||i.status||',&start_sample_id_br'||',&finish_sample_id_br'||',&start_sample_time_br'||',&finish_sample_time_br'||'\n"'
from v$database d, v$instance i UNION
select
'+ "Test run,'||TO_CHAR(d.dbid)||','||d.name||','||to_char(d.created,'DD.MM.YYYY HH24:MI:SS')||','||d.log_mode||','||d.platform_name||','||TO_CHAR(i.instance_number)||','||i.instance_name||','||i.host_name||','||i.version||','||to_char(i.startup_time,'DD.MM.YYYY HH24:MI:SS')||','||i.status||',&start_sample_id_tr'||',&finish_sample_id_tr'||',&start_sample_time_tr'||',&finish_sample_time_tr'||'\n"'
from v$database d, v$instance i;
prompt ;;
prompt
prompt var csvSqlStatsChart = "stat_name,sql_type,value_b,value_t\n"
with tr as (
SELECT
SQL_ID SQL_ID_T,
PLAN_HASH_VALUE PLAN_HASH_VALUE_T,
PARSE_CALLS PARSE_CALLS_T,
DISK_READS DISK_READS_T,
DIRECT_WRITES DIRECT_WRITES_T,
BUFFER_GETS BUFFER_GETS_T,
ROWS_PROCESSED ROWS_PROCESSED_T,
FETCHES FETCHES_T,
EXECUTIONS EXECUTIONS_T,
PX_SERVERS_EXECUTIONS PX_SERVERS_EXECUTIONS_T,
END_OF_FETCH_COUNT END_OF_FETCH_COUNT_T,
CPU_TIME CPU_TIME_T,
ELAPSED_TIME ELAPSED_TIME_T,
APPLICATION_WAIT_TIME APPLICATION_WAIT_TIME_T,
CONCURRENCY_WAIT_TIME CONCURRENCY_WAIT_TIME_T,
CLUSTER_WAIT_TIME CLUSTER_WAIT_TIME_T,
USER_IO_WAIT_TIME USER_IO_WAIT_TIME_T,
PLSQL_EXEC_TIME PLSQL_EXEC_TIME_T,
JAVA_EXEC_TIME JAVA_EXEC_TIME_T,
(ELAPSED_TIME - CPU_TIME - APPLICATION_WAIT_TIME - CONCURRENCY_WAIT_TIME - CLUSTER_WAIT_TIME - USER_IO_WAIT_TIME) OTHER_WAIT_TIME_T,
SORTS SORTS_T,
LOADS LOADS_T,
INVALIDATIONS INVALIDATIONS_T,
PHYSICAL_READ_REQUESTS PHYSICAL_READ_REQUESTS_T,
PHYSICAL_READ_BYTES PHYSICAL_READ_BYTES_T,
PHYSICAL_WRITE_REQUESTS PHYSICAL_WRITE_REQUESTS_T,
PHYSICAL_WRITE_BYTES PHYSICAL_WRITE_BYTES_T,
IO_INTERCONNECT_BYTES IO_INTERCONNECT_BYTES_T
FROM
(SELECT
SQL_ID,
PLAN_HASH_VALUE,
SUM(NVL(DELTA_PARSE_CALLS,0)) PARSE_CALLS,
SUM(NVL(DELTA_DISK_READS,0)) DISK_READS,
SUM(NVL(DELTA_DIRECT_WRITES,0)) DIRECT_WRITES,
SUM(NVL(DELTA_BUFFER_GETS,0)) BUFFER_GETS,
SUM(NVL(DELTA_ROWS_PROCESSED,0)) ROWS_PROCESSED,
SUM(NVL(DELTA_FETCH_COUNT,0)) FETCHES,
SUM(NVL(DELTA_EXECUTION_COUNT,0)) EXECUTIONS,
SUM(NVL(DELTA_PX_SERVERS_EXECUTIONS,0)) PX_SERVERS_EXECUTIONS,
SUM(NVL(DELTA_END_OF_FETCH_COUNT,0)) END_OF_FETCH_COUNT,
SUM(NVL(DELTA_CPU_TIME,0)) CPU_TIME,
SUM(NVL(DELTA_ELAPSED_TIME,0)) ELAPSED_TIME,
SUM(NVL(DELTA_APPLICATION_WAIT_TIME,0)) APPLICATION_WAIT_TIME,
SUM(NVL(DELTA_CONCURRENCY_TIME,0)) CONCURRENCY_WAIT_TIME,
SUM(NVL(DELTA_CLUSTER_WAIT_TIME,0)) CLUSTER_WAIT_TIME,
SUM(NVL(DELTA_USER_IO_WAIT_TIME,0)) USER_IO_WAIT_TIME,
SUM(NVL(DELTA_PLSQL_EXEC_TIME,0)) PLSQL_EXEC_TIME,
SUM(NVL(DELTA_JAVA_EXEC_TIME,0)) JAVA_EXEC_TIME,
SUM(NVL(DELTA_SORTS,0)) SORTS,
SUM(NVL(DELTA_LOADS,0)) LOADS,
SUM(NVL(DELTA_INVALIDATIONS,0)) INVALIDATIONS,
SUM(NVL(DELTA_PHYSICAL_READ_REQUESTS,0)) PHYSICAL_READ_REQUESTS,
SUM(NVL(DELTA_PHYSICAL_READ_BYTES,0)) PHYSICAL_READ_BYTES,
SUM(NVL(DELTA_PHYSICAL_WRITE_REQUESTS,0)) PHYSICAL_WRITE_REQUESTS,
SUM(NVL(DELTA_PHYSICAL_WRITE_BYTES,0)) PHYSICAL_WRITE_BYTES,
SUM(NVL(DELTA_IO_INTERCONNECT_BYTES,0)) IO_INTERCONNECT_BYTES
FROM XDBSNAPSHOT.TBL_SQLSTATS
WHERE sample_id between &start_sample_id_tr+1 and &finish_sample_id_tr
GROUP BY SQL_ID,PLAN_HASH_VALUE)
WHERE ABS(ELAPSED_TIME)+ABS(BUFFER_GETS)+ABS(DISK_READS)+ABS(EXECUTIONS)>0)
, br as (
SELECT
SQL_ID SQL_ID_B,
PLAN_HASH_VALUE PLAN_HASH_VALUE_B,
PARSE_CALLS PARSE_CALLS_B,
DISK_READS DISK_READS_B,
DIRECT_WRITES DIRECT_WRITES_B,
BUFFER_GETS BUFFER_GETS_B,
ROWS_PROCESSED ROWS_PROCESSED_B,
FETCHES FETCHES_B,
EXECUTIONS EXECUTIONS_B,
PX_SERVERS_EXECUTIONS PX_SERVERS_EXECUTIONS_B,
END_OF_FETCH_COUNT END_OF_FETCH_COUNT_B,
CPU_TIME CPU_TIME_B,
ELAPSED_TIME ELAPSED_TIME_B,
APPLICATION_WAIT_TIME APPLICATION_WAIT_TIME_B,
CONCURRENCY_WAIT_TIME CONCURRENCY_WAIT_TIME_B,
CLUSTER_WAIT_TIME CLUSTER_WAIT_TIME_B,
USER_IO_WAIT_TIME USER_IO_WAIT_TIME_B,
PLSQL_EXEC_TIME PLSQL_EXEC_TIME_B,
JAVA_EXEC_TIME JAVA_EXEC_TIME_B,
(ELAPSED_TIME - CPU_TIME - APPLICATION_WAIT_TIME - CONCURRENCY_WAIT_TIME - CLUSTER_WAIT_TIME - USER_IO_WAIT_TIME) OTHER_WAIT_TIME_B,
SORTS SORTS_B,
LOADS LOADS_B,
INVALIDATIONS INVALIDATIONS_B,
PHYSICAL_READ_REQUESTS PHYSICAL_READ_REQUESTS_B,
PHYSICAL_READ_BYTES PHYSICAL_READ_BYTES_B,
PHYSICAL_WRITE_REQUESTS PHYSICAL_WRITE_REQUESTS_B,
PHYSICAL_WRITE_BYTES PHYSICAL_WRITE_BYTES_B,
IO_INTERCONNECT_BYTES IO_INTERCONNECT_BYTES_B
FROM
(SELECT
SQL_ID,
PLAN_HASH_VALUE,
SUM(NVL(DELTA_PARSE_CALLS,0)) PARSE_CALLS,
SUM(NVL(DELTA_DISK_READS,0)) DISK_READS,
SUM(NVL(DELTA_DIRECT_WRITES,0)) DIRECT_WRITES,
SUM(NVL(DELTA_BUFFER_GETS,0)) BUFFER_GETS,
SUM(NVL(DELTA_ROWS_PROCESSED,0)) ROWS_PROCESSED,
SUM(NVL(DELTA_FETCH_COUNT,0)) FETCHES,
SUM(NVL(DELTA_EXECUTION_COUNT,0)) EXECUTIONS,
SUM(NVL(DELTA_PX_SERVERS_EXECUTIONS,0)) PX_SERVERS_EXECUTIONS,
SUM(NVL(DELTA_END_OF_FETCH_COUNT,0)) END_OF_FETCH_COUNT,
SUM(NVL(DELTA_CPU_TIME,0)) CPU_TIME,
SUM(NVL(DELTA_ELAPSED_TIME,0)) ELAPSED_TIME,
SUM(NVL(DELTA_APPLICATION_WAIT_TIME,0)) APPLICATION_WAIT_TIME,
SUM(NVL(DELTA_CONCURRENCY_TIME,0)) CONCURRENCY_WAIT_TIME,
SUM(NVL(DELTA_CLUSTER_WAIT_TIME,0)) CLUSTER_WAIT_TIME,
SUM(NVL(DELTA_USER_IO_WAIT_TIME,0)) USER_IO_WAIT_TIME,
SUM(NVL(DELTA_PLSQL_EXEC_TIME,0)) PLSQL_EXEC_TIME,
SUM(NVL(DELTA_JAVA_EXEC_TIME,0)) JAVA_EXEC_TIME,
SUM(NVL(DELTA_SORTS,0)) SORTS,
SUM(NVL(DELTA_LOADS,0)) LOADS,
SUM(NVL(DELTA_INVALIDATIONS,0)) INVALIDATIONS,
SUM(NVL(DELTA_PHYSICAL_READ_REQUESTS,0)) PHYSICAL_READ_REQUESTS,
SUM(NVL(DELTA_PHYSICAL_READ_BYTES,0)) PHYSICAL_READ_BYTES,
SUM(NVL(DELTA_PHYSICAL_WRITE_REQUESTS,0)) PHYSICAL_WRITE_REQUESTS,
SUM(NVL(DELTA_PHYSICAL_WRITE_BYTES,0)) PHYSICAL_WRITE_BYTES,
SUM(NVL(DELTA_IO_INTERCONNECT_BYTES,0)) IO_INTERCONNECT_BYTES
FROM XDBSNAPSHOT.TBL_SQLSTATS
WHERE sample_id between &start_sample_id_br+1 and &finish_sample_id_br
GROUP BY SQL_ID,PLAN_HASH_VALUE)
WHERE ABS(ELAPSED_TIME)+ABS(BUFFER_GETS)+ABS(DISK_READS)+ABS(EXECUTIONS)>0)
, s as (select 'c6n9vdhjkgg1j' sql_id, 'AWR' sql_type from dual union
select '0109cw056m96y' sql_id, 'AWR' sql_type from dual union
select '2ckav84qvrjg9' sql_id, 'AWR' sql_type from dual union
select '40ppuqwqk6brb' sql_id, 'AWR' sql_type from dual union
select '4ndwnvfsu3ufm' sql_id, 'AWR' sql_type from dual union
select '94m7y1a60jg2n' sql_id, 'AWR' sql_type from dual union
select 'cv61hcs3xkh0a' sql_id, 'Contacts' sql_type from dual union
select 'dy8u5zsmdzgks' sql_id, 'Contacts' sql_type from dual union
select '4rdq6x27bkwvf' sql_id, 'Contacts' sql_type from dual union
select 'f5ypgtcjkbf95' sql_id, 'Contacts' sql_type from dual union
select 'cfmjqnfaqngnu' sql_id, 'Contacts' sql_type from dual union
select 'danzt0bdrra93' sql_id, 'Contacts' sql_type from dual union
select '58d9aa28z0jzp' sql_id, 'Contacts' sql_type from dual union
select 'crft2sr0yzpr9' sql_id, 'Contacts' sql_type from dual union
select '4h0y82y0dwnwa' sql_id, 'Contacts' sql_type from dual union
select '2qfwmd4vbcbcg' sql_id, 'Contacts' sql_type from dual union
select '9m685urx5th2d' sql_id, 'Contacts' sql_type from dual union
select '8hk24xhz2qg78' sql_id, 'Contacts' sql_type from dual union
select '9vb1xsjvm5gdc' sql_id, 'Contacts' sql_type from dual union
select '8jrxbk6add2qd' sql_id, 'Contacts' sql_type from dual union
select 'cg16vntgj3k15' sql_id, 'Contacts' sql_type from dual union
select '1uw85c8c5kr8w' sql_id, 'Contacts' sql_type from dual union
select '3fw4absn88h38' sql_id, 'Contacts' sql_type from dual union
select '2wv3tx7qq38k8' sql_id, 'Contacts' sql_type from dual union
select 'gyvrtfjs7j05x' sql_id, 'Contacts' sql_type from dual union
select '8jrxbk6add2qd' sql_id, 'Contacts' sql_type from dual union
select 'f5ypgtcjkbf95' sql_id, 'Contacts' sql_type from dual union
select 'ax9jn9ypdjmk7' sql_id, 'Contacts' sql_type from dual union
select '9vb1xsjvm5gdc' sql_id, 'Contacts' sql_type from dual union
select 'ax9jn9ypdjmk7' sql_id, 'Contacts' sql_type from dual union
select '7sx5p1ug5ag12' sql_id, 'sys' sql_type from dual union
select '63cnhugxhmakh' sql_id, 'BB User' sql_type from dual union
select '7umy6juhzw766' sql_id, 'sys' sql_type from dual union
select 'cumxzt4usubs3' sql_id, 'Access Control' sql_type from dual union
select '5uun7vdkpktg4' sql_id, 'Access Control' sql_type from dual union
select '6msa3cfw970b3' sql_id, 'sys' sql_type from dual union
select 'gnhkshx7g60h8' sql_id, 'Arrangement' sql_type from dual union
select '8uh6xphq54kh0' sql_id, 'sys' sql_type from dual union
select '1p5grz1gs7fjq' sql_id, 'sys' sql_type from dual union
select 'ct2g3h4c98fp4' sql_id, 'sys' sql_type from dual union
select '5wwkp7spyq2fn' sql_id, 'sys' sql_type from dual union
select '37846778azhd6' sql_id, 'Payment' sql_type from dual union
select '27by5yrm0buq1' sql_id, 'Arrangement' sql_type from dual union
select '93xubhsjvgyfp' sql_id, 'Payment' sql_type from dual union
select 'b0cq5rsrh71vw' sql_id, 'Payment' sql_type from dual union
select '65c65nng8tkdt' sql_id, 'Payment' sql_type from dual union
select '6qz82dptj0qr7' sql_id, 'sys' sql_type from dual union
select '3un99a0zwp4vd' sql_id, 'sys' sql_type from dual union
select '7nuw4xwrnuwxq' sql_id, 'sys' sql_type from dual union
select 'axa03uqckxg9t' sql_id, 'Payment' sql_type from dual union
select '96m2bmmjg33gj' sql_id, 'Payment' sql_type from dual union
select 'g66md6muf0mb3' sql_id, 'Payment' sql_type from dual union
select '9g485acn2n30m' sql_id, 'sys' sql_type from dual union
select '21dsn7a9w4tyr' sql_id, 'Access Control' sql_type from dual union
select '9d2hmk8gy0r44' sql_id, 'Access Control' sql_type from dual union
select '2czz7mv2r6xqx' sql_id, 'Access Control' sql_type from dual union
select '7ytfq31vb7u32' sql_id, 'Access Control' sql_type from dual union
select '8gsfhmjtw00w0' sql_id, 'Arrangement' sql_type from dual union
select '9rfqm06xmuwu0' sql_id, 'sys' sql_type from dual union
select 'fny4dtx31y1zp' sql_id, 'Payment' sql_type from dual union
select '8wksn7rs3x23f' sql_id, 'sys' sql_type from dual union
select '7fwum1yuknrsh' sql_id, 'sys' sql_type from dual union
select 'gd28w82ct6rva' sql_id, 'sys' sql_type from dual union
select 'fq3f1vdv581ds' sql_id, 'sys' sql_type from dual union
select '86kwhy1f0bttn' sql_id, 'sys' sql_type from dual union
select '2tkw12w5k68vd' sql_id, 'sys' sql_type from dual union
select 'a6ygk0r9s5xuj' sql_id, 'sys' sql_type from dual union
select '622ufbrgvxdc7' sql_id, 'sys' sql_type from dual union
select '7u49y06aqxg1s' sql_id, 'sys' sql_type from dual union
select 'f0h5rpzmhju11' sql_id, 'sys' sql_type from dual union
select '73y7sjsqhzm6t' sql_id, 'rds' sql_type from dual union
select 'b3v25sg2hrsrv' sql_id, 'rds' sql_type from dual union
select 'gp1dhz5jffc0f' sql_id, 'Payment' sql_type from dual union
select '1y8d34phk5wq5' sql_id, 'Payment' sql_type from dual union
select '0m6rqhsrrq5g8' sql_id, 'Payment' sql_type from dual union
select '277b2d3au6ukw' sql_id, 'Payment' sql_type from dual union
select '3nzv2smdzzbsf' sql_id, 'sys' sql_type from dual union
select '6qj7bn8hvc7ph' sql_id, 'Arrangement' sql_type from dual union
select 'c4cr75ud9ujvg' sql_id, 'sys' sql_type from dual union
select '3h0a0h5srz9t9' sql_id, 'sys' sql_type from dual union
select 'fuws5bqghb2qh' sql_id, 'sys' sql_type from dual union
select '679x4qggryd2v' sql_id, 'sys' sql_type from dual union
select 'ca6tq9wk5wakf' sql_id, 'sys' sql_type from dual union
select 'bayq8637hww90' sql_id, 'sys' sql_type from dual union
select '7k3py88s25w9w' sql_id, 'rds' sql_type from dual union
select '0zg5scs7brcfg' sql_id, 'sys' sql_type from dual union
select '7rhmtdnh02uq6' sql_id, 'sys' sql_type from dual union
select '4xvhbr5835v9r' sql_id, 'other' sql_type from dual union
select '3y1nk3vthv2hj' sql_id, 'other' sql_type from dual union
select '26xzgnyjsfwpa' sql_id, 'other' sql_type from dual union
select '8jdvgmwjshhgd' sql_id, 'other' sql_type from dual union
select '9xkk4svdm8gw6' sql_id, 'other' sql_type from dual union
select 'fxfzwt2y20tdm' sql_id, 'sys' sql_type from dual union
select '80z99fv2c3j4c' sql_id, 'other' sql_type from dual union
select '0fmb19vjgk8d9' sql_id, 'Payment' sql_type from dual union
select '8fk98540xbfcb' sql_id, 'sys' sql_type from dual union
select '60bwp9x9jc0dy' sql_id, 'sys' sql_type from dual union
select '5pvg4869ju1y0' sql_id, 'other' sql_type from dual union
select 'a9dgdvgmbwcwm' sql_id, 'other' sql_type from dual union
select 'fcbh6d0cbmmca' sql_id, 'sys' sql_type from dual union
select '14dsy1hg4057q' sql_id, 'Payment' sql_type from dual union
select '5r8sf8qp40tj1' sql_id, 'sys' sql_type from dual union
select '4phvdvx32a3mf' sql_id, 'sys' sql_type from dual union
select '98n7q1kq9p5a7' sql_id, 'sys' sql_type from dual union
select '1kz16yhs993h2' sql_id, 'sys' sql_type from dual union
select 'b3s1x9zqrvzvc' sql_id, 'sys' sql_type from dual union
select '0v3dvmc22qnam' sql_id, 'sys' sql_type from dual union
select 'dma0vxbwh325p' sql_id, 'sys' sql_type from dual union
select '1h3hsh6y85ty8' sql_id, 'sys' sql_type from dual union
select 'gm9t6ycmb1yu6' sql_id, 'sys' sql_type from dual union
select 'gqp6kd8xbjkvv' sql_id, 'Payment' sql_type from dual union
select '7kmbrw7q8hn4g' sql_id, 'sys' sql_type from dual union
select '0qbzfjt00pbsx' sql_id, 'sys' sql_type from dual union
select '2ygnt73ck3jk8' sql_id, 'sys' sql_type from dual union
select 'b9c6ffh8tc71f' sql_id, 'sys' sql_type from dual union
select '00zqy3yd0r3p3' sql_id, 'sys' sql_type from dual union
select '2jhah7b46j8m1' sql_id, 'sys' sql_type from dual union
select '3j02ckjb0j3hh' sql_id, 'Access Control' sql_type from dual union
select '1zjccx5tkctb1' sql_id, 'Contacts' sql_type from dual union
select '11st4yznxdj3r' sql_id, 'Contacts' sql_type from dual union
select '0qjwxgbsgg9d1' sql_id, 'Contacts' sql_type from dual union
select '9f7z8cc1cmaxx' sql_id, 'Contacts' sql_type from dual union
select '7fxn85xbb04u1' sql_id, 'Access Control' sql_type from dual union
select 'b899gb63y1kav' sql_id, 'CX6' sql_type from dual union
select '34ttdsp2rn9x0' sql_id, 'CX6' sql_type from dual union
select '3mp90hzdswcqb' sql_id, 'CX6' sql_type from dual union
select 'f9rkhg3pwsp50' sql_id, 'Access Control' sql_type from dual union
select 'faft02rqhk2f0' sql_id, 'CX6' sql_type from dual union
select '00afbbc4bk0tc' sql_id, 'BB User' sql_type from dual union
select '3kzydt3r6q224' sql_id, 'CX6' sql_type from dual union
select 'gykmypgdujmam' sql_id, 'Arrangement' sql_type from dual union
select 'azcp0rpx81gf4' sql_id, 'CX6' sql_type from dual union
select '2ur6uh0f11ard' sql_id, 'CX6' sql_type from dual union
select 'ayt5z7acz1001' sql_id, 'CX6' sql_type from dual union
select 'ct45cc74j14un' sql_id, 'CX6' sql_type from dual union
select 'cnfy6j57fyxy5' sql_id, 'Arrangement' sql_type from dual union
select 'gjmr4dnw3yk82' sql_id, 'Access Control' sql_type from dual union
select '56pfkggymym2p' sql_id, 'CX6' sql_type from dual union
select '5txdc2rqwymck' sql_id, 'CX6' sql_type from dual union
select '5va2qknrnqmfc' sql_id, 'CX6' sql_type from dual union
select '5v69hhf3wvtv5' sql_id, 'CX6' sql_type from dual union
select 'cv3453453rydr' sql_id, 'Arrangement' sql_type from dual union
select 'fv2hjgzsbzv9q' sql_id, 'CX6' sql_type from dual union
select 'b8u6d0awybfs8' sql_id, 'CX6' sql_type from dual union
select '3b177g5msmt5v' sql_id, 'CX6' sql_type from dual union
select '6fav4yc54mt6m' sql_id, 'CX6' sql_type from dual union
select '6drwfd9mybm7m' sql_id, 'Arrangement' sql_type from dual union
select '7gtvc55fsvtd3' sql_id, 'CX6' sql_type from dual union
select '1pza3j4133942' sql_id, 'CX6' sql_type from dual union
select '94dv5f3hg4r8u' sql_id, 'Transactions' sql_type from dual union
select '3wxtkjmb7x8yq' sql_id, 'Transactions' sql_type from dual union
select '8tv1uka27xn8m' sql_id, 'Transactions' sql_type from dual union
select '6mjw9haua9ngg' sql_id, 'Transactions' sql_type from dual union
select 'f42sm56xp5x66' sql_id, 'Transactions' sql_type from dual union
select 'bxkaqmz1yf01z' sql_id, 'Transactions' sql_type from dual union
select '92cqxt4cyab0h' sql_id, 'Transactions' sql_type from dual union
select '00yms5xqwycqv' sql_id, 'Transactions' sql_type from dual union
select '1yn5xsrs82g20' sql_id, 'Transactions' sql_type from dual union
select '53xc07dtu2wm2' sql_id, 'Transactions' sql_type from dual union
select 'cx84mma9prk5m' sql_id, 'Transactions' sql_type from dual union
select 'ggkarwqs78jn7' sql_id, 'Payment' sql_type from dual union
select '53wx4ak7x9ah9' sql_id, 'Payment' sql_type from dual union
select '778dr3qavbxfk' sql_id, 'Payment' sql_type from dual union
select '5gtpvwg82fy41' sql_id, 'Payment' sql_type from dual union
select '02aadxg67pksv' sql_id, 'Payment' sql_type from dual union
select '6svsd0xvj2u2v' sql_id, 'Payment' sql_type from dual union
select 'auuz1u18j9w5x' sql_id, 'Payment' sql_type from dual union
select '4pdp35mr2fb61' sql_id, 'Payment' sql_type from dual union
select '7u71x647vz56s' sql_id, 'Payment' sql_type from dual union
select '1cba2zkbtt6fu' sql_id, 'Payment' sql_type from dual union
select '8wgsw60wxf930' sql_id, 'Payment' sql_type from dual union
select 'bb7yjnp1hst56' sql_id, 'Payment' sql_type from dual union
select 'bb9m2g03azvga' sql_id, 'Payment' sql_type from dual union
select 'g1yq5vdhgk06z' sql_id, 'Payment' sql_type from dual union
select '9c9xt6vpg45vy' sql_id, 'Payment' sql_type from dual union
select '0r1tn59zuh68w' sql_id, 'Payment' sql_type from dual union
select '1dmtfuc74441q' sql_id, 'Payment' sql_type from dual union
select 'byaqpnh2gyqpy' sql_id, 'Payment' sql_type from dual union
select '4shxww12dmat5' sql_id, 'Payment' sql_type from dual union
select '3wbmvtaqf8g6h' sql_id, 'Payment' sql_type from dual union
select 'dqtk7ftf90mwu' sql_id, 'Payment' sql_type from dual union
select 'fc71r4rh4p949' sql_id, 'Payment' sql_type from dual union
select 'bgzhgynxp2pm7' sql_id, 'Payment' sql_type from dual union
select '4suxbg3vjhd9u' sql_id, 'Payment' sql_type from dual union
select 'gy309816j1kbx' sql_id, 'Payment' sql_type from dual union
select '66198wmmyrmqr' sql_id, 'Payment' sql_type from dual union
select 'ggkarwqs78jn7' sql_id, 'Payment' sql_type from dual union
select 'fkyc9wy38vwf' sql_id, 'Access Control (APR)' sql_type from dual union
select 'dpgwfw8fvzxfk' sql_id, 'Approvals' sql_type from dual union
select '5q8zu8x491f0t' sql_id, 'Access Control (APR)' sql_type from dual union
select '1t79hxzxm9sjv' sql_id, 'Approvals' sql_type from dual union
select 'f1u78k5tq0xq7' sql_id, 'Access Control (APR)' sql_type from dual union
select 'f0cjmxm6azh5t' sql_id, 'Approvals' sql_type from dual union
select '83a8a9ka93195' sql_id, 'Access Control (APR)' sql_type from dual union
select '09g380c5b1qj9' sql_id, 'Access Control (APR)' sql_type from dual union
select '89vpbbhqxm2ax' sql_id, 'Approvals' sql_type from dual union
select '5xbqwzs9xcbb1' sql_id, 'Access Control (APR)' sql_type from dual union
select 'f46npwj4x4ytr' sql_id, 'Access Control (APR)' sql_type from dual union
select '4zbm5v7yk1878' sql_id, 'Access Control (APR)' sql_type from dual union
select '8tnv5mds95tzz' sql_id, 'Access Control (APR)' sql_type from dual union
select 'fvqmd33zx5p04' sql_id, 'Access Control (APR)' sql_type from dual union
select '0h4z2wy0vyqrt' sql_id, 'Approvals' sql_type from dual union
select '53wzjtnjxqsyj' sql_id, 'Access Control (APR)' sql_type from dual union
select 'a1t7q7nncvwdf' sql_id, 'Access Control (APR)' sql_type from dual union
select 'c1rj3byg33twq' sql_id, 'Approvals' sql_type from dual union
select 'gx1yas2tkt2yr' sql_id, 'Approvals' sql_type from dual union
select '4pg4b91b5r61b' sql_id, 'Approvals' sql_type from dual union
select 'f2215uv1c6kt9' sql_id, 'Approvals' sql_type from dual union
select 'fuq5jcn7z9m7p' sql_id, 'Arrangement (APR)' sql_type from dual union
select '5gfvdpc83n286' sql_id, 'Payments (APR)' sql_type from dual union
select 'az8ucsb10tg5x' sql_id, 'Payments (APR)' sql_type from dual union
select '7bn0wjjww5yzk' sql_id, 'Payments (APR)' sql_type from dual union
select '0pmj8h3gq2bfb' sql_id, 'Payments (APR)' sql_type from dual union
select '5y20xcatfh7sh' sql_id, 'Approvals' sql_type from dual union
select '4rrm51bug5cuc' sql_id, 'Approvals' sql_type from dual union
select '367bj7upgacfw' sql_id, 'Approvals' sql_type from dual union
select '46zhgrcsfg9f8' sql_id, 'Approvals' sql_type from dual union
select '3j24bjsypjxah' sql_id, 'Approvals' sql_type from dual union
select '8dkfwqtkrjzr4' sql_id, 'Approvals' sql_type from dual union
select '5uzft0uq2wpkz' sql_id, 'Approvals' sql_type from dual union
select 'bm1fvy9t4xuvd' sql_id, 'Approvals' sql_type from dual union
select '7whr9khcc88h4' sql_id, 'Approvals' sql_type from dual union
select '3cu2p8q1kcfys' sql_id, 'Approvals' sql_type from dual union
select '7dtmzstfug6m8' sql_id, 'Approvals' sql_type from dual union
select 'avv5zrjvhd3xj' sql_id, 'Approvals' sql_type from dual union
select '5a0uz59p6u5v9' sql_id, 'Approvals' sql_type from dual union
select '39kpwxnravmh2' sql_id, 'Approvals' sql_type from dual union
select '4f3hzj35ytskm' sql_id, 'Approvals' sql_type from dual union
select 'cd9hwu9pcrh5z' sql_id, 'Approvals' sql_type from dual union
select 'csuj198tns39c' sql_id, 'Approvals' sql_type from dual union
select 'cs5gahs0j7ghw' sql_id, 'Approvals' sql_type from dual union
select '71484v5m1t013' sql_id, 'Approvals' sql_type from dual union
select '72utgkwstrxwx' sql_id, 'Approvals' sql_type from dual union
select 'ffkyc9wy38vwf' sql_id, 'Access Control (APR)' sql_type from dual union
select 'bpjhfj17bng4u' sql_id, 'Arrangement' sql_type from dual union
select 'an3wz0xm0rfk1' sql_id, 'Transactions' sql_type from dual union
select 'bvbv768a84myc' sql_id, 'Audit' sql_type from dual union
select '683bt8z9j8sru' sql_id, 'Audit' sql_type from dual union
select '1pga15vgv0kgt' sql_id, 'CX6' sql_type from dual union
select '4pjpcqmtbhhsu' sql_id, 'CX6' sql_type from dual union
select '5hqps6h0h4wcd' sql_id, 'Transactions' sql_type from dual union
select '5npzvxnd9m0nd' sql_id, 'Transactions' sql_type from dual union
select 'b8g6j3q0tnm9y' sql_id, 'CX6' sql_type from dual union
select 'bn81tpsm5ssu0' sql_id, 'CX6' sql_type from dual union
select 'fuhf1vtfzraf3' sql_id, 'Transactions' sql_type from dual union
select '84z7f9dfytvpc' sql_id, 'Transactions' sql_type from dual union
select '6t2wbzjps5b0v' sql_id, 'Transactions' sql_type from dual union
select '8f5zf904md4kk' sql_id, 'Arrangement' sql_type from dual union
select '711q0yw1cfz1m' sql_id, 'Arrangement' sql_type from dual union
select 'f775m0fn4hxgn' sql_id, 'BB User' sql_type from dual union
select '2nmgnxcbnup2x' sql_id, 'Arrangement' sql_type from dual union
select '0u8yjjuwbx2x0' sql_id, 'Access Control' sql_type from dual union
select '05s98hk89sg18' sql_id, 'Access Control' sql_type from dual union
select '4g2qwacu3ynj6' sql_id, 'Arrangement' sql_type from dual union
select '5v3mah5g1pr9h' sql_id, 'Arrangement' sql_type from dual union
select '9nbwu4r9k129x' sql_id, 'Access Control' sql_type from dual union
select 'a64ku5gv1phy5' sql_id, 'Access Control' sql_type from dual union
select '4wz2ukp0dd360' sql_id, 'Arrangement' sql_type from dual union
select 'fdjhhwksyuka9' sql_id, 'Arrangement' sql_type from dual union
select 'ghh8hxkkdj3h0' sql_id, 'Arrangement' sql_type from dual union
select 'f4mq3mngkppxu' sql_id, 'Access Control' sql_type from dual union
select 'am0h1xmwzq1h1' sql_id, 'Limits' sql_type from dual union
select '09p6jj81vv4q1' sql_id, 'Arrangement' sql_type from dual union
select '87y5ptm5my924' sql_id, 'Payment' sql_type from dual union
select '2j4j1mstp70b5' sql_id, 'Payment' sql_type from dual union
select 'fdw5qg82c2atp' sql_id, 'Access Control' sql_type from dual union
select '058kt9szy52y0' sql_id, 'Limits' sql_type from dual union
select '3bg74kbda1f2y' sql_id, 'Payment' sql_type from dual union
select 'fdu6hwm81gj3b' sql_id, 'Limits' sql_type from dual union
select 'bjnx2s7tmzryd' sql_id, 'Payment' sql_type from dual union
select '9mvaxd1pyddjv' sql_id, 'Payment' sql_type from dual)
, x as (select
case when br.sql_id_b is null then '0: New (+)'
       when tr.sql_id_t is null then '0: Aged out (-)'
       when s.sql_id is not null then s.sql_type
       else '0: Unclassified' end sql_type
       , br.*
       , tr.*
from tr
full outer join br on tr.sql_id_t=br.sql_id_b AND tr.plan_hash_value_t = br.plan_hash_value_b
left join s on tr.sql_id_t = s.sql_id)
SELECT '+ "'||'SQL_TYPE,'||sql_type||','||0||','||COUNT(1)||'\n"' from x WHERE sql_type = '0: New (+)' GROUP BY sql_type UNION
SELECT '+ "'||'SQL_TYPE,'||sql_type||','||COUNT(1)||','||0||'\n"' from x WHERE sql_type = '0: Aged out (-)' GROUP BY sql_type UNION
SELECT '+ "'||'SQL_TYPE,'||sql_type||','||COUNT(1)||','||COUNT(1)||'\n"' from x WHERE sql_type not in ('0: New (+)', '0: Aged out (-)') GROUP BY sql_type UNION
SELECT '+ "'||'PARSE_CALLS,'||sql_type||','||SUM(NVL(PARSE_CALLS_B,0))||','||SUM(NVL(PARSE_CALLS_T,0))||'\n"' from x GROUP BY sql_type UNION
SELECT '+ "'||'DISK_READS,'||sql_type||','||SUM(NVL(DISK_READS_B,0))||','||SUM(NVL(DISK_READS_T,0))||'\n"' from x GROUP BY sql_type UNION
SELECT '+ "'||'DIRECT_WRITES,'||sql_type||','||SUM(NVL(DIRECT_WRITES_B,0))||','||SUM(NVL(DIRECT_WRITES_T,0))||'\n"' from x GROUP BY sql_type UNION
SELECT '+ "'||'BUFFER_GETS,'||sql_type||','||SUM(NVL(BUFFER_GETS_B,0))||','||SUM(NVL(BUFFER_GETS_T,0))||'\n"' from x GROUP BY sql_type UNION
SELECT '+ "'||'ROWS_PROCESSED,'||sql_type||','||SUM(NVL(ROWS_PROCESSED_B,0))||','||SUM(NVL(ROWS_PROCESSED_T,0))||'\n"' from x GROUP BY sql_type UNION
SELECT '+ "'||'FETCHES,'||sql_type||','||SUM(NVL(FETCHES_B,0))||','||SUM(NVL(FETCHES_T,0))||'\n"' from x GROUP BY sql_type UNION
SELECT '+ "'||'EXECUTIONS,'||sql_type||','||SUM(NVL(EXECUTIONS_B,0))||','||SUM(NVL(EXECUTIONS_T,0))||'\n"' from x GROUP BY sql_type UNION
SELECT '+ "'||'PX_SERVERS_EXECUTIONS,'||sql_type||','||SUM(NVL(PX_SERVERS_EXECUTIONS_B,0))||','||SUM(NVL(PX_SERVERS_EXECUTIONS_T,0))||'\n"' from x GROUP BY sql_type UNION
SELECT '+ "'||'END_OF_FETCH_COUNT,'||sql_type||','||SUM(NVL(END_OF_FETCH_COUNT_B,0))||','||SUM(NVL(END_OF_FETCH_COUNT_T,0))||'\n"' from x GROUP BY sql_type UNION
SELECT '+ "'||'CPU_TIME,'||sql_type||','||TO_CHAR(ROUND(SUM(NVL(CPU_TIME_B,0))/1000000,0))||','||TO_CHAR(ROUND(SUM(NVL(CPU_TIME_T,0))/1000000,0))||'\n"' from x GROUP BY sql_type UNION
SELECT '+ "'||'ELAPSED_TIME,'||sql_type||','||TO_CHAR(ROUND(SUM(NVL(ELAPSED_TIME_B,0))/1000000,0))||','||TO_CHAR(ROUND(SUM(NVL(ELAPSED_TIME_T,0))/1000000,0))||'\n"' from x GROUP BY sql_type UNION
SELECT '+ "'||'APPLICATION_WAIT_TIME,'||sql_type||','||TO_CHAR(ROUND(SUM(NVL(APPLICATION_WAIT_TIME_B,0))/1000000,0))||','||TO_CHAR(ROUND(SUM(NVL(APPLICATION_WAIT_TIME_T,0))/1000000,0))||'\n"' from x GROUP BY sql_type UNION
SELECT '+ "'||'CONCURRENCY_WAIT_TIME,'||sql_type||','||TO_CHAR(ROUND(SUM(NVL(CONCURRENCY_WAIT_TIME_B,0))/1000000,0))||','||TO_CHAR(ROUND(SUM(NVL(CONCURRENCY_WAIT_TIME_T,0))/1000000,0))||'\n"' from x GROUP BY sql_type UNION
SELECT '+ "'||'CLUSTER_WAIT_TIME,'||sql_type||','||TO_CHAR(ROUND(SUM(NVL(CLUSTER_WAIT_TIME_B,0))/1000000,0))||','||TO_CHAR(ROUND(SUM(NVL(CLUSTER_WAIT_TIME_T,0))/1000000,0))||'\n"' from x GROUP BY sql_type UNION
SELECT '+ "'||'USER_IO_WAIT_TIME,'||sql_type||','||TO_CHAR(ROUND(SUM(NVL(USER_IO_WAIT_TIME_B,0))/1000000,0))||','||TO_CHAR(ROUND(SUM(NVL(USER_IO_WAIT_TIME_T,0))/1000000,0))||'\n"' from x GROUP BY sql_type UNION
SELECT '+ "'||'PLSQL_EXEC_TIME,'||sql_type||','||TO_CHAR(ROUND(SUM(NVL(PLSQL_EXEC_TIME_B,0))/1000000,0))||','||TO_CHAR(ROUND(SUM(NVL(PLSQL_EXEC_TIME_T,0))/1000000,0))||'\n"' from x GROUP BY sql_type UNION
SELECT '+ "'||'JAVA_EXEC_TIME,'||sql_type||','||TO_CHAR(ROUND(SUM(NVL(JAVA_EXEC_TIME_B,0))/1000000,0))||','||TO_CHAR(ROUND(SUM(NVL(JAVA_EXEC_TIME_T,0))/1000000,0))||'\n"' from x GROUP BY sql_type UNION
SELECT '+ "'||'SORTS,'||sql_type||','||SUM(NVL(SORTS_B,0))||','||SUM(NVL(SORTS_T,0))||'\n"' from x GROUP BY sql_type UNION
SELECT '+ "'||'LOADS,'||sql_type||','||SUM(NVL(LOADS_B,0))||','||SUM(NVL(LOADS_T,0))||'\n"' from x GROUP BY sql_type UNION
SELECT '+ "'||'INVALIDATIONS,'||sql_type||','||SUM(NVL(INVALIDATIONS_B,0))||','||SUM(NVL(INVALIDATIONS_T,0))||'\n"' from x GROUP BY sql_type UNION
SELECT '+ "'||'PHYSICAL_READ_REQUESTS,'||sql_type||','||SUM(NVL(PHYSICAL_READ_REQUESTS_B,0))||','||SUM(NVL(PHYSICAL_READ_REQUESTS_T,0))||'\n"' from x GROUP BY sql_type UNION
SELECT '+ "'||'PHYSICAL_READ_BYTES,'||sql_type||','||SUM(NVL(PHYSICAL_READ_BYTES_B,0))||','||SUM(NVL(PHYSICAL_READ_BYTES_T,0))||'\n"' from x GROUP BY sql_type UNION
SELECT '+ "'||'PHYSICAL_WRITE_REQUESTS,'||sql_type||','||SUM(NVL(PHYSICAL_WRITE_REQUESTS_B,0))||','||SUM(NVL(PHYSICAL_WRITE_REQUESTS_T,0))||'\n"' from x GROUP BY sql_type UNION
SELECT '+ "'||'PHYSICAL_WRITE_BYTES,'||sql_type||','||SUM(NVL(PHYSICAL_WRITE_BYTES_B,0))||','||SUM(NVL(PHYSICAL_WRITE_BYTES_T,0))||'\n"' from x GROUP BY sql_type UNION
SELECT '+ "'||'IO_INTERCONNECT_BYTES,'||sql_type||','||SUM(NVL(IO_INTERCONNECT_BYTES_B,0))||','||SUM(NVL(IO_INTERCONNECT_BYTES_T,0))||'\n"' from x GROUP BY sql_type;
prompt ;;
prompt var csvSqlText = "SQL_ID!@#!SQL_TYPE!@#!SQL_TEXT\n"
with tr as (SELECT SQL_ID_T FROM (
SELECT
SQL_ID SQL_ID_T,
PLAN_HASH_VALUE PLAN_HASH_VALUE_T,
PARSE_CALLS PARSE_CALLS_T,
DISK_READS DISK_READS_T,
DIRECT_WRITES DIRECT_WRITES_T,
BUFFER_GETS BUFFER_GETS_T,
ROWS_PROCESSED ROWS_PROCESSED_T,
FETCHES FETCHES_T,
EXECUTIONS EXECUTIONS_T,
PX_SERVERS_EXECUTIONS PX_SERVERS_EXECUTIONS_T,
END_OF_FETCH_COUNT END_OF_FETCH_COUNT_T,
CPU_TIME CPU_TIME_T,
ELAPSED_TIME ELAPSED_TIME_T,
APPLICATION_WAIT_TIME APPLICATION_WAIT_TIME_T,
CONCURRENCY_WAIT_TIME CONCURRENCY_WAIT_TIME_T,
CLUSTER_WAIT_TIME CLUSTER_WAIT_TIME_T,
USER_IO_WAIT_TIME USER_IO_WAIT_TIME_T,
PLSQL_EXEC_TIME PLSQL_EXEC_TIME_T,
JAVA_EXEC_TIME JAVA_EXEC_TIME_T,
(ELAPSED_TIME - CPU_TIME - APPLICATION_WAIT_TIME - CONCURRENCY_WAIT_TIME - CLUSTER_WAIT_TIME - USER_IO_WAIT_TIME) OTHER_WAIT_TIME_T,
SORTS SORTS_T,
LOADS LOADS_T,
INVALIDATIONS INVALIDATIONS_T,
PHYSICAL_READ_REQUESTS PHYSICAL_READ_REQUESTS_T,
PHYSICAL_READ_BYTES PHYSICAL_READ_BYTES_T,
PHYSICAL_WRITE_REQUESTS PHYSICAL_WRITE_REQUESTS_T,
PHYSICAL_WRITE_BYTES PHYSICAL_WRITE_BYTES_T,
IO_INTERCONNECT_BYTES IO_INTERCONNECT_BYTES_T,
ROW_NUMBER() OVER (ORDER BY PARSE_CALLS DESC) PARSE_CALLS_R,
ROW_NUMBER() OVER (ORDER BY DISK_READS DESC) DISK_READS_R,
ROW_NUMBER() OVER (ORDER BY DIRECT_WRITES DESC) DIRECT_WRITES_R,
ROW_NUMBER() OVER (ORDER BY BUFFER_GETS DESC) BUFFER_GETS_R,
ROW_NUMBER() OVER (ORDER BY ROWS_PROCESSED DESC) ROWS_PROCESSED_R,
ROW_NUMBER() OVER (ORDER BY FETCHES DESC) FETCHES_R,
ROW_NUMBER() OVER (ORDER BY EXECUTIONS DESC) EXECUTIONS_R,
ROW_NUMBER() OVER (ORDER BY PX_SERVERS_EXECUTIONS DESC) PX_SERVERS_EXECUTIONS_R,
ROW_NUMBER() OVER (ORDER BY END_OF_FETCH_COUNT DESC) END_OF_FETCH_COUNT_R,
ROW_NUMBER() OVER (ORDER BY CPU_TIME DESC) CPU_TIME_R,
ROW_NUMBER() OVER (ORDER BY ELAPSED_TIME DESC) ELAPSED_TIME_R,
ROW_NUMBER() OVER (ORDER BY APPLICATION_WAIT_TIME DESC) APPLICATION_WAIT_TIME_R,
ROW_NUMBER() OVER (ORDER BY CONCURRENCY_WAIT_TIME DESC) CONCURRENCY_WAIT_TIME_R,
ROW_NUMBER() OVER (ORDER BY CLUSTER_WAIT_TIME DESC) CLUSTER_WAIT_TIME_R,
ROW_NUMBER() OVER (ORDER BY USER_IO_WAIT_TIME DESC) USER_IO_WAIT_TIME_R,
ROW_NUMBER() OVER (ORDER BY PLSQL_EXEC_TIME DESC) PLSQL_EXEC_TIME_R,
ROW_NUMBER() OVER (ORDER BY JAVA_EXEC_TIME DESC) JAVA_EXEC_TIME_R,
ROW_NUMBER() OVER (ORDER BY (ELAPSED_TIME - CPU_TIME - APPLICATION_WAIT_TIME - CONCURRENCY_WAIT_TIME - CLUSTER_WAIT_TIME - USER_IO_WAIT_TIME) DESC) OTHER_WAIT_TIME_R,
ROW_NUMBER() OVER (ORDER BY SORTS DESC) SORTS_R,
ROW_NUMBER() OVER (ORDER BY LOADS DESC) LOADS_R,
ROW_NUMBER() OVER (ORDER BY INVALIDATIONS DESC) INVALIDATIONS_R,
ROW_NUMBER() OVER (ORDER BY PHYSICAL_READ_REQUESTS DESC) PHYSICAL_READ_REQUESTS_R,
ROW_NUMBER() OVER (ORDER BY PHYSICAL_READ_BYTES DESC) PHYSICAL_READ_BYTES_R,
ROW_NUMBER() OVER (ORDER BY PHYSICAL_WRITE_REQUESTS DESC) PHYSICAL_WRITE_REQUESTS_R,
ROW_NUMBER() OVER (ORDER BY PHYSICAL_WRITE_BYTES DESC) PHYSICAL_WRITE_BYTES_R,
ROW_NUMBER() OVER (ORDER BY IO_INTERCONNECT_BYTES DESC) IO_INTERCONNECT_BYTES_R,
ROUND(NVL(RATIO_TO_REPORT(PARSE_CALLS) OVER (),0),2) PARSE_CALLS_S,
ROUND(NVL(RATIO_TO_REPORT(DISK_READS) OVER (),0),2) DISK_READS_S,
ROUND(NVL(RATIO_TO_REPORT(DIRECT_WRITES) OVER (),0),2) DIRECT_WRITES_S,
ROUND(NVL(RATIO_TO_REPORT(BUFFER_GETS) OVER (),0),2) BUFFER_GETS_S,
ROUND(NVL(RATIO_TO_REPORT(ROWS_PROCESSED) OVER (),0),2) ROWS_PROCESSED_S,
ROUND(NVL(RATIO_TO_REPORT(FETCHES) OVER (),0),2) FETCHES_S,
ROUND(NVL(RATIO_TO_REPORT(EXECUTIONS) OVER (),0),2) EXECUTIONS_S,
ROUND(NVL(RATIO_TO_REPORT(PX_SERVERS_EXECUTIONS) OVER (),0),2) PX_SERVERS_EXECUTIONS_S,
ROUND(NVL(RATIO_TO_REPORT(END_OF_FETCH_COUNT) OVER (),0),2) END_OF_FETCH_COUNT_S,
ROUND(NVL(RATIO_TO_REPORT(CPU_TIME) OVER (),0),2) CPU_TIME_S,
ROUND(NVL(RATIO_TO_REPORT(ELAPSED_TIME) OVER (),0),2) ELAPSED_TIME_S,
ROUND(NVL(RATIO_TO_REPORT(APPLICATION_WAIT_TIME) OVER (),0),2) APPLICATION_WAIT_TIME_S,
ROUND(NVL(RATIO_TO_REPORT(CONCURRENCY_WAIT_TIME) OVER (),0),2) CONCURRENCY_WAIT_TIME_S,
ROUND(NVL(RATIO_TO_REPORT(CLUSTER_WAIT_TIME) OVER (),0),2) CLUSTER_WAIT_TIME_S,
ROUND(NVL(RATIO_TO_REPORT(USER_IO_WAIT_TIME) OVER (),0),2) USER_IO_WAIT_TIME_S,
ROUND(NVL(RATIO_TO_REPORT(PLSQL_EXEC_TIME) OVER (),0),2) PLSQL_EXEC_TIME_S,
ROUND(NVL(RATIO_TO_REPORT(JAVA_EXEC_TIME) OVER (),0),2) JAVA_EXEC_TIME_S,
ROUND(NVL(RATIO_TO_REPORT((ELAPSED_TIME - CPU_TIME - APPLICATION_WAIT_TIME - CONCURRENCY_WAIT_TIME - CLUSTER_WAIT_TIME - USER_IO_WAIT_TIME)) OVER (),0),2) OTHER_WAIT_TIME_S,
ROUND(NVL(RATIO_TO_REPORT(SORTS) OVER (),0),2) SORTS_S,
ROUND(NVL(RATIO_TO_REPORT(LOADS) OVER (),0),2) LOADS_S,
ROUND(NVL(RATIO_TO_REPORT(INVALIDATIONS) OVER (),0),2) INVALIDATIONS_S,
ROUND(NVL(RATIO_TO_REPORT(PHYSICAL_READ_REQUESTS) OVER (),0),2) PHYSICAL_READ_REQUESTS_S,
ROUND(NVL(RATIO_TO_REPORT(PHYSICAL_READ_BYTES) OVER (),0),2) PHYSICAL_READ_BYTES_S,
ROUND(NVL(RATIO_TO_REPORT(PHYSICAL_WRITE_REQUESTS) OVER (),0),2) PHYSICAL_WRITE_REQUESTS_S,
ROUND(NVL(RATIO_TO_REPORT(PHYSICAL_WRITE_BYTES) OVER (),0),2) PHYSICAL_WRITE_BYTES_S,
ROUND(NVL(RATIO_TO_REPORT(IO_INTERCONNECT_BYTES) OVER (),0),2) IO_INTERCONNECT_BYTES_S
FROM
(SELECT
SQL_ID,
PLAN_HASH_VALUE,
SUM(NVL(DELTA_PARSE_CALLS,0)) PARSE_CALLS,
SUM(NVL(DELTA_DISK_READS,0)) DISK_READS,
SUM(NVL(DELTA_DIRECT_WRITES,0)) DIRECT_WRITES,
SUM(NVL(DELTA_BUFFER_GETS,0)) BUFFER_GETS,
SUM(NVL(DELTA_ROWS_PROCESSED,0)) ROWS_PROCESSED,
SUM(NVL(DELTA_FETCH_COUNT,0)) FETCHES,
SUM(NVL(DELTA_EXECUTION_COUNT,0)) EXECUTIONS,
SUM(NVL(DELTA_PX_SERVERS_EXECUTIONS,0)) PX_SERVERS_EXECUTIONS,
SUM(NVL(DELTA_END_OF_FETCH_COUNT,0)) END_OF_FETCH_COUNT,
SUM(NVL(DELTA_CPU_TIME,0)) CPU_TIME,
SUM(NVL(DELTA_ELAPSED_TIME,0)) ELAPSED_TIME,
SUM(NVL(DELTA_APPLICATION_WAIT_TIME,0)) APPLICATION_WAIT_TIME,
SUM(NVL(DELTA_CONCURRENCY_TIME,0)) CONCURRENCY_WAIT_TIME,
SUM(NVL(DELTA_CLUSTER_WAIT_TIME,0)) CLUSTER_WAIT_TIME,
SUM(NVL(DELTA_USER_IO_WAIT_TIME,0)) USER_IO_WAIT_TIME,
SUM(NVL(DELTA_PLSQL_EXEC_TIME,0)) PLSQL_EXEC_TIME,
SUM(NVL(DELTA_JAVA_EXEC_TIME,0)) JAVA_EXEC_TIME,
SUM(NVL(DELTA_SORTS,0)) SORTS,
SUM(NVL(DELTA_LOADS,0)) LOADS,
SUM(NVL(DELTA_INVALIDATIONS,0)) INVALIDATIONS,
SUM(NVL(DELTA_PHYSICAL_READ_REQUESTS,0)) PHYSICAL_READ_REQUESTS,
SUM(NVL(DELTA_PHYSICAL_READ_BYTES,0)) PHYSICAL_READ_BYTES,
SUM(NVL(DELTA_PHYSICAL_WRITE_REQUESTS,0)) PHYSICAL_WRITE_REQUESTS,
SUM(NVL(DELTA_PHYSICAL_WRITE_BYTES,0)) PHYSICAL_WRITE_BYTES,
SUM(NVL(DELTA_IO_INTERCONNECT_BYTES,0)) IO_INTERCONNECT_BYTES
FROM XDBSNAPSHOT.TBL_SQLSTATS
WHERE sample_id between &start_sample_id_tr+1 and &finish_sample_id_tr
GROUP BY SQL_ID,PLAN_HASH_VALUE)
WHERE ABS(ELAPSED_TIME)+ABS(BUFFER_GETS)+ABS(DISK_READS)+ABS(EXECUTIONS)>0)
WHERE ((PARSE_CALLS_R<=20 AND PARSE_CALLS_T>0) OR
(DISK_READS_R<=20 AND DISK_READS_T>0) OR
(DIRECT_WRITES_R<=20 AND DIRECT_WRITES_T>0) OR
(BUFFER_GETS_R<=20 AND BUFFER_GETS_T>0) OR
(ROWS_PROCESSED_R<=20 AND ROWS_PROCESSED_T>0) OR
(FETCHES_R<=20 AND FETCHES_T>0) OR
(EXECUTIONS_R<=20 AND EXECUTIONS_T>0) OR
(PX_SERVERS_EXECUTIONS_R<=20 AND PX_SERVERS_EXECUTIONS_T>0) OR
(END_OF_FETCH_COUNT_R<=20 AND END_OF_FETCH_COUNT_T>0) OR
(CPU_TIME_R<=20 AND CPU_TIME_T>0) OR
(ELAPSED_TIME_R<=20 AND ELAPSED_TIME_T>0) OR
(APPLICATION_WAIT_TIME_R<=20 AND APPLICATION_WAIT_TIME_T>0) OR
(CONCURRENCY_WAIT_TIME_R<=20 AND CONCURRENCY_WAIT_TIME_T>0) OR
(CLUSTER_WAIT_TIME_R<=20 AND CLUSTER_WAIT_TIME_T>0) OR
(USER_IO_WAIT_TIME_R<=20 AND USER_IO_WAIT_TIME_T>0) OR
(PLSQL_EXEC_TIME_R<=20 AND PLSQL_EXEC_TIME_T>0) OR
(JAVA_EXEC_TIME_R<=20 AND JAVA_EXEC_TIME_T>0) OR
(SORTS_R<=20 AND SORTS_T>0) OR
(LOADS_R<=20 AND LOADS_T>0) OR
(INVALIDATIONS_R<=20 AND INVALIDATIONS_T>0) OR
(PHYSICAL_READ_REQUESTS_R<=20 AND PHYSICAL_READ_REQUESTS_T>0) OR
(PHYSICAL_READ_BYTES_R<=20 AND PHYSICAL_READ_BYTES_T>0) OR
(PHYSICAL_WRITE_REQUESTS_R<=20 AND PHYSICAL_WRITE_REQUESTS_T>0) OR
(PHYSICAL_WRITE_BYTES_R<=20 AND PHYSICAL_WRITE_BYTES_T>0) OR
(IO_INTERCONNECT_BYTES_R<=20 AND IO_INTERCONNECT_BYTES_T>0)))
, s as (select 'c6n9vdhjkgg1j' sql_id, 'AWR' sql_type from dual union
select '0109cw056m96y' sql_id, 'AWR' sql_type from dual union
select '2ckav84qvrjg9' sql_id, 'AWR' sql_type from dual union
select '40ppuqwqk6brb' sql_id, 'AWR' sql_type from dual union
select '4ndwnvfsu3ufm' sql_id, 'AWR' sql_type from dual union
select '94m7y1a60jg2n' sql_id, 'AWR' sql_type from dual union
select 'cv61hcs3xkh0a' sql_id, 'Contacts' sql_type from dual union
select 'dy8u5zsmdzgks' sql_id, 'Contacts' sql_type from dual union
select '4rdq6x27bkwvf' sql_id, 'Contacts' sql_type from dual union
select 'f5ypgtcjkbf95' sql_id, 'Contacts' sql_type from dual union
select 'cfmjqnfaqngnu' sql_id, 'Contacts' sql_type from dual union
select 'danzt0bdrra93' sql_id, 'Contacts' sql_type from dual union
select '58d9aa28z0jzp' sql_id, 'Contacts' sql_type from dual union
select 'crft2sr0yzpr9' sql_id, 'Contacts' sql_type from dual union
select '4h0y82y0dwnwa' sql_id, 'Contacts' sql_type from dual union
select '2qfwmd4vbcbcg' sql_id, 'Contacts' sql_type from dual union
select '9m685urx5th2d' sql_id, 'Contacts' sql_type from dual union
select '8hk24xhz2qg78' sql_id, 'Contacts' sql_type from dual union
select '9vb1xsjvm5gdc' sql_id, 'Contacts' sql_type from dual union
select '8jrxbk6add2qd' sql_id, 'Contacts' sql_type from dual union
select 'cg16vntgj3k15' sql_id, 'Contacts' sql_type from dual union
select '1uw85c8c5kr8w' sql_id, 'Contacts' sql_type from dual union
select '3fw4absn88h38' sql_id, 'Contacts' sql_type from dual union
select '2wv3tx7qq38k8' sql_id, 'Contacts' sql_type from dual union
select 'gyvrtfjs7j05x' sql_id, 'Contacts' sql_type from dual union
select '8jrxbk6add2qd' sql_id, 'Contacts' sql_type from dual union
select 'f5ypgtcjkbf95' sql_id, 'Contacts' sql_type from dual union
select 'ax9jn9ypdjmk7' sql_id, 'Contacts' sql_type from dual union
select '9vb1xsjvm5gdc' sql_id, 'Contacts' sql_type from dual union
select 'ax9jn9ypdjmk7' sql_id, 'Contacts' sql_type from dual union
select '7sx5p1ug5ag12' sql_id, 'sys' sql_type from dual union
select '63cnhugxhmakh' sql_id, 'BB User' sql_type from dual union
select '7umy6juhzw766' sql_id, 'sys' sql_type from dual union
select 'cumxzt4usubs3' sql_id, 'Access Control' sql_type from dual union
select '5uun7vdkpktg4' sql_id, 'Access Control' sql_type from dual union
select '6msa3cfw970b3' sql_id, 'sys' sql_type from dual union
select 'gnhkshx7g60h8' sql_id, 'Arrangement' sql_type from dual union
select '8uh6xphq54kh0' sql_id, 'sys' sql_type from dual union
select '1p5grz1gs7fjq' sql_id, 'sys' sql_type from dual union
select 'ct2g3h4c98fp4' sql_id, 'sys' sql_type from dual union
select '5wwkp7spyq2fn' sql_id, 'sys' sql_type from dual union
select '37846778azhd6' sql_id, 'Payment' sql_type from dual union
select '27by5yrm0buq1' sql_id, 'Arrangement' sql_type from dual union
select '93xubhsjvgyfp' sql_id, 'Payment' sql_type from dual union
select 'b0cq5rsrh71vw' sql_id, 'Payment' sql_type from dual union
select '65c65nng8tkdt' sql_id, 'Payment' sql_type from dual union
select '6qz82dptj0qr7' sql_id, 'sys' sql_type from dual union
select '3un99a0zwp4vd' sql_id, 'sys' sql_type from dual union
select '7nuw4xwrnuwxq' sql_id, 'sys' sql_type from dual union
select 'axa03uqckxg9t' sql_id, 'Payment' sql_type from dual union
select '96m2bmmjg33gj' sql_id, 'Payment' sql_type from dual union
select 'g66md6muf0mb3' sql_id, 'Payment' sql_type from dual union
select '9g485acn2n30m' sql_id, 'sys' sql_type from dual union
select '21dsn7a9w4tyr' sql_id, 'Access Control' sql_type from dual union
select '9d2hmk8gy0r44' sql_id, 'Access Control' sql_type from dual union
select '2czz7mv2r6xqx' sql_id, 'Access Control' sql_type from dual union
select '7ytfq31vb7u32' sql_id, 'Access Control' sql_type from dual union
select '8gsfhmjtw00w0' sql_id, 'Arrangement' sql_type from dual union
select '9rfqm06xmuwu0' sql_id, 'sys' sql_type from dual union
select 'fny4dtx31y1zp' sql_id, 'Payment' sql_type from dual union
select '8wksn7rs3x23f' sql_id, 'sys' sql_type from dual union
select '7fwum1yuknrsh' sql_id, 'sys' sql_type from dual union
select 'gd28w82ct6rva' sql_id, 'sys' sql_type from dual union
select 'fq3f1vdv581ds' sql_id, 'sys' sql_type from dual union
select '86kwhy1f0bttn' sql_id, 'sys' sql_type from dual union
select '2tkw12w5k68vd' sql_id, 'sys' sql_type from dual union
select 'a6ygk0r9s5xuj' sql_id, 'sys' sql_type from dual union
select '622ufbrgvxdc7' sql_id, 'sys' sql_type from dual union
select '7u49y06aqxg1s' sql_id, 'sys' sql_type from dual union
select 'f0h5rpzmhju11' sql_id, 'sys' sql_type from dual union
select '73y7sjsqhzm6t' sql_id, 'rds' sql_type from dual union
select 'b3v25sg2hrsrv' sql_id, 'rds' sql_type from dual union
select 'gp1dhz5jffc0f' sql_id, 'Payment' sql_type from dual union
select '1y8d34phk5wq5' sql_id, 'Payment' sql_type from dual union
select '0m6rqhsrrq5g8' sql_id, 'Payment' sql_type from dual union
select '277b2d3au6ukw' sql_id, 'Payment' sql_type from dual union
select '3nzv2smdzzbsf' sql_id, 'sys' sql_type from dual union
select '6qj7bn8hvc7ph' sql_id, 'Arrangement' sql_type from dual union
select 'c4cr75ud9ujvg' sql_id, 'sys' sql_type from dual union
select '3h0a0h5srz9t9' sql_id, 'sys' sql_type from dual union
select 'fuws5bqghb2qh' sql_id, 'sys' sql_type from dual union
select '679x4qggryd2v' sql_id, 'sys' sql_type from dual union
select 'ca6tq9wk5wakf' sql_id, 'sys' sql_type from dual union
select 'bayq8637hww90' sql_id, 'sys' sql_type from dual union
select '7k3py88s25w9w' sql_id, 'rds' sql_type from dual union
select '0zg5scs7brcfg' sql_id, 'sys' sql_type from dual union
select '7rhmtdnh02uq6' sql_id, 'sys' sql_type from dual union
select '4xvhbr5835v9r' sql_id, 'other' sql_type from dual union
select '3y1nk3vthv2hj' sql_id, 'other' sql_type from dual union
select '26xzgnyjsfwpa' sql_id, 'other' sql_type from dual union
select '8jdvgmwjshhgd' sql_id, 'other' sql_type from dual union
select '9xkk4svdm8gw6' sql_id, 'other' sql_type from dual union
select 'fxfzwt2y20tdm' sql_id, 'sys' sql_type from dual union
select '80z99fv2c3j4c' sql_id, 'other' sql_type from dual union
select '0fmb19vjgk8d9' sql_id, 'Payment' sql_type from dual union
select '8fk98540xbfcb' sql_id, 'sys' sql_type from dual union
select '60bwp9x9jc0dy' sql_id, 'sys' sql_type from dual union
select '5pvg4869ju1y0' sql_id, 'other' sql_type from dual union
select 'a9dgdvgmbwcwm' sql_id, 'other' sql_type from dual union
select 'fcbh6d0cbmmca' sql_id, 'sys' sql_type from dual union
select '14dsy1hg4057q' sql_id, 'Payment' sql_type from dual union
select '5r8sf8qp40tj1' sql_id, 'sys' sql_type from dual union
select '4phvdvx32a3mf' sql_id, 'sys' sql_type from dual union
select '98n7q1kq9p5a7' sql_id, 'sys' sql_type from dual union
select '1kz16yhs993h2' sql_id, 'sys' sql_type from dual union
select 'b3s1x9zqrvzvc' sql_id, 'sys' sql_type from dual union
select '0v3dvmc22qnam' sql_id, 'sys' sql_type from dual union
select 'dma0vxbwh325p' sql_id, 'sys' sql_type from dual union
select '1h3hsh6y85ty8' sql_id, 'sys' sql_type from dual union
select 'gm9t6ycmb1yu6' sql_id, 'sys' sql_type from dual union
select 'gqp6kd8xbjkvv' sql_id, 'Payment' sql_type from dual union
select '7kmbrw7q8hn4g' sql_id, 'sys' sql_type from dual union
select '0qbzfjt00pbsx' sql_id, 'sys' sql_type from dual union
select '2ygnt73ck3jk8' sql_id, 'sys' sql_type from dual union
select 'b9c6ffh8tc71f' sql_id, 'sys' sql_type from dual union
select '00zqy3yd0r3p3' sql_id, 'sys' sql_type from dual union
select '2jhah7b46j8m1' sql_id, 'sys' sql_type from dual union
select '3j02ckjb0j3hh' sql_id, 'Access Control' sql_type from dual union
select '1zjccx5tkctb1' sql_id, 'Contacts' sql_type from dual union
select '11st4yznxdj3r' sql_id, 'Contacts' sql_type from dual union
select '0qjwxgbsgg9d1' sql_id, 'Contacts' sql_type from dual union
select '9f7z8cc1cmaxx' sql_id, 'Contacts' sql_type from dual union
select '7fxn85xbb04u1' sql_id, 'Access Control' sql_type from dual union
select 'b899gb63y1kav' sql_id, 'CX6' sql_type from dual union
select '34ttdsp2rn9x0' sql_id, 'CX6' sql_type from dual union
select '3mp90hzdswcqb' sql_id, 'CX6' sql_type from dual union
select 'f9rkhg3pwsp50' sql_id, 'Access Control' sql_type from dual union
select 'faft02rqhk2f0' sql_id, 'CX6' sql_type from dual union
select '00afbbc4bk0tc' sql_id, 'BB User' sql_type from dual union
select '3kzydt3r6q224' sql_id, 'CX6' sql_type from dual union
select 'gykmypgdujmam' sql_id, 'Arrangement' sql_type from dual union
select 'azcp0rpx81gf4' sql_id, 'CX6' sql_type from dual union
select '2ur6uh0f11ard' sql_id, 'CX6' sql_type from dual union
select 'ayt5z7acz1001' sql_id, 'CX6' sql_type from dual union
select 'ct45cc74j14un' sql_id, 'CX6' sql_type from dual union
select 'cnfy6j57fyxy5' sql_id, 'Arrangement' sql_type from dual union
select 'gjmr4dnw3yk82' sql_id, 'Access Control' sql_type from dual union
select '56pfkggymym2p' sql_id, 'CX6' sql_type from dual union
select '5txdc2rqwymck' sql_id, 'CX6' sql_type from dual union
select '5va2qknrnqmfc' sql_id, 'CX6' sql_type from dual union
select '5v69hhf3wvtv5' sql_id, 'CX6' sql_type from dual union
select 'cv3453453rydr' sql_id, 'Arrangement' sql_type from dual union
select 'fv2hjgzsbzv9q' sql_id, 'CX6' sql_type from dual union
select 'b8u6d0awybfs8' sql_id, 'CX6' sql_type from dual union
select '3b177g5msmt5v' sql_id, 'CX6' sql_type from dual union
select '6fav4yc54mt6m' sql_id, 'CX6' sql_type from dual union
select '6drwfd9mybm7m' sql_id, 'Arrangement' sql_type from dual union
select '7gtvc55fsvtd3' sql_id, 'CX6' sql_type from dual union
select '1pza3j4133942' sql_id, 'CX6' sql_type from dual union
select '94dv5f3hg4r8u' sql_id, 'Transactions' sql_type from dual union
select '3wxtkjmb7x8yq' sql_id, 'Transactions' sql_type from dual union
select '8tv1uka27xn8m' sql_id, 'Transactions' sql_type from dual union
select '6mjw9haua9ngg' sql_id, 'Transactions' sql_type from dual union
select 'f42sm56xp5x66' sql_id, 'Transactions' sql_type from dual union
select 'bxkaqmz1yf01z' sql_id, 'Transactions' sql_type from dual union
select '92cqxt4cyab0h' sql_id, 'Transactions' sql_type from dual union
select '00yms5xqwycqv' sql_id, 'Transactions' sql_type from dual union
select '1yn5xsrs82g20' sql_id, 'Transactions' sql_type from dual union
select '53xc07dtu2wm2' sql_id, 'Transactions' sql_type from dual union
select 'cx84mma9prk5m' sql_id, 'Transactions' sql_type from dual union
select 'ggkarwqs78jn7' sql_id, 'Payment' sql_type from dual union
select '53wx4ak7x9ah9' sql_id, 'Payment' sql_type from dual union
select '778dr3qavbxfk' sql_id, 'Payment' sql_type from dual union
select '5gtpvwg82fy41' sql_id, 'Payment' sql_type from dual union
select '02aadxg67pksv' sql_id, 'Payment' sql_type from dual union
select '6svsd0xvj2u2v' sql_id, 'Payment' sql_type from dual union
select 'auuz1u18j9w5x' sql_id, 'Payment' sql_type from dual union
select '4pdp35mr2fb61' sql_id, 'Payment' sql_type from dual union
select '7u71x647vz56s' sql_id, 'Payment' sql_type from dual union
select '1cba2zkbtt6fu' sql_id, 'Payment' sql_type from dual union
select '8wgsw60wxf930' sql_id, 'Payment' sql_type from dual union
select 'bb7yjnp1hst56' sql_id, 'Payment' sql_type from dual union
select 'bb9m2g03azvga' sql_id, 'Payment' sql_type from dual union
select 'g1yq5vdhgk06z' sql_id, 'Payment' sql_type from dual union
select '9c9xt6vpg45vy' sql_id, 'Payment' sql_type from dual union
select '0r1tn59zuh68w' sql_id, 'Payment' sql_type from dual union
select '1dmtfuc74441q' sql_id, 'Payment' sql_type from dual union
select 'byaqpnh2gyqpy' sql_id, 'Payment' sql_type from dual union
select '4shxww12dmat5' sql_id, 'Payment' sql_type from dual union
select '3wbmvtaqf8g6h' sql_id, 'Payment' sql_type from dual union
select 'dqtk7ftf90mwu' sql_id, 'Payment' sql_type from dual union
select 'fc71r4rh4p949' sql_id, 'Payment' sql_type from dual union
select 'bgzhgynxp2pm7' sql_id, 'Payment' sql_type from dual union
select '4suxbg3vjhd9u' sql_id, 'Payment' sql_type from dual union
select 'gy309816j1kbx' sql_id, 'Payment' sql_type from dual union
select '66198wmmyrmqr' sql_id, 'Payment' sql_type from dual union
select 'ggkarwqs78jn7' sql_id, 'Payment' sql_type from dual union
select 'fkyc9wy38vwf' sql_id, 'Access Control (APR)' sql_type from dual union
select 'dpgwfw8fvzxfk' sql_id, 'Approvals' sql_type from dual union
select '5q8zu8x491f0t' sql_id, 'Access Control (APR)' sql_type from dual union
select '1t79hxzxm9sjv' sql_id, 'Approvals' sql_type from dual union
select 'f1u78k5tq0xq7' sql_id, 'Access Control (APR)' sql_type from dual union
select 'f0cjmxm6azh5t' sql_id, 'Approvals' sql_type from dual union
select '83a8a9ka93195' sql_id, 'Access Control (APR)' sql_type from dual union
select '09g380c5b1qj9' sql_id, 'Access Control (APR)' sql_type from dual union
select '89vpbbhqxm2ax' sql_id, 'Approvals' sql_type from dual union
select '5xbqwzs9xcbb1' sql_id, 'Access Control (APR)' sql_type from dual union
select 'f46npwj4x4ytr' sql_id, 'Access Control (APR)' sql_type from dual union
select '4zbm5v7yk1878' sql_id, 'Access Control (APR)' sql_type from dual union
select '8tnv5mds95tzz' sql_id, 'Access Control (APR)' sql_type from dual union
select 'fvqmd33zx5p04' sql_id, 'Access Control (APR)' sql_type from dual union
select '0h4z2wy0vyqrt' sql_id, 'Approvals' sql_type from dual union
select '53wzjtnjxqsyj' sql_id, 'Access Control (APR)' sql_type from dual union
select 'a1t7q7nncvwdf' sql_id, 'Access Control (APR)' sql_type from dual union
select 'c1rj3byg33twq' sql_id, 'Approvals' sql_type from dual union
select 'gx1yas2tkt2yr' sql_id, 'Approvals' sql_type from dual union
select '4pg4b91b5r61b' sql_id, 'Approvals' sql_type from dual union
select 'f2215uv1c6kt9' sql_id, 'Approvals' sql_type from dual union
select 'fuq5jcn7z9m7p' sql_id, 'Arrangement (APR)' sql_type from dual union
select '5gfvdpc83n286' sql_id, 'Payments (APR)' sql_type from dual union
select 'az8ucsb10tg5x' sql_id, 'Payments (APR)' sql_type from dual union
select '7bn0wjjww5yzk' sql_id, 'Payments (APR)' sql_type from dual union
select '0pmj8h3gq2bfb' sql_id, 'Payments (APR)' sql_type from dual union
select '5y20xcatfh7sh' sql_id, 'Approvals' sql_type from dual union
select '4rrm51bug5cuc' sql_id, 'Approvals' sql_type from dual union
select '367bj7upgacfw' sql_id, 'Approvals' sql_type from dual union
select '46zhgrcsfg9f8' sql_id, 'Approvals' sql_type from dual union
select '3j24bjsypjxah' sql_id, 'Approvals' sql_type from dual union
select '8dkfwqtkrjzr4' sql_id, 'Approvals' sql_type from dual union
select '5uzft0uq2wpkz' sql_id, 'Approvals' sql_type from dual union
select 'bm1fvy9t4xuvd' sql_id, 'Approvals' sql_type from dual union
select '7whr9khcc88h4' sql_id, 'Approvals' sql_type from dual union
select '3cu2p8q1kcfys' sql_id, 'Approvals' sql_type from dual union
select '7dtmzstfug6m8' sql_id, 'Approvals' sql_type from dual union
select 'avv5zrjvhd3xj' sql_id, 'Approvals' sql_type from dual union
select '5a0uz59p6u5v9' sql_id, 'Approvals' sql_type from dual union
select '39kpwxnravmh2' sql_id, 'Approvals' sql_type from dual union
select '4f3hzj35ytskm' sql_id, 'Approvals' sql_type from dual union
select 'cd9hwu9pcrh5z' sql_id, 'Approvals' sql_type from dual union
select 'csuj198tns39c' sql_id, 'Approvals' sql_type from dual union
select 'cs5gahs0j7ghw' sql_id, 'Approvals' sql_type from dual union
select '71484v5m1t013' sql_id, 'Approvals' sql_type from dual union
select '72utgkwstrxwx' sql_id, 'Approvals' sql_type from dual union
select 'ffkyc9wy38vwf' sql_id, 'Access Control (APR)' sql_type from dual union
select 'bpjhfj17bng4u' sql_id, 'Arrangement' sql_type from dual union
select 'an3wz0xm0rfk1' sql_id, 'Transactions' sql_type from dual union
select 'bvbv768a84myc' sql_id, 'Audit' sql_type from dual union
select '683bt8z9j8sru' sql_id, 'Audit' sql_type from dual union
select '1pga15vgv0kgt' sql_id, 'CX6' sql_type from dual union
select '4pjpcqmtbhhsu' sql_id, 'CX6' sql_type from dual union
select '5hqps6h0h4wcd' sql_id, 'Transactions' sql_type from dual union
select '5npzvxnd9m0nd' sql_id, 'Transactions' sql_type from dual union
select 'b8g6j3q0tnm9y' sql_id, 'CX6' sql_type from dual union
select 'bn81tpsm5ssu0' sql_id, 'CX6' sql_type from dual union
select 'fuhf1vtfzraf3' sql_id, 'Transactions' sql_type from dual union
select '84z7f9dfytvpc' sql_id, 'Transactions' sql_type from dual union
select '6t2wbzjps5b0v' sql_id, 'Transactions' sql_type from dual union
select '8f5zf904md4kk' sql_id, 'Arrangement' sql_type from dual union
select '711q0yw1cfz1m' sql_id, 'Arrangement' sql_type from dual union
select 'f775m0fn4hxgn' sql_id, 'BB User' sql_type from dual union
select '2nmgnxcbnup2x' sql_id, 'Arrangement' sql_type from dual union
select '0u8yjjuwbx2x0' sql_id, 'Access Control' sql_type from dual union
select '05s98hk89sg18' sql_id, 'Access Control' sql_type from dual union
select '4g2qwacu3ynj6' sql_id, 'Arrangement' sql_type from dual union
select '5v3mah5g1pr9h' sql_id, 'Arrangement' sql_type from dual union
select '9nbwu4r9k129x' sql_id, 'Access Control' sql_type from dual union
select 'a64ku5gv1phy5' sql_id, 'Access Control' sql_type from dual union
select '4wz2ukp0dd360' sql_id, 'Arrangement' sql_type from dual union
select 'fdjhhwksyuka9' sql_id, 'Arrangement' sql_type from dual union
select 'ghh8hxkkdj3h0' sql_id, 'Arrangement' sql_type from dual union
select 'f4mq3mngkppxu' sql_id, 'Access Control' sql_type from dual union
select 'am0h1xmwzq1h1' sql_id, 'Limits' sql_type from dual union
select '09p6jj81vv4q1' sql_id, 'Arrangement' sql_type from dual union
select '87y5ptm5my924' sql_id, 'Payment' sql_type from dual union
select '2j4j1mstp70b5' sql_id, 'Payment' sql_type from dual union
select 'fdw5qg82c2atp' sql_id, 'Access Control' sql_type from dual union
select '058kt9szy52y0' sql_id, 'Limits' sql_type from dual union
select '3bg74kbda1f2y' sql_id, 'Payment' sql_type from dual union
select 'fdu6hwm81gj3b' sql_id, 'Limits' sql_type from dual union
select 'bjnx2s7tmzryd' sql_id, 'Payment' sql_type from dual union
select '9mvaxd1pyddjv' sql_id, 'Payment' sql_type from dual)
, x as (SELECT case when s.sql_id is not null then s.sql_type
       else 'Unclassified' end sql_type
, tr.sql_id_t, t.sql_fulltext
FROM tr
LEFT JOIN s  ON tr.sql_id_t=s.sql_id
INNER JOIN XDBSNAPSHOT.TBL_SQL_TEXT t ON tr.sql_id_t=t.sql_id )
SELECT '+ "'||sql_id_t||'!@#!'||sql_type||'!@#!'||REPLACE(REPLACE(REPLACE(TO_CHAR(substr(sql_fulltext,1,2000)),chr(10),' '),chr(13),' '),'"','')||'\n"' from x ;
prompt ;;
prompt  var csvSysStat = "STATISTIC#!@#!NAME!@#!CLASS!@#!UNIT!@#!SYSSTAT_BL!@#!SYSSTAT_TR\n"
WITH stat_type as (SELECT 'OS CPU Qt wait time' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'CPU used when call started' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'CPU used by this session' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'DB time' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'cluster wait time' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'concurrency wait time' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'application wait time' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'user I/O wait time' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'scheduler wait time' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'non-idle wait time' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'in call idle wait time' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'session connect time' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'process last non-idle time' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'global enqueue get time' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'physical read total bytes optimized' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'physical read total bytes' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'physical write total bytes optimized' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'physical write total bytes' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'cell physical IO interconnect bytes' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'physical read snap bytes base' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'physical read snap bytes copy' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'global enqueue CPU used by this session' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'max cf enq hold time' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'total cf enq hold time' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'logical read bytes from cache' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'physical read bytes' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'physical write bytes' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'change write time' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'recovery array read time' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'redo k-bytes read for recovery' stat_name, 'k-bytes' stat_unit FROM DUAL UNION
SELECT 'redo k-bytes read for terminal recovery' stat_name, 'k-bytes' stat_unit FROM DUAL UNION
SELECT 'redo write time' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'redo write time (usec)' stat_name, 'time (usec)' stat_unit FROM DUAL UNION
SELECT 'redo write worker delay (usec)' stat_name, 'time (usec)' stat_unit FROM DUAL UNION
SELECT 'redo log space wait time' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'redo write broadcast ack time' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'redo synch time' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'redo synch time (usec)' stat_name, 'time (usec)' stat_unit FROM DUAL UNION
SELECT 'redo synch time overhead (usec)' stat_name, 'time (usec)' stat_unit FROM DUAL UNION
SELECT 'redo write gather time' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'redo write schedule time' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'redo write issue time' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'redo write finish time' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'redo write total time' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'file io service time' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'file io wait time' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'gc cr block flush time' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'gc read time waited' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'gc current block pin time' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'gc current block flush time' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'gc cr block receive time' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'gc current block receive time' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'gc ka grant receive time' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'gc cluster flash cache received read time' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'gc flash cache served read time' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'gc kbytes sent' stat_name, 'k-bytes' stat_unit FROM DUAL UNION
SELECT 'gc kbytes saved' stat_name, 'k-bytes' stat_unit FROM DUAL UNION
SELECT 'gc CPU used by this session' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'gc cr block build time' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'gc cr block send time' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'gc current block send time' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'Effective IO time' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'BA file bytes allocated' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'BA au bytes allocated' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'BA file bytes deleted' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'BA non-flash bytes requested' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'BA flash bytes requested' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'BA bytes for file maps' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'BA bytes read from flash' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'BA bytes read from disk' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'flashback log write bytes' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'cell physical IO bytes saved during optimized file creation' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'cell physical IO bytes saved during optimized RMAN file restore' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'cell physical IO bytes eligible for predicate offload' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'cell physical IO bytes saved by storage index' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'cell physical IO bytes sent directly to DB node to balance CPU' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'cell physical IO interconnect bytes returned by smart scan' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'cell num bytes in passthru during predicate offload' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'cell num bytes in block IO during predicate offload' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'cell num bytes of IO reissued due to relocation' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'cell physical IO bytes saved by columnar cache' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'cell physical write bytes saved by smart file initialization' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'cell XT granule bytes requested for predicate offload' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'cell interconnect bytes returned by XT smart scan' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'temp space allocated (bytes)' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'transaction lock foreground wait time' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'transaction lock background get time' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'CLI bytes fls to table' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'CLI bytes fls to ext' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'TBS Extension: bytes extended' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'KTFB alloc time (ms)' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'KTFB free time (ms)' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'KTFB apply time (ms)' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'KTFB commit time (ms)' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'segment prealloc bytes' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'segment prealloc time (ms)' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'segment prealloc ufs2cfs bytes' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'IM space CU bytes allocated' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'IM space SMU bytes allocated' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'IM space private journal bytes allocated' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'IM space shared journal bytes allocated' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'IM space CU bytes freed' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'IM space SMU bytes freed' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'IM space private journal bytes freed' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'IM space shared journal bytes freed' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'cell simulated physical IO bytes eligible for predicate offload' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'cell simulated physical IO bytes returned by predicate offload' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'cell IO uncompressed bytes' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'securefile allocation bytes' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'securefile direct read bytes' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'securefile direct write bytes' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'securefile inode read time' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'securefile inode write time' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'securefile inode ioreap time' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'securefile bytes non-transformed' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'securefile bytes encrypted' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'securefile bytes cleartext' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'securefile compressed bytes' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'securefile uncompressed bytes' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'securefile bytes deduplicated' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'IM populate bytes from storage' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'IM prepopulate bytes from storage' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'IM repopulate bytes from storage' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'IM repopulate (trickle) bytes from storage' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'IM populate accumulated time (ms)' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'IM prepopulate accumulated time (ms)' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'IM repopulate accumulated time (ms)' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'IM repopulate (trickle) accumulated time (ms)' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'IM populate bytes in-memory data' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'IM prepopulate bytes in-memory data' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'IM repopulate bytes in-memory data' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'IM repopulate (trickle) bytes in-memory data' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'IM populate bytes uncompressed data' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'IM prepopulate bytes uncompressed data' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'IM repopulate bytes uncompressed data' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'IM repopulate (trickle) bytes uncompressed data' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'IM populate (faststart) CUs bytes read' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'IM populate (faststart) accumulated time (ms)' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'IM populate (faststart) CUs bytes written' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'IM populate (faststart) CUs accumulated write time (ms)' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'IM populate (faststart) CUs wall clock write time (ms)' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'IM scan bytes in-memory' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'IM scan bytes uncompressed' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'DX/BB enqueue lock foreground wait time' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'DX/BB enqueue lock background get time' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'java call heap collected bytes' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'java session heap collected bytes' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'parse time cpu' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'parse time elapsed' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'bytes sent via SQL*Net to client' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'bytes received via SQL*Net from client' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'bytes sent via SQL*Net to dblink' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'bytes received via SQL*Net from dblink' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'bytes via SQL*Net vector to client' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'bytes via SQL*Net vector from client' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'bytes via SQL*Net vector to dblink' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'bytes via SQL*Net vector from dblink' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'OLAP Limit Time' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'OLAP Row Load Time' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'Workload Capture: size (in bytes) of recording' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'cell physical write IO bytes eligible for offload' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'cell physical write IO host network bytes written during offloa' stat_name, 'bytes' stat_unit FROM DUAL UNION
SELECT 'backup piece local processing time' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'backup piece remote processing time' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'OS User time used' stat_name, 'time' stat_unit FROM DUAL UNION
SELECT 'OS System time used' stat_name, 'time' stat_unit FROM DUAL)
, stat_class as (SELECT 1 class_id, 'User' class_name FROM DUAL UNION
SELECT 2 class_id, 'Redo' class_name FROM DUAL UNION
SELECT 4 class_id, 'Enqueue' class_name FROM DUAL UNION
SELECT 8 class_id, 'Cache' class_name FROM DUAL UNION
SELECT 16 class_id, 'OS' class_name FROM DUAL UNION
SELECT 32 class_id, 'RAC' class_name FROM DUAL UNION
SELECT 62 class_id, 'SQL' class_name FROM DUAL UNION
SELECT 128 class_id, 'Debug' class_name FROM DUAL)
, bl as (select /*+ materialize */ name, max(value) - min(value) value from XDBSNAPSHOT.tbl_sysstat where sample_id between &start_sample_id_br and &finish_sample_id_br group by name)
, tr as (select /*+ materialize */ name, max(value) - min(value) value from XDBSNAPSHOT.tbl_sysstat where sample_id between &start_sample_id_tr and &finish_sample_id_tr group by name)
select '+ "'||ss.statistic#||'!@#!'||ss.name||'!@#!'|| NVL(sc.class_name,'Other')||'!@#!'||NVL(st.stat_unit,'event')||'!@#!'|| NVL(bl.value,0)||'!@#!'||NVL(tr.value,0)||'\n"'
from v$sysstat ss
left join stat_type st ON ss.name = st.stat_name
left join stat_class sc ON ss.class = sc.class_id
left join bl ON ss.name = bl.name
left join tr ON ss.name = tr.name
WHERE  NVL(bl.value,0) + NVL(tr.value,0) > 0 ORDER BY ss.statistic#;
prompt ;;
prompt  var timeFormatDMY = d3.timeParse("%d/%m/%Y");;
prompt  var timeFormatDMY_HM = d3.timeParse("%d/%m/%Y %H:%M");;
prompt  var timeFormatDMY_HMS = d3.timeParse("%d/%m/%Y %H:%M:%S");;
prompt  var tableDescriptionText = "B - baseline, T - test run, Δ - actual change, Δ% - percentage change, Time in Seconds";;
prompt
prompt  var date_output = {
prompt  weekday: 'long',
prompt  year: 'numeric',
prompt  month: 'long',
prompt  day: 'numeric'
prompt  };;
prompt
prompt  var dbTimeKeys = ["DB CPU","User I/O","Other"];;
prompt  var dbTimeColors = d3.scaleOrdinal().range(["#96dfce","#65a1ac","#F0C080"]);;
prompt
prompt  var dataDbTime = d3.csvParse(csvDbTime);;
prompt  dataDbTime.forEach(function(d) {
prompt  d.date = timeFormatDMY(d.date);;
prompt  d.value = +d.value;;
prompt  });;
prompt
prompt  //var dbTimeStart = timeFormatDMY("15/07/2019");;
prompt  //var dbTimeEnd = timeFormatDMY("25/08/2019");;
prompt
prompt  //var dbTimeArray = dbTimeParse(dbTimeStart, dbTimeEnd, dataDbTime);;
prompt  // svgStackedAreaDraw(800,450,dbTimeArray,"#chartMain",1,"DB Time: Last 6 weeks",dbTimeStart,dbTimeEnd,1.05*d3.max(dbTimeArray, function(d){return d.total;}));;
prompt
prompt  var dataDbTimeBr = d3.csvParse(csvDbTimeBr);;
prompt  dataDbTimeBr.forEach(function(d) {
prompt  d.date = timeFormatDMY_HM(d.date);;
prompt  d.value = +d.value;;
prompt  });;
prompt
prompt  var startTimeBr = timeFormatDMY_HM("&start_sample_time_br");;
prompt  var finishTimeBr = timeFormatDMY_HM("&finish_sample_time_br");;
prompt
prompt  var dataDbTimeTr = d3.csvParse(csvDbTimeTr);;
prompt  dataDbTimeTr.forEach(function(d) {
prompt  d.date = timeFormatDMY_HM(d.date);;
prompt  d.value = +d.value;;
prompt  });;
prompt
prompt  var startTimeTr = timeFormatDMY_HM("&start_sample_time_tr");;
prompt  var finishTimeTr = timeFormatDMY_HM("&finish_sample_time_tr");;
prompt
prompt  var dbTimeArrayTr = dbTimeParse(startTimeTr, finishTimeTr, dataDbTimeTr);;
prompt
prompt  var totalCpuTr = totalCpu;;
prompt  var totalUserIOTr = totalUserIO;;
prompt  var totalOtherTr = totalOther;;
prompt
prompt  var dbTimeArrayBr = dbTimeParse(startTimeBr, finishTimeBr, dataDbTimeBr);;
prompt
prompt  var totalCpuBr = totalCpu;;
prompt  var totalUserIOBr = totalUserIO;;
prompt  var totalOtherBr = totalOther;;
prompt
prompt	var maxDbTimeValue = d3.max([d3.max(dbTimeArrayBr, function(d){return d.total;}),d3.max(dbTimeArrayTr, function(d){return d.total;})]);;
prompt
prompt  var ashKeys = ["CPU","Scheduler","User I/O","System I/O","Concurrency","Application","Commit","Configuration","Administrative","Network","Queueing","Cluster","Other"];;
prompt  var ashColors = d3.scaleOrdinal().range(["#96dfce","#9DE0AD","#65a1ac","#5FB2D5","#C14755","#EE3E38","#F0C080","#FF9190","#96B6C5","#ADC4CE","#EEE0C9","#F1F0E8","#E4DECB"]);;
prompt
prompt  var waitClassColors = d3.scaleOrdinal().range(["#9DE0AD","#65a1ac","#5FB2D5","#C14755","#EE3E38","#F0C080","#FF9190","#96B6C5","#ADC4CE","#EEE0C9","#F1F0E8","#E4DECB"]);;
prompt
prompt
prompt  var cat20Colors = d3.scaleOrdinal(d3.schemeCategory20);;
prompt
prompt  var dataAshBr = d3.csvParse(csvAshBr);;
prompt  dataAshBr.forEach(function(d) {
prompt  d.date = timeFormatDMY_HMS(d.date);;
prompt  d.value = +d.value;;
prompt  });;
prompt
prompt
prompt
prompt  var ashStartTimeBr = timeFormatDMY_HM("&start_sample_time_br");;
prompt  var ashFinishTimeBr = timeFormatDMY_HM("&finish_sample_time_br");;
prompt
prompt  var dataAshTr = d3.csvParse(csvAshTr);;
prompt  dataAshTr.forEach(function(d) {
prompt  d.date = timeFormatDMY_HMS(d.date);;
prompt  d.value = +d.value;;
prompt  });;
prompt
prompt
prompt
prompt  var ashStartTimeTr = timeFormatDMY_HM("&start_sample_time_tr");;
prompt  var ashFinishTimeTr = timeFormatDMY_HM("&finish_sample_time_tr");;
prompt
prompt
prompt
prompt  var ashArrayBr = ashParse(ashStartTimeBr, ashFinishTimeBr, dataAshBr);;
prompt  var ashArrayTr = ashParse(ashStartTimeTr, ashFinishTimeTr, dataAshTr);;
prompt
prompt	var maxDbSessionCount = d3.max([d3.max(ashArrayBr, function(d){return d.total;}),d3.max(ashArrayTr, function(d){return d.total;})]);;
prompt
prompt  var waitEventsData = d3.csvParse(csvWaitEvents);;
prompt
prompt  var pointA = "Baseline";;
prompt  var pointB = "Test Run";;
prompt
prompt  var waitClassGroups = {
prompt  "Scheduler":[{series:pointA, total:0},{series:pointB, total:0}]
prompt  ,"User I/O":[{series:pointA, total:0},{series:pointB, total:0}]
prompt  ,"System I/O":[{series:pointA, total:0},{series:pointB, total:0}]
prompt  ,"Concurrency":[{series:pointA, total:0},{series:pointB, total:0}]
prompt  ,"Application":[{series:pointA, total:0},{series:pointB, total:0}]
prompt  ,"Commit":[{series:pointA, total:0},{series:pointB, total:0}]
prompt  ,"Configuration":[{series:pointA, total:0},{series:pointB, total:0}]
prompt  ,"Administrative":[{series:pointA, total:0},{series:pointB, total:0}]
prompt  ,"Network":[{series:pointA, total:0},{series:pointB, total:0}]
prompt  ,"Queueing":[{series:pointA, total:0},{series:pointB, total:0}]
prompt  ,"Cluster":[{series:pointA, total:0},{series:pointB, total:0}]
prompt  ,"Other":[{series:pointA, total:0},{series:pointB, total:0}]
prompt  ,"Idle":[{series:pointA, total:0},{series:pointB, total:0}]
prompt  ,"Wait Classes":[{series:pointA, total:0},{series:pointB, total:0}]
prompt  ,"DB Time":[{series:pointA, total:0},{series:pointB, total:0}]
prompt  };;
prompt
prompt  waitEventsData.forEach(function(d) {
prompt  d.tst_before = +d.tst_before;;
prompt  d.tst_after = +d.tst_after;;
prompt  });;
prompt
prompt  for (i = 0, t = 0; i < waitEventsData.length; ++i)
prompt  {
prompt  waitClassGroups[waitEventsData[i].wait_class][0][waitEventsData[i].wait_event] = waitEventsData[i].tst_before;;
prompt  waitClassGroups[waitEventsData[i].wait_class][0]["total"] += waitEventsData[i].tst_before;;
prompt  waitClassGroups[waitEventsData[i].wait_class][1][waitEventsData[i].wait_event] = waitEventsData[i].tst_after;;
prompt  waitClassGroups[waitEventsData[i].wait_class][1]["total"] += waitEventsData[i].tst_after;;
prompt
prompt  if (!waitClassGroups[waitEventsData[i].wait_class].columns) waitClassGroups[waitEventsData[i].wait_class].columns = [];;
prompt  waitClassGroups[waitEventsData[i].wait_class].columns.push(waitEventsData[i].wait_event);;
prompt  }
prompt
prompt
prompt  waitClassGroups["Wait Classes"].columns = [];;
prompt
prompt  ["Scheduler","User I/O","System I/O","Concurrency","Application","Commit","Configuration","Administrative","Network","Queueing","Cluster","Other"].forEach(function(d) {
prompt
prompt  waitClassGroups["Wait Classes"][0][d] = waitClassGroups[d][0]["total"];;
prompt  waitClassGroups["Wait Classes"][0]["total"] += waitClassGroups[d][0]["total"];;
prompt  waitClassGroups["Wait Classes"][1][d] = waitClassGroups[d][1]["total"];;
prompt  waitClassGroups["Wait Classes"][1]["total"] += waitClassGroups[d][1]["total"];;
prompt  waitClassGroups["Wait Classes"].columns.push(d);;
prompt
prompt  });;
prompt
prompt  waitClassGroups["DB Time"].columns = [];;
prompt  waitClassGroups["DB Time"][0]["DB CPU"] = totalCpuBr;;
prompt  waitClassGroups["DB Time"][1]["DB CPU"] = totalCpuTr;;
prompt  waitClassGroups["DB Time"].columns.push("DB CPU");;
prompt
prompt  waitClassGroups["DB Time"][0]["User I/O"] = totalUserIOBr;;
prompt  waitClassGroups["DB Time"][1]["User I/O"] = totalUserIOTr;;
prompt  waitClassGroups["DB Time"].columns.push("User I/O");;
prompt
prompt  waitClassGroups["DB Time"][0]["Other"] = totalOtherBr;;
prompt  waitClassGroups["DB Time"][1]["Other"] = totalOtherTr;;
prompt  waitClassGroups["DB Time"].columns.push("Other");;
prompt
prompt  waitClassGroups["DB Time"][0]["total"] = totalCpuBr + totalUserIOBr + totalOtherBr;;
prompt  waitClassGroups["DB Time"][1]["total"] = totalCpuTr + totalUserIOTr + totalOtherTr;;
prompt
prompt  // SQL Stats tables
prompt
prompt  var execFormat = d3.format(".2s");;
prompt  var timeFormat = d3.format(".3");;
prompt  var percentFormat = d3.format(".0%");;
prompt
prompt  var timeFormatArray= ["CPU_TIME_T","ELAPSED_TIME_T","APPLICATION_WAIT_TIME_T","CONCURRENCY_WAIT_TIME_T","CLUSTER_WAIT_TIME_T","USER_IO_WAIT_TIME_T","PLSQL_EXEC_TIME_T","JAVA_EXEC_TIME_T","CPU_TIME_B","ELAPSED_TIME_B","APPLICATION_WAIT_TIME_B","CONCURRENCY_WAIT_TIME_B","CLUSTER_WAIT_TIME_B","USER_IO_WAIT_TIME_B","PLSQL_EXEC_TIME_B","JAVA_EXEC_TIME_B","SYS_TIME_MODEL_BR","SYS_TIME_MODEL_TR","SYS_TIME_MODEL_D","CPU_TIME_D","ELAPSED_TIME_D","APPLICATION_WAIT_TIME_D"
prompt  ,"CONCURRENCY_WAIT_TIME_D","CLUSTER_WAIT_TIME_D","USER_IO_WAIT_TIME_D","PLSQL_EXEC_TIME_D","JAVA_EXEC_TIME_D","ELAPSED_TIME_BA","ELAPSED_TIME_TA","CPU_TIME_BA","CPU_TIME_TA"];;
prompt  var execFormatArray = ["PARSE_CALLS_T","DISK_READS_T","DIRECT_WRITES_T","BUFFER_GETS_T","ROWS_PROCESSED_T","FETCHES_T","EXECUTIONS_T","PX_SERVERS_EXECUTIONS_T","END_OF_FETCH_COUNT_T","SORTS_T","LOADS_T","INVALIDATIONS_T","PHYSICAL_READ_REQUESTS_T","PHYSICAL_READ_BYTES_T","PHYSICAL_WRITE_REQUESTS_T","PHYSICAL_WRITE_BYTES_T","IO_INTERCONNECT_BYTES_T","PARSE_CALLS_B","DISK_READS_B","DIRECT_WRITES_B","BUFFER_GETS_B","ROWS_PROCESSED_B","FETCHES_B","EXECUTIONS_B","PX_SERVERS_EXECUTIONS_B","END_OF_FETCH_COUNT_B","SORTS_B","LOADS_B","INVALIDATIONS_B","PHYSICAL_READ_REQUESTS_B","PHYSICAL_READ_BYTES_B","PHYSICAL_WRITE_REQUESTS_B","PHYSICAL_WRITE_BYTES_B","IO_INTERCONNECT_BYTES_B","SYSSTAT_BL","SYSSTAT_TR","SYSSTAT_DIFF","PARSE_CALLS_D","DISK_READS_D","DIRECT_WRITES_D","BUFFER_GETS_D","ROWS_PROCESSED_D","FETCHES_D","EXECUTIONS_D","PX_SERVERS_EXECUTIONS_D","END_OF_FETCH_COUNT_D","SORTS_D","LOADS_D","INVALIDATIONS_D","PHYSICAL_READ_REQUESTS_D","PHYSICAL_READ_BYTES_D","PHYSICAL_WRITE_REQUESTS_D","PHYSICAL_WRITE_BYTES_D","IO_INTERCONNECT_BYTES_D","BUFFER_GETS_BA","BUFFER_GETS_TA","ROWS_PROCESSED_BA","ROWS_PROCESSED_TA"];;
prompt  var percentFormatArray = ["PARSE_CALLS_S","DISK_READS_S","DIRECT_WRITES_S","BUFFER_GETS_S","ROWS_PROCESSED_S","FETCHES_S","EXECUTIONS_S","PX_SERVERS_EXECUTIONS_S","END_OF_FETCH_COUNT_S","CPU_TIME_S","ELAPSED_TIME_S","APPLICATION_WAIT_TIME_S","CONCURRENCY_WAIT_TIME_S","CLUSTER_WAIT_TIME_S","USER_IO_WAIT_TIME_S","PLSQL_EXEC_TIME_S","JAVA_EXEC_TIME_S","OTHER_WAIT_TIME_S","SORTS_S","LOADS_S","INVALIDATIONS_S","PHYSICAL_READ_REQUESTS_S","PHYSICAL_READ_BYTES_S","PHYSICAL_WRITE_REQUESTS_S","PHYSICAL_WRITE_BYTES_S","IO_INTERCONprompt  ECT_BYTES_S","EXECUTIONS_PC","SYSSTAT_PC","SYS_TIME_MODEL_PC"];;
prompt
prompt  var dataSqlStatsTable = d3.csvParse(csvSqlStatsTable);;
prompt  dataSqlStatsTable.forEach(function(d) {d.RANK = +d.RANK});;
prompt
prompt  var sqlStats = {"PARSE_CALLS":[],"DISK_READS":[],"DIRECT_WRITES":[],"BUFFER_GETS":[],"ROWS_PROCESSED":[],"FETCHES":[],"EXECUTIONS":[],"PX_SERVERS_EXECUTIONS":[],"END_OF_FETCH_COUNT":[],"CPU_TIME":[],"ELAPSED_TIME":[]
prompt  ,"APPLICATION_WAIT_TIME":[],"CONCURRENCY_WAIT_TIME":[],"CLUSTER_WAIT_TIME":[],"USER_IO_WAIT_TIME":[],"PLSQL_EXEC_TIME":[],"JAVA_EXEC_TIME":[],"SORTS":[],"LOADS":[],"INVALIDATIONS":[],"PHYSICAL_READ_REQUESTS":[]
prompt  ,"PHYSICAL_READ_BYTES":[],"PHYSICAL_WRITE_REQUESTS":[],"PHYSICAL_WRITE_BYTES":[],"IO_INTERCONNECT_BYTES":[],"OTHER_WAIT_TIME":[],"SYS_TIME_MODEL":[],"DB_SUMMARY":[],"SQL_TEXT":[],"SYS_STAT":[]};;
prompt
prompt  var sqlStatsCols = {"PARSE_CALLS":["RANK","SQL_ID","SQL_TYPE","PARSE_CALLS_S","PLAN_HASH_VALUE","PARSE_CALLS_B","PARSE_CALLS_T","PARSE_CALLS_D","EXECUTIONS_B","EXECUTIONS_T","EXECUTIONS_D","EXECUTIONS_PC","ELAPSED_TIME_T","CPU_TIME_T","USER_IO_WAIT_TIME_T","CONCURRENCY_WAIT_TIME_T","APPLICATION_WAIT_TIME_T","CLUSTER_WAIT_TIME_T","OTHER_WAIT_TIME_T","BUFFER_GETS_T","ROWS_PROCESSED_T","DISK_READS_T","IO_INTERCONNECT_BYTES_T"]
prompt  , "DISK_READS":["RANK","SQL_ID","SQL_TYPE","DISK_READS_S","PLAN_HASH_VALUE","DISK_READS_B","DISK_READS_T","DISK_READS_D","EXECUTIONS_B","EXECUTIONS_T","EXECUTIONS_D","EXECUTIONS_PC","ELAPSED_TIME_T","CPU_TIME_T","USER_IO_WAIT_TIME_T","CONCURRENCY_WAIT_TIME_T","APPLICATION_WAIT_TIME_T","CLUSTER_WAIT_TIME_T","OTHER_WAIT_TIME_T","BUFFER_GETS_T","ROWS_PROCESSED_T","DISK_READS_T","IO_INTERCONNECT_BYTES_T"]
prompt  , "DIRECT_WRITES":["RANK","SQL_ID","SQL_TYPE","DIRECT_WRITES_S","PLAN_HASH_VALUE","DIRECT_WRITES_B","DIRECT_WRITES_T","DIRECT_WRITES_D","EXECUTIONS_B","EXECUTIONS_T","EXECUTIONS_D","EXECUTIONS_PC","ELAPSED_TIME_T","CPU_TIME_T","USER_IO_WAIT_TIME_T","CONCURRENCY_WAIT_TIME_T","APPLICATION_WAIT_TIME_T","CLUSTER_WAIT_TIME_T","OTHER_WAIT_TIME_T","BUFFER_GETS_T","ROWS_PROCESSED_T","DISK_READS_T","IO_INTERCONNECT_BYTES_T"]
prompt  , "BUFFER_GETS":["RANK","SQL_ID","SQL_TYPE","BUFFER_GETS_S","PLAN_HASH_VALUE","BUFFER_GETS_B","BUFFER_GETS_T","BUFFER_GETS_D","EXECUTIONS_B","EXECUTIONS_T","EXECUTIONS_D","EXECUTIONS_PC","ELAPSED_TIME_T","CPU_TIME_T","USER_IO_WAIT_TIME_T","CONCURRENCY_WAIT_TIME_T","APPLICATION_WAIT_TIME_T","CLUSTER_WAIT_TIME_T","OTHER_WAIT_TIME_T","BUFFER_GETS_T","ROWS_PROCESSED_T","DISK_READS_T","IO_INTERCONNECT_BYTES_T","BUFFER_GETS_BA","BUFFER_GETS_TA"]
prompt  , "ROWS_PROCESSED":["RANK","SQL_ID","SQL_TYPE","ROWS_PROCESSED_S","PLAN_HASH_VALUE","ROWS_PROCESSED_B","ROWS_PROCESSED_T","ROWS_PROCESSED_D","EXECUTIONS_B","EXECUTIONS_T","EXECUTIONS_D","EXECUTIONS_PC","ELAPSED_TIME_T","CPU_TIME_T","USER_IO_WAIT_TIME_T","CONCURRENCY_WAIT_TIME_T","APPLICATION_WAIT_TIME_T","CLUSTER_WAIT_TIME_T","OTHER_WAIT_TIME_T","BUFFER_GETS_T","ROWS_PROCESSED_T","DISK_READS_T","IO_INTERCONNECT_BYTES_T","ROWS_PROCESSED_BA","ROWS_PROCESSED_TA"]
prompt  , "FETCHES":["RANK","SQL_ID","SQL_TYPE","FETCHES_S","PLAN_HASH_VALUE","FETCHES_B","FETCHES_T","FETCHES_D","EXECUTIONS_B","EXECUTIONS_T","EXECUTIONS_D","EXECUTIONS_PC","ELAPSED_TIME_T","CPU_TIME_T","USER_IO_WAIT_TIME_T","CONCURRENCY_WAIT_TIME_T","APPLICATION_WAIT_TIME_T","CLUSTER_WAIT_TIME_T","OTHER_WAIT_TIME_T","BUFFER_GETS_T","ROWS_PROCESSED_T","DISK_READS_T","IO_INTERCONNECT_BYTES_T"]
prompt  , "EXECUTIONS":["RANK","SQL_ID","SQL_TYPE","EXECUTIONS_S","PLAN_HASH_VALUE","EXECUTIONS_B","EXECUTIONS_T","EXECUTIONS_D","EXECUTIONS_PC","ELAPSED_TIME_T","CPU_TIME_T","USER_IO_WAIT_TIME_T","CONCURRENCY_WAIT_TIME_T","APPLICATION_WAIT_TIME_T","CLUSTER_WAIT_TIME_T","OTHER_WAIT_TIME_T","BUFFER_GETS_T","ROWS_PROCESSED_T","DISK_READS_T","IO_INTERCONNECT_BYTES_T"]
prompt  , "PX_SERVERS_EXECUTIONS":["RANK","SQL_ID","SQL_TYPE","PX_SERVERS_EXECUTIONS_S","PLAN_HASH_VALUE","PX_SERVERS_EXECUTIONS_B","PX_SERVERS_EXECUTIONS_T","PX_SERVERS_EXECUTIONS_D","EXECUTIONS_B","EXECUTIONS_T","EXECUTIONS_D","EXECUTIONS_PC","ELAPSED_TIME_T","CPU_TIME_T","USER_IO_WAIT_TIME_T","CONCURRENCY_WAIT_TIME_T","APPLICATION_WAIT_TIME_T","CLUSTER_WAIT_TIME_T","OTHER_WAIT_TIME_T","BUFFER_GETS_T","ROWS_PROCESSED_T","DISK_READS_T","IO_INTERCONNECT_BYTES_T"]
prompt  , "END_OF_FETCH_COUNT":["RANK","SQL_ID","SQL_TYPE","END_OF_FETCH_COUNT_S","PLAN_HASH_VALUE","END_OF_FETCH_COUNT_B","END_OF_FETCH_COUNT_T","END_OF_FETCH_COUNT_D","EXECUTIONS_B","EXECUTIONS_T","EXECUTIONS_D","EXECUTIONS_PC","ELAPSED_TIME_T","CPU_TIME_T","USER_IO_WAIT_TIME_T","CONCURRENCY_WAIT_TIME_T","APPLICATION_WAIT_TIME_T","CLUSTER_WAIT_TIME_T","OTHER_WAIT_TIME_T","BUFFER_GETS_T","ROWS_PROCESSED_T","DISK_READS_T","IO_INTERCONNECT_BYTES_T"]
prompt  , "CPU_TIME":["RANK","SQL_ID","SQL_TYPE","CPU_TIME_S","PLAN_HASH_VALUE","CPU_TIME_B","CPU_TIME_T","CPU_TIME_D","EXECUTIONS_B","EXECUTIONS_T","EXECUTIONS_D","EXECUTIONS_PC","ELAPSED_TIME_T","CPU_TIME_T","USER_IO_WAIT_TIME_T","CONCURRENCY_WAIT_TIME_T","APPLICATION_WAIT_TIME_T","CLUSTER_WAIT_TIME_T","OTHER_WAIT_TIME_T","BUFFER_GETS_T","ROWS_PROCESSED_T","DISK_READS_T","IO_INTERCONNECT_BYTES_T","CPU_TIME_BA","CPU_TIME_TA"]
prompt  , "ELAPSED_TIME":["RANK","SQL_ID","SQL_TYPE","ELAPSED_TIME_S","PLAN_HASH_VALUE","ELAPSED_TIME_B","ELAPSED_TIME_T","ELAPSED_TIME_D","EXECUTIONS_B","EXECUTIONS_T","EXECUTIONS_D","EXECUTIONS_PC","ELAPSED_TIME_T","CPU_TIME_T","USER_IO_WAIT_TIME_T","CONCURRENCY_WAIT_TIME_T","APPLICATION_WAIT_TIME_T","CLUSTER_WAIT_TIME_T","OTHER_WAIT_TIME_T","BUFFER_GETS_T","ROWS_PROCESSED_T","DISK_READS_T","IO_INTERCONNECT_BYTES_T","ELAPSED_TIME_BA","ELAPSED_TIME_TA"]
prompt  , "APPLICATION_WAIT_TIME":["RANK","SQL_ID","SQL_TYPE","APPLICATION_WAIT_TIME_S","PLAN_HASH_VALUE","APPLICATION_WAIT_TIME_B","APPLICATION_WAIT_TIME_T","APPLICATION_WAIT_TIME_D","EXECUTIONS_B","EXECUTIONS_T","EXECUTIONS_D","EXECUTIONS_PC","ELAPSED_TIME_T","CPU_TIME_T","USER_IO_WAIT_TIME_T","CONCURRENCY_WAIT_TIME_T","APPLICATION_WAIT_TIME_T","CLUSTER_WAIT_TIME_T","OTHER_WAIT_TIME_T","BUFFER_GETS_T","ROWS_PROCESSED_T","DISK_READS_T","IO_INTERCONNECT_BYTES_T"]
prompt  , "CONCURRENCY_WAIT_TIME":["RANK","SQL_ID","SQL_TYPE","CONCURRENCY_WAIT_TIME_S","PLAN_HASH_VALUE","CONCURRENCY_WAIT_TIME_B","CONCURRENCY_WAIT_TIME_T","CONCURRENCY_WAIT_TIME_D","EXECUTIONS_B","EXECUTIONS_T","EXECUTIONS_D","EXECUTIONS_PC","ELAPSED_TIME_T","CPU_TIME_T","USER_IO_WAIT_TIME_T","CONCURRENCY_WAIT_TIME_T","APPLICATION_WAIT_TIME_T","CLUSTER_WAIT_TIME_T","OTHER_WAIT_TIME_T","BUFFER_GETS_T","ROWS_PROCESSED_T","DISK_READS_T","IO_INTERCONNECT_BYTES_T"]
prompt  , "CLUSTER_WAIT_TIME":["RANK","SQL_ID","SQL_TYPE","CLUSTER_WAIT_TIME_S","PLAN_HASH_VALUE","CLUSTER_WAIT_TIME_B","CLUSTER_WAIT_TIME_T","CLUSTER_WAIT_TIME_D","EXECUTIONS_B","EXECUTIONS_T","EXECUTIONS_D","EXECUTIONS_PC","ELAPSED_TIME_T","CPU_TIME_T","USER_IO_WAIT_TIME_T","CONCURRENCY_WAIT_TIME_T","APPLICATION_WAIT_TIME_T","CLUSTER_WAIT_TIME_T","OTHER_WAIT_TIME_T","BUFFER_GETS_T","ROWS_PROCESSED_T","DISK_READS_T","IO_INTERCONNECT_BYTES_T"]
prompt  , "USER_IO_WAIT_TIME":["RANK","SQL_ID","SQL_TYPE","USER_IO_WAIT_TIME_S","PLAN_HASH_VALUE","USER_IO_WAIT_TIME_B","USER_IO_WAIT_TIME_T","USER_IO_WAIT_TIME_D","EXECUTIONS_B","EXECUTIONS_T","EXECUTIONS_D","EXECUTIONS_PC","ELAPSED_TIME_T","CPU_TIME_T","USER_IO_WAIT_TIME_T","CONCURRENCY_WAIT_TIME_T","APPLICATION_WAIT_TIME_T","CLUSTER_WAIT_TIME_T","OTHER_WAIT_TIME_T","BUFFER_GETS_T","ROWS_PROCESSED_T","DISK_READS_T","IO_INTERCONNECT_BYTES_T"]
prompt  , "PLSQL_EXEC_TIME":["RANK","SQL_ID","SQL_TYPE","PLSQL_EXEC_TIME_S","PLAN_HASH_VALUE","PLSQL_EXEC_TIME_B","PLSQL_EXEC_TIME_T","PLSQL_EXEC_TIME_D","EXECUTIONS_B","EXECUTIONS_T","EXECUTIONS_D","EXECUTIONS_PC","ELAPSED_TIME_T","CPU_TIME_T","USER_IO_WAIT_TIME_T","CONCURRENCY_WAIT_TIME_T","APPLICATION_WAIT_TIME_T","CLUSTER_WAIT_TIME_T","OTHER_WAIT_TIME_T","BUFFER_GETS_T","ROWS_PROCESSED_T","DISK_READS_T","IO_INTERCONNECT_BYTES_T"]
prompt  , "JAVA_EXEC_TIME":["RANK","SQL_ID","SQL_TYPE","JAVA_EXEC_TIME_S","PLAN_HASH_VALUE","JAVA_EXEC_TIME_B","JAVA_EXEC_TIME_T","JAVA_EXEC_TIME_D","EXECUTIONS_B","EXECUTIONS_T","EXECUTIONS_D","EXECUTIONS_PC","ELAPSED_TIME_T","CPU_TIME_T","USER_IO_WAIT_TIME_T","CONCURRENCY_WAIT_TIME_T","APPLICATION_WAIT_TIME_T","CLUSTER_WAIT_TIME_T","OTHER_WAIT_TIME_T","BUFFER_GETS_T","ROWS_PROCESSED_T","DISK_READS_T","IO_INTERCONNECT_BYTES_T"]
prompt  , "SORTS":["RANK","SQL_ID","SQL_TYPE","SORTS_S","PLAN_HASH_VALUE","SORTS_B","SORTS_T","SORTS_D","EXECUTIONS_B","EXECUTIONS_T","EXECUTIONS_D","EXECUTIONS_PC","ELAPSED_TIME_T","CPU_TIME_T","USER_IO_WAIT_TIME_T","CONCURRENCY_WAIT_TIME_T","APPLICATION_WAIT_TIME_T","CLUSTER_WAIT_TIME_T","OTHER_WAIT_TIME_T","BUFFER_GETS_T","ROWS_PROCESSED_T","DISK_READS_T","IO_INTERCONNECT_BYTES_T"]
prompt  , "LOADS":["RANK","SQL_ID","SQL_TYPE","LOADS_S","PLAN_HASH_VALUE","LOADS_B","LOADS_T","LOADS_D","EXECUTIONS_B","EXECUTIONS_T","EXECUTIONS_D","EXECUTIONS_PC","ELAPSED_TIME_T","CPU_TIME_T","USER_IO_WAIT_TIME_T","CONCURRENCY_WAIT_TIME_T","APPLICATION_WAIT_TIME_T","CLUSTER_WAIT_TIME_T","OTHER_WAIT_TIME_T","BUFFER_GETS_T","ROWS_PROCESSED_T","DISK_READS_T","IO_INTERCONNECT_BYTES_T"]
prompt  , "INVALIDATIONS":["RANK","SQL_ID","SQL_TYPE","INVALIDATIONS_S","PLAN_HASH_VALUE","INVALIDATIONS_B","INVALIDATIONS_T","INVALIDATIONS_D","EXECUTIONS_B","EXECUTIONS_T","EXECUTIONS_D","EXECUTIONS_PC","ELAPSED_TIME_T","CPU_TIME_T","USER_IO_WAIT_TIME_T","CONCURRENCY_WAIT_TIME_T","APPLICATION_WAIT_TIME_T","CLUSTER_WAIT_TIME_T","OTHER_WAIT_TIME_T","BUFFER_GETS_T","ROWS_PROCESSED_T","DISK_READS_T","IO_INTERCONNECT_BYTES_T"]
prompt  , "PHYSICAL_READ_REQUESTS":["RANK","SQL_ID","SQL_TYPE","PHYSICAL_READ_REQUESTS_S","PLAN_HASH_VALUE","PHYSICAL_READ_REQUESTS_B","PHYSICAL_READ_REQUESTS_T","PHYSICAL_READ_REQUESTS_D","EXECUTIONS_B","EXECUTIONS_T","EXECUTIONS_D","EXECUTIONS_PC","ELAPSED_TIME_T","CPU_TIME_T","USER_IO_WAIT_TIME_T","CONCURRENCY_WAIT_TIME_T","APPLICATION_WAIT_TIME_T","CLUSTER_WAIT_TIME_T","OTHER_WAIT_TIME_T","BUFFER_GETS_T","ROWS_PROCESSED_T","DISK_READS_T","IO_INTERCONNECT_BYTES_T"]
prompt  , "PHYSICAL_READ_BYTES":["RANK","SQL_ID","SQL_TYPE","PHYSICAL_READ_BYTES_S","PLAN_HASH_VALUE","PHYSICAL_READ_BYTES_B","PHYSICAL_READ_BYTES_T","PHYSICAL_READ_BYTES_D","EXECUTIONS_B","EXECUTIONS_T","EXECUTIONS_D","EXECUTIONS_PC","ELAPSED_TIME_T","CPU_TIME_T","USER_IO_WAIT_TIME_T","CONCURRENCY_WAIT_TIME_T","APPLICATION_WAIT_TIME_T","CLUSTER_WAIT_TIME_T","OTHER_WAIT_TIME_T","BUFFER_GETS_T","ROWS_PROCESSED_T","DISK_READS_T","IO_INTERCONNECT_BYTES_T"]
prompt  , "PHYSICAL_WRITE_REQUESTS":["RANK","SQL_ID","SQL_TYPE","PHYSICAL_WRITE_REQUESTS_S","PLAN_HASH_VALUE","PHYSICAL_WRITE_REQUESTS_B","PHYSICAL_WRITE_REQUESTS_T","PHYSICAL_WRITE_REQUESTS_D","EXECUTIONS_B","EXECUTIONS_T","EXECUTIONS_D","EXECUTIONS_PC","ELAPSED_TIME_T","CPU_TIME_T","USER_IO_WAIT_TIME_T","CONCURRENCY_WAIT_TIME_T","APPLICATION_WAIT_TIME_T","CLUSTER_WAIT_TIME_T","OTHER_WAIT_TIME_T","BUFFER_GETS_T","ROWS_PROCESSED_T","DISK_READS_T","IO_INTERCONNECT_BYTES_T"]
prompt  , "PHYSICAL_WRITE_BYTES":["RANK","SQL_ID","SQL_TYPE","PHYSICAL_WRITE_BYTES_S","PLAN_HASH_VALUE","PHYSICAL_WRITE_BYTES_B","PHYSICAL_WRITE_BYTES_T","PHYSICAL_WRITE_BYTES_D","EXECUTIONS_B","EXECUTIONS_T","EXECUTIONS_D","EXECUTIONS_PC","ELAPSED_TIME_T","CPU_TIME_T","USER_IO_WAIT_TIME_T","CONCURRENCY_WAIT_TIME_T","APPLICATION_WAIT_TIME_T","CLUSTER_WAIT_TIME_T","OTHER_WAIT_TIME_T","BUFFER_GETS_T","ROWS_PROCESSED_T","DISK_READS_T","IO_INTERCONNECT_BYTES_T"]
prompt  , "IO_INTERCONNECT_BYTES":["RANK","SQL_ID","SQL_TYPE","IO_INTERCONNECT_BYTES_S","PLAN_HASH_VALUE","IO_INTERCONNECT_BYTES_B","IO_INTERCONNECT_BYTES_T","IO_INTERCONNECT_BYTES_D","EXECUTIONS_B","EXECUTIONS_T","EXECUTIONS_D","EXECUTIONS_PC","ELAPSED_TIME_T","CPU_TIME_T","USER_IO_WAIT_TIME_T","CONCURRENCY_WAIT_TIME_T","APPLICATION_WAIT_TIME_T","CLUSTER_WAIT_TIME_T","OTHER_WAIT_TIME_T","BUFFER_GETS_T","ROWS_PROCESSED_T","DISK_READS_T","IO_INTERCONNECT_BYTES_T"]
prompt  , "OTHER_WAIT_TIME":["RANK","SQL_ID","SQL_TYPE","OTHER_WAIT_TIME_S","PLAN_HASH_VALUE","OTHER_WAIT_TIME_B","OTHER_WAIT_TIME_T","OTHER_WAIT_TIME_D","EXECUTIONS_B","EXECUTIONS_T","EXECUTIONS_D","EXECUTIONS_PC","ELAPSED_TIME_T","CPU_TIME_T","USER_IO_WAIT_TIME_T","CONCURRENCY_WAIT_TIME_T","APPLICATION_WAIT_TIME_T","CLUSTER_WAIT_TIME_T","OTHER_WAIT_TIME_T","BUFFER_GETS_T","ROWS_PROCESSED_T","DISK_READS_T","IO_INTERCONNECT_BYTES_T"]
prompt  , "SYS_TIME_MODEL":["RANK","STAT_NAME","SYS_TIME_MODEL_BR","SYS_TIME_MODEL_TR","SYS_TIME_MODEL_D","SYS_TIME_MODEL_PC"]
prompt  , "DB_SUMMARY":["RUNID","DBID","DBNAME","CREATED","LOG_MODE","PLATFORM_NAME","INSTANCE_NUMBER","INSTANCE_NAME","HOST_NAME","VERSION","STARTUP_TIME","STATUS","START_SNAP","END_SNAP","START_TIME","END_TIME"]
prompt  , "SQL_TEXT":["SQL_ID", "SQL_TYPE", "SQL_TEXT"]
prompt  , "SYS_STAT":["STATISTIC#", "NAME", "CLASS","UNIT","SYSSTAT_BL","SYSSTAT_TR","SYSSTAT_DIFF","SYSSTAT_PC"]
prompt  };;
prompt
prompt
prompt  var sqlStatsColsHeader1 = {
prompt  "PARSE_CALLS":["#","SQL_ID","SQL TYPE","%","SQL PLAN","PARSE CALLS","EXECUTIONS","TIME DISTRIBUTION","GETS","ROWS","READS","IO BYTES"]
prompt  , "DISK_READS":["#","SQL_ID","SQL TYPE","%","SQL PLAN","DISK READS","EXECUTIONS","TIME DISTRIBUTION","GETS","ROWS","READS","IO BYTES"]
prompt  , "DIRECT_WRITES":["#","SQL_ID","SQL TYPE","%","SQL PLAN","DIRECT WRITES","EXECUTIONS","TIME DISTRIBUTION","GETS","ROWS","READS","IO BYTES"]
prompt  , "BUFFER_GETS":["#","SQL_ID","SQL TYPE","%","SQL PLAN","BUFFER GETS","EXECUTIONS","TIME DISTRIBUTION","GETS","ROWS","READS","IO BYTES","GETS PER EXEC"]
prompt  , "ROWS_PROCESSED":["#","SQL_ID","SQL TYPE","%","SQL PLAN","ROWS PROCESSED","EXECUTIONS","TIME DISTRIBUTION","GETS","ROWS","READS","IO BYTES","ROWS PER EXEC"]
prompt  , "FETCHES":["#","SQL_ID","SQL TYPE","%","SQL PLAN","FETCHES","EXECUTIONS","TIME DISTRIBUTION","GETS","ROWS","READS","IO BYTES"]
prompt  , "EXECUTIONS":["#","SQL_ID","SQL TYPE","%","SQL PLAN","EXECUTIONS","TIME DISTRIBUTION","GETS","ROWS","READS","IO BYTES"]
prompt  , "PX_SERVERS_EXECUTIONS":["#","SQL_ID","SQL TYPE","%","SQL PLAN","PX SERVERS EXECUTIONS","EXECUTIONS","TIME DISTRIBUTION","GETS","ROWS","READS","IO BYTES"]
prompt  , "END_OF_FETCH_COUNT":["#","SQL_ID","SQL TYPE","%","SQL PLAN","END OF FETCH COUNT","EXECUTIONS","TIME DISTRIBUTION","GETS","ROWS","READS","IO BYTES"]
prompt  , "CPU_TIME":["#","SQL_ID","SQL TYPE","%","SQL PLAN","CPU TIME","EXECUTIONS","TIME DISTRIBUTION","GETS","ROWS","READS","IO BYTES","CPU PER EXEC"]
prompt  , "ELAPSED_TIME":["#","SQL_ID","SQL TYPE","%","SQL PLAN","ELAPSED TIME","EXECUTIONS","TIME DISTRIBUTION","GETS","ROWS","READS","IO BYTES","ELAPSED PER EXEC"]
prompt  , "APPLICATION_WAIT_TIME":["#","SQL_ID","SQL TYPE","%","SQL PLAN","APPLICATION WAIT TIME","EXECUTIONS","TIME DISTRIBUTION","GETS","ROWS","READS","IO BYTES"]
prompt  , "CONCURRENCY_WAIT_TIME":["#","SQL_ID","SQL TYPE","%","SQL PLAN","CONCURRENCY WAIT TIME","EXECUTIONS","TIME DISTRIBUTION","GETS","ROWS","READS","IO BYTES"]
prompt  , "CLUSTER_WAIT_TIME":["#","SQL_ID","SQL TYPE","%","SQL PLAN","CLUSTER WAIT TIME","EXECUTIONS","TIME DISTRIBUTION","GETS","ROWS","READS","IO BYTES"]
prompt  , "USER_IO_WAIT_TIME":["#","SQL_ID","SQL TYPE","%","SQL PLAN","USERIO WAIT TIME","EXECUTIONS","TIME DISTRIBUTION","GETS","ROWS","READS","IO BYTES"]
prompt  , "PLSQL_EXEC_TIME":["#","SQL_ID","SQL TYPE","%","SQL PLAN","PLSQL EXEC TIME","EXECUTIONS","TIME DISTRIBUTION","GETS","ROWS","READS","IO BYTES"]
prompt  , "JAVA_EXEC_TIME":["#","SQL_ID","SQL TYPE","%","SQL PLAN","JAVA EXEC TIME","EXECUTIONS","TIME DISTRIBUTION","GETS","ROWS","READS","IO BYTES"]
prompt  , "SORTS":["#","SQL_ID","SQL TYPE","%","SQL PLAN","SORTS","EXECUTIONS","TIME DISTRIBUTION","GETS","ROWS","READS","IO BYTES"]
prompt  , "LOADS":["#","SQL_ID","SQL TYPE","%","SQL PLAN","LOADS","EXECUTIONS","TIME DISTRIBUTION","GETS","ROWS","READS","IO BYTES"]
prompt  , "INVALIDATIONS":["#","SQL_ID","SQL TYPE","%","SQL PLAN","INVALIDATIONS","EXECUTIONS","TIME DISTRIBUTION","GETS","ROWS","READS","IO BYTES"]
prompt  , "PHYSICAL_READ_REQUESTS":["#","SQL_ID","SQL TYPE","%","SQL PLAN","PHYSICAL READ REQUESTS","EXECUTIONS","TIME DISTRIBUTION","GETS","ROWS","READS","IO BYTES"]
prompt  , "PHYSICAL_READ_BYTES":["#","SQL_ID","SQL TYPE","%","SQL PLAN","PHYSICAL READ BYTES","EXECUTIONS","TIME DISTRIBUTION","GETS","ROWS","READS","IO BYTES"]
prompt  , "PHYSICAL_WRITE_REQUESTS":["#","SQL_ID","SQL TYPE","%","SQL PLAN","PHYSICAL WRITE REQUESTS","EXECUTIONS","TIME DISTRIBUTION","GETS","ROWS","READS","IO BYTES"]
prompt  , "PHYSICAL_WRITE_BYTES":["#","SQL_ID","SQL TYPE","%","SQL PLAN","PHYSICAL WRITE BYTES","EXECUTIONS","TIME DISTRIBUTION","GETS","ROWS","READS","IO BYTES"]
prompt  , "IO_INTERCONNECT_BYTES":["#","SQL_ID","SQL TYPE","%","SQL PLAN","IO INTERCONNECT BYTES","EXECUTIONS","TIME DISTRIBUTION","GETS","ROWS","READS","IO BYTES"]
prompt  , "OTHER_WAIT_TIME":["#","SQL_ID","SQL TYPE","%","SQL PLAN","OTHER WAIT TIME","EXECUTIONS","TIME DISTRIBUTION","GETS","ROWS","READS","IO BYTES"]
prompt  , "SYS_TIME_MODEL":["#","STATISTIC NAME","B","T","Δ","%Δ"]
prompt  , "DB_SUMMARY":["TEST NAME","DBID","DBNAME","CREATED","LOG MODE","PLATFORM NAME","INSTANCE NUMBER","INSTANCE NAME","HOST NAME","VERSION","STARTUP TIME","STATUS","START SNAP","END SNAP","START TIME","END TIME"]
prompt  , "SQL_TEXT":["SQL_ID", "SQL TYPE", "SQL_TEXT (First 2000 characters)"]
prompt  , "SYS_STAT":["#", "STATISTIC NAME", "CLASS","UNIT","B","T", "Δ", "%Δ"]
prompt  };;
prompt
prompt  var sqlStatsColsHeader2 = {
prompt    "PARSE_CALLS":["B","T","Δ","B","T","Δ","%Δ","ELAPSED","CPU","IO","CC","APP","CL","OTHER"]
prompt  , "DISK_READS":["B","T","Δ","B","T","Δ","%Δ","ELAPSED","CPU","IO","CC","APP","CL","OTHER"]
prompt  , "DIRECT_WRITES":["B","T","Δ","B","T","Δ","%Δ","ELAPSED","CPU","IO","CC","APP","CL","OTHER"]
prompt  , "BUFFER_GETS":["B","T","Δ","B","T","Δ","%Δ","ELAPSED","CPU","IO","CC","APP","CL","OTHER","B","T"]
prompt  , "ROWS_PROCESSED":["B","T","Δ","B","T","Δ","%Δ","ELAPSED","CPU","IO","CC","APP","CL","OTHER","B","T"]
prompt  , "FETCHES":["B","T","Δ","B","T","Δ","%Δ","ELAPSED","CPU","IO","CC","APP","CL","OTHER"]
prompt  , "EXECUTIONS":["B","T","Δ","%Δ","ELAPSED","CPU","IO","CC","APP","CL","OTHER"]
prompt  , "PX_SERVERS_EXECUTIONS":["B","T","Δ","B","T","Δ","%Δ","ELAPSED","CPU","IO","CC","APP","CL","OTHER"]
prompt  , "END_OF_FETCH_COUNT":["B","T","Δ","B","T","Δ","%Δ","ELAPSED","CPU","IO","CC","APP","CL","OTHER"]
prompt  , "CPU_TIME":["B","T","Δ","B","T","Δ","%Δ","ELAPSED","CPU","IO","CC","APP","CL","OTHER","B","T"]
prompt  , "ELAPSED_TIME":["B","T","Δ","B","T","Δ","%Δ","ELAPSED","CPU","IO","CC","APP","CL","OTHER","B","T"]
prompt  , "APPLICATION_WAIT_TIME":["B","T","Δ","B","T","Δ","%Δ","ELAPSED","CPU","IO","CC","APP","CL","OTHER"]
prompt  , "CONCURRENCY_WAIT_TIME":["B","T","Δ","B","T","Δ","%Δ","ELAPSED","CPU","IO","CC","APP","CL","OTHER"]
prompt  , "CLUSTER_WAIT_TIME":["B","T","Δ","B","T","Δ","%Δ","ELAPSED","CPU","IO","CC","APP","CL","OTHER"]
prompt  , "USER_IO_WAIT_TIME":["B","T","Δ","B","T","Δ","%Δ","ELAPSED","CPU","IO","CC","APP","CL","OTHER"]
prompt  , "PLSQL_EXEC_TIME":["B","T","Δ","B","T","Δ","%Δ","ELAPSED","CPU","IO","CC","APP","CL","OTHER"]
prompt  , "JAVA_EXEC_TIME":["B","T","Δ","B","T","Δ","%Δ","ELAPSED","CPU","IO","CC","APP","CL","OTHER"]
prompt  , "SORTS":["B","T","Δ","B","T","Δ","%Δ","ELAPSED","CPU","IO","CC","APP","CL","OTHER"]
prompt  , "LOADS":["B","T","Δ","B","T","Δ","%Δ","ELAPSED","CPU","IO","CC","APP","CL","OTHER"]
prompt  , "INVALIDATIONS":["B","T","Δ","B","T","Δ","%Δ","ELAPSED","CPU","IO","CC","APP","CL","OTHER"]
prompt  , "PHYSICAL_READ_REQUESTS":["B","T","Δ","B","T","Δ","%Δ","ELAPSED","CPU","IO","CC","APP","CL","OTHER"]
prompt  , "PHYSICAL_READ_BYTES":["B","T","Δ","B","T","Δ","%Δ","ELAPSED","CPU","IO","CC","APP","CL","OTHER"]
prompt  , "PHYSICAL_WRITE_REQUESTS":["B","T","Δ","B","T","Δ","%Δ","ELAPSED","CPU","IO","CC","APP","CL","OTHER"]
prompt  , "PHYSICAL_WRITE_BYTES":["B","T","Δ","B","T","Δ","%Δ","ELAPSED","CPU","IO","CC","APP","CL","OTHER"]
prompt  , "IO_INTERCONNECT_BYTES":["B","T","Δ","B","T","Δ","%Δ","ELAPSED","CPU","IO","CC","APP","CL","OTHER"]
prompt  , "OTHER_WAIT_TIME":["B","T","Δ","B","T","Δ","%Δ","ELAPSED","CPU","IO","CC","APP","CL","OTHER"]
prompt  , "SYS_TIME_MODEL":[]
prompt  , "DB_SUMMARY":[]
prompt  , "SQL_TEXT":[]
prompt  , "SYS_STAT":[]
prompt  };;
prompt
prompt  var sqlStatsHeaderColspan2 = ["ELAPSED PER EXEC","CPU PER EXEC","GETS PER EXEC","ROWS PER EXEC"];;
prompt  var sqlStatsHeaderColspan3 = ["PARSE CALLS","DISK READS","DIRECT WRITES","BUFFER GETS","ROWS PROCESSED","FETCHES","PX SERVERS EXECUTIONS","END OF FETCH COUNT","CPU TIME","ELAPSED TIME","APPLICATION WAIT TIME","CONCURRENCY WAIT TIME","CLUSTER WAIT TIME","USERIO WAIT TIME","PLSQL EXEC TIME","JAVA EXEC TIME","SORTS","LOADS","INVALIDATIONS","PHYSICAL READ REQUESTS","PHYSICAL READ BYTES","PHYSICAL WRITE REQUESTS","PHYSICAL WRITE BYTES","PHYSICAL WRITE REQUESTS","PHYSICAL WRITE BYTES","IO INTERCONNECT BYTES","OTHER WAIT TIME", "AVG ELAPSED"];;
prompt  var sqlStatsHeaderColspan4 = ["EXECUTIONS"];;
prompt  var sqlStatsHeaderColspan7 = ["TIME DISTRIBUTION"];;
prompt
prompt
prompt
prompt  var sqlStatsTableDetails = {
prompt  "PARSE_CALLS":{name:"Top 20 SQL by Parse Calls", description:"Total Parse Calls",colShare:"PARSE_CALLS_S",colDiff:"PARSE_CALLS_D",colBaseline:"PARSE_CALLS_B",colTestrun:"PARSE_CALLS_T"}
prompt  , "DISK_READS":{name:"Top 20 SQL by Disk Reads", description:"Total Disk Reads",colShare:"DISK_READS_S",colDiff:"DISK_READS_D",colBaseline:"DISK_READS_B",colTestrun:"DISK_READS_T"}
prompt  , "DIRECT_WRITES":{name:"Top 20 SQL by Direct Writes", description:"Total Direct Writes",colShare:"DIRECT_WRITES_S",colDiff:"DIRECT_WRITES_D",colBaseline:"DIRECT_WRITES_B",colTestrun:"DIRECT_WRITES_T"}
prompt  , "BUFFER_GETS":{name:"Top 20 SQL by Buffer Gets", description:"Total Buffer Gets",colShare:"BUFFER_GETS_S",colDiff:"BUFFER_GETS_D",colBaseline:"BUFFER_GETS_B",colTestrun:"BUFFER_GETS_T"}
prompt  , "ROWS_PROCESSED":{name:"Top 20 SQL by Processed Rows", description:"Total Processed Rows",colShare:"ROWS_PROCESSED_S",colDiff:"ROWS_PROCESSED_D",colBaseline:"ROWS_PROCESSED_B",colTestrun:"ROWS_PROCESSED_T"}
prompt  , "FETCHES":{name:"Top 20 SQL by Fetches", description:"Total Fetches",colShare:"FETCHES_S",colDiff:"FETCHES_D",colBaseline:"FETCHES_B",colTestrun:"FETCHES_T"}
prompt  , "EXECUTIONS":{name:"Top 20 SQL by Executions", description:"Total Executions",colShare:"EXECUTIONS_S",colDiff:"EXECUTIONS_D",colBaseline:"EXECUTIONS_B",colTestrun:"EXECUTIONS_T"}
prompt  , "PX_SERVERS_EXECUTIONS":{name:"Top 20 SQL by PX Servers Executions", description:"Total PX Server Executions",colShare:"PX_SERVERS_EXECUTIONS_S",colDiff:"PX_SERVERS_EXECUTIONS_D",colBaseline:"PX_SERVERS_EXECUTIONS_B",colTestrun:"PX_SERVERS_EXECUTIONS_T"}
prompt  , "END_OF_FETCH_COUNT":{name:"Top 20 SQL by End Of Fetch Count", description:"Total End Of Fetch Count",colShare:"END_OF_FETCH_COUNT_S",colDiff:"END_OF_FETCH_COUNT_D",colBaseline:"END_OF_FETCH_COUNT_B",colTestrun:"END_OF_FETCH_COUNT_T"}
prompt  , "CPU_TIME":{name:"Top 20 SQL by CPU Time", description:"Total CPU Time",colShare:"CPU_TIME_S",colDiff:"CPU_TIME_D",colBaseline:"CPU_TIME_B",colTestrun:"CPU_TIME_T"}
prompt  , "ELAPSED_TIME":{name:"Top 20 SQL by Elapsed Time", description:"Total Elapsed Time",colShare:"ELAPSED_TIME_S",colDiff:"ELAPSED_TIME_D",colBaseline:"ELAPSED_TIME_B",colTestrun:"ELAPSED_TIME_T"}
prompt  , "APPLICATION_WAIT_TIME":{name:"Top 20 SQL by Application Wait Time", description:"Total Application Wait Time",colShare:"APPLICATION_WAIT_TIME_S",colDiff:"APPLICATION_WAIT_TIME_D",colBaseline:"APPLICATION_WAIT_TIME_B",colTestrun:"APPLICATION_WAIT_TIME_T"}
prompt  , "CONCURRENCY_WAIT_TIME":{name:"Top 20 SQL by Concurrency Wait Time", description:"Total Concurrency Wait Time",colShare:"CONCURRENCY_WAIT_TIME_S",colDiff:"CONCURRENCY_WAIT_TIME_D",colBaseline:"CONCURRENCY_WAIT_TIME_B",colTestrun:"CONCURRENCY_WAIT_TIME_T"}
prompt  , "CLUSTER_WAIT_TIME":{name:"Top 20 SQL by Cluster Wait Time", description:"Total Cluster Wait Time",colShare:"CLUSTER_WAIT_TIME_S",colDiff:"CLUSTER_WAIT_TIME_D",colBaseline:"CLUSTER_WAIT_TIME_B",colTestrun:"CLUSTER_WAIT_TIME_T"}
prompt  , "USER_IO_WAIT_TIME":{name:"Top 20 SQL by User IO Wait Time", description:"Total User IO Wait Time",colShare:"USER_IO_WAIT_TIME_S",colDiff:"USER_IO_WAIT_TIME_D",colBaseline:"USER_IO_WAIT_TIME_B",colTestrun:"USER_IO_WAIT_TIME_T"}
prompt  , "PLSQL_EXEC_TIME":{name:"Top 20 SQL by PLSQL Execution Time", description:"Total PLSQL Execution Time",colShare:"PLSQL_EXEC_TIME_S",colDiff:"PLSQL_EXEC_TIME_D",colBaseline:"PLSQL_EXEC_TIME_B",colTestrun:"PLSQL_EXEC_TIME_T"}
prompt  , "JAVA_EXEC_TIME":{name:"Top 20 SQL by Java Execution Time", description:"Total Java Execution Time",colShare:"JAVA_EXEC_TIME_S",colDiff:"JAVA_EXEC_TIME_D",colBaseline:"JAVA_EXEC_TIME_B",colTestrun:"JAVA_EXEC_TIME_T"}
prompt  , "SORTS":{name:"Top 20 SQL by Sorts", description:"Total Sorts",colShare:"SORTS_S",colDiff:"SORTS_D",colBaseline:"SORTS_B",colTestrun:"SORTS_T"}
prompt  , "LOADS":{name:"Top 20 SQL by Loads", description:"Total Loads",colShare:"LOADS_S",colDiff:"LOADS_D",colBaseline:"LOADS_B",colTestrun:"LOADS_T"}
prompt  , "INVALIDATIONS":{name:"Top 20 SQL by Invalidations", description:"Total Invalidations",colShare:"INVALIDATIONS_S",colDiff:"INVALIDATIONS_D",colBaseline:"INVALIDATIONS_B",colTestrun:"INVALIDATIONS_T"}
prompt  , "PHYSICAL_READ_REQUESTS":{name:"Top 20 SQL by Physical Read Requests", description:"Total Physical Read Requests",colShare:"PHYSICAL_READ_REQUESTS_S",colDiff:"PHYSICAL_READ_REQUESTS_D",colBaseline:"PHYSICAL_READ_REQUESTS_B",colTestrun:"PHYSICAL_READ_REQUESTS_T"}
prompt  , "PHYSICAL_READ_BYTES":{name:"Top 20 SQL by Physical Read Bytes", description:"Total Physical Read Bytes",colShare:"PHYSICAL_READ_BYTES_S",colDiff:"PHYSICAL_READ_BYTES_D",colBaseline:"PHYSICAL_READ_BYTES_B",colTestrun:"PHYSICAL_READ_BYTES_T"}
prompt  , "PHYSICAL_WRITE_REQUESTS":{name:"Top 20 SQL by Physical Write Requests", description:"Total Physical Write Requests",colShare:"PHYSICAL_WRITE_REQUESTS_S",colDiff:"PHYSICAL_WRITE_REQUESTS_D",colBaseline:"PHYSICAL_WRITE_REQUESTS_B",colTestrun:"PHYSICAL_WRITE_REQUESTS_T"}
prompt  , "PHYSICAL_WRITE_BYTES":{name:"Top 20 SQL by Physical Write Bytes", description:"Total Physical Write Bytes",colShare:"PHYSICAL_WRITE_BYTES_S",colDiff:"PHYSICAL_WRITE_BYTES_D",colBaseline:"PHYSICAL_WRITE_BYTES_B",colTestrun:"PHYSICAL_WRITE_BYTES_T"}
prompt  , "IO_INTERCONNECT_BYTES":{name:"Top 20 SQL by IO Interconnect Bytes", description:"Total IO Interconnect Bytes",colShare:"IO_INTERCONNECT_BYTES_S",colDiff:"IO_INTERCONNECT_BYTES_D",colBaseline:"IO_INTERCONNECT_BYTES_B",colTestrun:"IO_INTERCONNECT_BYTES_T"}
prompt  , "OTHER_WAIT_TIME":{name:"Top 20 SQL by Other Wait Time", description:"Total Other Wait Time",colShare:"OTHER_WAIT_TIME_S",colDiff:"OTHER_WAIT_TIME_D",colBaseline:"OTHER_WAIT_TIME_B",colTestrun:"OTHER_WAIT_TIME_T"}
prompt  , "SYS_TIME_MODEL":{name:"System Time Model", description:"",colShare:"",colDiff:"",colBaseline:"",colTestrun:""}
prompt  , "DB_SUMMARY":{name:"", description:"",colShare:"",colDiff:"",colBaseline:"",colTestrun:""}
prompt  , "SQL_TEXT":{name:"SQL Text", description:"",colShare:"",colDiff:"",colBaseline:"",colTestrun:""}
prompt  , "SYS_STAT":{name:"System Statistics", description:"",colShare:"",colDiff:"",colBaseline:"",colTestrun:""}
prompt  };;
prompt
prompt
prompt  for (i = 0, t = 0; i < dataSqlStatsTable.length; i++)
prompt  {
prompt  var myObj = {};;
prompt  sqlStatsCols[dataSqlStatsTable[i]["STATISTIC"]].forEach(function(d){
prompt
prompt  switch(d)
prompt  {
prompt  case "ELAPSED_TIME_D": myObj[d] = (+dataSqlStatsTable[i]["ELAPSED_TIME_T"]) - (+dataSqlStatsTable[i]["ELAPSED_TIME_B"]); break;;
prompt  case "CPU_TIME_D": myObj[d] = (+dataSqlStatsTable[i]["CPU_TIME_T"]) - (+dataSqlStatsTable[i]["CPU_TIME_B"]); break;;
prompt  case "USER_IO_WAIT_TIME_D": myObj[d] = (+dataSqlStatsTable[i]["USER_IO_WAIT_TIME_T"]) - (+dataSqlStatsTable[i]["USER_IO_WAIT_TIME_B"]); break;;
prompt  case "CONCURRENCY_WAIT_TIME_D": myObj[d] = (+dataSqlStatsTable[i]["CONCURRENCY_WAIT_TIME_T"]) - (+dataSqlStatsTable[i]["CONCURRENCY_WAIT_TIME_B"]); break;;
prompt  case "APPLICATION_WAIT_TIME_D": myObj[d] = (+dataSqlStatsTable[i]["APPLICATION_WAIT_TIME_T"]) - (+dataSqlStatsTable[i]["APPLICATION_WAIT_TIME_B"]); break;;
prompt  case "CLUSTER_WAIT_TIME_D": myObj[d] = (+dataSqlStatsTable[i]["CLUSTER_WAIT_TIME_T"]) - (+dataSqlStatsTable[i]["CLUSTER_WAIT_TIME_B"]); break;;
prompt  case "OTHER_WAIT_TIME_D": myObj[d] = (+dataSqlStatsTable[i]["OTHER_WAIT_TIME_T"]) - (+dataSqlStatsTable[i]["OTHER_WAIT_TIME_B"]); break;;
prompt  case "EXECUTIONS_D": myObj[d] = (+dataSqlStatsTable[i]["EXECUTIONS_T"]) - (+dataSqlStatsTable[i]["EXECUTIONS_B"]); break;;
prompt  case "BUFFER_GETS_D": myObj[d] = (+dataSqlStatsTable[i]["BUFFER_GETS_T"]) - (+dataSqlStatsTable[i]["BUFFER_GETS_B"]); break;;
prompt  case "ROWS_PROCESSED_D": myObj[d] = (+dataSqlStatsTable[i]["ROWS_PROCESSED_T"]) - (+dataSqlStatsTable[i]["ROWS_PROCESSED_B"]); break;;
prompt  case "DISK_READS_D": myObj[d] = (+dataSqlStatsTable[i]["DISK_READS_T"]) - (+dataSqlStatsTable[i]["DISK_READS_B"]); break;;
prompt  case "PHYSICAL_READ_REQUESTS_D": myObj[d] = (+dataSqlStatsTable[i]["PHYSICAL_READ_REQUESTS_T"]) - (+dataSqlStatsTable[i]["PHYSICAL_READ_REQUESTS_B"]); break;;
prompt  case "PHYSICAL_READ_BYTES_D": myObj[d] = (+dataSqlStatsTable[i]["PHYSICAL_READ_BYTES_T"]) - (+dataSqlStatsTable[i]["PHYSICAL_READ_BYTES_B"]); break;;
prompt  case "DIRECT_WRITES_D": myObj[d] = (+dataSqlStatsTable[i]["DIRECT_WRITES_T"]) - (+dataSqlStatsTable[i]["DIRECT_WRITES_B"]); break;;
prompt  case "PHYSICAL_WRITE_REQUESTS_D": myObj[d] = (+dataSqlStatsTable[i]["PHYSICAL_WRITE_REQUESTS_T"]) - (+dataSqlStatsTable[i]["PHYSICAL_WRITE_REQUESTS_B"]); break;;
prompt  case "PHYSICAL_WRITE_BYTES_D": myObj[d] = (+dataSqlStatsTable[i]["PHYSICAL_WRITE_BYTES_T"]) - (+dataSqlStatsTable[i]["PHYSICAL_WRITE_BYTES_B"]); break;;
prompt  case "IO_INTERCONNECT_BYTES_D": myObj[d] = (+dataSqlStatsTable[i]["IO_INTERCONNECT_BYTES_T"]) - (+dataSqlStatsTable[i]["IO_INTERCONNECT_BYTES_B"]); break;;
prompt  case "PLSQL_EXEC_TIME_D": myObj[d] = (+dataSqlStatsTable[i]["PLSQL_EXEC_TIME_T"]) - (+dataSqlStatsTable[i]["PLSQL_EXEC_TIME_B"]); break;;
prompt  case "JAVA_EXEC_TIME_D": myObj[d] = (+dataSqlStatsTable[i]["JAVA_EXEC_TIME_T"]) - (+dataSqlStatsTable[i]["JAVA_EXEC_TIME_B"]); break;;
prompt  case "PARSE_CALLS_D": myObj[d] = (+dataSqlStatsTable[i]["PARSE_CALLS_T"]) - (+dataSqlStatsTable[i]["PARSE_CALLS_B"]); break;;
prompt  case "FETCHES_D": myObj[d] = (+dataSqlStatsTable[i]["FETCHES_T"]) - (+dataSqlStatsTable[i]["FETCHES_B"]); break;;
prompt  case "PX_SERVERS_EXECUTIONS_D": myObj[d] = (+dataSqlStatsTable[i]["PX_SERVERS_EXECUTIONS_T"]) - (+dataSqlStatsTable[i]["PX_SERVERS_EXECUTIONS_B"]); break;;
prompt  case "END_OF_FETCH_COUNT_D": myObj[d] = (+dataSqlStatsTable[i]["END_OF_FETCH_COUNT_T"]) - (+dataSqlStatsTable[i]["END_OF_FETCH_COUNT_B"]); break;;
prompt  case "SORTS_D": myObj[d] = (+dataSqlStatsTable[i]["SORTS_T"]) - (+dataSqlStatsTable[i]["SORTS_B"]); break;;
prompt  case "LOADS_D": myObj[d] = (+dataSqlStatsTable[i]["LOADS_T"]) - (+dataSqlStatsTable[i]["LOADS_B"]); break;;
prompt  case "INVALIDATIONS_D": myObj[d] = (+dataSqlStatsTable[i]["INVALIDATIONS_T"]) - (+dataSqlStatsTable[i]["INVALIDATIONS_B"]); break;;
prompt  case "EXECUTIONS_PC": if ((+dataSqlStatsTable[i]["EXECUTIONS_B"]) == 0 ) {myObj[d] = 1} else {myObj[d] = ((+dataSqlStatsTable[i]["EXECUTIONS_T"]) - (+dataSqlStatsTable[i]["EXECUTIONS_B"]))/(+dataSqlStatsTable[i]["EXECUTIONS_B"]);} break;;
prompt  case "ELAPSED_TIME_BA": if ((+dataSqlStatsTable[i]["EXECUTIONS_B"]) == 0 ) {myObj[d] = (+dataSqlStatsTable[i]["ELAPSED_TIME_B"])} else {myObj[d] = ((+dataSqlStatsTable[i]["ELAPSED_TIME_B"]))/(+dataSqlStatsTable[i]["EXECUTIONS_B"]);} break;;
prompt  case "ELAPSED_TIME_TA": if ((+dataSqlStatsTable[i]["EXECUTIONS_T"]) == 0 ) {myObj[d] = (+dataSqlStatsTable[i]["ELAPSED_TIME_T"])} else {myObj[d] = ((+dataSqlStatsTable[i]["ELAPSED_TIME_T"]))/(+dataSqlStatsTable[i]["EXECUTIONS_T"]);} break;;
prompt  case "CPU_TIME_BA": if ((+dataSqlStatsTable[i]["EXECUTIONS_B"]) == 0 ) {myObj[d] = (+dataSqlStatsTable[i]["CPU_TIME_B"])} else {myObj[d] = ((+dataSqlStatsTable[i]["CPU_TIME_B"]))/(+dataSqlStatsTable[i]["EXECUTIONS_B"]);} break;;
prompt  case "CPU_TIME_TA": if ((+dataSqlStatsTable[i]["EXECUTIONS_T"]) == 0 ) {myObj[d] = (+dataSqlStatsTable[i]["CPU_TIME_T"])} else {myObj[d] = ((+dataSqlStatsTable[i]["CPU_TIME_T"]))/(+dataSqlStatsTable[i]["EXECUTIONS_T"]);} break;;
prompt  case "BUFFER_GETS_BA": if ((+dataSqlStatsTable[i]["EXECUTIONS_B"]) == 0 ) {myObj[d] = (+dataSqlStatsTable[i]["BUFFER_GETS_B"])} else {myObj[d] = ((+dataSqlStatsTable[i]["BUFFER_GETS_B"]))/(+dataSqlStatsTable[i]["EXECUTIONS_B"]);} break;;
prompt  case "BUFFER_GETS_TA": if ((+dataSqlStatsTable[i]["EXECUTIONS_T"]) == 0 ) {myObj[d] = (+dataSqlStatsTable[i]["BUFFER_GETS_T"])} else {myObj[d] = ((+dataSqlStatsTable[i]["BUFFER_GETS_T"]))/(+dataSqlStatsTable[i]["EXECUTIONS_T"]);} break;;
prompt  case "ROWS_PROCESSED_BA": if ((+dataSqlStatsTable[i]["EXECUTIONS_B"]) == 0 ) {myObj[d] = (+dataSqlStatsTable[i]["ROWS_PROCESSED_B"])} else {myObj[d] = ((+dataSqlStatsTable[i]["ROWS_PROCESSED_B"]))/(+dataSqlStatsTable[i]["EXECUTIONS_B"]);} break;;
prompt  case "ROWS_PROCESSED_TA": if ((+dataSqlStatsTable[i]["EXECUTIONS_T"]) == 0 ) {myObj[d] = (+dataSqlStatsTable[i]["ROWS_PROCESSED_T"])} else {myObj[d] = ((+dataSqlStatsTable[i]["ROWS_PROCESSED_T"]))/(+dataSqlStatsTable[i]["EXECUTIONS_T"]);} break;;
prompt
prompt  default: myObj[d] = dataSqlStatsTable[i][d];;
prompt  }
prompt
prompt  })
prompt  sqlStats[dataSqlStatsTable[i]["STATISTIC"]].push(myObj);;
prompt  };;
prompt
prompt  var sqlStatsTables = ["ELAPSED_TIME","CPU_TIME","USER_IO_WAIT_TIME","CONCURRENCY_WAIT_TIME","APPLICATION_WAIT_TIME","CLUSTER_WAIT_TIME","OTHER_WAIT_TIME",
prompt  ,"EXECUTIONS","BUFFER_GETS","ROWS_PROCESSED","DISK_READS","PHYSICAL_READ_REQUESTS"
prompt  ,"PHYSICAL_READ_BYTES","DIRECT_WRITES","PHYSICAL_WRITE_REQUESTS","PHYSICAL_WRITE_BYTES","IO_INTERCONNECT_BYTES","PLSQL_EXEC_TIME","JAVA_EXEC_TIME","PARSE_CALLS"
prompt  ,"FETCHES","PX_SERVERS_EXECUTIONS","END_OF_FETCH_COUNT","SORTS","LOADS","INVALIDATIONS"];;
prompt
prompt  // System Time Model
prompt  var dataSysTimeModel = d3.csvParse(csvSysTimeModel);;
prompt  dataSysTimeModel.forEach(function(d) {
prompt  d.RANK = +d.RANK;;
prompt  });;
prompt
prompt  for (i = 0, t = 0; i < dataSysTimeModel.length; i++)
prompt  {
prompt  var myObj = {};;
prompt  sqlStatsCols["SYS_TIME_MODEL"].forEach(function(d){
prompt    switch(d)
prompt      {
prompt      case "SYS_TIME_MODEL_D":
prompt      myObj[d] = dataSysTimeModel[i]["SYS_TIME_MODEL_TR"] - dataSysTimeModel[i]["SYS_TIME_MODEL_BR"];;
prompt      break;;
prompt      case "SYS_TIME_MODEL_PC":
prompt      if ((+dataSysTimeModel[i]["SYS_TIME_MODEL_BR"]) == 0 ) { if ((+dataSysTimeModel[i]["SYS_TIME_MODEL_TR"]) == 0) {myObj[d] = 0} else {myObj[d] = 1}} else {myObj[d] = ((+dataSysTimeModel[i]["SYS_TIME_MODEL_TR"]) - (+dataSysTimeModel[i]["SYS_TIME_MODEL_BR"]))/(+dataSysTimeModel[i]["SYS_TIME_MODEL_BR"]);}
prompt      break;;
prompt      default:
prompt      myObj[d] = dataSysTimeModel[i][d];;
prompt      }
prompt  })
prompt  sqlStats["SYS_TIME_MODEL"].push(myObj);;
prompt  };;
prompt
prompt  // DB Summary
prompt  var dataDbSummary = d3.csvParse(csvDbSummary);;
prompt
prompt  for (i = 0, t = 0; i < dataDbSummary.length; i++)
prompt  {
prompt  var myObj = {};;
prompt  sqlStatsCols["DB_SUMMARY"].forEach(function(d){
prompt  myObj[d] = dataDbSummary[i][d];;
prompt  })
prompt  sqlStats["DB_SUMMARY"].push(myObj);;
prompt  };;
prompt
prompt  // SQL Stats Charts
prompt  var dataSqlStatsChart = d3.csvParse(csvSqlStatsChart);;
prompt  dataSqlStatsChart.forEach(function(d) {
prompt  d.value_b = +d.value_b;;
prompt  d.value_t = +d.value_t;;
prompt  });;
prompt
prompt  var sqlStatsGroups = {
prompt  "SQL_TYPE":[{series:pointA,total:0},{series:pointB,total:0}]
prompt  ,"PARSE_CALLS":[{series:pointA,total:0},{series:pointB,total:0}]
prompt  ,"DISK_READS":[{series:pointA,total:0},{series:pointB,total:0}]
prompt  ,"DIRECT_WRITES":[{series:pointA,total:0},{series:pointB,total:0}]
prompt  ,"BUFFER_GETS":[{series:pointA,total:0},{series:pointB,total:0}]
prompt  ,"ROWS_PROCESSED":[{series:pointA,total:0},{series:pointB,total:0}]
prompt  ,"FETCHES":[{series:pointA,total:0},{series:pointB,total:0}]
prompt  ,"EXECUTIONS":[{series:pointA,total:0},{series:pointB,total:0}]
prompt  ,"PX_SERVERS_EXECUTIONS":[{series:pointA,total:0},{series:pointB,total:0}]
prompt  ,"END_OF_FETCH_COUNT":[{series:pointA,total:0},{series:pointB,total:0}]
prompt  ,"CPU_TIME":[{series:pointA,total:0},{series:pointB,total:0}]
prompt  ,"ELAPSED_TIME":[{series:pointA,total:0},{series:pointB,total:0}]
prompt  ,"APPLICATION_WAIT_TIME":[{series:pointA,total:0},{series:pointB,total:0}]
prompt  ,"CONCURRENCY_WAIT_TIME":[{series:pointA,total:0},{series:pointB,total:0}]
prompt  ,"CLUSTER_WAIT_TIME":[{series:pointA,total:0},{series:pointB,total:0}]
prompt  ,"USER_IO_WAIT_TIME":[{series:pointA,total:0},{series:pointB,total:0}]
prompt  ,"PLSQL_EXEC_TIME":[{series:pointA,total:0},{series:pointB,total:0}]
prompt  ,"JAVA_EXEC_TIME":[{series:pointA,total:0},{series:pointB,total:0}]
prompt  ,"SORTS":[{series:pointA,total:0},{series:pointB,total:0}]
prompt  ,"LOADS":[{series:pointA,total:0},{series:pointB,total:0}]
prompt  ,"INVALIDATIONS":[{series:pointA,total:0},{series:pointB,total:0}]
prompt  ,"PHYSICAL_READ_REQUESTS":[{series:pointA,total:0},{series:pointB,total:0}]
prompt  ,"PHYSICAL_READ_BYTES":[{series:pointA,total:0},{series:pointB,total:0}]
prompt  ,"PHYSICAL_WRITE_REQUESTS":[{series:pointA,total:0},{series:pointB,total:0}]
prompt  ,"PHYSICAL_WRITE_BYTES":[{series:pointA,total:0},{series:pointB,total:0}]
prompt  ,"IO_INTERCONNECT_BYTES":[{series:pointA,total:0},{series:pointB,total:0}]
prompt  };;
prompt
prompt  var sqlStatsChartDetails = [
prompt  {chartId:"SQL_TYPE",chartName:"SQL TYPE",axisName:"Count"}
prompt  ,{chartId:"EXECUTIONS",chartName:"EXECUTIONS",axisName:"Count"}
prompt  ,{chartId:"BUFFER_GETS",chartName:"BUFFER GETS",axisName:"Count"}
prompt  ,{chartId:"ROWS_PROCESSED",chartName:"ROWS PROCESSED",axisName:"Count"}
prompt  ,{chartId:"ELAPSED_TIME",chartName:"ELAPSED TIME",axisName:"Seconds"}
prompt  ,{chartId:"CPU_TIME",chartName:"CPU TIME",axisName:"Seconds"}
prompt  ,{chartId:"USER_IO_WAIT_TIME",chartName:"USER IO TIME",axisName:"Seconds"}
prompt  ,{chartId:"CONCURRENCY_WAIT_TIME",chartName:"CONCURRENCY TIME",axisName:"Seconds"}
prompt  ,{chartId:"APPLICATION_WAIT_TIME",chartName:"APPLICATION TIME",axisName:"Seconds"}
prompt  ,{chartId:"CLUSTER_WAIT_TIME",chartName:"CLUSTER TIME",axisName:"Seconds"}
prompt  ,{chartId:"DISK_READS",chartName:"DISK READS",axisName:"Count"}
prompt  ,{chartId:"DIRECT_WRITES",chartName:"DIRECT WRITES",axisName:"Count"}
prompt  ,{chartId:"PHYSICAL_READ_REQUESTS",chartName:"PHYSICAL READS",axisName:"Count"}
prompt  ,{chartId:"PHYSICAL_READ_BYTES",chartName:"PHYSICAL READ BYTES",axisName:"Bytes"}
prompt  ,{chartId:"PHYSICAL_WRITE_REQUESTS",chartName:"PHYSICAL WRITES",axisName:"Count"}
prompt  ,{chartId:"PHYSICAL_WRITE_BYTES",chartName:"PHYSICAL WRITE BYTES",axisName:"Bytes"}
prompt  ,{chartId:"IO_INTERCONNECT_BYTES",chartName:"IO INTERCONNECT BYTES",axisName:"Bytes"}
prompt  ,{chartId:"PARSE_CALLS",chartName:"PARSE CALLS",axisName:"Count"}
prompt  ,{chartId:"FETCHES",chartName:"FETCHES",axisName:"Count"}
prompt  ,{chartId:"PX_SERVERS_EXECUTIONS",chartName:"PX SERVERS EXECUTIONS",axisName:"Count"}
prompt  ,{chartId:"END_OF_FETCH_COUNT",chartName:"END OF FETCH COUNT",axisName:"Count"}
prompt  ,{chartId:"PLSQL_EXEC_TIME",chartName:"PLSQL EXEC TIME",axisName:"Seconds"}
prompt  ,{chartId:"JAVA_EXEC_TIME",chartName:"JAVA EXEC TIME",axisName:"Seconds"}
prompt  ,{chartId:"SORTS",chartName:"SORTS",axisName:"Count"}
prompt  ,{chartId:"LOADS",chartName:"LOADS",axisName:"Count"}
prompt  ,{chartId:"INVALIDATIONS",chartName:"INVALIDATIONS",axisName:"Count"}
prompt  ];;
prompt
prompt  for (i = 0, t = 0; i < dataSqlStatsChart.length; ++i)
prompt  {
prompt  sqlStatsGroups[dataSqlStatsChart[i].stat_name][0][dataSqlStatsChart[i].sql_type] = dataSqlStatsChart[i].value_b;;
prompt  sqlStatsGroups[dataSqlStatsChart[i].stat_name][0]["total"] += dataSqlStatsChart[i].value_b;;
prompt  sqlStatsGroups[dataSqlStatsChart[i].stat_name][1][dataSqlStatsChart[i].sql_type] = dataSqlStatsChart[i].value_t;;
prompt  sqlStatsGroups[dataSqlStatsChart[i].stat_name][1]["total"] += dataSqlStatsChart[i].value_t;;
prompt
prompt  if (!sqlStatsGroups[dataSqlStatsChart[i].stat_name].columns) sqlStatsGroups[dataSqlStatsChart[i].stat_name].columns = [];;
prompt  sqlStatsGroups[dataSqlStatsChart[i].stat_name].columns.push(dataSqlStatsChart[i].sql_type);;
prompt  }
prompt
prompt  // SQL Text Tables
prompt
prompt  var psv = d3.dsvFormat("!@#!");;
prompt  var dataSqlText = psv.parse(csvSqlText);;
prompt
prompt  for (i = 0, t = 0; i < dataSqlText.length; i++)
prompt  {
prompt  var myObj = {};;
prompt  sqlStatsCols["SQL_TEXT"].forEach(function(d){
prompt  myObj[d] = dataSqlText[i][d];;
prompt  })
prompt  sqlStats["SQL_TEXT"].push(myObj);;
prompt  };;
prompt
prompt  // System Stats
prompt  var dataSysStat = psv.parse(csvSysStat);;
prompt
prompt  dataSysStat.forEach(function(d) {
prompt  switch(d.UNIT)
prompt  {
prompt  case "time":
prompt  d.SYSSTAT_BL = Math.round(+d.SYSSTAT_BL * 10000 / 1000000);;
prompt  d.SYSSTAT_TR = Math.round(+d.SYSSTAT_TR * 10000 / 1000000);;
prompt  break
prompt  case "time (usec)":
prompt  d.SYSSTAT_BL = Math.round(+d.SYSSTAT_BL  / 1000000);;
prompt  d.SYSSTAT_TR = Math.round(+d.SYSSTAT_TR  / 1000000);;
prompt  break
prompt  default:
prompt  d.SYSSTAT_BL = +d.SYSSTAT_BL;;
prompt  d.SYSSTAT_TR = +d.SYSSTAT_TR;;
prompt  }
prompt  })
prompt
prompt  for (i = 0, t = 0; i < dataSysStat.length; i++)
prompt  {
prompt  var myObj = {};;
prompt
prompt  sqlStatsCols["SYS_STAT"].forEach(function(d){
prompt  switch(d)
prompt  {
prompt  case "SYSSTAT_DIFF":
prompt  myObj[d] = dataSysStat[i]["SYSSTAT_TR"] - dataSysStat[i]["SYSSTAT_BL"];;
prompt  break;;
prompt  case "SYSSTAT_PC":
prompt  if ((+dataSysStat[i]["SYSSTAT_BL"]) == 0 ) { myObj[d] = 1} else {myObj[d] = ((+dataSysStat[i]["SYSSTAT_TR"]) - (+dataSysStat[i]["SYSSTAT_BL"]))/(+dataSysStat[i]["SYSSTAT_BL"]);}
prompt  break;;
prompt  default:
prompt  myObj[d] = dataSysStat[i][d];;
prompt  }
prompt
prompt  })
prompt  sqlStats["SYS_STAT"].push(myObj);;
prompt  }
prompt
prompt  // Conditional formatting
prompt  var colorScale = d3.scaleThreshold()
prompt  .domain([-0.5,-0.3,-0.1,0.1,1])
prompt  .range([d3.interpolateGreens(0.45), d3.interpolateGreens(0.4),d3.interpolateGreens(0.3), d3.interpolateGreens(0),d3.interpolateReds(0.3), d3.interpolateReds(0.45)]);;
prompt
prompt  var colorInterpolateRed = d3.scaleSequential(d3.interpolateReds)
prompt  var colorInterpolateGreen = d3.scaleSequential(d3.interpolateGreens)
prompt
prompt  drawAllObjects(getWrapperWidth());;
prompt
prompt  </script>
spool off;
set termout on;
prompt Report is written to &file_name.
set termout off;
clear columns sql;
ttitle off;
btitle off;
repfooter off;
set linesize 78 termout on feedback 6 heading on;
whenever sqlerror continue;
