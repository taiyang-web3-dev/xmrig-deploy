#!/bin/bash

echo "$(date): Starting auto_config.sh"

# 确保目录存在
mkdir -p ~/logs

# 获取当前内存使用率
MEM_PERCENT=$(vm_stat | awk '/Pages free/ {free=$3; total=free+$5+$7+$9; used=total-free; printf "%.0f", used/total*100}')

# 检测主业进程
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

# 决策逻辑：最低 4 线程
if [ $MEM_PERCENT -gt 90 ]; then
    CONFIG_FILE="configs/config.4threads.json"
    echo "$(date): MEMORY CRITICAL (${MEM_PERCENT}%), using 4 threads"
elif [ $OPTIMAI_RUNNING -eq 1 ] && [ $NEXUS_RUNNING -eq 1 ]; then
    CONFIG_FILE="configs/config.4threads.json"
    echo "$(date): OptimAI + Nexus running, using 4 threads"
else
    CONFIG_FILE="configs/config.4threads.json"
    echo "$(date): Using 4 threads (OptimAI=$OPTIMAI_RUNNING, Nexus=$NEXUS_RUNNING, MEM=${MEM_PERCENT}%)"
fi

# 生成配置
WORKER_ID=$(/usr/sbin/scutil --get LocalHostName | sed 's/ /_/g' | sed 's/-/_/g')
cd ~/miner-config

# 检查配置文件是否存在
if [ ! -f "$CONFIG_FILE" ]; then
    echo "$(date): ERROR - Config file $CONFIG_FILE not found!"
    exit 1
fi

# 生成配置并验证
sed "s/{{WORKER_ID}}/$WORKER_ID/g" $CONFIG_FILE > ~/xmrig/config.json

if [ ! -s ~/xmrig/config.json ]; then
    echo "$(date): ERROR - Generated config is empty!"
    exit 1
fi

echo "$(date): Config generated successfully"

# 启动挖矿
~/miner-config/scripts/start.sh

echo "$(date): auto_config.sh completed"
