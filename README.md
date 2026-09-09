# 🏦 Bank Database Server Log Analyzer

A shell script that parses a bank database server's log file and generates structured, human-readable reports — turning raw log data into actionable insight for administrators.

Built for **ENCS3130 – Linux Laboratory**, Birzeit University.

---

## 📋 Overview

Database servers in banking environments generate large volumes of log data every day: authentication attempts, queries, transactions, backups, and system errors. Manually reviewing these logs to catch suspicious activity, performance issues, or operational failures is impractical at scale.

This project automates that process with a modular, menu-driven Bash script built entirely from core Unix/Linux command-line tools — `grep`, `sed`, `cut`, `sort`, `uniq`, `tr`, and shell scripting constructs (functions, loops, conditionals).

---

## ✨ Features

The script offers **9 analysis services**, each implemented as its own function:

| # | Report | Description |
|---|--------|-------------|
| 1 | **Failed Login Report** | Counts failed login attempts, grouped by IP and by user; flags IPs with 3+ failures as possible brute-force sources |
| 2 | **Query Activity Summary** | Breaks down QUERY events by type (SELECT / UPDATE / INSERT / DELETE) |
| 3 | **Slow Query Detector** | Lists WARNING entries for slow queries with execution time and user |
| 4 | **Transaction Report** | Summarizes deposits, withdrawals, declines, and rollbacks, with totals |
| 5 | **Critical Events Report** | Lists all CRITICAL log entries with timestamps |
| 6 | **User Activity Report** | Shows all actions for a given username, sorted chronologically |
| 7 | **Login/Logout Session Report** | Login time, logout time, and duration per session |
| 8 | **Events-per-Hour Report** | Event counts by hour of day, to spot peak usage |
| 9 | **General Log Summary** | Total lines, counts per log level, and busiest module |

All 9 reports can also be run together and saved to a combined output file.

---

## 🗂️ Log Format

Each line in `bank_server.log` follows this structure:

```
[TIMESTAMP] [LOG_LEVEL] [SESSION_ID] [USER] [CLIENT_IP] [MODULE] - MESSAGE
```

**Example:**
```
[2026-08-15 08:07:33] [ERROR] [SESSION_1003] [unknown] [203.0.113.55] [AUTH] - Failed login attempt for user root (invalid password)
```

| Field | Example | Meaning |
|---|---|---|
| `LOG_LEVEL` | `INFO`, `WARNING`, `ERROR`, `CRITICAL` | Severity of the event |
| `SESSION_ID` | `SESSION_1003` | Unique session identifier |
| `USER` | `admin`, `teller01`, `unknown` | Associated username |
| `CLIENT_IP` | `203.0.113.55` | Origin IP address |
| `MODULE` | `AUTH`, `QUERY`, `TRANSACTION`, `BACKUP` | Subsystem that generated the event |

---

## 🖥️ Environment

- **OS:** Ubuntu Linux
- **Shell:** Bash
- **Tools used:** `grep`, `sed`, `cut`, `sort`, `uniq`, `tr`, `wc`, `printf`, core shell scripting (functions, loops, conditionals, `case`)

No external dependencies — everything runs with tools available on a standard Ubuntu installation.

---

## 🚀 Usage

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd <repository-folder>
   ```

2. Make the script executable:
   ```bash
   chmod +x bank_log_analyzer.sh
   ```

3. Make sure `bank_server.log` is in the same directory as the script.

4. Run it:
   ```bash
   ./bank_log_analyzer.sh
   ```

5. Use the on-screen menu to select a report, or run all reports at once:
   ```
   Bank Analyzer

   1. Failed Login Report
   2. Query Activity Summary
   3. Slow Query Detector
   4. Transaction Report
   5. Critical Events Report
   6. User Activity Report
   7. Login/Logout Session Report
   8. Events-per-Hour Report
   9. General Log Summary
   10. Run All Reports
   0. Exit

   Enter your choice:
   ```

Running **option 10** generates a full combined report and saves it to `full_report.txt`.

---

## 🛡️ Error Handling

The script gracefully handles:
- A missing or unreadable log file (exits with a clear error message)
- Invalid menu selections
- Empty or invalid username input for the User Activity Report
- Log sections with no matching events (e.g., no failed logins, no critical events)

---

## 🧩 Design

The script is built modularly:
- Each report is a **dedicated, single-purpose function**
- Shared logic (log file validation, username input handling) is factored into **helper functions**
- Code is commented throughout to explain non-obvious parsing logic

---

## 👥 Authors

This project was completed as a two-person team for the ENCS3130 Linux Laboratory course.

- Amir — Computer Engineering, Birzeit University
- Mohammad — Computer Engineering, Birzeit University

---

## 📄 License

This project was developed for academic purposes as part of the ENCS3130 course at Birzeit University.
