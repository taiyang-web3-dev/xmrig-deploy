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
    # 内存极度紧张 -> 2 线程
    CONFIG_FILE="configs/config.2threads.json"
    echo "$(date): MEMORY CRITICAL (${MEM_PERCENT}%), using 2 threads"
elif [ $OPTIMAI_RUNNING -eq 1 ] && [ $NEXUS_RUNNING -eq 1 ]; then
    # 两个主业都在跑 -> 3 线程
    CONFIG_FILE="configs/config.3threads.json"
    echo "$(date): OptimAI + Nexus running, using 3 threads"
elif [ $OPTIMAI_RUNNING -eq 1 ] || [ $NEXUS_RUNNING -eq 1 ]; then
    # 只有一个主业 -> 4 线程
    CONFIG_FILE="configs/config.auto.json"
    echo "$(date): Main task running (OptimAI=$OPTIMAI_RUNNING, Nexus=$NEXUS_RUNNING), using 4 threads"
else
    # 无主业，全力挖矿 -> 6 线程
    CONFIG_FILE="configs/config.full.json"
    echo "$(date): No main tasks, using 6 threads"
fi

# 应用配置
WORKER_ID=$(/usr/sbin/scutil --get LocalHostName | sed 's/ /_/g' | sed 's/-/_/g')
cd ~/miner-config
sed "s/{{WORKER_ID}}/$WORKER_ID/g" $CONFIG_FILE > ~/xmrig/config.json

# 重启挖矿
~/miner-config/scripts/start.sh
