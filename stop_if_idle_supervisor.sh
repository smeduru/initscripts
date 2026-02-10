#!/bin/bash

# CONFIGURATION
IDLE_LIMIT=300       # Time in seconds (e.g., 5 minutes)
CPU_THRESHOLD=5      # CPU usage below this % is considered idle
IDLE_COUNT=0

echo "Supervisor: Starting idle monitor..."

while true; do
    # 1. Check for active SSH users
    USER_COUNT=$(who | wc -l)

    # 2. Check CPU usage (using 'top' to get a 1-second average)
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
    CPU_USAGE_INT=${CPU_USAGE%.*} # Convert to integer

    # 3. Determine if idle
    if [ "$USER_COUNT" -eq 0 ] && [ "$CPU_USAGE_INT" -lt "$CPU_THRESHOLD" ]; then
        ((IDLE_COUNT+=60))
        echo "System idle for $IDLE_COUNT seconds..."
    else
        IDLE_COUNT=0
        # Optional: echo "Activity detected. Resetting timer."
    fi

    # 4. Take action if limit reached
    if [ "$IDLE_COUNT" -ge "$IDLE_LIMIT" ]; then
        echo "Idle limit reached. Shutting down..."
        
        # ACTION: Shutdown the server
        sudo shutdown -h now
        
        # ALTERNATIVE ACTION: If you just want to stop another Supervisor process:
        # supervisorctl stop my_expensive_app
        
        exit 0
    fi

    sleep 60
done
