# Get current LRU

```
lctl get_param ldlm.namespaces.*osc*.lru_size
```

# Set LRU

Need to create script to run on boot via crontab (as root).

```
tee /usr/local/bin/setlru << EOF
#!/bin/bash
mount /lustre
lctl set_param ldlm.namespaces.*osc*.lru_size=4096
EOF
chmod +x /usr/local/bin/setlru
```

```
tee -a /etc/crontab << EOF
@reboot /usr/local/bin/setlru
EOF
```
