#!/bin/sh

# Set the log file path
LOG_FILE="/var/log/update_dns.log"

# Log when the container starts
echo "$(date): Starting container" >> "$LOG_FILE"

# Run the update_dns script once
/usr/local/bin/update_dns.sh

# Start the cron daemon
crond -L /var/log/cron.log

# Tail the logs to keep the container running
tail -f /var/log/update_dns.log /var/log/cron.log &

# Log when the container stops
trap "echo $(date): Stopping container >> $LOG_FILE" EXIT

# Wait for the container to stop
wait
