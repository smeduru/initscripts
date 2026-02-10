#!/bin/bash

cat << 'EOF' > /usr/local/bin/stop_if_idle.sh
#!/bin/bash
THRESHOLD=5
IDLE_TIME_LIMIT=3600
IDLE_COUNT=0
CONTAINER_ID=$(echo ${VAST_CONTAINERLABEL} | awk -F. '{print $2}')
while true; do
    GPU_UTIL=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits)
    if [ "$GPU_UTIL" -lt "$THRESHOLD" ]; then
        IDLE_COUNT=$((IDLE_COUNT + 60))
    else
        IDLE_COUNT=0
    fi
    if [ "$IDLE_COUNT" -ge "$IDLE_TIME_LIMIT" ]; then
        vastai stop instance $CONTAINER_ID
        exit 0
    fi
    sleep 60
done
EOF

chmod +x /usr/local/bin/stop_if_idle.sh
nohup /usr/local/bin/stop_if_idle.sh > /workspace/shutdown.log 2>&1 &
