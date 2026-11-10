# System Architecture

## 1. Overview

The Linux Incident Triage Toolkit follows a modular architecture.

It consists of monitoring checks, alert-state management, a diagnostic engine, and incident evidence collection.

## 2. Execution Flow

1. Cron or manual execution starts the main script.
2. A locking mechanism prevents overlapping executions.
3. Monitoring modules inspect system health.
4. Alert-state logic evaluates abnormal conditions.
5. The triage engine investigates triggered incidents.
6. Diagnostic evidence is collected.
7. An incident bundle and report are generated.

## 3. Main Components

| Component | Responsibility |
|---|---|
| bin/ | Main entry point |
| checks/ | System health checks |
| lib/ | Shared functions |
| config/ | Monitoring configuration |
| state/ | Alert state and heartbeat |
| incidents/ | Incident evidence and reports |
| logs/ | Application execution logs |
| tests/ | Fault injection and testing |
| docs/ | Project documentation |

## 4. Design Principles

- Modular scripts
- Configurable thresholds
- Evidence-based diagnosis
- Safe incident testing
- Clear error handling
- Maintainable documentation

## 5. Project Scope

Version 1 focuses on monitoring and incident triage for a single Ubuntu Linux server.
