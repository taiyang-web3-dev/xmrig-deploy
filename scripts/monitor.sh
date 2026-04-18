#!/bin/bash
# 守护进程：根据主业负载自动切换线程数

MONITOR_LOG=~/logs/monitor.log
CURRENT_MODE=""

while true; do
    if pgrep -f "optimai|nexusr|gensyn|dkn-compute" > /dev/null; then
        DESIRED_MODE="3threads"
    else
        DESIRED_MODE="5threads"
    fi
    
    if [ "$DESIRED_MODE" != "$CURRENT_MODE" ]; then
        echo "$(date): Switching to $DESIRED_MODE mode" >> $MONITOR_LOG
        
        WORKER_ID=$(scutil --get LocalHostName | sed 's/ /_/g' | sed 's/-/_/g')
        cd ~/miner-config
        sed "s/{{WORKER_ID}}/$WORKER_ID/g" configs/config.${DESIRED_MODE}.json > ~/xmrig/config.json
        
        ~/miner-config/scripts/start.sh
        CURRENT_MODE=$DESIRED_MODE
    fi
    
    sleep 30
done
