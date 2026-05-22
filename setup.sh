#!/bin/bash
set -e

echo "=========================================="
echo "  Bot DevContainer — US West + DNS Setup"
echo "=========================================="

# 1. Timezone
echo "[+] Setting timezone → America/Los_Angeles..."
sudo ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
echo "America/Los_Angeles" | sudo tee /etc/timezone > /dev/null

# 2. System packages
echo "[+] Installing system packages..."
sudo apt-get update -qq
sudo apt-get install -y -qq dnsutils bind9-host netcat-openbsd curl git build-essential

# 3. Python packages
echo "[+] Installing Python packages..."
pip install --quiet --upgrade python-telegram-bot

# ⚡ 4. COMPILE bgmi.c → bgmi binary
cd /workspaces/Bot
echo "[+] Compiling bgmi.c → bgmi..."
gcc -o bgmi bgmi.c -lpthread -O3 -Wall 2>&1
if [ -f "./bgmi" ]; then
    chmod +x ./bgmi
    echo "[+] bgmi compiled successfully!"
else
    echo "[!] COMPILATION FAILED!"
    exit 1
fi

# 5. DNS check
echo ""
echo "[+] DNS Verification:"
nslookup google.com 8.8.8.8 2>/dev/null | grep -E "Address|Name" | head -4
echo ""

# 6. Timezone
echo "[+] Timezone: $(date)"
echo ""

# 7. Start bot
echo "[+] Starting DIE.py..."
python3 DIE.py
