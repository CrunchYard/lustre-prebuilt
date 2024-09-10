## NB: Can also use rbh-find directly to find files larger than a certain size on a specific OST
```bash
rbh-find -size +50M -ost 1
```

# Various scripts

Example usage:

## Generate list to stdout of files larger than 50MB on OST1 in path /lustre
```bash
sudo get_large_files_on_ost -p /lustre -s 50 -n 1
```

Example output (stdio):
```
#/path/filename
/lustre/crunchyard/testfile
```

## Generate list with prefix text to stdout of files larger than 50MB on OST1 in path /lustre
```bash
sudo get_large_files_on_ost -p /lustre -s 50 -n 1 -t "Prefix:" 
```

Example output (stdio):
```
#/path/filename
Prefix:/lustre/crunchyard/testfile
```

## Generate large-files-on-ost2.csv which contains list of files larger than 100MB on OST2 in path /lustre
```bash
sudo get_large_files_on_ost -p /lustre -s 100 -n 1 -o large-files-on-ost2.csv
```

## Generate single-stripe-files.csv which contains list of all files larger than 10MB that are single striped in path /lustre
```bash
sudo get_single_stripe_files -p /lustre -s 10 -o single-stripe-files.csv
```

Example output (stdio):
```
#/path/filename,stripe_cnt,stripe_size
/lustre/crunchyard/random/file011.bin,1,1.00MB
/lustre/crunchyard/random/file012.bin,1,1.00MB
/lustre/crunchyard/random/file013.bin,1,1.00MB
```

## Generate reverse sorted list of directory sizes in bytes in a particular directory
```bash
sudo get_large_directories -p /lustre -o large.txt
```

Example output:
```
15831268	/lustre/crunchyard
14696548	/lustre/random
512012	/lustre/another
69476	/lustre/doc
```
