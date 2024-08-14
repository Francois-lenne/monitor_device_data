#!/bin/bash

date_to_check=$(date +"%d_%m_%Y")

# Path of the file to check
file_path="/Users/francoislenne/monitor_time_devices/files/data_mac_${date_to_check}.csv"

echo "Script executed at $(date)" >> /Users/francoislenne/monitor_time_devices/script.log

if [ -f "$file_path" ]; then
    echo "The file $file_path is present." >> /Users/francoislenne/monitor_time_devices/script.log
else
    echo "The file $file_path is absent." >> /Users/francoislenne/monitor_time_devices/script.log
    # Execute the Python script main.py with sudo without password, using the venv Python and passing environment variables
    sudo R2_ENDPOINT="$R2_ENDPOINT" R2_ACCESS_KEY="$R2_ACCESS_KEY" R2_SECRET_KEY="$R2_SECRET_KEY" /Users/francoislenne/monitor_time_devices/time/bin/python /Users/francoislenne/monitor_time_devices/main.py >> /Users/francoislenne/monitor_time_devices/script.log 2>&1
fi