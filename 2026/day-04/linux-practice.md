# Linux Practice Notes

## Process Checks

### 1. ps aux | head
- Displayed currently running processes with CPU and memory usage.

### 2. pgrep sshd
- Returned PID of SSH service process.

---

## Service Checks

### 3. systemctl status ssh
- SSH service is active and running.

### 4. systemctl list-units --type=service | head
- Listed active system services.

---

## Log Checks

### 5. journalctl -u ssh -n 10
- Displayed recent logs for SSH service.

### 6. tail -n 20 /var/log/syslog
- Showed latest system log entries.

---

## Mini Troubleshooting Flow

### Scenario:
Verified whether SSH service was healthy.

### Steps:
1. Checked process using `pgrep sshd`
2. Verified service status using `systemctl status ssh`
3. Reviewed logs using `journalctl -u ssh`

### Result:
SSH service was running normally with no critical errors.
