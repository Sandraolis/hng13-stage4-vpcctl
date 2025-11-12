
# 🧩 Stage 4 DevOps Project — Build My Own Virtual Private Cloud (VPC) on Linux

This project simulates an AWS-like VPC environment entirely using **Linux networking tools** such as:
- `ip`, `ip netns`, `ip link`, `bridge`
- `iptables`
- Bash scripting for automation

The goal is to create isolated VPCs, subnets, NAT gateways, and firewall rules — just like in a real cloud environment.

---

## 🚀 Features

✅ Create virtual VPCs  
✅ Add multiple subnets (public & private)  
 Enable NAT for public subnet internet access  
 Apply firewall rules (via `rules.json`)  
 Full automation setup (`setup.sh`) and teardown (`cleanup.sh`)

---

##  Architecture Overview

               ┌──────────────────────────────┐
               │        HOST MACHINE          │
               │   (Ubuntu VM - VirtualBox)   │
               │                              │
               │   +----------------------+   │
               │   | Bridge: br_vpcA      |   │
               │   | Acts as VPC Router   |   │
               │   +----------┬-----------+   │
               │              │               │
    ┌──────────┴────────────┐ │ ┌───────────┴───────────┐
    │ ns_vpcA_public1       │ │ │ ns_vpcA_private1      │
    │ Public Subnet (10.20) │ │ │ Private Subnet (10.20)│
    │ NAT + Web Server      │ │ │ Internal Only         │
    └───────────────────────┘ │ └───────────────────────┘
               │
          Internet Access
         via Host Interface


---

# 🧩 Project Structure

vpc-lab/
├── vpcctl # Bash CLI for creating VPCs, subnets, NAT & firewall
├── setup.sh # Automation script for full setup
├── cleanup.sh # Cleanup script to remove all virtual networks
├── rules.json # Firewall rule configuration
├── README.md # Documentation
└── vpcctl.log # Logs actions (created automatically)


---

## 🧪 Usage

# 1️⃣ Setup VPC environment
```bash
sudo bash setup.sh



# 2️⃣ Verify resources

sudo ip netns list
ip link show type bridge



# 3️⃣ Test connectivity

sudo ip netns exec ns_vpcA_public1 ping -c 3 8.8.8.8
sudo ip netns exec ns_vpcA_private1 curl http://10.20.1.10



# 4️⃣ Cleanup environment

sudo bash cleanup.sh



# 🧱 Firewall Rules Example (rules.json)

{
  "subnet": "10.20.1.0/24",
  "ingress": [
    {"port": 80, "protocol": "tcp", "action": "allow"},
    {"port": 22, "protocol": "tcp", "action": "deny"},
    {"port": 443, "protocol": "tcp", "action": "allow"}
  ]
}




---

## 🖼️ STEP 4 — Save/Files

Save the file:  
**Ctrl + O**, then press **Enter**  
Exit nano:  
**Ctrl + X**

---
      COMMANDS

# 1️. Cleanup any previous runs
sudo bash cleanup.sh

# 2️. Deploy full environment
sudo bash setup.sh

# 3️. Verify namespaces and bridge
sudo ip netns list
ip link show type bridge

# 4️. Test web server manually (optional)
sudo ip netns exec ns_vpcA_public1 python3 -m http.server 80 &
sudo ip netns exec ns_vpcA_private1 curl http://10.20.1.10

# 5️. Show firewall rules
sudo ip netns exec ns_vpcA_public1 iptables -L

# 6️. Teardown for a clean exit
sudo bash cleanup.sh



