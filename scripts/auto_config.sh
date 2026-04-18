#!/bin/bash
cat > scripts/auto_config.sh << 'EOF'
#!/bin/bash

# 获取当前内存使用率
MEM_PERCENT=$(vm_stat | awk '/Pages free/ {free=$3; total=free+$5+$7+$9; used=total-free; printf "%.0f", used/total*100}')

# 检测 Nexus 是否在运行
if pgrep -f "nexus-cli" > /dev/null; then
    NEXUS_RUNNING=1
else
    NEXUS_RUNNING=0
fi

# 决定使用哪个配置
if [ $MEM_PERCENT -gt 90 ] || [ $NEXUS_RUNNING -eq 1 ]; then
    # 内存紧张或 Nexus 运行中 -> 使用 3 线程
    CONFIG_FILE="configs/config.3threads.json"
    echo "$(date): High memory pressure (${MEM_PERCENT}%) or Nexus running, using 3 threads"
else
    # 内存充足 -> 使用 4 线程
    CONFIG_FILE="configs/config.auto.json"
    echo "$(date): Normal memory (${MEM_PERCENT}%), using 4 threads"
fi

# 应用配置
WORKER_ID=$(scutil --get LocalHostName | sed 's/ /_/g' | sed 's/-/_/g')
cd ~/miner-config
sed "s/{{WORKER_ID}}/$WORKER_ID/g" $CONFIG_FILE > ~/xmrig/config.json

# 重启挖矿
~/miner-config/scripts/start.sh
