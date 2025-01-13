# Robinhood Upgrade from 3.1.7 to 3.2.0

### 1 - Stop the running robinhood
```bash
systemctl stop robinhood
```

### 2 - Get the RPMs
```bash
wget https://github.com/CrunchYard/lustre-prebuilt/raw/master/3.2.0/robinhood-adm-3.2.0-1.x86_64.rpm
wget https://github.com/CrunchYard/lustre-prebuilt/raw/master/3.2.0/robinhood-lustre-3.2.0-1.lustre2.15.el8.x86_64.rpm
wget https://github.com/CrunchYard/lustre-prebuilt/raw/master/3.2.0/robinhood-tools-3.2.0-1.lustre2.15.el8.x86_64.rpm
wget https://github.com/CrunchYard/lustre-prebuilt/raw/master/3.2.0/robinhood-webgui-3.2.0-1.x86_64.rpm
```

### 3 - Install the RPMs
```bash
sudo rpm -Uvh robinhood-adm-3.2.0-1.x86_64.rpm  robinhood-lustre-3.2.0-1.lustre2.15.el8.x86_64.rpm  robinhood-tools-3.2.0-1.lustre2.15.el8.x86_64.rpm  robinhood-webgui-3.2.0-1.x86_64.rpm
```

### 4 - Recreate robinhood database

** Note: Will require the root admin password for mariadb/mysql **

```bash
sudo rbh-config empty_db robinhood_lustre
````
** NB: Will need to supply database name, access for localhost, and use the existing robinhood database password. **

```bash
sudo rbh-config create_db
```

### 5 - Update robinhood config file

```bash
sudo vi /etc/robinhood.d/LustreFS.conf
```

```bash
update_rules {
    ignore { last_mod < 10m }
    ignore { last_mod > 1d }

    rule default {
        condition = true; # apply to all entries (except above exclusions)
    }
}

# run every 12h
update_trigger {
    trigger_on = scheduled;
    check_interval = 12h;
}
```

### 6 - Start robinhood
```bash
systemctl start robinhood
```

### 7 - Initial scan
```bash
sudo robinhood --scan --once
```
