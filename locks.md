# Checking for lock information

## Get list of files that are locked (including the PID)

```
lslocks
```

## See how long a specific process has been running and what the user and userid is (assuming the lock happened when the process started)

```
ps -o lstart= -o user= -o uid= -p <PID>
```

## NOT working - Get list of the file paths (lslocks unfortunately truncates the path)

Prints out the (truncated) path, username, userid, process id and process start time for all locked files.
```
lslocks -r -u | awk '{cmd=sprintf("echo -n \"%s \"\nps -o user= -o uid= -o pid= -o lstart= -p %s", $8, $2); system(cmd);}'
```

## The lsof command can also list deleted/locked files with their full paths:

```
sudo lsof | grep '(deleted\|LOCKED)'
```
