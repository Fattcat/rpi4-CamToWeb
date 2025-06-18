#!/bin/bash

# === KONFIGURÁCIA ===
VENV_PATH="$HOME/Desktop/CamToWeb/venv"
TMP_PIP_DIR="$HOME/pip_tmp"
LOG_FILE="$HOME/Desktop/CamToWeb/install_log.txt"

# === FUNKCIA: INFO HEADER ===
function header {
  echo -e "\n===== $1 ====="
  echo -e "\n===== $1 =====" >> "$LOG_FILE"
}

# === VYMAZANIE STARÉHO LOGU ===
rm -f "$LOG_FILE"

# === KONTROLA DOSTUPNEJ RAM/SWAP ===
header "Systémové zdroje"
echo "[INFO] RAM a SWAP:"
free -h | tee -a "$LOG_FILE"

MEM_AVAIL=$(free -m | awk '/Mem:/ {print $7}')
SWAP_FREE=$(free -m | awk '/Swap:/ {print $4}')

if [ "$MEM_AVAIL" -lt 250 ]; then
  echo "[WARNING] Máš málo voľnej RAM: ${MEM_AVAIL}MB" | tee -a "$LOG_FILE"
fi

if [ "$SWAP_FREE" -lt 500 ]; then
  echo "[WARNING] Málo voľného SWAP priestoru: ${SWAP_FREE}MB" | tee -a "$LOG_FILE"
fi

# === VOĽNÉ MIESTO NA DISKU ===
header "Voľné miesto"
df -h | tee -a "$LOG_FILE"

# === VEĽKOSŤ PIP_TMP ===
if [ -d "$TMP_PIP_DIR" ]; then
    du -sh "$TMP_PIP_DIR" | tee -a "$LOG_FILE"
fi

# === AKTIVÁCIA VENV ===
header "Aktivácia venv"
if [ -f "$VENV_PATH/bin/activate" ]; then
  source "$VENV_PATH/bin/activate"
  echo "[INFO] Virtuálne prostredie aktivované." | tee -a "$LOG_FILE"
else
  echo "[ERROR] Virtuálne prostredie neexistuje na $VENV_PATH" | tee -a "$LOG_FILE"
  exit 1
fi

# === VYTVOR DOČASNÝ PIP TMP DIR ===
mkdir -p "$TMP_PIP_DIR"

# === INŠTALÁCIA OPENCV ===
header "Inštalácia OpenCV"
echo "[INFO] Inštalujem opencv-python-headless==4.4.0.42..." | tee -a "$LOG_FILE"

TMPDIR="$TMP_PIP_DIR" pip install opencv-python-headless==4.4.0.42 --no-cache-dir 2>&1 | tee -a "$LOG_FILE"
INSTALL_STATUS=$?

if [ "$INSTALL_STATUS" -ne 0 ]; then
  echo "[ERROR] Inštalácia zlyhala. Pozri log: $LOG_FILE" | tee -a "$LOG_FILE"
  exit 2
fi

# === KONTROLA INŠTALÁCIE CV2 ===
header "Overenie inštalácie cv2"
python3 -c "
try:
    import cv2
    print('[SUCCESS] OpenCV verzia:', cv2.__version__)
    print('[SUCCESS] Nájdené v:', cv2.__file__)
except Exception as e:
    print('[ERROR] Modul cv2 nefunguje:', str(e))
" | tee -a "$LOG_FILE"

# === ODSTRÁNENIE DOČASNÉHO TMP ===
rm -rf "$TMP_PIP_DIR"
echo -e "\n[INFO] Hotovo. Log: $LOG_FILE"