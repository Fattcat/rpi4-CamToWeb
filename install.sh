#!/bin/bash

# Aktivácia virtuálneho prostredia
source ~/Desktop/CamToWeb/venv/bin/activate

# Vytvorenie dočasného priečinka pre pip
mkdir -p ~/pip_tmp

# Inštalácia OpenCV bez cache
echo "[INFO] Inštalujem OpenCV (headless)..."
TMPDIR=~/pip_tmp pip install opencv-python-headless==4.4.0.42 --no-cache-dir

# Kontrola inštalácie
echo "[INFO] Kontrolujem inštaláciu OpenCV..."
python3 -c "
try:
    import cv2
    print('[SUCCESS] OpenCV verzia:', cv2.__version__)
    print('[SUCCESS] Modul načítaný z:', cv2.__file__)
except ImportError:
    print('[ERROR] Modul cv2 nie je dostupný.')
"

# Odstránenie dočasného priečinka
rm -rf ~/pip_tmp