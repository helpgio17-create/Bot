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

# Load environment variables from set_env.sh if it exists
if [ -f "$SCRIPT_DIR/set_env.sh" ]; then
    echo "[+] Loading environment variables from set_env.sh..."
    source "$SCRIPT_DIR/set_env.sh"
else
    echo "[!] WARNING: set_env.sh not found!"
    echo "[!] Create it by copying set_env.example.sh and adding your token."
fi

# Start bot
echo "[+] Starting DIE.py..."
python3 DIE.py
