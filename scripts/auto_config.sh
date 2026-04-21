#!/bin/bash
echo "$(date): Starting auto_config.sh"
mkdir -p ~/logs

# 强制使用 2 线程配置
CONFIG_FILE="configs/config.2threads.json"

WORKER_ID=$(/usr/sbin/scutil --get LocalHostName | sed 's/ /_/g' | sed 's/-/_/g')
cd ~/miner-config

if [ ! -f "$CONFIG_FILE" ]; then
    echo "$(date): ERROR - Config file $CONFIG_FILE not found!"
    exit 1
fi

sed "s/{{WORKER_ID}}/$WORKER_ID/g" "$CONFIG_FILE" > ~/xmrig/config.json

if [ ! -s ~/xmrig/config.json ]; then
    echo "$(date): ERROR - Generated config is empty!"
    exit 1
fi

echo "$(date): Config generated successfully"
~/miner-config/scripts/start.sh
echo "$(date): auto_config.sh completed"
