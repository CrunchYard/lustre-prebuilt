# Database tuning for robinhood

Must check memory and resource utilisation on the client machinen that is running the database.

## Database preparation
- Stop running services
  - `systemctl stop robinhood`
  - `systemctl stop mariadb`
- Completely remove mariadb-server.
  - `yum remove mariadb-server`
- Remove contents of `/var/lib/mariadb`.
  - `rm -rf /opt/mysql/*`
- Reinstall mariadb-server.
  - `yum install mariadb-server`
- Change database data path in `/etc/my.cnf.d/mariadb-server.cnf`
  - Ensure `datadir=/opt/mysql`.
- **Note - must check installed memory size on system.**  Add to `/etc/my.cnf.d/mariadb-server.cnf`
```
[mysqld]
 performance_schema
 table_open_cache=2028
 max_connections=1024
 thread_cache_size=512
 table_cache=2048
 connect_timeout=60
 key_buffer_size=512M
 query_cache_size=512M
 query_cache_limit=512M
 sort_buffer_size=512M
 read_rnd_buffer_size=1G
 tmp_table_size=1G
 max_heap_table_size=1G

 # innodb_buffer_pool_size: recommended value is 80% of physical memory
 innodb_buffer_pool_size = 50G
 #innodb_additional_mem_pool_size = 16M
 innodb_max_dirty_pages_pct = 20
 innodb_file_per_table = 1
 innodb_data_file_path = ibdata1:100M:autoextend
 innodb_write_io_threads = 32
 innodb_read_io_threads = 32
 innodb_flush_method=O_DIRECT
 innodb_io_capacity=100000
 innodb_autoinc_lock_mode = 2
 innodb_thread_concurrency = 0
 innodb_log_buffer_size = 256M
 innodb_log_file_size = 900M
 innodb_log_files_in_group = 4
 innodb_lock_wait_timeout = 120

[mysqld_safe]
  open-files-limit=2048
```
- Start the database
  - `systemctl enable mariadb --now` 
- Secure the database installation (keep a record of the root password).
  - `mysql_secure_installation`
- Reinstall the robinhood database
  - `rbh-config create_db`
- Modify the update frequency to 6 hours in `/etc/robinhood.d/LustreFS.conf` 
- Start robinhood
  - `systemctl enable robinhood --now` 
- Run robinhood scan
  - `sudo robinhood --scan --once`
