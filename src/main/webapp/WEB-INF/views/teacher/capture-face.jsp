<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Register Your Face – AttendX</title>
            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/teacher.css">
            <style>
                .face-setup-page {
                    min-height: 100vh;
                    background: #f0f4ff;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    padding: 20px;
                }
                
                .face-card {
                    background: #fff;
                    border-radius: 16px;
                    box-shadow: 0 4px 24px rgba(0, 0, 0, .12);
                    padding: 32px;
                    max-width: 480px;
                    width: 100%;
                    text-align: center;
                }
                
                .face-card h2 {
                    margin: 0 0 6px;
                    font-size: 1.4rem;
                    color: #1e293b;
                }
                
                .face-card p {
                    color: #64748b;
                    font-size: .9rem;
                    margin: 0 0 20px;
                }
                
                #videoBox {
                    position: relative;
                    display: inline-block;
                    border-radius: 12px;
                    overflow: hidden;
                    border: 3px solid #e2e8f0;
                    background: #000;
                }
                
                #videoEl {
                    display: block;
                    width: 320px;
                    height: 240px;
                    object-fit: cover;
                    border-radius: 10px;
                }
                
                #canvasEl {
                    position: absolute;
                    top: 0;
                    left: 0;
                    width: 320px;
                    height: 240px;
                }
                
                .face-status {
                    margin: 14px 0 6px;
                    font-weight: 600;
                    font-size: .95rem;
                }
                
                .face-status.ok {
                    color: #16a34a;
                }
                
                .face-status.bad {
                    color: #dc2626;
                }
                
                .face-status.wait {
                    color: #d97706;
                }
                
                #captureBtn {
                    margin-top: 16px;
                }
                
                .step-hint {
                    font-size: .8rem;
                    color: #94a3b8;
                    margin-top: 8px;
                }
            </style>
        </head>

        <body>
            <div class="face-setup-page">
                <div class="face-card">
                    <div style="font-size:2.5rem; margin-bottom:10px;">&#x1F9D1;&#x200D;&#x1F3EB;</div>
                    <h2>
                        <c:choose>
                            <c:when test="${recapture}">Update Face Registration</c:when>
                            <c:otherwise>Register Your Face</c:otherwise>
                        </c:choose>
                    </h2>
                    <p>This one-time setup lets AttendX verify your identity when marking attendance.<br> Look straight at the camera in good lighting.</p>

                    <div id="videoBox">
                        <video id="videoEl" autoplay muted playsinline></video>
                        <canvas id="canvasEl"></canvas>
                    </div>

                    <div id="faceStatus" class="face-status wait">&#x23F3; Loading face-recognition models…</div>
                    <p class="step-hint">Keep your face centred inside the frame and hold still.</p>

                    <button id="captureBtn" class="btn btn-primary btn-lg" disabled>Capture &amp; Register Face</button>
                    <div id="result" class="alert mt-3" style="display:none"></div>

                    <p class="mt-3" style="font-size:12px; color:#94a3b8;">
                        <a href="${pageContext.request.contextPath}/teacher/dashboard">Skip for now</a> (you won't be able to mark attendance without face registration)
                    </p>
                </div>
            </div>

            <!-- face-api.js from CDN -->
            <script src="https://cdn.jsdelivr.net/npm/face-api.js@0.22.2/dist/face-api.min.js"></script>
            <script>
                const MODEL_URL = 'https://justadudewhohacks.github.io/face-api.js/models';
                const video = document.getElementById('videoEl');
                const canvas = document.getElementById('canvasEl');
                const statusEl = document.getElementById('faceStatus');
                const captureBtn = document.getElementById('captureBtn');
                const resultEl = document.getElementById('result');

                let lastDescriptor = null;
                let detectionLoop = null;
                let modelsReady = false;

                function setStatus(msg, cls) {
                    statusEl.textContent = msg;
                    statusEl.className = 'face-status ' + (cls || 'wait');
                }

                async function loadModels() {
                    try {
                        await Promise.all([
                            faceapi.nets.ssdMobilenetv1.loadFromUri(MODEL_URL),
                            faceapi.nets.faceLandmark68Net.loadFromUri(MODEL_URL),
                            faceapi.nets.faceRecognitionNet.loadFromUri(MODEL_URL)
                        ]);
                        modelsReady = true;
                        setStatus('Camera ready. Face model loaded. Position your face in frame.', 'wait');
                        if (video.srcObject) {
                            startDetecting();
                        }
                    } catch (e) {
                        modelsReady = false;
                        setStatus('Camera is on, but face model failed to load. Check internet and refresh.', 'bad');
                    }
                }

                async function startCamera() {
                    try {
                        if (!window.isSecureContext && location.hostname !== 'localhost' && location.hostname !== '127.0.0.1') {
                            setStatus('Camera needs HTTPS or localhost in this browser.', 'bad');
                            return;
                        }

                        const stream = await navigator.mediaDevices.getUserMedia({
                            video: {
                                facingMode: 'user'
                            }
                        });
                        video.srcObject = stream;
                        await new Promise(r => video.onloadedmetadata = r);
                        canvas.width = video.videoWidth || 320;
                        canvas.height = video.videoHeight || 240;
                        if (modelsReady) {
                            setStatus('Camera ready. Position your face in the frame.', 'wait');
                            startDetecting();
                        } else {
                            setStatus('Camera is on. Loading face model...', 'wait');
                        }
                    } catch (e) {
                        setStatus('Camera access denied. Please allow camera permission.', 'bad');
                    }
                }

                function startDetecting() {
                    const displaySize = {
                        width: video.videoWidth || 320,
                        height: video.videoHeight || 240
                    };
                    faceapi.matchDimensions(canvas, displaySize);

                    detectionLoop = setInterval(async() => {
                        const det = await faceapi.detectSingleFace(video, new faceapi.SsdMobilenetv1Options({
                                minConfidence: 0.6
                            }))
                            .withFaceLandmarks()
                            .withFaceDescriptor();

                        const ctx = canvas.getContext('2d');
                        ctx.clearRect(0, 0, canvas.width, canvas.height);

                        if (det) {
                            const resized = faceapi.resizeResults(det, displaySize);
                            faceapi.draw.drawDetections(canvas, resized);
                            faceapi.draw.drawFaceLandmarks(canvas, resized);
                            lastDescriptor = det.descriptor;
                            setStatus('✔ Face detected! Click "Capture & Register Face".', 'ok');
                            captureBtn.disabled = false;
                        } else {
                            lastDescriptor = null;
                            captureBtn.disabled = true;
                            setStatus('No face detected. Look directly at the camera.', 'bad');
                        }
                    }, 400);
                }

                captureBtn.addEventListener('click', async() => {
                    if (!lastDescriptor) {
                        setStatus('No face in frame. Try again.', 'bad');
                        return;
                    }

                    captureBtn.disabled = true;
                    captureBtn.textContent = 'Saving…';

                    const descriptorArr = Array.from(lastDescriptor);

                    try {
                        const res = await fetch('${pageContext.request.contextPath}/api/save-face', {
                            method: 'POST',
                            headers: {
                                'Content-Type': 'application/json'
                            },
                            body: JSON.stringify({
                                faceDescriptor: descriptorArr
                            })
                        });
                        const json = await res.json();
                        if (json.success) {
                            clearInterval(detectionLoop);
                            resultEl.className = 'alert alert-success mt-3';
                            resultEl.textContent = '✔ Face registered! Redirecting to dashboard…';
                            resultEl.style.display = 'block';
                            setTimeout(() => location.href = '${pageContext.request.contextPath}/teacher/dashboard', 1500);
                        } else {
                            resultEl.className = 'alert alert-danger mt-3';
                            resultEl.textContent = '✖ ' + json.message;
                            resultEl.style.display = 'block';
                            captureBtn.disabled = false;
                            captureBtn.textContent = 'Capture & Register Face';
                        }
                    } catch (e) {
                        resultEl.className = 'alert alert-danger mt-3';
                        resultEl.textContent = 'Network error. Please try again.';
                        resultEl.style.display = 'block';
                        captureBtn.disabled = false;
                        captureBtn.textContent = 'Capture & Register Face';
                    }
                });

                // Start camera immediately so user sees camera even if model CDN is slow/offline.
                startCamera();
                loadModels();
            </script>
        </body>

        </html>