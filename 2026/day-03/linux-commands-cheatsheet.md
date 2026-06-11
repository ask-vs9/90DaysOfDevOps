# Day 03 - Linux Commands Cheat Sheet

## Process Management

| Command         | Usage                        |
| --------------- | ---------------------------- |
| `ps aux`        | View all running processes   |
| `top`           | Monitor CPU and memory usage |
| `htop`          | Interactive process viewer   |
| `pgrep nginx`   | Find process ID by name      |
| `kill <PID>`    | Terminate a process          |
| `kill -9 <PID>` | Force kill a process         |
| `pkill nginx`   | Kill process by name         |
| `pstree`        | Display process hierarchy    |

---

## File System Commands

| Command                   | Usage                     |
| ------------------------- | ------------------------- |
| `pwd`                     | Show current directory    |
| `ls -lh`                  | List files with details   |
| `cd <dir>`                | Change directory          |
| `mkdir test`              | Create directory          |
| `touch file.txt`          | Create empty file         |
| `cp file1 file2`          | Copy files                |
| `mv old new`              | Move or rename files      |
| `rm -rf dir`              | Remove files/directories  |
| `find / -name nginx.conf` | Search files              |
| `du -sh *`                | Check directory sizes     |
| `df -h`                   | Check disk usage          |
| `cat file.txt`            | Display file content      |
| `less file.txt`           | Read large files          |
| `tail -f app.log`         | Monitor logs in real time |
| `grep ERROR app.log`      | Search text in files      |

---

## Networking Troubleshooting

| Command                    | Usage                      |
| -------------------------- | -------------------------- |
| `ping google.com`          | Check network connectivity |
| `ip addr`                  | View IP addresses          |
| `ip route`                 | View routing table         |
| `ss -tulpn`                | Check listening ports      |
| `netstat -tulpn`           | View network connections   |
| `curl https://example.com` | Test HTTP endpoint         |
| `wget <url>`               | Download files             |
| `dig google.com`           | DNS lookup                 |
| `nslookup google.com`      | Query DNS records          |
| `traceroute google.com`    | Trace network path         |

---

## System Monitoring

| Command   | Usage                       |
| --------- | --------------------------- |
| `free -h` | Check memory usage          |
| `uptime`  | View system uptime and load |
| `vmstat`  | Display system performance  |
| `iostat`  | Monitor disk I/O            |
| `lscpu`   | View CPU information        |

---

## Service Management (systemd)

| Command                   | Usage                |
| ------------------------- | -------------------- |
| `systemctl status nginx`  | Check service status |
| `systemctl start nginx`   | Start service        |
| `systemctl stop nginx`    | Stop service         |
| `systemctl restart nginx` | Restart service      |
| `journalctl -u nginx`     | View service logs    |

---

## My Most Used DevOps Commands

```bash
tail -f /var/log/messages
journalctl -xe
systemctl status nginx
df -h
free -h
top
curl <url>
ss -tulpn
```

## Key Takeaway

Linux troubleshooting becomes faster when you know the right commands. Most production incidents involve checking processes, logs, disk usage, memory consumption, services, and network connectivity. These commands form the foundation of daily DevOps operations.

