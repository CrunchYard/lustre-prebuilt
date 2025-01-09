# Robinhood Installation

## Generally useful information
[Robinhood v3 admin documentation](https://github.com/cea-hpc/robinhood/wiki/robinhood_v3_admin_doc)

## On Lustre MDS

Install administrative tool and register a changelog reader ([Enabling Lustre v2 Changelogs](https://github.com/cea-hpc/robinhood/wiki/robinhood_v3_admin_doc#enabling-lustre-v2-changelogs))

### 1 - Get RPM
```bash 
wget https://github.com/CrunchYard/lustre-prebuilt/raw/master/robinhood-adm-3.2.0-1.x86_64.rpm
```

### 2 - Install RPM
```bash 
sudo rpm -i robinhood-adm-3.2.0-1.x86_64.rpm
```

### 3 - Register changelog reader
```bash
sudo rbh-config enable_chglogs
```

### 4 - Confirm the name of the changelog reader
Make a note of this for the robinhood client configuration file.
```bash
sudo lctl get_param mdd.*.changelog_users
```

*Setting changelog event mask?*

## On Lustre Client

### 1 - Use yum to install Webserver, PHP, DB and required packages
```bash
sudo yum install -y php php-mysqlnd php-pdo php-json mariadb mariadb-server jemalloc mailx mariadb-connector-c-devel
```

### 2 - Get the RPMs
```bash
wget https://github.com/CrunchYard/lustre-prebuilt/raw/master/robinhood-adm-3.2.0-1.x86_64.rpm
wget https://github.com/CrunchYard/lustre-prebuilt/raw/master/robinhood-lustre-3.2.0-1.lustre2.15.el8.x86_64.rpm
wget https://github.com/CrunchYard/lustre-prebuilt/raw/master/robinhood-tools-3.2.0-1.lustre2.15.el8.x86_64.rpm
wget https://github.com/CrunchYard/lustre-prebuilt/raw/master/robinhood-webgui-3.2.0-1.x86_64.rpm
```

### 3 - Install the RPMs
```bash
sudo rpm -i robinhood-adm-3.2.0-1.x86_64.rpm  robinhood-lustre-3.2.0-1.lustre2.15.el8.x86_64.rpm  robinhood-tools-3.2.0-1.lustre2.15.el8.x86_64.rpm  robinhood-webgui-3.2.0-1.x86_64.rpm
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

### 5 - Enable and start mariadb

```bash
sudo systemctl enable mariadb --now
```

### 6 - Lockdown mariadb

**Default database root password is blank.  Set to something sensible.  Answer yes to all questions.**
```bash
sudo mysql_secure_installation
```
### 7 - Create lustre database

1. **Will need to supply the identifier for the lustre filesystem (check in /etc/fstab)**
2. localhost sufficient for where robinhood command will be run.
3. **Set and remember password for next step.**
4. Use database root password from previous step.
Note that default DB name is based on the identifier, e.g. robinhood_LustreFS.
```bash
sudo rbh-config create_db
```
### 8 - Write DB password
```bash
sudo vi /etc/robinhood.d/.dbpassword
```
### 9 - Secure permissions on DB password file
```bash
sudo chmod 600 /etc/robinhood.d/.dbpassword
```

### 10 - Copy basic robinhood config file
Use `/etc/robinhood.d/templates/basic.conf` as template
**NB the config filename must match name of the lustre filesystem name**
```bash
sudo cp /etc/robinhood.d/templates/basic.conf /etc/robinhood.d/LustreFS.conf
```

### 11 - Edit basic config file

1. **Set `fs_path` to where lustre is mounted** (template has "/path/to/fs")
2. **Set `fs_type` to lustre**  (template has xfs)
3. **Set `db` to robinhood_LustreFS (refer back to previous step)** (template has rbh_test)
4. **Set `reader_id` to whatever changelog reader was created on the MDS (see previous)**
5. **Add entry to reduce log verbosity**
   ```
   Log {
    # Log verbosity level
    # Possible values are: CRIT, MAJOR, EVENT, VERB, DEBUG, FULL
    debug_level = MAJOR;
   }
```bash
sudo vi /etc/robinhood.d/LustreFS.conf
```

### 12 - Initial scan
**Useful notes in the admin documentation** [Initial scan](https://github.com/cea-hpc/robinhood/wiki/robinhood_v3_admin_doc#initial-scan)
```bash
sudo robinhood --scan --once
```
*Various errors could happen here if misconfigured, e.g. CheckFS realpath: No such file or directory, Failed to connect to MySQL after 0 retries: Error: Access denied for user*

**NOTE: must find out how to increase the number of threads for the scan**

### 13 - Scan will take time!

Not too sure how long - will probably want to run it outside of busy hours.

At the end of the scan a report will be printed to the screen.  Please make a note of the total time taken and other statistics.

### 14 - Setup the systemctl service file correctly

```bash
cat <<EOF | sudo tee -a /usr/lib/systemd/system/robinhood.service

[Install]
WantedBy=multi-user.target
Alias=robinhood.service
EOF
```

### 15 - Ensure robinhood is configured to read Lustre changelogs

Verify that `RBH_OPT` includes `"--readlog"` in `/etc/sysconfig/robinhood`.

### 16 - Enable and start robinhood

```bash
sudo systemctl enable robinhood --now
```

### 17 - Display stats about daemon activity

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

### 5 - Enable and start the webserver
```bash
sudo systemctl enable httpd --now
```

### 6 - Standard webserver setup things

Setup authentication / access control and SSL.

For access control only for user called `admin`:

First create an `htpasswd` file:

```bash
sudo htpasswd -c /etc/httpd/conf/passwd admin
```

Will be prompted to enter the password for user `admin` and to asked to re-enter it.

Next edit `/etc/httpd/conf.d/robinhood.conf` and replace contents with the following (not forgetting to change ServerName to the FQDN of the host):
```
<VirtualHost *:80>
# NB: Must edit the following line!
ServerName localhost
DocumentRoot /var/www/

Alias / /var/www/robinhood/
<Directory "/var/www/robinhood">
  AuthType Basic
  AuthName "Restricted"
  AuthBasicProvider file
  AuthUserFile "/etc/httpd/conf/passwd"
  Require user admin
</Directory>

</VirtualHost>
```

For access control and SSL:

Create `htpasswd` file if not already done (see previous).

Will first need to obtain the SSL certificate files - both the cert and the key.  Suggestion is to place these in `/etc/httpd/conf`.  Ensure file permissions are appropriate, ownership would need to be `httpd`.

Edit `/etc/httpd/conf/httpd.conf` and comment out `Listen 80`.

Next edit `/etc/httpd/conf.d/robinhood.conf` and replace contents with the following (not forgetting to change ServerName to the FQDN of the host):

```
LoadModule ssl_module modules/mod_ssl.so

Listen 443

<VirtualHost *:443>
  # NB: Must edit the following line!
  ServerName localhost
  SSLEngine on
  SSLCertificateFile "/etc/httpd/conf/www.example.com.cert"
  SSLCertificateKeyFile "/etc/httpd/conf/www.example.com.key"
  DocumentRoot /var/www/

  Alias / /var/www/robinhood/
  <Directory "/var/www/robinhood">
    AuthType Basic
    AuthName "Restricted"
    AuthBasicProvider file
    AuthUserFile "/etc/httpd/conf/passwd"
    Require user admin
  </Directory>
</VirtualHost>
```


## Additional Notes

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
