#!/bin/bash

echo "========================================="
echo "OptimAI CLI Installer for macOS M4"
echo "========================================="

# 1. 下载 OptimAI CLI
echo "[1/5] Downloading OptimAI CLI..."
curl -L https://cli-node.optimai.network/optimai_cli_darwin_universal2 -o /tmp/optimai-cli

# 2. 安装
echo "[2/5] Installing..."
chmod +x /tmp/optimai-cli
sudo mv /tmp/optimai-cli /usr/local/bin/optimai-cli

# 3. 检查安装
echo "[3/5] Verifying installation..."
if command -v optimai-cli &> /dev/null; then
    echo "✅ OptimAI CLI installed successfully"
    optimai-cli --version
else
    echo "❌ Installation failed"
    exit 1
fi

# 4. 登录（如果需要）
echo "[4/5] Checking login status..."
optimai-cli auth status 2>/dev/null || echo "Please run: optimai-cli auth login"

# 5. 启动节点
echo "[5/5] Starting OptimAI node..."
optimai-cli node start

echo "========================================="
echo "OptimAI node started!"
echo "Monitor: optimai-cli node status"
echo "========================================="
