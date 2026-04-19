# Linux Commands Cheatsheet

## Process Management
- `ps aux` → list running processes
- `top` → live CPU/memory usage
- `htop` → interactive process monitor
- `kill PID` → stop process
- `kill -9 PID` → force kill process
- `pgrep nginx` → find PID by name
- `pkill nginx` → kill by process name

## File System
- `pwd` → show current directory
- `ls -la` → list files with details
- `cd /path` → change directory
- `mkdir test` → create folder
- `touch file.txt` → create file
- `cp a.txt b.txt` → copy file
- `mv a.txt b.txt` → move/rename file
- `rm -rf test` → delete file/folder
- `cat file.txt` → view file content
- `grep error app.log` → search text
- `find / -name nginx.conf` → find file
- `df -h` → disk usage
- `du -sh *` → folder sizes

## Networking Troubleshooting
- `ping google.com` → test connectivity
- `ip addr` → show IP addresses
- `ss -tulpn` → open ports/processes
- `curl http://site.com` → test HTTP response
- `dig google.com` → DNS lookup
- `traceroute google.com` → route path

## Logs
- `tail -f /var/log/syslog` → live logs
- `journalctl -xe` → systemd logs
