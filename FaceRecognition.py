from flask import Flask, render_template, Response
import cv2

app = Flask(__name__)

IPA = '192.168.0.148'

# Aktivuj OpenCV optimalizácie
cv2.setUseOptimized(True)

# Inicializuj kameru
camera = cv2.VideoCapture(1)
camera.set(cv2.CAP_PROP_FRAME_WIDTH, 320)
camera.set(cv2.CAP_PROP_FRAME_HEIGHT, 240)

if not camera.isOpened():
    print("[ERROR] Kamera sa nedá otvoriť!")
    exit()

# Načítaj Haar Cascade klasifikátor
face_cascade = cv2.CascadeClassifier('haarcascade_frontalface_default.xml')

if face_cascade.empty():
    print("Chyba: Nepodarilo sa načítať klasifikátor.")
    exit()

# Počet snímok pre občasnú detekciu
frame_count = 0
last_faces = []

def generate_frames():
    global frame_count, last_faces
    while True:
        success, frame = camera.read()
        if not success:
            break

        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        frame_count += 1

        if frame_count % 5 == 0:
            # Detekcia na zmenšenom obrázku
            small_gray = cv2.resize(gray, (0, 0), fx=0.5, fy=0.5)
            faces = face_cascade.detectMultiScale(small_gray, scaleFactor=1.2, minNeighbors=4)
            last_faces = [(x*2, y*2, w*2, h*2) for (x, y, w, h) in faces]

        # Nakresli posledné detekované tváre
        for (x, y, w, h) in last_faces:
            cv2.rectangle(frame, (x, y), (x+w, y+h), (0, 255, 255), 2)

        # Encode obrázok ako JPEG
        ret, buffer = cv2.imencode('.jpg', frame)
        frame = buffer.tobytes()

        # HTTP multipart odpoveď
        yield (b'--frame\r\n'
               b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n')


@app.route('/')
def index():
    return render_template('index.html')

@app.route('/video_feed')
def video_feed():
    return Response(generate_frames(),
                    mimetype='multipart/x-mixed-replace; boundary=frame')


if __name__ == "__main__":
    print("[INFO] Spúšťam Flask server...")
    app.run(host=IPA, port=5000)
