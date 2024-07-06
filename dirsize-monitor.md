# Directory Size Monitor with RobinHood

## sudo to root

The following steps will need to be undertaken as the root user.

## Create a Configuration File:

Create a text file named `/usr/local/etc/dir_list.conf` with a list of directories to track. For example:

```
/path/to/first_directory
/path/to/second_directory
/path/to/third_directory
```

## Create the Bash Script:

Create the script `/usr/local/bin/track_dir_size.sh` and insert the following (feel free to change the log file location).

```bash
#!/bin/bash
  
# Configuration file containing the list of directories
CONFIG_FILE="/usr/local/etc/dir_list.conf"

# Log file to store the size data
LOG_FILE="/var/log/dir_size.log"

# Get the current date and time
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

# Read directories from the configuration file and track their sizes
while IFS= read -r DIRECTORY; do
    if [ -d "$DIRECTORY" ]; then
        # Get the size of the directory
        DIR_SIZE=$(rbh-du -b "$DIRECTORY" | cut -f1)

        # Write the timestamp, directory, and size to the log file
        echo "$TIMESTAMP $DIRECTORY $DIR_SIZE" >> "$LOG_FILE"
    else  # directory not found
        echo "$TIMESTAMP $DIRECTORY -1" >> "$LOG_FILE"
    fi
done < "$CONFIG_FILE"
```

## Make the Script Executable:

Save the script and make it executable:

```bash
chmod +x /usr/local/bin/track_dir_size.sh
```
## Create a Cron Job:

Open the crontab editor:  `crontab -e`

Add a new cron job to run the script at regular intervals, e.g., every day at midnight:

```bash
0 0 * * * test -x /usr/local/bin/track_dir_size.sh && /usr/local/bin/track_dir_size.sh > /dev/null 2>&1
```

## Possible modifications

Easy enough to modify the script to output in a CSV format.
Could also modify to output to separate log files based on the directory being tracked.
