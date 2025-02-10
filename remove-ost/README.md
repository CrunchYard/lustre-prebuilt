# Removing an OST

https://doc.lustre.org/lustre_manual.xhtml#lustremaint.remove_ost

## Stop the OST and migrate files off
- check status:
  - `sudo lctl dl`
- On each MDS, to remove "OST0003":  (change LustreFS as appropriate)
  - `sudo lctl set_param osp.LustreFS-OST0003-osc-MDT*.max_create_count=0`
- Discover all files that have objects residing on the deactivated OST. Depending on whether the deactivated OST is available or not, the data from that OST may be migrated to other OSTs, or may need to be restored from backup.
  - Must do this on a client, *not* MDS
  - Note that even with "-y" may be prompted to confirm migrations.
    -  `sudo lfs find --ost LustreFS-OST0003 /lustre | lfs_migrate -y`   
- To check which files are on an OST:
  - `lfs find /lustre -ost 3`
- On the MGS - "permanently" deactivate the OST
  - `sudo lctl conf_param LustreFS-OST0003.osc.active=0`

## Remove the OST from lustre
Must be on the OSS
- Unmount the target disk
  - `umount /dev/sdd`
- Remove from OST
- `tunefs.lustre --erase-params --mgsnode=10.10.0.20 /dev/sdd`
On the MGS
  - `lctl conf_param LustreFS-OST0003.failover.node=`
  - `lctl conf_param LustreFS-OST0003.failover.nid=`
  - `systemctl restart lustre`

## Repurpose OSS
- Need to reformat with replace

# Notes
- Determining Which Machine is Serving an OST
  - `lctl get_param osc.*-OST0003*.ost_conn_uuid`
  
