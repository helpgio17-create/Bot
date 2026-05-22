#!/bin/bash
# setup.sh — US West Timezone + DNS + DIE.py boot

echo "[+] Setting timezone to US West (America/Los_Angeles)..."
sudo ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
echo "America/Los_Angeles" | sudo tee /etc/timezone > /dev/null

echo "[+] Updating packages..."
sudo apt-get update -qq

echo "[+] Installing DNS utilities..."
sudo apt-get install -y -qq dnsutils bind9-host netcat-openbsd curl

echo "[+] DNS Verification:"
nslookup google.com 8.8.8.8 2>/dev/null | head -6

echo "[+] Timezone Verification:"
date

echo "[+] Starting DIE.py..."
cd /workspaces/Bot
python3 DIE.py
