# 🏦 Bank Database Server Log Analyzer

A modular Bash shell script designed to analyze, filter, and extract security and operational insights from server log files on **Ubuntu Linux**.

This tool processes structured log data to track failed login attempts (brute force detection), database queries, slow query execution times, financial transaction totals, critical system errors, user activity, and user session durations.

---

## 🖥️ System Requirements & Environment

This script was developed, tested, and validated in the following environment:

* **OS:** Ubuntu 22.04 LTS / 24.04 LTS
* **Shell:** GNU Bash 5.x
* **Core Utilities:** `grep`, `sed`, `awk`, `cut`, `sort`, `uniq`, `tr`, `date`
* **Dependencies:** Standard Ubuntu core utilities (no external installations required)

---

## 🛠️ Features

* **Brute Force Detection:** Aggregates failed login attempts by IP address and user, automatically flagging suspicious IPs (3+ failures).
* **Database Query Analytics:** Breaks down total queries by SQL type (`SELECT`, `INSERT`, `UPDATE`, `DELETE`).
* **Slow Query Detector:** Captures execution times and identifies queries causing performance bottlenecks.
* **Financial Transaction Auditor:** Calculates global totals for deposits, withdrawals, rollbacks, and declined transactions.
* **Session Duration Tracker:** Computes active user session lengths in hours, minutes, and seconds using epoch time conversion.
* **User Activity Auditor:** Performs filtered timeline searches for individual bank users.
* **Comprehensive Reporting:** Saves full system audit reports directly to `full_report.txt` while maintaining terminal output using `tee`.

---

## 🚀 Getting Started on Ubuntu

### 1. Clone the Repository

```bash
git clone [https://github.com/your-username/bank-log-analyzer.git](https://github.com/your-username/bank-log-analyzer.git)
cd bank-log-analyzer
