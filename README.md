# Linux Background Process Monitor & Alert System

## Overview

A Bash-based Linux utility that monitors user-configured process names and generates alerts when new matching process instances are detected. It records alerts and monitoring results in a log file and can run automatically on a schedule using cron.

## Features

- Monitors exact Linux process names listed in `watchlist.txt`.
- Detects newly appearing process instances using process IDs (PIDs).
- Avoids repeating alerts for the same process instance across consecutive checks.
- Records alerts and check results with timestamps.
- Supports automated checks using cron.
- Does not automatically terminate processes or modify system software.

## Technologies

- Linux / Ubuntu
- Bash scripting
- `pgrep` and `grep`
- Cron scheduling
- Git and GitHub

## Project Files

- `monitor.sh` — monitoring and alerting logic.
- `watchlist.txt` — process names selected for monitoring.
- `monitor.log` — timestamped monitoring history.
- `.previous_processes` — internal state used to avoid duplicate alerts.

## Setup and Usage

1. Clone or download this repository.
2. Open a terminal in the project directory.
3. Add exact Linux process names to `watchlist.txt`, one per line.
4. Make the script executable:

   ```bash
   chmod +x monitor.sh
   ```

5. Run a manual check:

   ```bash
   ./monitor.sh
   ```

6. Review the log:

   ```bash
   tail -n 20 monitor.log
   ```

## Automated Monitoring

To run the monitor every five minutes, open your user crontab:

```bash
crontab -e
```

Add the following line:

```cron
*/5 * * * * /usr/bin/bash /home/ashley/linux-background-monitor/monitor.sh
```

Save the crontab and verify it with:

```bash
crontab -l
```

Cron must be running, and the Ubuntu/WSL environment must remain active for scheduled checks to execute.

## Testing

Tested on Ubuntu 26.04.1 LTS running under WSL.

- Detected a watched test process and recorded its PID.
- Confirmed that consecutive checks did not repeat the same alert.
- Confirmed that a restarted process with a new PID generated another alert.
- Verified a scheduled execution through a new timestamped log entry.

## Limitations

- Monitors Linux processes within the environment where the script runs; it does not monitor all Windows background applications.
- Only process names explicitly configured in `watchlist.txt` are checked.
- A running process is not necessarily unwanted or malicious.
- Alerts are written to the terminal and log file; desktop notifications are not currently configured.
- The script does not automatically stop or kill processes.

## Future Improvements

- Optional desktop notifications where supported.
- Configurable alert destinations.
- Monitoring multiple process attributes.
- Improved reporting and configurable scan intervals.

## Disclaimer

This project is intended for learning and authorized system monitoring. Review a process before deciding whether it should be stopped.

