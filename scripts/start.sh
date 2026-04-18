#!/bin/bash
cd ~/xmrig
pkill xmrig 2>/dev/null
./xmrig --config=config.json >> ~/logs/xmrig.log 2>&1 &
echo "XMRig started with PID: $!"
