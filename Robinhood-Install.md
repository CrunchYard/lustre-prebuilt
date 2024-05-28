# Robinhood Installation

## Generally useful information
[Robinhood v3 admin documentation](https://github.com/cea-hpc/robinhood/wiki/robinhood_v3_admin_doc)

## On Lustre MDS

Install administrative tool and register a changelog reader ([Enabling Lustre v2 Changelogs](https://github.com/cea-hpc/robinhood/wiki/robinhood_v3_admin_doc#enabling-lustre-v2-changelogs))

### 1 - Get RPM
```bash 
wget https://github.com/CrunchYard/lustre-prebuilt/raw/master/robinhood-adm-3.1.7-1.x86_64.rpm
```

### 2 - Install RPM
```bash 
sudo rpm -i robinhood-adm-3.1.7-1.x86_64.rpm
```

### 3 - Register changelog reader
```bash
sudo rbh-config enable_chglogs
```

*Setting changelog event mask?*

## On Lustre Client

### 1 - Use yum to install Webserver, PHP, DB and required packages
```bash
sudo yum install -y php php-mysqlnd php-pdo php-json mariadb mariadb-server jemalloc mailx mariadb-connector-c-devel
```

### 2 - Get the RPMs
```bash
wget https://github.com/CrunchYard/lustre-prebuilt/raw/master/robinhood-adm-3.1.7-1.x86_64.rpm
wget https://github.com/CrunchYard/lustre-prebuilt/raw/master/robinhood-lustre-3.1.7-1.lustre2.15.el8.x86_64.rpm
wget https://github.com/CrunchYard/lustre-prebuilt/raw/master/robinhood-tools-3.1.7-1.lustre2.15.el8.x86_64.rpm
wget https://github.com/CrunchYard/lustre-prebuilt/raw/master/robinhood-webgui-3.1.7-1.x86_64.rpm
```

### 3 - Install the RPMs
```bash
sudo rpm -i robinhood-adm-3.1.7-1.x86_64.rpm  robinhood-lustre-3.1.7-1.lustre2.15.el8.x86_64.rpm  robinhood-tools-3.1.7-1.lustre2.15.el8.x86_64.rpm  robinhood-webgui-3.1.7-1.x86_64.rpm
```

### 4 - Set directory to where mariadb databases are mounted

Change `datadir` configuration option to where the mariadb databases are mounted.  For example, `/opt/mysql`.
```bash
vi /etc/my.cnf.d/mariadb-server.cnf
```
Ensure `/opt/mysql` is owned by mysql.mysql.
```bash
sudo chown mysql.mysql /opt/mysql
```

### 4 - Enable and start mariadb

```bash
sudo systemctl enable mariadb --now
```

### 5 - Lockdown mariadb

**Default database root password is blank.  Set to something sensible.  Answer yes to all questions.**
```bash
sudo mysql_secure_installation
```
### 6 - Create lustre database

1. **Will need to supply the identifier for the lustre filesystem (check in /etc/fstab)**
2. localhost sufficient for where robinhood command will be run.
3. **Set and remember password for next step.**
4. Use database root password from previous step.
Note that default DB name is based on the identifier, e.g. robinhood_LustreFS.
```bash
sudo rbh-config create_db
```
### 7 - Write DB password
```bash
sudo vi /etc/robinhood.d/.dbpassword
```
### 8 - Secure permissions on DB password file
```bash
sudo chmod 600 /etc/robinhood.d/.dbpassword
```

### 9 - Copy basic robinhood config file
Use `/etc/robinhood.d/templates/basic.conf` as template
**NB the config filename must match name of the lustre filesystem name**
```bash
sudo cp /etc/robinhood.d/templates/basic.conf /etc/robinhood.d/LustreFS.conf
```

### 10 - Edit basic config file

1. **Set `fs_path` to where lustre is mounted** (template has "/path/to/fs")
2. **Set `fs_type` to lustre**  (template has xfs)
3. **Set `db` to robinhood_LustreFS (refer back to previous step)** (template has rbh_test)
```bash
sudo vi /etc/robinhood.d/LustreFS.conf
```

### 11 - Initial scan
**Useful notes in the admin documentation** [Initial scan](https://github.com/cea-hpc/robinhood/wiki/robinhood_v3_admin_doc#initial-scan)
```bash
sudo robinhood --scan --once
```
*Various errors could happen here if misconfigured, e.g. CheckFS realpath: No such file or directory, Failed to connect to MySQL after 0 retries: Error: Access denied for user*

**NOTE: must find out how to increase the number of threads for the scan**

### 12 - Scan will take time!

Not too sure how long - will probably want to run it outside of busy hours.

At the end of the scan a report will be printed to the screen.  Please make a note of the total time taken and other statistics.

### 13 - Setup the systemctl service file correctly

```bash
cat <<EOF | sudo tee -a /usr/lib/systemd/system/robinhood.service

[Install]
WantedBy=multi-user.target
Alias=robinhood.service
EOF
```

### 14 - Enable and start robinhood

```bash
sudo systemctl enable robinhood --now
```

### 15 - Display stats about daemon activity

```bash
rbh-report -a
```

## Webserver on robinhood client

### 1 - Copy the config template
```bash
sudo cp -a /var/www/robinhood/config_local.php.template /var/www/robinhood/config_local.php
```

### 2 - Edit config template

**Specifically need to set "DB_NAME" (robinhood_LustreFS), "DB_USER" (robinhood), "DB_PASSWD"**
```bash
sudo vi /var/www/robinhood/config_local.php
```

### 3 - Allow port 80 traffic through the default firewall

```bash
sudo firewall-cmd --zone=public --add-port=80/tcp --permanent
```

### 4 - Configure robinhood apache file

1. Change `Alias /robinhood /var/www/robinhood/` to `Alias / /var/www/robinhood/`
2. Will also most likely need to set `Servername` to IP address of the system.
```bash
vi /etc/httpd/conf.d/robinhood.conf
```

### 6 - Enable and start the webserver
```bash
sudo systemctl enable httpd --now
```

### 7 - Standard webserver setup things

Setup authentication / access control.

Important file:
```bash
/etc/httpd/conf/httpd.conf
```

## Notes

> Required disk space is around 1KB per entry (e.g. 100GB for 100 million entries, 1TB for 1 billion entries...). This sizing is influenced by filesystems contents profile like entry name and path length, stripe width...

### If lustre not already on system
```bash
wget https://downloads.whamcloud.com/public/lustre/lustre-2.15.1/el8.6/client/RPMS/x86_64/kmod-lustre-client-2.15.1-1.el8.x86_64.rpm
wget https://downloads.whamcloud.com/public/lustre/lustre-2.15.1/el8.6/client/RPMS/x86_64/lustre-client-2.15.1-1.el8.x86_64.rpm
sudo yum --nogpgcheck -y install kmod-lustre-client-2.15.1-1.el8.x86_64.rpm lustre-client-2.15.1-1.el8.x86_64.rpm
```

### For EPEL
```bash
sudo yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
sudo yum repolist
```
