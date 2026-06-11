# Day 02 - Linux Architecture, Processes, and systemd

## Linux Architecture

Linux consists of three main components:

### 1. Kernel

* Core of the operating system.
* Manages CPU, memory, storage, networking, and hardware devices.
* Acts as a bridge between hardware and applications.

### 2. User Space

* Area where users and applications run.
* Includes shells, utilities, services, and user applications.
* Communicates with the kernel through system calls.

### 3. Init / systemd

* First process started by the kernel (PID 1).
* Responsible for starting and managing system services.
* Handles boot process, service management, and logging.

---

## Process Management

A process is a running instance of a program.

### Process Creation

* A new process is usually created using `fork()`.
* The child process may load a new program using `exec()`.
* Every process has a unique Process ID (PID).

### Common Process States

| State               | Description                              |
| ------------------- | ---------------------------------------- |
| Running (R)         | Currently executing on CPU               |
| Sleeping (S)        | Waiting for an event or resource         |
| Interruptible Sleep | Can be awakened by signals               |
| Zombie (Z)          | Process completed but entry still exists |
| Stopped (T)         | Paused by user or signal                 |

### Useful Process Commands

```bash
ps aux
top
htop
pgrep nginx
kill -9 <PID>
```

---

## Understanding systemd

systemd is the service manager used by most modern Linux distributions.

### Why systemd Matters

* Starts services during boot.
* Restarts failed services automatically.
* Tracks service status.
* Manages logs through journalctl.
* Improves system reliability and automation.

### Common systemd Commands

```bash
systemctl status nginx
systemctl start nginx
systemctl stop nginx
systemctl restart nginx
systemctl enable nginx
journalctl -u nginx
```

---

## 5 Linux Commands I Will Use Daily

```bash
ps        # View running processes
top       # Monitor CPU and memory
systemctl # Manage services
journalctl # View logs
kill      # Stop processes
```

## Key Takeaway

Understanding Linux processes and systemd is essential for troubleshooting production servers. Most DevOps incidents involve checking processes, logs, resource usage, or service status, making these concepts fundamental for day-to-day operations.

