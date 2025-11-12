#!/bin/bash

# test_webapp.sh — deploy and verify web app in public subnet

PUB_NS="ns_vpcA_public1"
PRIV_NS="ns_vpcA_private1"
PUB_IP="10.20.1.10"
PORT=80

echo "==============================================="
echo "[*] Launching simple web server in $PUB_NS ..."
echo "==============================================="

# Stop any old server that may still be running
sudo pkill -f "python3 -m http.server" 2>/dev/null

# Start a new Python HTTP server in the public subnet namespace
sudo ip netns exec $PUB_NS python3 -m http.server $PORT >/dev/null 2>&1 &

sleep 2

# Verify the process started
if sudo ip netns exec $PUB_NS lsof -i :$PORT >/dev/null 2>&1; then
    echo "[+] Web server successfully started on port $PORT inside $PUB_NS"
else
    echo "[!] Failed to start web server. Check namespace or port."
    exit 1
fi

echo
echo "==============================================="
echo "[*] Testing connectivity from host ..."
echo "==============================================="

if curl -s --connect-timeout 3 http://$PUB_IP >/dev/null; then
    echo "[✓] Host can reach the web app in public subnet ($PUB_IP)"
else
    echo "[✗] Host cannot reach public subnet app — check NAT/firewall."
fi

echo
echo "==============================================="
echo "[*] Testing connectivity from private subnet ..."
echo "==============================================="

if sudo ip netns exec $PRIV_NS curl -s --connect-timeout 3 http://$PUB_IP >/dev/null; then
    echo "[✗] Private subnet can reach public app (should be blocked)"
else
    echo "[✓] Private subnet is correctly isolated (no access to public app)"
fi

echo
echo "[*] Stopping web server..."
sudo pkill -f "python3 -m http.server" 2>/dev/null
echo "[+] Test complete."
echo "==============================================="

