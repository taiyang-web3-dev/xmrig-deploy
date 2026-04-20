#!/bin/bash

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

# 决策逻辑
if [ $MEM_PERCENT -gt 90 ]; then
    CONFIG_FILE="configs/config.2threads.json"
    echo "$(date): MEMORY CRITICAL (${MEM_PERCENT}%), using 2 threads"
elif [ $OPTIMAI_RUNNING -eq 1 ] && [ $NEXUS_RUNNING -eq 1 ]; then
    CONFIG_FILE="configs/config.3threads.json"
    echo "$(date): OptimAI + Nexus running, using 3 threads"
else
    # 默认：4 线程（无论是否有主业）
    CONFIG_FILE="configs/config.auto.json"
    echo "$(date): Using 4 threads (OptimAI=$OPTIMAI_RUNNING, Nexus=$NEXUS_RUNNING, MEM=${MEM_PERCENT}%)"
fi

WORKER_ID=$(/usr/sbin/scutil --get LocalHostName | sed 's/ /_/g' | sed 's/-/_/g')
cd ~/miner-config
sed "s/{{WORKER_ID}}/$WORKER_ID/g" $CONFIG_FILE > ~/xmrig/config.json

~/miner-config/scripts/start.sh
