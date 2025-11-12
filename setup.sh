#!/bin/bash

# ========================================
# DevOps Stage 4 - Automated VPC Deployment Script
# ========================================

set -e

echo "Starting automated VPC setup..."
sleep 1

# --- Clean previous state ---
sudo ./vpcctl destroy-all 2>/dev/null || true
echo "[+] Cleaned up previous VPC state"

# --- Step 1: Create VPC A ---
sudo ./vpcctl vpc create vpcA 10.20.0.0/16
sleep 1

# --- Step 2: Add Subnets ---
sudo ./vpcctl subnet add vpcA public1 10.20.1.0/24
sudo ./vpcctl subnet add vpcA private1 10.20.2.0/24
sleep 1

# --- Step 3: Enable NAT on the public subnet ---
sudo ./vpcctl nat enable vpcA public1
sleep 1

# --- Step 4: Test connectivity (public subnet only) ---
echo "[*] Testing internet access from public subnet..."
sudo ip netns exec ns_vpcA_public1 ping -c 3 8.8.8.8 || echo "[!] Internet test failed (check NAT config)"
sleep 1

echo "[*] Testing blocked access from private subnet..."
sudo ip netns exec ns_vpcA_private1 ping -c 3 8.8.8.8 || echo "[✓] Private subnet correctly isolated."
sleep 1

# --- Step 5: Apply Firewall Rules ---
cat <<EOF > rules.json
{
  "subnet": "10.20.1.0/24",
  "ingress": [
    {"port": 80, "protocol": "tcp", "action": "allow"},
    {"port": 22, "protocol": "tcp", "action": "deny"},
    {"port": 443, "protocol": "tcp", "action": "allow"}
  ]
}
EOF

sudo ./vpcctl firewall apply ns_vpcA_public1 rules.json
sleep 1

# --- Step 6: Show routing & iptables summary ---
echo "[+] Namespace Routing Table (Public Subnet)"
sudo ip netns exec ns_vpcA_public1 ip route

echo "[+] Firewall Rules (Public Subnet)"
sudo ip netns exec ns_vpcA_public1 iptables -L
sleep 1

# --- Step 7: Deploy Simple HTTP Server ---
echo "[*] Launching test web server on ns_vpcA_public1 (port 80)..."
sudo ip netns exec ns_vpcA_public1 nohup python3 -m http.server 80 >/dev/null 2>&1 &
sleep 2

echo "[*] Testing connectivity from private subnet to public subnet web server..."
sudo ip netns exec ns_vpcA_private1 curl -s -o /dev/null -w "%{http_code}\n" 10.20.1.10
sleep 1

# --- Step 8: Cleanup ---
echo "[*] Cleaning up after demo..."
sudo ./vpcctl destroy-all
echo "Cleanup complete."

echo "Stage 4 Project automation complete!"

