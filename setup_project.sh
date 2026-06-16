#!/bin/bash
echo "Enter your project name:"
read name
project="attendance_tracker_$name"
cleanup() {
    echo "Setup interrupted."

    if [ -d "$project" ]; then
        tar -czf "${project}_archive.tar.gz" "$project"
        rm -rf "$project"
        echo "Archive created."
        echo "Incomplete directory removed."
    fi

    exit 1
}
trap cleanup SIGINT
mkdir "$project"
mkdir -p "$project/Helpers"
mkdir -p "$project/reports"
cat > "$project/attendance_checker.py" <<EOF
import csv
import json
import os
from datetime import datetime

def run_attendance_check():
    # 1. Load Config
    with open('Helpers/config.json', 'r') as f:
        config = json.load(f)
    
    # 2. Archive old reports.log if it exists
    if os.path.exists('reports/reports.log'):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        os.rename('reports/reports.log', f'reports/reports_{timestamp}.log.archive')

    # 3. Process Data
    with open('Helpers/assets.csv', mode='r') as f, open('reports/reports.log', 'w') as log:
        reader = csv.DictReader(f)
        total_sessions = config['total_sessions']
        
        log.write(f"--- Attendance Report Run: {datetime.now()} ---\n")
        
        for row in reader:
            name = row['Names']
            email = row['Email']
            attended = int(row['Attendance Count'])
            
            # Simple Math: (Attended / Total) * 100
            attendance_pct = (attended / total_sessions) * 100
            
            message = ""
            if attendance_pct < config['thresholds']['failure']:
                message = f"URGENT: {name}, your attendance is {attendance_pct:.1f}%. You will fail this class."
            elif attendance_pct < config['thresholds']['warning']:
                message = f"WARNING: {name}, your attendance is {attendance_pct:.1f}%. Please be careful."
            
            if message:
                if config['run_mode'] == "live":
                    log.write(f"[{datetime.now()}] ALERT SENT TO {email}: {message}\n")
                    print(f"Logged alert for {name}")
                else:
                    print(f"[DRY RUN] Email to {email}: {message}")

if __name__ == "__main__":
    run_attendance_check()
EOF
cat > "$project/Helpers/assets.csv" <<EOF
Email,Names,Attendance Count,Absence Count
alice@example.com,Alice Johnson,14,1
bob@example.com,Bob Smith,7,8
charlie@example.com,Charlie Davis,4,11
diana@example.com,Diana Prince,15,0
EOF
cat > "$project/Helpers/config.json" <<EOF
{
    "thresholds": {
        "warning": 75,
        "failure": 50
    },
    "run_mode": "live",
    "total_sessions": 15
    }
EOF
cat > "$project/reports/reports.log" <<EOF
   --- Attendance Report Run: 2026-02-06 18:10:01.468726 ---
[2026-02-06 18:10:01.469363] ALERT SENT TO bob@example.com: URGENT: Bob Smith, your attendance is 46.7%. You will fail this class.
[2026-02-06 18:10:01.469424] ALERT SENT TO charlie@example.com: URGENT: Charlie Davis, your attendance is 26.7%. You will fail this class.
EOF
echo "Do you want to update attendance thresholds? (yes/no)"
read choice

if [ "$choice" = "yes" ]; then

    echo "Enter Warning Threshold:"
    read warning

    echo "Enter Failure Threshold:"
    read failure

sed -i "s/\"warning\": 75/\"warning\": $warning/" "$project/Helpers/config.json"
sed -i "s/\"failure\": 50/\"failure\": $failure/" "$project/Helpers/config.json"

fi
echo "Running Health Check..."

if python3 --version >/dev/null 2>&1
then
    echo "SUCCESS: Python3 is installed."
else
    echo "WARNING: Python3 is not installed."
fi
if [ -f "$project/attendance_checker.py" ] &&
   [ -f "$project/Helpers/assets.csv" ] &&
   [ -f "$project/Helpers/config.json" ] &&
   [ -f "$project/reports/reports.log" ]
then
    echo "SUCCESS: Directory structure verified."
else
    echo "ERROR: Directory structure is incorrect."
fi