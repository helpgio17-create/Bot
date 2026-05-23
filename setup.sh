#!/bin/bash
set -e

echo "=== Bot Setup: US West + DNS + bgmi ==="

# Timezone
sudo ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
echo "America/Los_Angeles" | sudo tee /etc/timezone > /dev/null

# Packages
sudo apt-get update -qq
sudo apt-get install -y -qq dnsutils build-essential upx-ucl clang

# Python deps
pip install --quiet --upgrade python-telegram-bot

# Compile bgmi.c with optimization
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"
echo "[+] Compiling bgmi.c..."
clang -Os -s -ffunction-sections -fdata-sections bgmi.c -o bgmi -Wl,--gc-sections
strip bgmi
echo "[+] Stripped binary size: $(ls -lh bgmi | awk '{print $5}')"
upx --best --lzma bgmi || true
chmod +x ./bgmi
echo "[+] bgmi compiled & compressed!"

# Verify DNS
echo "[+] DNS: $(nslookup google.com 8.8.8.8 2>/dev/null | grep Address | head -1)"
echo "[+] TZ: $(date)"

# Set environment variables (replace with actual values after regenerating token)
export TELEGRAM_BOT_TOKEN="7384442199:AAFDFWROw7orPM_D3I0xes2lLeq7a1chIhs"
export ADMIN_USER_ID="7265678519"

# Start bot
echo "[+] Starting DIE.py..."
python3 DIE.py
