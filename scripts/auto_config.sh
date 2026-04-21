#!/bin/bash

echo "$(date): Starting auto_config.sh"
mkdir -p ~/logs

# 简单可靠的内存检测
MEM_PERCENT=$(top -l 1 | grep "PhysMem" | awk '{print $2}' | tr -d '%')

# 默认使用 4 线程
CONFIG_FILE="configs/config.4threads.json"

if [ -n "$MEM_PERCENT" ] && [ "$MEM_PERCENT" -gt 95 ] 2>/dev/null; then
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

# 生成配置，替换占位符
sed "s/{{WORKER_ID}}/$WORKER_ID/g" "$CONFIG_FILE" > ~/xmrig/config.json

# 验证配置不为空
if [ ! -s ~/xmrig/config.json ]; then
    echo "$(date): ERROR - Generated config is empty!"
    exit 1
fi

echo "$(date): Config generated successfully"
~/miner-config/scripts/start.sh
echo "$(date): auto_config.sh completed"
