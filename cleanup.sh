#!/bin/bash

# cleanup.sh - Safely remove all VPC resources (namespaces, bridges, veths, firewall rules)


echo "[+] Destroying all VPC components..."
set -e

# Delete all namespaces
for ns in $(ip netns list | awk '{print $1}'); do
  echo "  - Deleting namespace: $ns"
  ip netns delete $ns 2>/dev/null || true
done

# Delete all VPC bridges
for br in $(ip link show type bridge | grep -oE 'br_vpc[A-Z]'); do
  echo "  - Deleting bridge: $br"
  ip link set $br down 2>/dev/null || true
  ip link delete $br type bridge 2>/dev/null || true
done

# Delete veth pairs (vpcA-*, vpcB-*, A_*, B_*)
for veth in $(ip link show | grep -E 'vpc|A_|B_' | awk -F: '{print $2}' | awk '{print $1}'); do
  echo "  - Removing veth interface: $veth"
  ip link delete $veth 2>/dev/null || true
done

# Flush and reset iptables
echo "[+] Flushing iptables rules..."
iptables -F
iptables -t nat -F
iptables -X

echo "[✓] Cleanup complete! All virtual networks removed."

