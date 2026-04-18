#!/bin/bash
echo "=== XMRig Status ==="
if pgrep xmrig > /dev/null; then
    echo "Status: RUNNING"
    echo "PID: $(pgrep xmrig)"
    echo ""
    echo "Last 5 log lines:"
    tail -5 ~/logs/xmrig.log 2>/dev/null || echo "No log file"
else
    echo "Status: STOPPED"
fi
