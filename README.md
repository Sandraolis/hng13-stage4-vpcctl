
# 🧩 Stage 4 DevOps Project — Build My Own Virtual Private Cloud (VPC) on Linux


🌐 Overview

This project recreates the fundamentals of an AWS-like Virtual Private Cloud (VPC) entirely on Linux using only native networking tools (ip, iptables, bridge, and veth).

The project demonstrates how to:

Create isolated VPCs with unique CIDR ranges.

Add subnets (public and private) using Linux network namespaces.

Configure routing and NAT gateways for internet access.

Enforce firewall rules (security groups) using iptables.

Deploy a web application in a public subnet and verify connectivity.

Implement full automation with Bash scripts for setup and cleanup.




---

## 🚀 Features

✅ Create virtual VPCs  
✅ Add multiple subnets (public & private)  
 Enable NAT for public subnet internet access  
 Apply firewall rules (via `rules.json`)  
 Full automation setup (`setup.sh`) and teardown (`cleanup.sh`)

---

##  Architecture Overview


                 ┌──────────────────────────────────────────┐
                 │               Host Machine               │
                 │   (Ubuntu on VirtualBox)                 │
                 └──────────────────────────────────────────┘
                                │
               ┌────────────────┴────────────────┐
               │                                 │
     ┌─────────────────────┐          ┌─────────────────────┐
     │       VPC A         │          │       VPC B         │
     │   CIDR: 10.20.0.0/16│          │   CIDR: 10.30.0.0/16│
     │ Bridge: br_vpcA     │          │ Bridge: br_vpcB     │
     │                     │          │                     │
     │  ┌──────────────┐   │          │  ┌──────────────┐   │
     │  │ Public Subnet│   │          │  │ Public Subnet│   │
     │  │ 10.20.1.0/24 │   │          │  │ 10.30.1.0/24 │   │
     │  │ NAT + HTTP   │   │          │  │ NAT + HTTP   │   │
     │  └──────────────┘   │          │  └──────────────┘   │
     │  ┌──────────────┐   │          │  ┌──────────────┐   │
     │  │ Private Subnet│  │          │  │ Private Subnet│  │
     │  │ 10.20.2.0/24 │   │          │  │ 10.30.2.0/24 │   │
     │  │ Internal only│   │          │  │ Internal only│   │
     │  └──────────────┘   │          │  └──────────────┘   │
     └─────────────────────┘          └─────────────────────┘


✅ Deploy and test the web application

sudo bash test_webapp.sh


✅ Expected Output

[*] Launching simple web server in ns_vpcA_public1 ...
[+] Web server successfully started on port 80 inside ns_vpcA_public1
[*] Testing connectivity from host ...
[✓] Host can reach the web app in public subnet (10.20.1.10)
[*] Testing connectivity from private subnet ...
[✓] Private subnet is correctly isolated (no access to public app)
[+] Test complete.



# 🧱 About vpcctl

I built a custom CLI tool called vpcctl, written in Bash.
It automates the creation of VPCs, subnets, bridges, NAT gateways, firewall policies, and cleanup — just like AWS VPC operations.
The CLI supports commands such as:


vpc create → to create a new virtual VPC

subnet add → to add subnets inside a VPC

NAT enable → to allow internet access for public subnets

test_webapp.sh → Deploys and tests a sample web server in the public subnet.

firewall apply → to enforce security group–style rules

and destroy-all → to clean up all resources after testing.


🧱 Tools Used

Ubuntu 22.04 LTS

VirtualBox 7.0.24

iproute2, bridge-utils, iptables

Bash scripting

Python HTTP server (for app test)


# 🧱 Firewall Rules Example (rules.json)

The rules.json file defines the firewall rules dynamically.
It works like AWS security groups, allowing or blocking specific ports and protocols.
For example, my configuration allows ports 80 and 443 but denies port 22

{
  "subnet": "10.20.1.0/24",
  "ingress":
 [
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



