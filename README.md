
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




# 🧱 About vpcctl

I built a custom CLI tool called vpcctl, written in Bash.
It automates the creation of VPCs, subnets, bridges, NAT gateways, firewall policies, and cleanup — just like AWS VPC operations.
The CLI supports commands such as:

vpc create → to create a new virtual VPC
subnet add → to add subnets inside a VPC
NAT enable → to allow internet access for public subnets
firewall apply → to enforce security group–style rules
and destroy-all → to clean up all resources after testing.



# 🧱 Firewall Rules Example (rules.json)

The rules.json file defines the firewall rules dynamically.
It works like AWS security groups, allowing or blocking specific ports and protocols.
For example, my configuration allows ports 80 and 443 but denies port 22

{
  "subnet": "10.20.1.0/24",
  "ingress": [
    {"port": 80, "protocol": "tcp", "action": "allow"},
    {"port": 22, "protocol": "tcp", "action": "deny"},
    {"port": 443, "protocol": "tcp", "action": "allow"}
  ]
}

These rules are applied to the namespace using iptables, ensuring that only allowed traffic passes through.



1.🚀  About setup.sh

The setup.sh script is the main automation for this entire project.
It performs all the steps automatically — from creating the VPC to cleanup.
Here’s what it does in order



2.🚀  About VPC and Subnets Creation:

It creates a new VPC named vpcA and sets up both public and private subnets with their respective CIDR ranges.



3.🚀  About NAT Gateway Setup:

It enables NAT on the public subnet so that only public instances have outbound internet access.



4.🚀  About Connectivity Tests:

The script then tests connectivity 
the public subnet should reach the internet
while the private subnet remains isolated.



5.🚀  About  Firewall Enforcement:

It applies the JSON-based firewall rules to the public subnet and displays the iptables table to verify access control.



6.🚀  About Web Server Test:

A simple Python HTTP server is deployed inside the public subnet to simulate an app.
The private subnet is then tested to ensure it can reach port 80, while port 22 remains blocked.




7.🚀  About Cleanup.sh:

Finally, the script performs a complete teardown — deleting all namespaces, bridges, veth pairs, and rules.
This ensures idempotency, meaning the setup can be safely run again without duplication.
It starts by removing any previous VPCs or bridges to ensure a clean environment.

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




---

## 🖼️ STEP 4 — Save/Files

Save the file:  
**Ctrl + O**, then press **Enter**  
Exit nano:  
**Ctrl + X**

---
     🚀  COMMANDS

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



