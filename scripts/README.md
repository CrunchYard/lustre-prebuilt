# Various scripts
Example usage:

## Generate list to stdout of files larger than 50MB on OST2 in path /lustre
```bash
sudo get_large_files_on_ost -p /lustre -s 50 -n 2 -o large-files-on-ost2.csv
```

## Generate large-files-on-ost1.csv which contains list of files larger than 100MB on OST2 in path /lustre
```bash
sudo get_large_files_on_ost -p /lustre -s 100 -n 1 -o large-files-on-ost1.csv
```

## Generate single-stripe-files.csv which contains list of all files larger than 10MB that are single striped
```bash
# Generate single-stripe-files.csv which contains list of all files larger than 10MB that are single striped
sudo ./get-single-stripe-files.sh
```

## Notes
- Include argument for path to check.
- Use rbh-du to look for largest directories.
- Name for output to prefix (BU).
