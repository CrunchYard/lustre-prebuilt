# Checking for lock information

## Get list of files that are locked (includes PID)

```
lslocks
```

## See how long a specific process has been running and what the userid is (assuming the lock happened when the process started)

```
ps -o lstart= -o uid= -p <PID>
```
