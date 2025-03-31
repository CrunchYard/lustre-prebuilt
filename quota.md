# Lustre Quota Cheat Sheet

## Usage by user
```
lfs quota -u root /lustre/
```

Example output:
```
Disk quotas for usr root (uid 0):
     Filesystem  kbytes   quota   limit   grace   files   quota   limit   grace
       /lustre/ 9857068       0       0       -    4490       0       0       -
```

## Usage by group
```
lfs quota -g root /lustre/
```

Example output:
```
Disk quotas for grp root (gid 0):
     Filesystem  kbytes   quota   limit   grace   files   quota   limit   grace
       /lustre/ 9887700       0       0       -    5158       0       0       -
```

## Verbose and human readable
```
lfs quota -h -v -u root /lustre
```

Example output:
```
Disk quotas for usr root (uid 0):
     Filesystem    used   quota   limit   grace   files   quota   limit   grace
       /lustre/    9.4G      0k      0k       -    4490       0       0       -
LustreFS-MDT0000_UUID
                 4.734M       -      0k       -    4490       -       0       -
quotactl ost0 failed.
LustreFS-OST0001_UUID
                 8.413G       -      0k       -       -       -       -       -
LustreFS-OST0002_UUID
                  1001M       -      0k       -       -       -       -       -
LustreFS-OST0003_UUID
                  1.32M       -      0k       -       -       -       -       -
LustreFS-OST0004_UUID
                 1.316M       -      0k       -       -       -       -       -
LustreFS-OST0005_UUID
                 1.316M       -      0k       -       -       -       -       -
LustreFS-OST0006_UUID
                 1.316M       -      0k       -       -       -       -       -
Total allocated inode limit: 0, total allocated block limit: 0k
Some errors happened when getting quota info. Some devices may be not working or deactivated. The data in "[]" is inaccurate.
```
