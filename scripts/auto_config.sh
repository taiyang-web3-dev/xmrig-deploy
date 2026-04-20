#!/bin/bash

# 获取当前内存使用率
MEM_PERCENT=$(vm_stat | awk '/Pages free/ {free=$3; total=free+$5+$7+$9; used=total-free; printf "%.0f", used/total*100}')

# 获取 CPU 核心数
CPU_CORES=$(sysctl -n hw.ncpu)

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

# 决策逻辑：最低 4 线程，最高 6 线程
if [ $MEM_PERCENT -gt 90 ]; then
    # 内存紧张 -> 4 线程（最低保障）
    THREADS=4
    CONFIG_FILE="configs/config.4threads.json"
    echo "$(date): MEMORY CRITICAL (${MEM_PERCENT}%), using 4 threads (minimum)"
elif [ $OPTIMAI_RUNNING -eq 1 ] && [ $NEXUS_RUNNING -eq 1 ]; then
    # 双主业 -> 4 线程
    THREADS=4
    CONFIG_FILE="configs/config.4threads.json"
    echo "$(date): OptimAI + Nexus running, using 4 threads"
elif [ $OPTIMAI_RUNNING -eq 1 ] || [ $NEXUS_RUNNING -eq 1 ]; then
    # 单主业 -> 5 线程（如果内存充足）
    if [ $MEM_PERCENT -lt 80 ]; then
        THREADS=5
        CONFIG_FILE="configs/config.5threads.json"
        echo "$(date): Main task + good memory (${MEM_PERCENT}%), using 5 threads"
    else
        THREADS=4
        CONFIG_FILE="configs/config.4threads.json"
        echo "$(date): Main task + moderate memory (${MEM_PERCENT}%), using 4 threads"
    fi
else
    # 无主业 -> 6 线程（如果内存充足）
    if [ $MEM_PERCENT -lt 80 ]; then
        THREADS=6
        CONFIG_FILE="configs/config.6threads.json"
        echo "$(date): No main tasks + good memory (${MEM_PERCENT}%), using 6 threads"
    elif [ $MEM_PERCENT -lt 90 ]; then
        THREADS=5
        CONFIG_FILE="configs/config.5threads.json"
        echo "$(date): No main tasks + moderate memory (${MEM_PERCENT}%), using 5 threads"
    else
        THREADS=4
        CONFIG_FILE="configs/config.4threads.json"
        echo "$(date): No main tasks + high memory (${MEM_PERCENT}%), using 4 threads"
    fi
fi

WORKER_ID=$(/usr/sbin/scutil --get LocalHostName | sed 's/ /_/g' | sed 's/-/_/g')
cd ~/miner-config
sed "s/{{WORKER_ID}}/$WORKER_ID/g" $CONFIG_FILE > ~/xmrig/config.json

~/miner-config/scripts/start.sh
