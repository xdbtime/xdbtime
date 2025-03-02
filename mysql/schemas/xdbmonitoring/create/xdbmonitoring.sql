/*
    Copyright 2016-2025 XDBTIME Taras Guliak
    All rights reserved.
    Version: 2025.02
    
    XDBMONITORING schema contains tables, stored procedures and events 
		to collect performance metrics from the Performance Schema.

	Event Scheduler and Performance Schema must be enabled on your database.
		select @@event_scheduler; 
		SET GLOBAL event_scheduler = ON;

	Perofrmance schema snapshots are created by default every 5 minutes - it is recommended for Capability performance tests.
	15 minute intervals are recommended for Production.

	Active threads are captured every 10 seconds by default. It is not recommended to enable it for production since it can write a lot of data on busy systems.

*/

DROP DATABASE IF EXISTS xdbmonitoring;

CREATE DATABASE xdbmonitoring DEFAULT CHARACTER SET utf8mb4;

USE xdbmonitoring;


CREATE TABLE tbl_db_info (
	db_name VARCHAR(128),
    app_name VARCHAR(128),
    app_version VARCHAR(128),
    data_set VARCHAR(128),
    description VARCHAR(128),
	PRIMARY KEY (db_name)
);

INSERT INTO tbl_db_info (db_name, app_name, app_version, data_set, description) 
	VALUES ('db-name','app-name','app-version','app-dataset',null);

CREATE TABLE tbl_active_thread_history (
	id BIGINT AUTO_INCREMENT NOT NULL,
	sample_time TIMESTAMP,
	thread_id BIGINT UNSIGNED,
	name VARCHAR(128),
	type VARCHAR(10),
	processlist_id BIGINT UNSIGNED,
	processlist_user VARCHAR(32),
	processlist_host VARCHAR(60),
	processlist_db VARCHAR(64),
	processlist_command VARCHAR(16),
	processlist_time BIGINT,
	processlist_state VARCHAR(64),
	processlist_info LONGTEXT,
	parent_thread_id BIGINT UNSIGNED,
	role VARCHAR(64),
	instrumented ENUM('yes','no'),
	history ENUM('yes','no'),
	connection_type VARCHAR(16),
	thread_os_id BIGINT UNSIGNED,
	PRIMARY KEY (id)
);

CREATE INDEX ix_active_thread_history_01 ON tbl_active_thread_history (sample_time);

CREATE TABLE tbl_snapshot (
	sample_id BIGINT AUTO_INCREMENT NOT NULL,
	sample_time TIMESTAMP,
	from_sample_time TIMESTAMP,
	instance_start_time TIMESTAMP,
	innodb_buffer_pool_size BIGINT,
	version VARCHAR(64),
	host_name VARCHAR(128),
    PRIMARY KEY (sample_id)
);

CREATE INDEX ix_snapshot_01 ON tbl_snapshot (sample_time);

CREATE TABLE tbl_events_statements_summary_by_digest (
	id BIGINT AUTO_INCREMENT NOT NULL,
    sample_id BIGINT,
	sample_time TIMESTAMP,
	schema_name VARCHAR(64),
	digest VARCHAR(64),
	digest_text LONGTEXT,
	count_star BIGINT UNSIGNED,
	sum_timer_wait BIGINT UNSIGNED,
	min_timer_wait BIGINT UNSIGNED,
	avg_timer_wait BIGINT UNSIGNED,
	max_timer_wait BIGINT UNSIGNED,
	sum_lock_time BIGINT UNSIGNED,
	sum_errors BIGINT UNSIGNED,
	sum_warnings BIGINT UNSIGNED,
	sum_rows_affected BIGINT UNSIGNED,
	sum_rows_sent BIGINT UNSIGNED,
	sum_rows_examined BIGINT UNSIGNED,
	sum_created_tmp_disk_tables BIGINT UNSIGNED,
	sum_created_tmp_tables BIGINT UNSIGNED,
	sum_select_full_join BIGINT UNSIGNED,
	sum_select_full_range_join BIGINT UNSIGNED,
	sum_select_range BIGINT UNSIGNED,
	sum_select_range_check BIGINT UNSIGNED,
	sum_select_scan BIGINT UNSIGNED,
	sum_sort_merge_passes BIGINT UNSIGNED,
	sum_sort_range BIGINT UNSIGNED,
	sum_sort_rows BIGINT UNSIGNED,
	sum_sort_scan BIGINT UNSIGNED,
	sum_no_index_used BIGINT UNSIGNED,
	sum_no_good_index_used BIGINT UNSIGNED,
	first_seen TIMESTAMP DEFAULT '2001-01-01 00:00:00',
	last_seen TIMESTAMP DEFAULT '2001-01-01 00:00:00',
	delta_count_star BIGINT UNSIGNED,
	delta_timer_wait BIGINT UNSIGNED,
	delta_lock_time BIGINT UNSIGNED,
	delta_errors BIGINT UNSIGNED,
	delta_warnings BIGINT UNSIGNED,
	delta_rows_affected BIGINT UNSIGNED,
	delta_rows_sent BIGINT UNSIGNED,
	delta_rows_examined BIGINT UNSIGNED,
	delta_created_tmp_disk_tables BIGINT UNSIGNED,
	delta_created_tmp_tables BIGINT UNSIGNED,
	delta_select_full_join BIGINT UNSIGNED,
	delta_select_full_range_join BIGINT UNSIGNED,
	delta_select_range BIGINT UNSIGNED,
	delta_select_range_check BIGINT UNSIGNED,
	delta_select_scan BIGINT UNSIGNED,
	delta_sort_merge_passes BIGINT UNSIGNED,
	delta_sort_range BIGINT UNSIGNED,
	delta_sort_rows BIGINT UNSIGNED,
	delta_sort_scan BIGINT UNSIGNED,
	delta_no_index_used BIGINT UNSIGNED,
	delta_no_good_index_used BIGINT UNSIGNED,
    PRIMARY KEY (id),
    KEY (sample_id, digest)
);

CREATE INDEX ix_events_statements_summary_digest_01 ON tbl_events_statements_summary_by_digest (sample_time);

CREATE TABLE tbl_events_waits_summary_global_by_event_name (
	id BIGINT AUTO_INCREMENT NOT NULL,
	sample_id BIGINT,
	sample_time TIMESTAMP,
	event_name VARCHAR(128),
	count_star BIGINT UNSIGNED,
	sum_timer_wait BIGINT UNSIGNED,
	min_timer_wait BIGINT UNSIGNED,
	avg_timer_wait BIGINT UNSIGNED,
	max_timer_wait BIGINT UNSIGNED,
    delta_count_star BIGINT UNSIGNED,
    delta_timer_wait BIGINT UNSIGNED,
	PRIMARY KEY (id)
);

CREATE INDEX ix_events_waits_summary_01 ON tbl_events_waits_summary_global_by_event_name (sample_id, event_name);
CREATE INDEX ix_events_waits_summary_02 ON tbl_events_waits_summary_global_by_event_name (sample_time);

CREATE TABLE tbl_events_stages_summary_global_by_event_name (
	id BIGINT AUTO_INCREMENT NOT NULL,
	sample_id BIGINT,
	sample_time TIMESTAMP,
	event_name VARCHAR(128),
	count_star BIGINT UNSIGNED,
	sum_timer_wait BIGINT UNSIGNED,
	min_timer_wait BIGINT UNSIGNED,
	avg_timer_wait BIGINT UNSIGNED,
	max_timer_wait BIGINT UNSIGNED,
    delta_count_star BIGINT UNSIGNED,
    delta_timer_wait BIGINT UNSIGNED,
	PRIMARY KEY (id)
);

CREATE INDEX ix_events_stages_summary_02 ON tbl_events_stages_summary_global_by_event_name (sample_time);
CREATE INDEX ix_events_stages_summary_01 ON xdbmonitoring.tbl_events_stages_summary_global_by_event_name (sample_id, event_name);

CREATE TABLE tbl_events_statements_summary_global_by_event_name (
	id BIGINT AUTO_INCREMENT NOT NULL,
	sample_id BIGINT,
	sample_time TIMESTAMP,
	event_name VARCHAR(128),
	count_star BIGINT UNSIGNED,
	sum_timer_wait BIGINT UNSIGNED,
	min_timer_wait BIGINT UNSIGNED,
	avg_timer_wait BIGINT UNSIGNED,
	max_timer_wait BIGINT UNSIGNED,
	sum_lock_time BIGINT UNSIGNED,
	sum_errors BIGINT UNSIGNED,
	sum_warnings BIGINT UNSIGNED,
	sum_rows_affected BIGINT UNSIGNED,
	sum_rows_sent BIGINT UNSIGNED,
	sum_rows_examined BIGINT UNSIGNED,
	sum_created_tmp_disk_tables BIGINT UNSIGNED,
	sum_created_tmp_tables BIGINT UNSIGNED,
	sum_select_full_join BIGINT UNSIGNED,
	sum_select_full_range_join BIGINT UNSIGNED,
	sum_select_range BIGINT UNSIGNED,
	sum_select_range_check BIGINT UNSIGNED,
	sum_select_scan BIGINT UNSIGNED,
	sum_sort_merge_passes BIGINT UNSIGNED,
	sum_sort_range BIGINT UNSIGNED,
	sum_sort_rows BIGINT UNSIGNED,
	sum_sort_scan BIGINT UNSIGNED,
	sum_no_index_used BIGINT UNSIGNED,
	sum_no_good_index_used BIGINT UNSIGNED,
    delta_count_star BIGINT UNSIGNED,
    delta_timer_wait BIGINT UNSIGNED,
	PRIMARY KEY (id)
);

CREATE INDEX ix_events_statements_summary_01 ON xdbmonitoring.tbl_events_statements_summary_global_by_event_name (sample_id, event_name);
CREATE INDEX ix_events_statements_summary_02 ON tbl_events_statements_summary_global_by_event_name (sample_time);

CREATE TABLE tbl_file_summary_by_event_name (
	id BIGINT AUTO_INCREMENT NOT NULL,
	sample_id BIGINT,
	sample_time TIMESTAMP,
	event_name VARCHAR(128),
	count_star BIGINT UNSIGNED,
	sum_timer_wait BIGINT UNSIGNED,
	min_timer_wait BIGINT UNSIGNED,
	avg_timer_wait BIGINT UNSIGNED,
	max_timer_wait BIGINT UNSIGNED,
	count_read BIGINT UNSIGNED,
	sum_timer_read BIGINT UNSIGNED,
	min_timer_read BIGINT UNSIGNED,
	avg_timer_read BIGINT UNSIGNED,
	max_timer_read BIGINT UNSIGNED,
	sum_number_of_bytes_read BIGINT,
	count_write BIGINT UNSIGNED,
	sum_timer_write BIGINT UNSIGNED,
	min_timer_write BIGINT UNSIGNED,
	avg_timer_write BIGINT UNSIGNED,
	max_timer_write BIGINT UNSIGNED,
	sum_number_of_bytes_write BIGINT,
	count_misc BIGINT UNSIGNED,
	sum_timer_misc BIGINT UNSIGNED,
	min_timer_misc BIGINT UNSIGNED,
	avg_timer_misc BIGINT UNSIGNED,
	max_timer_misc BIGINT UNSIGNED,
	PRIMARY KEY (id)
);

CREATE INDEX ix_file_summary_01 ON tbl_file_summary_by_event_name (sample_time);

CREATE TABLE tbl_digest_text (
	id BIGINT AUTO_INCREMENT NOT NULL,
	sample_id BIGINT,
	sample_time TIMESTAMP,
	digest VARCHAR(64),
	digest_text LONGTEXT,
	PRIMARY KEY (id),
    KEY (digest)
);

CREATE TABLE tbl_global_status (
	id BIGINT AUTO_INCREMENT NOT NULL,
	sample_id BIGINT,
	sample_time TIMESTAMP,
	variable_name VARCHAR(64) ,
	variable_value VARCHAR(1024),
	PRIMARY KEY (id)
);

CREATE INDEX ix_global_status_01 ON tbl_global_status (sample_time);

CREATE TABLE tbl_aggregated_digest_stats (
  id BIGINT AUTO_INCREMENT NOT NULL,
  digest_type VARCHAR(64),
  schema_name_t VARCHAR(64),
  digest_t VARCHAR(64),
  count_star_t BIGINT UNSIGNED,
  timer_wait_t BIGINT UNSIGNED,
  lock_time_t BIGINT UNSIGNED,
  errors_t BIGINT UNSIGNED,
  warnings_t BIGINT UNSIGNED,
  rows_affected_t BIGINT UNSIGNED,
  rows_sent_t BIGINT UNSIGNED,
  rows_examined_t BIGINT UNSIGNED,
  created_tmp_disk_tables_t BIGINT UNSIGNED,
  created_tmp_tables_t BIGINT UNSIGNED,
  select_full_join_t BIGINT UNSIGNED,
  select_full_range_join_t BIGINT UNSIGNED,
  select_range_t BIGINT UNSIGNED,
  select_range_check_t BIGINT UNSIGNED,
  select_scan_t BIGINT UNSIGNED,
  sort_merge_passes_t BIGINT UNSIGNED,
  sort_range_t BIGINT UNSIGNED,
  sort_rows_t BIGINT UNSIGNED,
  sort_scan_t BIGINT UNSIGNED,
  no_index_used_t BIGINT UNSIGNED,
  no_good_index_used_t BIGINT UNSIGNED,
  schema_name_b VARCHAR(64),
  digest_b VARCHAR(64),
  count_star_b BIGINT UNSIGNED,
  timer_wait_b BIGINT UNSIGNED,
  lock_time_b BIGINT UNSIGNED,
  errors_b BIGINT UNSIGNED,
  warnings_b BIGINT UNSIGNED,
  rows_affected_b BIGINT UNSIGNED,
  rows_sent_b BIGINT UNSIGNED,
  rows_examined_b BIGINT UNSIGNED,
  created_tmp_disk_tables_b BIGINT UNSIGNED,
  created_tmp_tables_b BIGINT UNSIGNED,
  select_full_join_b BIGINT UNSIGNED,
  select_full_range_join_b BIGINT UNSIGNED,
  select_range_b BIGINT UNSIGNED,
  select_range_check_b BIGINT UNSIGNED,
  select_scan_b BIGINT UNSIGNED,
  sort_merge_passes_b BIGINT UNSIGNED,
  sort_range_b BIGINT UNSIGNED,
  sort_rows_b BIGINT UNSIGNED,
  sort_scan_b BIGINT UNSIGNED,
  no_index_used_b BIGINT UNSIGNED,
  no_good_index_used_b BIGINT UNSIGNED,
  PRIMARY KEY (id)
);

-- Users AND Permissions

CREATE USER IF NOT EXISTS 'xdbmo'@'%' IDENTIFIED BY 'mypassword';
GRANT SELECT ON `xdbmonitoring`.* TO 'xdbmo'@'%';
GRANT INSERT, DELETE, UPDATE ON `xdbmonitoring`.`tbl_aggregated_digest_stats` TO 'xdbmo'@'%';

-- Stored Procedures

delimiter //

DROP PROCEDURE IF EXISTS pr_active_thread_capture;
//

CREATE DEFINER=`root`@`%` PROCEDURE `pr_active_thread_capture`()
BEGIN

	START TRANSACTION;

	INSERT INTO tbl_active_thread_history
	(
		sample_time,
		thread_id,
		name,
		type,
		processlist_id,
		processlist_user,
		processlist_host,
		processlist_db,
		processlist_command,
		processlist_time,
		processlist_state,
		processlist_info,
		parent_thread_id,
		role,
		instrumented,
		history,
		connection_type,
		thread_os_id
	)
	SELECT
		current_timestamp(),
		thread_id,
		name,
		type,
		processlist_id,
		processlist_user,
		processlist_host,
		processlist_db,
		processlist_command,
		processlist_time,
		processlist_state,
		processlist_info,
		parent_thread_id,
		role,
		instrumented,
		history,
		connection_type,
		thread_os_id
	FROM performance_schema.threads s 
		WHERE processlist_state IS NOT NULL 
			AND processlist_state NOT IN ('Waiting ON empty queue','Waiting for next activation') AND name NOT IN ('thread/sql/event_scheduler','thread/sql/event_worker','thread/sql/compress_gtid_table');

	COMMIT;

	END;
	//
	
	delimiter //
	DROP PROCEDURE IF EXISTS pr_capture_snapshot;
	//
	CREATE DEFINER=`root`@`%` PROCEDURE `pr_capture_snapshot`()
	BEGIN
		
		DECLARE l_date DATETIME DEFAULT SYSDATE();
		DECLARE l_current_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP();
		DECLARE l_sample_id BIGINT;
		DECLARE l_previous_sample_id BIGINT;
		DECLARE l_max_sample_id BIGINT;
		DECLARE l_max_sample_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP();
		DECLARE l_max_instance_start_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP();

		START TRANSACTION;
		
		SELECT max(sample_id), max(sample_time), max(instance_start_time)
		INTO l_max_sample_id, l_max_sample_time, l_max_instance_start_time
		FROM xdbmonitoring.tbl_snapshot;

		INSERT INTO xdbmonitoring.tbl_snapshot
		(
			sample_time,
			host_name,
			instance_start_time,
			innodb_buffer_pool_size,
			version,
			from_sample_time
		)
		SELECT
			l_current_timestamp,
			@@hostname,
			now() - INTERVAL variable_value SECOND,
			@@innodb_buffer_pool_size,
			@@version,
			IFNULL(l_max_sample_time,now() - INTERVAL variable_value SECOND)
		FROM performance_schema.global_status
		WHERE variable_name='Uptime';

		SELECT LAST_INSERT_ID() 
		INTO l_sample_id;
		
		SELECT count(*)*IFNULL(l_max_sample_id,0) 
			INTO l_previous_sample_id 
		FROM xdbmonitoring.tbl_snapshot 
			WHERE sample_id = l_sample_id 
				AND instance_start_time = l_max_instance_start_time;
		
		INSERT INTO tbl_events_statements_summary_by_digest (
			sample_id,
			sample_time,
			schema_name,
			digest,
			count_star,
			sum_timer_wait,
			min_timer_wait,
			avg_timer_wait,
			max_timer_wait,
			sum_lock_time,
			sum_errors,
			sum_warnings,
			sum_rows_affected,
			sum_rows_sent,
			sum_rows_examined,
			sum_created_tmp_disk_tables,
			sum_created_tmp_tables,
			sum_select_full_join,
			sum_select_full_range_join,
			sum_select_range,
			sum_select_range_check,
			sum_select_scan,
			sum_sort_merge_passes,
			sum_sort_range,
			sum_sort_rows,
			sum_sort_scan,
			sum_no_index_used,
			sum_no_good_index_used,
			first_seen,
			last_seen,
			delta_count_star,
			delta_timer_wait,
			delta_lock_time,
			delta_errors,
			delta_warnings,
			delta_rows_affected,
			delta_rows_sent,
			delta_rows_examined,
			delta_created_tmp_disk_tables,
			delta_created_tmp_tables,
			delta_select_full_join,
			delta_select_full_range_join,
			delta_select_range,
			delta_select_range_check,
			delta_select_scan,
			delta_sort_merge_passes,
			delta_sort_range,
			delta_sort_rows,
			delta_sort_scan,
			delta_no_index_used,
			delta_no_good_index_used)
		SELECT
			l_sample_id,
			l_current_timestamp,
			b.schema_name,
			b.digest,
			b.count_star,
			b.sum_timer_wait,
			b.min_timer_wait,
			b.avg_timer_wait,
			b.max_timer_wait,
			b.sum_lock_time,
			b.sum_errors,
			b.sum_warnings,
			b.sum_rows_affected,
			b.sum_rows_sent,
			b.sum_rows_examined,
			b.sum_created_tmp_disk_tables,
			b.sum_created_tmp_tables,
			b.sum_select_full_join,
			b.sum_select_full_range_join,
			b.sum_select_range,
			b.sum_select_range_check,
			b.sum_select_scan,
			b.sum_sort_merge_passes,
			b.sum_sort_range,
			b.sum_sort_rows,
			b.sum_sort_scan,
			b.sum_no_index_used,
			b.sum_no_good_index_used,
			b.first_seen,
			b.last_seen,
			IFNULL(b.count_star,0) - IFNULL(a.count_star,0) delta_count_star,
			IFNULL(b.sum_timer_wait,0) - IFNULL(a.sum_timer_wait,0) delta_timer_wait,
			IFNULL(b.sum_lock_time,0) - IFNULL(a.sum_lock_time,0) delta_lock_time,
			IFNULL(b.sum_errors,0) - IFNULL(a.sum_errors,0) delta_errors,
			IFNULL(b.sum_warnings,0) - IFNULL(a.sum_warnings,0) delta_warnings,
			IFNULL(b.sum_rows_affected,0) - IFNULL(a.sum_rows_affected,0) delta_rows_affected,
			IFNULL(b.sum_rows_sent,0) - IFNULL(a.sum_rows_sent,0) delta_rows_sent,
			IFNULL(b.sum_rows_examined,0) - IFNULL(a.sum_rows_examined,0) delta_rows_examined,
			IFNULL(b.sum_created_tmp_disk_tables,0) - IFNULL(a.sum_created_tmp_disk_tables,0) delta_created_tmp_disk_tables,
			IFNULL(b.sum_created_tmp_tables,0) - IFNULL(a.sum_created_tmp_tables,0) delta_created_tmp_tables,
			IFNULL(b.sum_select_full_join,0) - IFNULL(a.sum_select_full_join,0) delta_select_full_join,
			IFNULL(b.sum_select_full_range_join,0) - IFNULL(a.sum_select_full_range_join,0) delta_select_full_range_join,
			IFNULL(b.sum_select_range,0) - IFNULL(a.sum_select_range,0) delta_select_range,
			IFNULL(b.sum_select_range_check,0) - IFNULL(a.sum_select_range_check,0) delta_select_range_check,
			IFNULL(b.sum_select_scan,0) - IFNULL(a.sum_select_scan,0) delta_select_scan,
			IFNULL(b.sum_sort_merge_passes,0) - IFNULL(a.sum_sort_merge_passes,0) delta_sort_merge_passes,
			IFNULL(b.sum_sort_range,0) - IFNULL(a.sum_sort_range,0) delta_sort_range,
			IFNULL(b.sum_sort_rows,0) - IFNULL(a.sum_sort_rows,0) delta_sort_rows,
			IFNULL(b.sum_sort_scan,0) - IFNULL(a.sum_sort_scan,0) delta_sort_scan,
			IFNULL(b.sum_no_index_used,0) - IFNULL(a.sum_no_index_used,0) delta_no_index_used,
			IFNULL(b.sum_no_good_index_used,0) - IFNULL(a.sum_no_good_index_used,0) delta_no_good_index_used
		FROM (SELECT * FROM performance_schema.events_statements_summary_by_digest WHERE count_star>0) AS b
			LEFT JOIN tbl_events_statements_summary_by_digest AS a ON a.sample_id = l_previous_sample_id AND a.digest = b.digest AND IFNULL(a.schema_name,'d1f2l3t4') = IFNULL(b.schema_name,'d1f2l3t4');
		
		INSERT INTO tbl_events_waits_summary_global_by_event_name 
		(
			sample_id,
			sample_time,
			event_name,
			count_star,
			sum_timer_wait,
			min_timer_wait,
			avg_timer_wait,
			max_timer_wait,
			delta_count_star,
			delta_timer_wait
		)
		SELECT
			l_sample_id,
			l_current_timestamp,
			b.event_name,
			b.count_star,
			b.sum_timer_wait,
			b.min_timer_wait,
			b.avg_timer_wait,
			b.max_timer_wait,
			IFNULL(b.count_star,0) - IFNULL(a.count_star,0) delta_count_star,
			IFNULL(b.sum_timer_wait,0) - IFNULL(a.sum_timer_wait,0) delta_timer_wait
		FROM performance_schema.events_waits_summary_global_by_event_name b
		LEFT JOIN tbl_events_waits_summary_global_by_event_name AS a ON a.sample_id = l_previous_sample_id AND a.event_name = b.event_name
		WHERE b.count_star>0 OR b.sum_timer_wait>0;
		
		
		INSERT INTO tbl_events_stages_summary_global_by_event_name 
		(
			sample_id,
			sample_time,
			event_name,
			count_star,
			sum_timer_wait,
			min_timer_wait,
			avg_timer_wait,
			max_timer_wait,
			delta_count_star,
			delta_timer_wait
		)
		SELECT
			l_sample_id,
			l_current_timestamp,
			b.event_name,
			b.count_star,
			b.sum_timer_wait,
			b.min_timer_wait,
			b.avg_timer_wait,
			b.max_timer_wait,
			IFNULL(b.count_star,0) - IFNULL(a.count_star,0) delta_count_star,
			IFNULL(b.sum_timer_wait,0) - IFNULL(a.sum_timer_wait,0) delta_timer_wait
		FROM performance_schema.events_stages_summary_global_by_event_name b
			LEFT JOIN tbl_events_stages_summary_global_by_event_name AS a ON a.sample_id = l_previous_sample_id AND a.event_name = b.event_name
				WHERE b.count_star>0 OR b.sum_timer_wait>0;
		
		INSERT INTO tbl_file_summary_by_event_name 
		(
			sample_id,
			sample_time,
			event_name,
			count_star,
			sum_timer_wait,
			min_timer_wait,
			avg_timer_wait,
			max_timer_wait,
			count_read,
			sum_timer_read,
			min_timer_read,
			avg_timer_read,
			max_timer_read,
			sum_number_of_bytes_read,
			count_write,
			sum_timer_write,
			min_timer_write,
			avg_timer_write,
			max_timer_write,
			sum_number_of_bytes_write,
			count_misc,
			sum_timer_misc,
			min_timer_misc,
			avg_timer_misc,
			max_timer_misc
		)
		SELECT
			l_sample_id,
			l_current_timestamp,
			event_name,
			count_star,
			sum_timer_wait,
			min_timer_wait,
			avg_timer_wait,
			max_timer_wait,
			count_read,
			sum_timer_read,
			min_timer_read,
			avg_timer_read,
			max_timer_read,
			sum_number_of_bytes_read,
			count_write,
			sum_timer_write,
			min_timer_write,
			avg_timer_write,
			max_timer_write,
			sum_number_of_bytes_write,
			count_misc,
			sum_timer_misc,
			min_timer_misc,
			avg_timer_misc,
			max_timer_misc
		FROM performance_schema.file_summary_by_event_name
			WHERE count_star>0 OR sum_timer_wait>0;



		INSERT INTO tbl_events_statements_summary_global_by_event_name 
		(
			sample_id,
			sample_time,
			event_name,
			count_star,
			sum_timer_wait,
			min_timer_wait,
			avg_timer_wait,
			max_timer_wait,
			sum_lock_time,
			sum_errors,
			sum_warnings,
			sum_rows_affected,
			sum_rows_sent,
			sum_rows_examined,
			sum_created_tmp_disk_tables,
			sum_created_tmp_tables,
			sum_select_full_join,
			sum_select_full_range_join,
			sum_select_range,
			sum_select_range_check,
			sum_select_scan,
			sum_sort_merge_passes,
			sum_sort_range,
			sum_sort_rows,
			sum_sort_scan,
			sum_no_index_used,
			sum_no_good_index_used,
			delta_count_star,
			delta_timer_wait
		)
		SELECT
			l_sample_id,
			l_current_timestamp,
			b.event_name,
			b.count_star,
			b.sum_timer_wait,
			b.min_timer_wait,
			b.avg_timer_wait,
			b.max_timer_wait,
			b.sum_lock_time,
			b.sum_errors,
			b.sum_warnings,
			b.sum_rows_affected,
			b.sum_rows_sent,
			b.sum_rows_examined,
			b.sum_created_tmp_disk_tables,
			b.sum_created_tmp_tables,
			b.sum_select_full_join,
			b.sum_select_full_range_join,
			b.sum_select_range,
			b.sum_select_range_check,
			b.sum_select_scan,
			b.sum_sort_merge_passes,
			b.sum_sort_range,
			b.sum_sort_rows,
			b.sum_sort_scan,
			b.sum_no_index_used,
			b.sum_no_good_index_used,
			IFNULL(b.count_star,0) - IFNULL(a.count_star,0) delta_count_star,
			IFNULL(b.sum_timer_wait,0) - IFNULL(a.sum_timer_wait,0) delta_timer_wait
		FROM performance_schema.events_statements_summary_global_by_event_name b
			LEFT JOIN tbl_events_statements_summary_global_by_event_name AS a ON a.sample_id = l_previous_sample_id AND a.event_name = b.event_name
			WHERE b.count_star>0 OR b.sum_timer_wait>0;

		INSERT INTO tbl_digest_text 
		(
			sample_id,
			sample_time,
			digest,
			digest_text
		)
		SELECT
			l_sample_id,
			l_current_timestamp,
			digest,
			digest_text
		FROM performance_schema.events_statements_summary_by_digest a
			WHERE NOT EXISTS (SELECT 1 FROM tbl_digest_text b WHERE a.digest=b.digest);

		INSERT INTO tbl_global_status 
		(
			sample_id,
			sample_time,
			variable_name,
			variable_value
		)
		SELECT
			l_sample_id,
			l_current_timestamp,
			variable_name,
			variable_value
		FROM performance_schema.global_status;

	COMMIT;

END;
//

delimiter //

DROP PROCEDURE IF EXISTS pr_xdbmonitoring_housekeeping;
//

CREATE DEFINER=`root`@`%` PROCEDURE `pr_xdbmonitoring_housekeeping`(IN p_housekeeping_interval_days INT)
BEGIN

	DELETE FROM tbl_active_thread_history WHERE sample_time < DATE_ADD(SYSDATE(),INTERVAL -1 * p_housekeeping_interval_days DAY);
	DELETE FROM tbl_events_stages_summary_global_by_event_name WHERE sample_time < DATE_ADD(SYSDATE(),INTERVAL -1 * p_housekeeping_interval_days DAY);
	DELETE FROM tbl_events_statements_summary_by_digest WHERE sample_time < DATE_ADD(SYSDATE(),INTERVAL -1 * p_housekeeping_interval_days DAY);
	DELETE FROM tbl_events_statements_summary_global_by_event_name WHERE sample_time < DATE_ADD(SYSDATE(),INTERVAL -1 * p_housekeeping_interval_days DAY);
	DELETE FROM tbl_events_waits_summary_global_by_event_name WHERE sample_time < DATE_ADD(SYSDATE(),INTERVAL -1 * p_housekeeping_interval_days DAY);
	DELETE FROM tbl_file_summary_by_event_name WHERE sample_time < DATE_ADD(SYSDATE(),INTERVAL -1 * p_housekeeping_interval_days DAY);
	DELETE FROM tbl_global_status WHERE sample_time < DATE_ADD(SYSDATE(),INTERVAL -1 * p_housekeeping_interval_days DAY);
	DELETE FROM tbl_snapshot WHERE sample_time < DATE_ADD(SYSDATE(),INTERVAL -1 * p_housekeeping_interval_days DAY);

COMMIT;

end;
//

delimiter ;

CREATE EVENT ev_capture_active_threads
ON SCHEDULE EVERY 10 SECOND STARTS '2022-01-01 00:00:00' ENDS CURRENT_TIMESTAMP + INTERVAL 365 YEAR
ON COMPLETION NOT PRESERVE
ENABLE
DO
   CALL pr_active_thread_capture();

CREATE EVENT ev_capture_snapshot
ON SCHEDULE EVERY 5 MINUTE STARTS '2022-01-01 00:00:00' ENDS CURRENT_TIMESTAMP + INTERVAL 365 YEAR
ON COMPLETION NOT PRESERVE
ENABLE
DO
  CALL pr_capture_snapshot();

CREATE EVENT ev_xdbmonitoring_housekeeping
ON SCHEDULE EVERY 1 DAY STARTS '2022-01-01 00:05:00' ENDS CURRENT_TIMESTAMP + INTERVAL 365 YEAR
ON COMPLETION NOT PRESERVE
ENABLE
DO
  CALL pr_xdbmonitoring_housekeeping(14);
