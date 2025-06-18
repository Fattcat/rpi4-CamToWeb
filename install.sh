#!/bin/bash

echo "===== Systémové zdroje ====="
free -h
RAM_FREE=$(free -m | awk '/^Mem:/ { print $7 }')
SWAP_FREE=$(free -m | awk '/^Swap:/ { print $4 }')
echo "[INFO] Dostupná RAM: ${RAM_FREE}MB, SWAP: ${SWAP_FREE}MB"
if [ "$RAM_FREE" -lt 300 ]; then
    echo "[WARNING] Veľmi málo RAM (<300MB), odporúča sa pridať SWAP!"
fi

echo
echo "===== Voľné miesto ====="
df -h /

echo
echo "===== Aktivácia venv ====="
source venv/bin/activate || { echo "[ERROR] Nepodarilo sa aktivovať venv!"; exit 1; }

echo
echo "===== Inštalácia numpy ====="
pip install --upgrade pip setuptools wheel
pip install numpy || { echo "[ERROR] Nepodarilo sa nainštalovať numpy."; exit 1; }

echo
echo "===== Inštalácia OpenCV (nová kompatibilná verzia) ====="
OPENCV_VERSION="4.9.0.80"
pip install opencv-python-headless=="$OPENCV_VERSION" || {
    echo "[ERROR] Nepodarilo sa nainštalovať OpenCV."
    echo "Skúsime alternatívnu verziu (4.8.1.78)..."
    pip install opencv-python-headless==4.8.1.78 || {
        echo "[FATAL] Zlyhala aj záložná inštalácia OpenCV!"
        exit 1
    }
}

echo
echo "===== Overenie inštalácie cv2 ====="
python -c "import cv2; print('[OK] OpenCV verzia:', cv2.__version__)" || {
    echo "[ERROR] Modul cv2 nefunguje: Nie je správne nainštalovaný."
    exit 1
}