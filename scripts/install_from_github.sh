#!/bin/bash
echo "========================================="
echo "M4 一键安装包 - 从 GitHub 下载安装"
echo "========================================="

echo "[1/3] 下载安装包..."
curl -L -o /tmp/M4_Deploy_Pack.zip https://github.com/taiyang-web3-dev/xmrig-deploy/releases/download/v1.0.0/M4_Deploy_Pack.zip

echo "[2/3] 解压安装包..."
cd ~
unzip -o /tmp/M4_Deploy_Pack.zip -d /tmp/m4_install

echo "[3/3] 运行安装..."
cd /tmp/m4_install/M4_Deploy_Pack
chmod +x install_all.sh
./install_all.sh

rm -rf /tmp/m4_install /tmp/M4_Deploy_Pack.zip
echo "========================================="
echo "安装完成！"
echo "========================================="
