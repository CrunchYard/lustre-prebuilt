# Checking for lock information

## Get list of files that are locked (including the PID)

```
lslocks
```

## See how long a specific process has been running and what the user and userid is (assuming the lock happened when the process started)

```
ps -o lstart= -o user= -o uid= -p <PID>
```
