#!/bin/bash
# setup.sh — US West Timezone + DNS + DIE.py Bootstrapper

set -e

echo "=========================================="
echo "  Bot DevContainer — US West + DNS Setup"
echo "=========================================="

# 1. Timezone
echo "[+] Setting timezone → America/Los_Angeles..."
sudo ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
echo "America/Los_Angeles" | sudo tee /etc/timezone > /dev/null

# 2. System update + DNS tools
echo "[+] Installing system packages..."
sudo apt-get update -qq
sudo apt-get install -y -qq dnsutils bind9-host netcat-openbsd curl git build-essential

# 3. Python dependencies
echo "[+] Installing Python packages..."
pip install --quiet --upgrade python-telegram-bot

# 4. danger binary check
cd /workspaces/Bot
if [ ! -f "./danger" ]; then
    echo "[!] WARNING: 'danger' binary not found!"
    echo "[!] Place it in /workspaces/Bot/ and chmod +x danger"
    echo "[!] Bot will fail if danger is missing."
else
    chmod +x ./danger
    echo "[+] danger binary found and made executable"
fi

# 5. DNS verification
echo ""
echo "[+] DNS Verification:"
echo "--------------------"
nslookup google.com 8.8.8.8 2>/dev/null | grep -E "Address|Name" | head -4
echo ""

# 6. Timezone verification
echo "[+] Timezone: $(date)"
echo ""

# 7. Start bot
echo "[+] Starting DIE.py (Telegram Bot)..."
python3 DIE.py
