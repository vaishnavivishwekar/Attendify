<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Teacher Registration – AttendX</title>
            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/teacher.css">
            <style>
                .face-step-box {
                    margin-bottom: 16px;
                    padding: 14px;
                    border: 1px solid #e2e8f0;
                    border-radius: 12px;
                    background: #f8fafc;
                }
                
                .face-step-title {
                    font-weight: 700;
                    color: #1e293b;
                    margin-bottom: 10px;
                }
                
                .face-counter {
                    font-size: 13px;
                    color: #475569;
                    margin-bottom: 8px;
                }
                
                #regVideoBox {
                    position: relative;
                    border-radius: 10px;
                    overflow: hidden;
                    border: 2px solid #dbeafe;
                    background: #000;
                }
                
                #regFaceVideo {
                    width: 100%;
                    max-height: 220px;
                    object-fit: cover;
                    display: block;
                }
                
                #regFaceCanvas {
                    position: absolute;
                    top: 0;
                    left: 0;
                    width: 100%;
                    height: 100%;
                }
                
                .mini-row {
                    display: flex;
                    gap: 8px;
                    margin-top: 10px;
                    flex-wrap: wrap;
                }
                
                .mini-btn {
                    padding: 8px 12px;
                    border: 1px solid #cbd5e1;
                    border-radius: 8px;
                    background: #fff;
                    font-size: 13px;
                    cursor: pointer;
                }
                
                .mini-btn:disabled {
                    opacity: .5;
                    cursor: not-allowed;
                }
                
                #faceEnrollStatus {
                    font-size: 13px;
                    margin-top: 8px;
                }
                
                #faceEnrollStatus.ok {
                    color: #15803d;
                }
                
                #faceEnrollStatus.bad {
                    color: #b91c1c;
                }
                
                #faceEnrollStatus.wait {
                    color: #b45309;
                }
            </style>
        </head>

        <body>
            <div class="auth-page">
                <div class="auth-header">
                    <div class="brand">AttendX</div>
                    <div class="tagline">Teacher Registration</div>
                </div>
                <div class="auth-body">
                    <h2 class="auth-title">Create Teacher Account</h2>
                    <p class="auth-sub">Register using admin-provided QR link.</p>

                    <c:if test="${not empty error}">
                        <div class="alert alert-danger">&#x26A0; ${error}</div>
                    </c:if>

                    <form id="registerForm" method="post" action="${pageContext.request.contextPath}/teacher/register">
                        <input type="hidden" name="regToken" value="${regToken}">
                        <input type="hidden" name="faceDescriptor" id="faceDescriptorInput">

                        <div class="face-step-box">
                            <div class="face-step-title">Step 1: Capture Face (8 Images)</div>
                            <div class="face-counter">Captured: <span id="sampleCount">0</span>/8</div>
                            <div id="regVideoBox">
                                <video id="regFaceVideo" autoplay muted playsinline></video>
                                <canvas id="regFaceCanvas"></canvas>
                            </div>
                            <div class="mini-row">
                                <button type="button" class="mini-btn" id="captureSampleBtn" disabled>Capture Image</button>
                                <button type="button" class="mini-btn" id="resetSampleBtn">Reset</button>
                            </div>
                            <div id="faceEnrollStatus" class="wait">Starting camera and loading face model...</div>
                        </div>

                        <div class="face-step-title" style="margin:4px 0 10px;">Step 2: Fill Details</div>
                        <div class="form-group">
                            <label class="form-label">Full Name</label>
                            <input type="text" name="name" class="form-control" required>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Email</label>
                            <input type="email" name="email" class="form-control" required>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Phone</label>
                            <input type="text" name="phone" class="form-control">
                        </div>
                        <div class="form-group">
                            <label class="form-label">Department</label>
                            <input type="text" name="department" class="form-control">
                        </div>
                        <div class="form-group">
                            <label class="form-label">Password</label>
                            <input type="password" name="password" class="form-control" minlength="6" required>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Confirm Password</label>
                            <input type="password" name="confirmPassword" class="form-control" minlength="6" required>
                        </div>

                        <button id="registerBtn" type="submit" class="btn btn-primary btn-lg mt-3" disabled>
                            Register Account
                        </button>
                    </form>

                    <p class="text-center mt-4" style="font-size:13px">
                        Already registered? <a class="auth-link" href="${pageContext.request.contextPath}/teacher/login">Login here</a>
                    </p>
                </div>
            </div>

            <script src="https://cdn.jsdelivr.net/npm/face-api.js@0.22.2/dist/face-api.min.js"></script>
            <script>
                var MODEL_URL = 'https://justadudewhohacks.github.io/face-api.js/models';
                var video = document.getElementById('regFaceVideo');
                var canvas = document.getElementById('regFaceCanvas');
                var statusEl = document.getElementById('faceEnrollStatus');
                var sampleCountEl = document.getElementById('sampleCount');
                var captureBtn = document.getElementById('captureSampleBtn');
                var resetBtn = document.getElementById('resetSampleBtn');
                var registerBtn = document.getElementById('registerBtn');
                var faceDescriptorInput = document.getElementById('faceDescriptorInput');

                var latestDetectedDescriptor = null;
                var samples = [];
                var detectLoop = null;
                var modelsReady = false;

                function setStatus(msg, cls) {
                    statusEl.textContent = msg;
                    statusEl.className = cls || 'wait';
                }

                function updateCounter() {
                    sampleCountEl.textContent = samples.length;
                    if (samples.length >= 8) {
                        var avg = averageDescriptor(samples);
                        faceDescriptorInput.value = JSON.stringify(avg);
                        registerBtn.disabled = false;
                        captureBtn.disabled = true;
                        setStatus('Face enrollment complete. Now fill details and register.', 'ok');
                    } else {
                        registerBtn.disabled = true;
                    }
                }

                function averageDescriptor(sampleList) {
                    var out = new Array(128);
                    for (var i = 0; i < 128; i++) out[i] = 0;
                    for (var s = 0; s < sampleList.length; s++) {
                        for (var j = 0; j < 128; j++) out[j] += sampleList[s][j];
                    }
                    for (var k = 0; k < 128; k++) out[k] = out[k] / sampleList.length;
                    return out;
                }

                function startDetectionLoop() {
                    var size = {
                        width: video.videoWidth || 320,
                        height: video.videoHeight || 220
                    };
                    faceapi.matchDimensions(canvas, size);

                    detectLoop = setInterval(function() {
                        faceapi.detectSingleFace(video, new faceapi.SsdMobilenetv1Options({
                                minConfidence: 0.65
                            }))
                            .withFaceLandmarks()
                            .withFaceDescriptor()
                            .then(function(det) {
                                var ctx = canvas.getContext('2d');
                                ctx.clearRect(0, 0, canvas.width, canvas.height);
                                if (det) {
                                    latestDetectedDescriptor = Array.from(det.descriptor);
                                    var resized = faceapi.resizeResults(det, size);
                                    faceapi.draw.drawDetections(canvas, resized);
                                    faceapi.draw.drawFaceLandmarks(canvas, resized);
                                    captureBtn.disabled = samples.length >= 8;
                                    if (samples.length < 8) {
                                        setStatus('Face detected. Capture image ' + (samples.length + 1) + ' of 8.', 'wait');
                                    }
                                } else {
                                    latestDetectedDescriptor = null;
                                    captureBtn.disabled = true;
                                    if (samples.length < 8) {
                                        setStatus('No face detected. Look straight at camera.', 'bad');
                                    }
                                }
                            });
                    }, 500);
                }

                function startCamera() {
                    if (!window.isSecureContext && location.hostname !== 'localhost' && location.hostname !== '127.0.0.1') {
                        setStatus('Camera requires HTTPS or localhost.', 'bad');
                        return;
                    }
                    navigator.mediaDevices.getUserMedia({
                            video: {
                                facingMode: 'user'
                            }
                        })
                        .then(function(stream) {
                            video.srcObject = stream;
                            video.onloadedmetadata = function() {
                                canvas.width = video.videoWidth || 320;
                                canvas.height = video.videoHeight || 220;
                                if (modelsReady) {
                                    setStatus('Camera ready. Capture 8 images.', 'wait');
                                    startDetectionLoop();
                                } else {
                                    setStatus('Camera ready. Loading face model...', 'wait');
                                }
                            };
                        })
                        .catch(function() {
                            setStatus('Camera access denied. Please allow camera permission.', 'bad');
                        });
                }

                function loadModels() {
                    Promise.all([
                        faceapi.nets.ssdMobilenetv1.loadFromUri(MODEL_URL),
                        faceapi.nets.faceLandmark68Net.loadFromUri(MODEL_URL),
                        faceapi.nets.faceRecognitionNet.loadFromUri(MODEL_URL)
                    ]).then(function() {
                        modelsReady = true;
                        if (video.srcObject && !detectLoop) {
                            setStatus('Face model loaded. Capture 8 images.', 'wait');
                            startDetectionLoop();
                        }
                    }).catch(function() {
                        setStatus('Could not load face model. Check internet connection and refresh.', 'bad');
                    });
                }

                captureBtn.addEventListener('click', function() {
                    if (!latestDetectedDescriptor) {
                        setStatus('No face detected for capture.', 'bad');
                        return;
                    }
                    if (samples.length >= 8) return;
                    samples.push(latestDetectedDescriptor);
                    updateCounter();
                    if (samples.length < 8) {
                        setStatus('Image ' + samples.length + '/8 captured. Slightly change face angle and capture next.', 'wait');
                    }
                });

                resetBtn.addEventListener('click', function() {
                    samples = [];
                    latestDetectedDescriptor = null;
                    faceDescriptorInput.value = '';
                    captureBtn.disabled = true;
                    registerBtn.disabled = true;
                    updateCounter();
                    setStatus('Samples reset. Capture 8 images again.', 'wait');
                });

                document.getElementById('registerForm').addEventListener('submit', function(e) {
                    if (!faceDescriptorInput.value) {
                        e.preventDefault();
                        setStatus('Please complete 8 face captures before registration.', 'bad');
                    }
                });

                startCamera();
                loadModels();
                updateCounter();
            </script>
        </body>

        </html>