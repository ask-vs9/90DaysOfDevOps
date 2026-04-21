# Linux Troubleshooting Runbook

## Target Service / Process
- Service inspected: SSH

---

## Snapshot: Environment

### `uname -a`
- Verified kernel version and host details.

### `cat /etc/os-release`
- Confirmed operating system version.

---

## Snapshot: Filesystem Sanity

### `mkdir -p /tmp/runbook-demo`
- Created temporary troubleshooting workspace.

### `cp /etc/hosts /tmp/runbook-demo/hosts-copy && ls -l /tmp/runbook-demo`
- Confirmed file copy and permissions.

---

## Snapshot: CPU & Memory

### `top -b -n 1 | head`
- System load normal, no unusual CPU spikes.

### `free -h`
- Memory available, no swap pressure observed.

---

## Snapshot: Disk & IO

### `df -h`
- Root filesystem had sufficient free space.

### `du -sh /var/log`
- Log usage within acceptable range.

---

## Snapshot: Network

### `ss -tulpn | head`
- Verified listening ports and sockets.

---

## Logs Reviewed

### `journalctl -u ssh -n 20`
- No recent critical service errors.

### `tail -n 20 /var/log/syslog`
- Recent system events looked normal.

---

## Quick Findings

- SSH service healthy and active.
- CPU, memory, disk stable.
- No urgent log errors found.

---

## If This Worsens (Next Steps)

1. Restart safely using `systemctl restart ssh`
2. Increase log review and check auth failures
3. Capture deeper diagnostics using `strace`
