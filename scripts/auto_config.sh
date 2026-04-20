#!/bin/bash
# 强制使用 4 线程，不检测主业
CONFIG_FILE="configs/config.auto.json"
WORKER_ID=$(/usr/sbin/scutil --get LocalHostName | sed 's/ /_/g' | sed 's/-/_/g')
cd ~/miner-config
sed "s/{{WORKER_ID}}/$WORKER_ID/g" $CONFIG_FILE > ~/xmrig/config.json
~/miner-config/scripts/start.sh
