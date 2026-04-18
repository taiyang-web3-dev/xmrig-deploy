#!/bin/bash
cd ~/miner-config

git fetch origin
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse @{u} 2>/dev/null)

if [ "$LOCAL" != "$REMOTE" ]; then
    echo "$(date): New config detected, updating..." >> ~/logs/update.log
    git pull
    
    # 运行智能配置
    ~/miner-config/scripts/auto_config.sh
fi
