#!/bin/bash
# XMRig 自动安装配置脚本
# CPU 限制: 5 线程 (约 50%)
# 钱包: DOGE:DTiQZt5t2iB7agoGbzrFJYMFePWJ8yNkrx.worker

set -e

# ============================================
# 配置区域
# ============================================

WALLET_ADDR="DTiQZt5t2iB7agoGbzrFJYMFePWJ8yNkrx"
WORKER_NAME="worker"
CPU_THREADS=5
POOL_URL="rx.unmineable.com"
POOL_PORT="443"
VERSION="6.25.0"
ARCH="macos-arm64"

# ============================================
# 以下不需要修改
# ============================================

DOWNLOAD_URL="https://github.com/xmrig/xmrig/releases/download/v${VERSION}/xmrig-${VERSION}-${ARCH}.tar.gz"
TAR_FILE="xmrig-${VERSION}-${ARCH}.tar.gz"
EXTRACT_DIR="xmrig-${VERSION}"
CONFIG_FILE="config.json"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
print_status() { echo -e "${GREEN}[+]${NC} $1"; }
print_error() { echo -e "${RED}[!]${NC} $1"; }

if [[ "$(uname)" != "Darwin" ]]; then
    print_error "此脚本仅支持 macOS"
    exit 1
fi

if ! command -v curl &> /dev/null; then
    print_error "curl 未安装"
    exit 1
fi

cleanup() {
    print_status "清理旧文件..."
    pkill -f xmrig 2>/dev/null || true
    rm -rf ~/xmrig-* 2>/dev/null || true
    rm -f "$TAR_FILE" 2>/dev/null || true
}

download() {
    print_status "下载 XMRig ${VERSION}..."
    curl -L --progress-bar -o "$TAR_FILE" "$DOWNLOAD_URL" || \
    curl -L --progress-bar -o "$TAR_FILE" "https://ghproxy.net/${DOWNLOAD_URL}"
    [ ! -f "$TAR_FILE" ] && { print_error "下载失败"; exit 1; }
}

extract() {
    print_status "解压..."
    tar -xzf "$TAR_FILE"
    cd "$EXTRACT_DIR"
}

create_config() {
    print_status "创建配置文件（CPU 限制: ${CPU_THREADS} 线程）..."
    cat > "$CONFIG_FILE" << CFG
{
    "autosave": true,
    "cpu": {
        "enabled": true,
        "threads": ${CPU_THREADS},
        "huge-pages": true
    },
    "pools": [{
        "url": "${POOL_URL}:${POOL_PORT}",
        "user": "DOGE:${WALLET_ADDR}.${WORKER_NAME}",
        "pass": "x",
        "tls": true
    }],
    "donate-level": 1
}
CFG
}

run() {
    chmod +x xmrig
    echo "=========================================="
    echo "  挖矿启动，CPU ${CPU_THREADS} 线程"
    echo "  按 Ctrl+C 停止"
    echo "=========================================="
    ./xmrig --config=config.json
}

main() {
    echo "=========================================="
    echo "  XMRig 一键安装 (CPU ${CPU_THREADS} 线程)"
    echo "=========================================="
    cleanup
    download
    extract
    create_config
    run
}

main
