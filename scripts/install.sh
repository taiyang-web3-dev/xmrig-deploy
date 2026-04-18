#!/bin/bash
# M4 Miner Fleet - 一键安装脚本

set -e

GITHUB_REPO="taiyang-web3-dev/xmrig-deploy"
WORKER_ID=$(scutil --get LocalHostName | sed 's/ /_/g' | sed 's/-/_/g')

echo "========================================="
echo "M4 Miner Fleet Installer"
echo "Worker ID: $WORKER_ID"
echo "========================================="

# 创建日志目录
mkdir -p ~/logs

# 1. 安装 xmrig
if [ ! -f ~/xmrig/xmrig ]; then
    echo "[1/4] Downloading xmrig..."
    mkdir -p ~/xmrig
    cd ~/xmrig
    curl -L -o xmrig.tar.gz "https://github.com/xmrig/xmrig/releases/download/v6.25.0/xmrig-6.25.0-macos-arm64.tar.gz"
    tar -xzf xmrig.tar.gz --strip-components=1
    rm xmrig.tar.gz
    chmod +x xmrig
    echo "XMRig installed"
else
    echo "[1/4] XMRig already exists"
fi

# 2. 克隆配置仓库
echo "[2/4] Fetching configuration..."
cd ~
if [ -d ~/miner-config ]; then
    cd ~/miner-config
    git pull
else
    git clone "https://github.com/$GITHUB_REPO.git" ~/miner-config
fi

# 3. 生成配置文件
echo "[3/4] Generating config for worker: $WORKER_ID"
cd ~/miner-config
sed "s/{{WORKER_ID}}/$WORKER_ID/g" configs/config.5threads.json > ~/xmrig/config.json

# 4. 设置定时任务
echo "[4/4] Setting up auto-update cron job..."
(crontab -l 2>/dev/null | grep -v "miner-config/scripts/update.sh"; echo "*/5 * * * * ~/miner-config/scripts/update.sh >> ~/logs/update.log 2>&1") | crontab -

# 启动挖矿
echo "Starting miner..."
~/miner-config/scripts/auto_config.sh

echo "========================================="
echo "Installation complete!"
echo "Monitor: tail -f ~/logs/xmrig.log"
echo "========================================="
