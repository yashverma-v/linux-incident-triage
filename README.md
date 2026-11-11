# Linux Incident Triage Toolkit

A Bash-based Linux server monitoring and incident triage toolkit that detects resource threshold breaches, tracks repeated incidents, collects diagnostic evidence, and generates incident reports.

## Problem Statement

Linux server issues such as high CPU usage, memory exhaustion, disk exhaustion, and failed services require timely investigation.

This toolkit automates basic health checks and collects useful diagnostic information to support incident investigation.

## Features

- CPU utilization monitoring
- Memory utilization monitoring
- Disk and inode utilization monitoring
- Top CPU-consuming process inspection
- Configurable system service monitoring
- Consecutive breach tracking
- Alert generation after three consecutive breaches
- Recovery state tracking
- Automatic incident triage
- Diagnostic evidence collection
- Incident report generation
- Process locking using flock
- Cron-based scheduled monitoring
- Centralized logging

## Architecture

```text
Linux Server
    |
    v
Monitoring Controller
    |
    +--> CPU Check
    +--> Memory Check
    +--> Disk and Inode Check
    +--> Process Check
    +--> Service Check
    |
    v
Alert Manager
    |
    +--> Breach Tracking
    +--> Recovery Tracking
    |
    v
Incident Triage Engine
    |
    +--> Diagnostic Evidence
    +--> System Information
    +--> Process Information
    +--> Recent System Errors
    |
    v
Incident Report
```

## Project Structure

```text
linux-incident-triage/
├── bin/
│   └── monitor.sh
├── checks/
│   ├── cpu_check.sh
│   ├── memory_check.sh
│   ├── disk_check.sh
│   ├── process_check.sh
│   └── service_check.sh
├── config/
│   ├── services.conf
│   └── thresholds.conf
├── docs/
│   └── architecture.md
├── incidents/
├── lib/
│   ├── alert_manager.sh
│   ├── logger.sh
│   ├── report.sh
│   └── triage.sh
├── logs/
├── state/
└── tests/
    └── test_alert_manager.sh
```

## Technology Stack

- Bash Shell Scripting
- Linux / Ubuntu
- Linux system utilities
- systemd
- flock
- cron
- Git and GitHub

## Configuration

Edit `config/thresholds.conf` to configure resource thresholds.

Default thresholds:

| Resource | Threshold |
|---|---:|
| CPU | 80% |
| Memory | 85% |
| Disk | 90% |
| Inodes | 90% |
| Process CPU | 80% |

Monitored services are configured in `config/services.conf`.

## Installation

```bash
git clone https://github.com/yashverma-v/linux-incident-triage.git

cd linux-incident-triage

chmod +x bin/monitor.sh
```

Requirements:
- Bash
- Linux `/proc` filesystem
- `flock`
- `systemctl`
- `cron`

## Usage

Run monitoring manually:

```bash
./bin/monitor.sh
```

Run alert manager tests:

```bash
bash tests/test_alert_manager.sh
```

View toolkit logs:

```bash
tail -f logs/toolkit.log
```

View generated incident reports:

```bash
ls -lh incidents/
```

## Automated Monitoring

The toolkit can be scheduled through cron.

Example: execute monitoring every five minutes.

```cron
*/5 * * * * /path/to/linux-incident-triage/bin/monitor.sh
```

Process locking prevents overlapping monitoring executions.

## Incident Investigation

When a monitored resource crosses its threshold for three consecutive checks, the alert manager triggers incident triage.

The toolkit collects:
- System uptime and load average
- Memory utilization
- Disk utilization
- Top CPU-consuming processes
- Failed system services
- Recent system error messages

Generated evidence and reports are stored in the `incidents/` directory.

## Testing

The alert manager has an automated test covering:
- First breach
- Second breach
- Third consecutive breach
- Automatic triage triggering
- Recovery state clearing

The toolkit has also been manually executed on an Ubuntu EC2 instance.

## Limitations

- Designed as a learning and demonstration project for a single Linux server.
- Does not replace enterprise monitoring platforms.
- Diagnostic evidence supports investigation but does not automatically establish root cause.
- No automatic remediation is performed.
- Additional failure, concurrency, and recovery scenarios require further testing.

## Future Improvements

- Alert cooldown and notification integrations
- Expanded automated testing
- Improved incident correlation
- Additional diagnostic checks
- Safe fault-injection testing

## Author

Yash

---

Built to practice Linux administration, Bash scripting, monitoring, and incident investigation.
