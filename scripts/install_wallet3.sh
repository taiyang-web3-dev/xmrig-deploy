#!/bin/bash
set -e

GITHUB_REPO="taiyang-web3-dev/xmrig-deploy"
WORKER_ID=$(scutil --get LocalHostName | sed 's/ /_/g' | sed 's/-/_/g')
WALLET="DF5Mjzk69kHwEE874nXDVtNqdn5UrYRhJk"

echo "========================================="
echo "M4 Miner Installer - AlCoreCloud (2 threads)"
echo "Worker ID: $WORKER_ID"
echo "Wallet: $WALLET"
echo "========================================="

mkdir -p ~/logs

if [ ! -f ~/xmrig/xmrig ]; then
    echo "[1/4] Downloading xmrig..."
    mkdir -p ~/xmrig
    cd ~/xmrig
    curl -L -o xmrig.tar.gz https://github.com/xmrig/xmrig/releases/download/v6.25.0/xmrig-6.25.0-macos-arm64.tar.gz
    tar -xzf xmrig.tar.gz --strip-components=1
    rm xmrig.tar.gz
    chmod +x xmrig
fi

echo "[2/4] Fetching configuration..."
cd ~
if [ -d ~/miner-config ]; then
    cd ~/miner-config && git pull
else
    git clone https://github.com/$GITHUB_REPO.git ~/miner-config
fi

echo "[3/4] Generating config for worker: $WORKER_ID"
cd ~/miner-config
sed "s/{{WORKER_ID}}/$WORKER_ID/g" configs/config.2threads.json | sed "s/{{WALLET}}/$WALLET/g" > ~/xmrig/config.json

echo "[4/4] Setting up auto-update..."
(crontab -l 2>/dev/null | grep -v "miner-config/scripts/update.sh"; echo "*/5 * * * * ~/miner-config/scripts/update.sh >> ~/logs/update.log 2>&1") | crontab -

~/miner-config/scripts/start.sh

echo "========================================="
echo "Installation complete!"
echo "Wallet: $WALLET"
echo "========================================="
