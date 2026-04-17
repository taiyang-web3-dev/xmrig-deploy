#!/bin/bash
# XMRig 自动安装配置脚本
# GitHub: 你的仓库地址
# CPU 使用率限制: 50%

set -e

# ============================================
# 配置区域（请修改为你的信息）
# ============================================

# 你的 DOGE 钱包地址
WALLET_ADDR="DTiQZt5t2iB7agoGbzrFJYMFePWJ8yNkrx"
WORKER_NAME="worker"  # 可以改成设备名或固定名称

# CPU 使用率限制（百分比，默认 50）
CPU_MAX_THREADS_HINT=50

# 矿池配置
POOL_URL="rx.unmineable.com"
POOL_PORT="443"  # 443 是 SSL 端口，需要 tls 支持

# ============================================
# 以下一般不需要修改
# ============================================

VERSION="6.25.0"
ARCH="macos-arm64"
DOWNLOAD_URL="https://github.com/xmrig/xmrig/releases/download/v${VERSION}/xmrig-${VERSION}-${ARCH}.tar.gz"
EXTRACT_DIR="xmrig-${VERSION}"
CONFIG_FILE="config.json"

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() { echo -e "${GREEN}[+]${NC} $1"; }
print_error() { echo -e "${RED}[!]${NC} $1"; }

# 检查系统
if [[ "$(uname)" != "Darwin" ]]; then
    print_error "此脚本仅支持 macOS"
    exit 1
fi

# 检查依赖
if ! command -v curl &> /dev/null; then
    print_error "curl 未安装"
    exit 1
fi

# 清理旧文件
cleanup() {
    [ -f "$TAR_FILE" ] && rm -f "$TAR_FILE"
    [ -d "$EXTRACT_DIR" ] && rm -rf "$EXTRACT_DIR"
}

# 下载
download() {
    print_status "下载 XMRig ${VERSION}..."
    curl -L "$DOWNLOAD_URL" -o "$TAR_FILE"
    if [ ! -f "$TAR_FILE" ]; then
        print_error "下载失败"
        exit 1
    fi
}

# 解压
extract() {
    print_status "解压..."
    tar -xzf "$TAR_FILE"
    cd "$EXTRACT_DIR"
}

# 创建配置（CPU 限制 50%）
create_config() {
    print_status "创建配置文件（CPU 限制 ${CPU_MAX_THREADS_HINT}%）..."
    
    cat > "$CONFIG_FILE" << CFG
{
    "api": {
        "id": null,
        "worker-id": null
    },
    "http": {
        "enabled": false,
        "host": "127.0.0.1",
        "port": 0,
        "access-token": null,
        "restricted": true
    },
    "autosave": true,
    "background": false,
    "colors": true,
    "title": true,
    "randomx": {
        "init": -1,
        "init-avx2": -1,
        "mode": "auto",
        "1gb-pages": false,
        "rdmsr": true,
        "wrmsr": false,
        "cache_qos": false,
        "numa": true,
        "scratchpad_prefetch_mode": 1
    },
    "cpu": {
        "enabled": true,
        "huge-pages": true,
        "huge-pages-jit": false,
        "hw-aes": null,
        "priority": null,
        "memory-pool": false,
        "yield": true,
        "max-threads-hint": ${CPU_MAX_THREADS_HINT},
        "argon2-impl": null,
        "argon2": [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
        "cn": [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
        "cn-heavy": [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
        "cn-lite": [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
        "cn-pico": [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
        "cn/upx2": [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
        "ghostrider": [[8, 0], [8, 1], [8, 2], [8, 3], [8, 4], [8, 5], [8, 6], [8, 7], [8, 8], [8, 9]],
        "rx": [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
        "rx/wow": [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    },
    "opencl": {"enabled": false},
    "cuda": {"enabled": false},
    "log-file": null,
    "donate-level": 1,
    "pools": [
        {
            "algo": null,
            "coin": null,
            "url": "${POOL_URL}:${POOL_PORT}",
            "user": "DOGE:${WALLET_ADDR}.${WORKER_NAME}",
            "pass": "x",
            "rig-id": null,
            "nicehash": false,
            "keepalive": false,
            "enabled": true,
            "tls": true,
            "sni": false,
            "tls-fingerprint": null,
            "daemon": false,
            "socks5": null,
            "self-select": null,
            "submit-to-origin": false
        }
    ],
    "retries": 5,
    "retry-pause": 5,
    "print-time": 60,
    "syslog": false,
    "tls": {"enabled": true},
    "dns": {"ip_version": 0, "ttl": 30},
    "user-agent": null,
    "verbose": 0,
    "watch": true,
    "pause-on-battery": false,
    "pause-on-active": false
}
CFG

    print_status "配置完成"
    echo "  矿池: ${POOL_URL}"
    echo "  钱包: DOGE:${WALLET_ADDR}.${WORKER_NAME}"
    echo "  CPU 限制: ${CPU_MAX_THREADS_HINT}%"
}

# 设置权限并启动
run() {
    chmod +x xmrig
    
    print_status "启动 XMRig..."
    echo "=========================================="
    echo "  挖矿已启动，CPU 使用率限制 ${CPU_MAX_THREADS_HINT}%"
    echo "  按 Ctrl+C 停止"
    echo "=========================================="
    
    ./xmrig --config=config.json
}

# 主流程
TAR_FILE="xmrig-${VERSION}-${ARCH}.tar.gz"

cleanup
download
extract
create_config
run
