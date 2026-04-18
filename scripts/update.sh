#!/bin/bash
cd ~/miner-config

git fetch origin
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse @{u} 2>/dev/null)

if [ "$LOCAL" != "$REMOTE" ]; then
    echo "$(date): New config detected, updating..."
    git pull
    
    # 检测主业进程
    if pgrep -f "optimai|nexusr|gensyn|dkn-compute" > /dev/null; then
        CONFIG_MODE="3threads"
    else
        CONFIG_MODE="5threads"
    fi
    
    WORKER_ID=$(scutil --get LocalHostName | sed 's/ /_/g' | sed 's/-/_/g')
    sed "s/{{WORKER_ID}}/$WORKER_ID/g" configs/config.${CONFIG_MODE}.json > ~/xmrig/config.json
    
    ~/miner-config/scripts/start.sh
fi
