#!/bin/bash
pkill xmrig 2>/dev/null
cd ~/xmrig
./xmrig --config=config.json >> ~/logs/xmrig.log 2>&1 &
echo "XMRig started with PID: $!"
