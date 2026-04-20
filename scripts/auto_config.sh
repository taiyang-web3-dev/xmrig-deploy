#!/bin/bash

echo "$(date): Starting auto_config.sh"

mkdir -p ~/logs

MEM_PERCENT=$(vm_stat | awk '/Pages free/ {free=$3; total=free+$5+$7+$9; used=total-free; printf "%.0f", used/total*100}')

if pgrep -f "optimai" > /dev/null; then
    OPTIMAI_RUNNING=1
else
    OPTIMAI_RUNNING=0
fi

if pgrep -f "nexus-cli" > /dev/null; then
    NEXUS_RUNNING=1
else
    NEXUS_RUNNING=0
fi

# 统一使用 config.auto.json，它已经包含了4线程的配置
CONFIG_FILE="configs/config.auto.json"
echo "$(date): Using 4 threads (OptimAI=$OPTIMAI_RUNNING, Nexus=$NEXUS_RUNNING, MEM=${MEM_PERCENT}%)"

WORKER_ID=$(/usr/sbin/scutil --get LocalHostName | sed 's/ /_/g' | sed 's/-/_/g')
cd ~/miner-config

if [ ! -f "$CONFIG_FILE" ]; then
    echo "$(date): ERROR - Config file $CONFIG_FILE not found!"
    exit 1
fi

# 生成配置
sed "s/{{WORKER_ID}}/$WORKER_ID/g" "$CONFIG_FILE" > ~/xmrig/config.json

if [ ! -s ~/xmrig/config.json ]; then
    echo "$(date): ERROR - Generated config is empty!"
    exit 1
fi

echo "$(date): Config generated successfully"

~/miner-config/scripts/start.sh
echo "$(date): auto_config.sh completed"
