#!/bin/bash

# Zastaviť pri chybe
set -e

echo "🔧 Inštalácia závislostí..."
sudo apt update
sudo apt install -y python3-pip python3-venv libjpeg-dev libpng-dev libtiff-dev

echo "📂 Aktivácia virtuálneho prostredia..."
cd ~/Desktop/CamToWeb
source venv/bin/activate

echo "⬆️ Aktualizácia pip a základných balíkov..."
pip install --upgrade pip setuptools wheel

echo "📦 Inštalácia OpenCV z .whl..."
# Meno .whl súboru – uprav podľa presného názvu súboru
WHL_FILE="opencv_python_headless-4.9.0.80-cp312-cp312-linux_armv7l.whl"

if [ ! -f "$WHL_FILE" ]; then
    echo "❌ Súbor $WHL_FILE sa nenašiel v adresári ~/Desktop/CamToWeb"
    echo "👉 Skopíruj ho z výkonného PC napríklad cez:"
    echo "   scp opencv_python_headless-*.whl banana@banana_pi_ip:~/Desktop/CamToWeb/"
    exit 1
fi

pip install "./$WHL_FILE"

echo "✅ Kontrola funkčnosti OpenCV..."
python3 - <<EOF
try:
    import cv2
    print("✅ OpenCV verzia:", cv2.__version__)
    print("✅ cv2 modul sa nachádza v:", cv2.__file__)
except Exception as e:
    print("❌ Chyba pri importe cv2:", e)
EOF

echo "🎉 OpenCV bolo úspešne nainštalované!"