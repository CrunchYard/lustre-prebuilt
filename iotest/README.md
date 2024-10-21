# Install

Information available at https://sas.service-now.com/csm?id=kb_article_view&sysparm_article=KB0039548#

```bash
wget "https://sas.service-now.com/sys_attachment.do?sys_id=3227addf97701218495ff9c0f053afb9"
unzip SASTSST_UNIX_installation.zip
bash ./SASTSST_UNIX_installation.sh
```
- Review and accept the license terms and conditions.
- Supply absolute path to the installation destination.
- Select the Testing Throughput for your SAS 9 File Systems: RHEL Linux platforms.

Once installed, make the rhel_iotest.sh file executable:  chmod +x rhel_iotest.sh

# Run

```bash
rhel_iotest.sh -t <target file system>
```

# To test the system

Will need spawn `rhel_iotest.sh -t /lustre` from all clients.

Suggest capturing output for analysis to a text file unique to each client, for example:

```bash
rhel_iotest.sh -t /lustre &> /tmp/rhel_iotest-`hostname`.txt
```
