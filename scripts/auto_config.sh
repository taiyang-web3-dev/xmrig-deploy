#!/bin/bash

echo "$(date): Starting auto_config.sh"
mkdir -p ~/logs

# 修复内存检测命令
MEM_PERCENT=$(vm_stat | grep "Pages free" | awk '{free=$3; total=free+$5+$7+$9; used=total-free; print int(used/total*100)}')

# 默认使用 4 线程
CONFIG_FILE="configs/config.4threads.json"

if [ "$MEM_PERCENT" -gt 95 ] 2>/dev/null; then
    CONFIG_FILE="configs/config.2threads.json"
    echo "$(date): MEMORY CRITICAL (${MEM_PERCENT}%), using 2 threads"
else
    echo "$(date): Memory OK (${MEM_PERCENT}%), using 4 threads"
fi

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
