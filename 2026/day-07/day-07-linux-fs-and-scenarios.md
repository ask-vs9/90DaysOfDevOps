# Day 07 – Linux File System Hierarchy & Scenario Practice

## Part 1: Linux File System Hierarchy

### `/`
Root of the Linux filesystem. Starting point of everything.

I would use this when navigating system directories.

### `/home`
Contains normal user home folders.

I would use this when checking user files.

### `/root`
Home directory of root user.

I would use this when logged in as root.

### `/etc`
Stores configuration files.

Examples: hosts, hostname, ssh configs.

I would use this when changing service settings.

### `/var/log`
Stores log files.

Examples: syslog, auth.log.

I would use this during troubleshooting.

### `/tmp`
Temporary files directory.

I would use this for temp scripts/files.

### `/bin`
Essential commands.

Examples: ls, cp, mv.

I would use this for core utilities.

### `/usr/bin`
Additional user commands.

Examples: curl, grep, vim.

I would use this for tools.

### `/opt`
Optional third-party applications.

I would use this for Jenkins/Grafana/custom apps.

---

## Hands-on Practice

### Largest Logs

Command:
`du -sh /var/log/* | sort -h | tail -5`

Used to find biggest logs.

### Hostname

Command:
`cat /etc/hostname`

Used to verify server name.

### Home Directory

Command:
`ls -la ~`

Used to inspect user files.

---

## Part 2: Scenario Practice

### Scenario 1: Service Not Starting

Step 1: `systemctl status myapp`  
Why: Check failed/running state.

Step 2: `journalctl -u myapp -n 50`  
Why: Review recent logs.

Step 3: `systemctl is-enabled myapp`  
Why: Check startup on boot.

Step 4: `systemctl restart myapp`  
Why: Retry after analysis.

---

### Scenario 2: High CPU Usage

Step 1: `top`  
Why: Live CPU view.

Step 2: `ps aux --sort=-%cpu | head -10`  
Why: Find top CPU processes.

Step 3: `ps -fp PID`  
Why: Inspect process details.

---

### Scenario 3: Finding Logs

Step 1: `systemctl status docker`

Step 2: `journalctl -u docker -n 50`

Step 3: `journalctl -u docker -f`

Why: Check status, recent logs, live logs.

---

### Scenario 4: Permission Denied

Step 1: `ls -l backup.sh`

Step 2: `chmod +x backup.sh`

Step 3: `ls -l backup.sh`

Step 4: `./backup.sh`

Why: Add execute permission and rerun.

---

## Key Learning

Strong DevOps engineers know where files live and how to troubleshoot quickly using a structured approach.
