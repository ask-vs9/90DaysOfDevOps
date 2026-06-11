# Day 04 - Linux Practice: Processes and Services

## Process Checks

### 1. View Running Processes

```bash
ps aux | head
```

**Observation:** Displayed the first few running processes along with CPU and memory usage.

### 2. Find a Specific Process

```bash
pgrep sshd
```

**Observation:** Returned the PID of the SSH daemon process.

### 3. Monitor System Resources

```bash
top
```

**Observation:** Viewed real-time CPU, memory, and process activity.

---

## Service Checks

### Service Selected: SSH (sshd)

### 4. Check Service Status

```bash
systemctl status ssh
```

**Observation:** SSH service was active and running successfully.

### 5. List Active Services

```bash
systemctl list-units --type=service --state=running
```

**Observation:** Displayed all currently running system services.

---

## Log Checks

### 6. View SSH Service Logs

```bash
journalctl -u ssh -n 20
```

**Observation:** Displayed the latest SSH login and service events.

### 7. View System Log Entries

```bash
tail -n 20 /var/log/syslog
```

**Observation:** Showed recent system activities and service messages.

---

## Mini Troubleshooting Flow

### Scenario

Verify whether the SSH service is healthy and accepting connections.

### Steps Performed

1. Checked if the process exists:

```bash
pgrep sshd
```

2. Verified service status:

```bash
systemctl status ssh
```

3. Reviewed recent logs:

```bash
journalctl -u ssh -n 20
```

4. Confirmed listening port:

```bash
ss -tulpn | grep :22
```

### Result

* SSH process was running.
* Service status showed "active (running)".
* Logs contained no critical errors.
* Port 22 was listening successfully.

## Key Takeaway

Today I practiced inspecting Linux processes, checking systemd services, and reviewing logs. These commands form the foundation of troubleshooting production Linux servers and are commonly used by DevOps engineers during incidents.

