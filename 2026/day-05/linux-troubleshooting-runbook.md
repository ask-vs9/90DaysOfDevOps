# Linux Troubleshooting Runbook

## Target Service / Process

**Service:** SSH (sshd)

**Objective:** Verify service health by checking CPU, memory, disk, network connectivity, and logs.

---

## 1. Environment Basics

### Command 1

```bash
uname -a
```

**Observation:**
System is running Linux kernel 6.x on Ubuntu. Kernel appears healthy.

### Command 2

```bash
cat /etc/os-release
```

**Observation:**
Ubuntu 24.04 LTS detected. Supported and stable OS version.

---

## 2. Filesystem Sanity

### Command 3

```bash
mkdir -p /tmp/runbook-demo
```

**Observation:**
Temporary directory created successfully.

### Command 4

```bash
cp /etc/hosts /tmp/runbook-demo/hosts-copy && ls -l /tmp/runbook-demo
```

**Observation:**
File copy operation completed successfully. Filesystem is writable.

---

## 3. CPU & Memory Snapshot

### Command 5

```bash
ps -o pid,pcpu,pmem,comm -C sshd
```

**Observation:**
SSH daemon shows minimal CPU and memory consumption. No abnormal resource usage.

### Command 6

```bash
free -h
```

**Observation:**
Memory usage is within normal range. No swap pressure observed.

---

## 4. Disk & IO Snapshot

### Command 7

```bash
df -h
```

**Observation:**
Root filesystem utilization below 80%. Sufficient free space available.

### Command 8

```bash
du -sh /var/log
```

**Observation:**
Log directory size is reasonable and not consuming excessive disk space.

---

## 5. Network Snapshot

### Command 9

```bash
ss -tulpn | grep ssh
```

**Observation:**
SSH service is listening on TCP port 22 and accepting connections.

### Command 10

```bash
ping -c 4 8.8.8.8
```

**Observation:**
Network connectivity is working. No packet loss observed.

---

## 6. Logs Review

### Command 11

```bash
sudo journalctl -u ssh -n 50
```

**Observation:**
Recent SSH activity visible. No critical errors or repeated failures found.

### Command 12

```bash
sudo tail -n 50 /var/log/auth.log
```

**Observation:**
Authentication logs show successful login attempts and normal SSH activity.

---

## Quick Findings

* SSH service is running normally.
* CPU and memory consumption are low.
* Disk space is sufficient.
* Network connectivity is healthy.
* No critical SSH-related errors found in logs.
* Service is listening on the expected port.

---

## If This Worsens

### Step 1: Restart Service

```bash
sudo systemctl restart ssh
sudo systemctl status ssh
```

### Step 2: Increase Investigation

```bash
sudo journalctl -u ssh -f
```

Monitor logs in real time for failures.

### Step 3: Deep Diagnostics

```bash
sudo strace -p <PID>
```

Collect system-call traces if the process becomes unresponsive.

---

## Conclusion

A complete health snapshot was captured for the SSH service. No resource bottlenecks, disk issues, network problems, or log errors were identified during the troubleshooting drill.

