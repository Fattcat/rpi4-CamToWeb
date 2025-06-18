#!/bin/bash
set -e

VENV_PATH="venv"
SWAPFILE="/swapfile"
SWAP_SIZE_MB=1024
OPENCV_VERSION="4.9.0.80"

echo "===== Kontrola systémových zdrojov ====="

# RAM + SWAP
free -h
RAM_FREE=$(free -m | awk '/^Mem:/ {print $7}')
SWAP_FREE=$(free -m | awk '/^Swap:/ {print $4}')

# Rozšírenie swapu ak je RAM nízka alebo swap <500 MB
if [[ "$RAM_FREE" -lt 300 && "$SWAP_FREE" -lt 500 ]]; then
  echo "[INFO] RAM <=300MB alebo swap <500MB detected. Vytváram/rozširujem SWAP..."
  sudo swapoff "$SWAPFILE" 2>/dev/null || true
  sudo fallocate -l "${SWAP_SIZE_MB}M" "$SWAPFILE"
  sudo chmod 600 "$SWAPFILE"
  sudo mkswap "$SWAPFILE"
  sudo swapon "$SWAPFILE"
  echo "[INFO] SWAP nastavený na ${SWAP_SIZE_MB}MB."
fi

# Diskový priestor
df -h /

echo "===== Aktivácia virtuálneho prostredia ====="
if [[ -f "$VENV_PATH/bin/activate" ]]; then
  source "$VENV_PATH/bin/activate"
else
  echo "[ERROR] Neexistuje venv v $VENV_PATH"
  exit 1
fi

echo "===== Inštalácia numpy ====="
pip install --upgrade pip setuptools wheel
pip install numpy

echo "===== Inštalácia OpenCV (headless) ====="
if ! pip install "opencv-python-headless==${OPENCV_VERSION}"; then
  echo "[WARNING] Hlavná verzia zlyhala, skúsim záložnú verziu 4.8.1.78"
  pip install "opencv-python-headless==4.8.1.78"
fi

echo "===== Overenie inštalácie cv2 ====="
python - <<'EOF'
import cv2, sys
print("[SUCCESS] OpenCV verzia:", cv2.__version__)
print("[SUCCESS] cv2 modul nachádza sa tu:", cv2.__file__)
EOF

echo "===== Úspešne nainštalované cv2 s verziou $(python -c 'import cv2; print(cv2.__version__)') ====="