# rpi4-CamToWeb
RaspberryPi4 kali linux python3 code for video streaming to flask server website
## FOlder Architecture
- CamToWebsite/
- ├── venv/             ← virtualenv
- ├── camera_stream.py  ← main python script
- └── templates/
-   ------└── index.html    ← HTML for stream video

# How to use ?
- Clone this repo (on rpi4 with linuxOS)
```
git clone https://github.com/Fattcat/rpi4-CamToWeb.git
```
- go to rpi4-CamToWeb folder
```
cd rpi4-CamToWeb
```
- Install dependencies
```
sudo apt install python3-venv
```
- Create new "venv folder" 
```
python3 -m venv venv
```

- Activate python3 venv (virtual environment)
- (It is necessary cuz otherwise we **CANT** install cv2 with pip3)
```
source venv/bin/activate
```
- Now we can install necessary modules using "venv" WITHOUT ANY ERROR (cuz we are using venv)
```
pip install flask opencv-python numpy
```
- Finally when we have installed, now start this
- Open camToWeb.py
```
nano camToWeb.py
```
- Now u need to change IP address on *line 8* to yours
- (type *iwconfig* to your terminal to see)
```
python3 camToWeb.py
```
- Now open some browser on other device (make sure you are on same WiFi network !)
- And type yourIP of device with port 5000
- Example: 192.168.0.199:5000
- Please support my job by GitHub Star this repository :D
## Finally, watch your LiveStream :D
### If you want to stop it, just press CTRL C in terminal
### Then type *deactivate* to shutdown python3 "venv"
