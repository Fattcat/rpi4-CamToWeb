#!/bin/bash
set -e

# — Konfigurácia
VENV_DIR="venv"
TMP_PIP_DIR="$HOME/pip_tmp"
SWAPFILE="/swapfile"
SWAP_SIZE_MB=1024

echo "=== Kontrola systémových zdrojov na Banana Pi M2 Zero ==="
free -h
RAM_FREE=$(free -m | awk '/^Mem:/ {print $7}')
SWAP_FREE=$(free -m | awk '/^Swap:/ {print $4}')
df -h /

if [ "$RAM_FREE" -lt 300 ] && [ "$SWAP_FREE" -lt 500 ]; then
  echo "[INFO] RAM je nízka (<300MB) a swap <500MB – pridávam swap."
  sudo swapoff "$SWAPFILE" 2>/dev/null || true
  sudo fallocate -l "${SWAP_SIZE_MB}M" "$SWAPFILE"
  sudo chmod 600 "$SWAPFILE"
  sudo mkswap "$SWAPFILE"
  sudo swapon "$SWAPFILE"
  echo "[INFO] Swap nastavený na ${SWAP_SIZE_MB}MB."
fi

echo "=== Vytváranie a nastavovanie dočasného pip adresára ==="
rm -rf "$TMP_PIP_DIR" || true
mkdir -p "$TMP_PIP_DIR"
export TMPDIR="$TMP_PIP_DIR"

echo "=== Aktivácia virtuálneho prostredia '$VENV_DIR' ==="
cd "$(dirname "$0")"
if [ -f "$VENV_DIR/bin/activate" ]; then
  source "$VENV_DIR/bin/activate"
else
  echo "[ERROR] Virtuálne prostredie '$VENV_DIR' sa nenašlo!"
  exit 1
fi

echo "=== Aktualizácia pip, setuptools, wheel ==="
nice -n19 pip install --upgrade pip setuptools wheel --no-cache-dir

echo "=== Inštalácia numpy ==="
nice -n19 pip install numpy --no-cache-dir

echo "=== Inštalácia OpenCV headless (ARMv7) z piwheels ==="
# použitie piwheels repozitára, kde sú predkompilované .whl
nice -n19 pip install opencv-python-headless --no-cache-dir \
  --extra-index-url https://www.piwheels.org/simple

echo "=== Overenie cv2 modulu ==="
python3 - <<EOF
import cv2
print("✅ OpenCV verzia:", cv2.__version__)
print("✅ cv2 modul nachádza sa tu:", cv2.__file__)
EOF

echo "=== Inštalácia dokončená úspešne! ==="
rm -rf "$TMP_PIP_DIR"