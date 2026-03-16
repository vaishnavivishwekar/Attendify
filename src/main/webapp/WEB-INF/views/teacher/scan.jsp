<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Scan Attendance QR – AttendX</title>
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/teacher.css">
                <style>
                    #verifyOverlay {
                        display: none;
                        position: fixed;
                        inset: 0;
                        background: rgba(15, 23, 42, .78);
                        z-index: 9999;
                        align-items: center;
                        justify-content: center;
                        padding: 16px;
                    }
                    
                    #verifyOverlay.show {
                        display: flex;
                    }
                    
                    .verify-card {
                        background: #fff;
                        border-radius: 16px;
                        padding: 28px 24px;
                        max-width: 440px;
                        width: 100%;
                        box-shadow: 0 8px 40px rgba(0, 0, 0, .3);
                    }
                    
                    .verify-card h3 {
                        margin: 0 0 4px;
                        font-size: 1.1rem;
                        color: #1e293b;
                    }
                    
                    .verify-card .sub {
                        margin: 0 0 16px;
                        font-size: .82rem;
                        color: #64748b;
                    }
                    
                    .info-row {
                        display: flex;
                        align-items: center;
                        gap: 10px;
                        background: #f8fafc;
                        border-radius: 8px;
                        padding: 10px 14px;
                        margin-bottom: 12px;
                    }
                    
                    .info-label {
                        font-size: .76rem;
                        color: #64748b;
                    }
                    
                    .info-val {
                        font-weight: 700;
                        color: #1e293b;
                        font-size: .95rem;
                    }
                    
                    .badge-row {
                        display: flex;
                        gap: 8px;
                        margin-bottom: 14px;
                        flex-wrap: wrap;
                    }
                    
                    .vbadge {
                        padding: 5px 12px;
                        border-radius: 20px;
                        font-size: .78rem;
                        font-weight: 600;
                    }
                    
                    .vbadge-pending {
                        background: #fef3c7;
                        color: #92400e;
                    }
                    
                    .vbadge-ok {
                        background: #dcfce7;
                        color: #15803d;
                    }
                    
                    .vbadge-fail {
                        background: #fee2e2;
                        color: #991b1b;
                    }
                    
                    #faceBox {
                        position: relative;
                        border-radius: 10px;
                        overflow: hidden;
                        border: 2px solid #e2e8f0;
                        background: #000;
                        margin-bottom: 8px;
                    }
                    
                    #faceVideo {
                        display: block;
                        width: 100%;
                        max-height: 190px;
                        object-fit: cover;
                    }
                    
                    #faceCanvas {
                        position: absolute;
                        top: 0;
                        left: 0;
                        width: 100%;
                        height: 100%;
                    }
                    
                    .face-hint {
                        font-size: .78rem;
                        color: #64748b;
                        text-align: center;
                        margin-bottom: 12px;
                    }
                    
                    .verify-input {
                        margin-bottom: 12px;
                    }
                    
                    .verify-input label {
                        display: block;
                        font-size: .8rem;
                        color: #475569;
                        margin-bottom: 6px;
                    }
                    
                    .verify-input input {
                        width: 100%;
                        padding: 10px 12px;
                        border: 1px solid #cbd5e1;
                        border-radius: 8px;
                        font-size: 14px;
                    }
                    
                    #submitAttBtn {
                        width: 100%;
                        margin-top: 4px;
                    }
                    
                    #cancelVerify {
                        width: 100%;
                        margin-top: 8px;
                    }
                </style>
            </head>

            <body>
                <div class="app-shell">
                    <%@ include file="_header.jsp" %>
                        <main class="page-content">

                            <c:if test="${not empty error}">
                                <div class="alert alert-danger">&#x26A0; ${error}</div>
                            </c:if>

                            <c:if test="${not empty todayRecord}">
                                <div class="alert alert-info">
                                    &#x2705; IN attendance already marked at
                                    <fmt:formatDate value="${todayRecord.inTime}" pattern="HH:mm" />.
                                </div>
                            </c:if>

                            <c:if test="${empty sessionScope.teacherUser.faceDescriptor}">
                                <div class="alert alert-danger">
                                    &#x26A0; Face not registered.
                                    <a href="${pageContext.request.contextPath}/teacher/capture-face"><strong>Register your face first</strong></a> to mark attendance.
                                </div>
                            </c:if>

                            <!-- STEP 1: QR Scanner -->
                            <div class="card" id="scanStep">
                                <div class="card-header">
                                    <span class="card-title">&#x1F4F7; Step 1 – Scan Daily Attendance QR</span>
                                </div>
                                <div class="card-body">
                                    <div id="reader" class="scanner-box"></div>
                                    <div id="scanStatus" class="alert alert-info mt-3">
                                        Click Start Scanner and point camera at the QR code shown by admin.
                                    </div>
                                    <button id="startBtn" class="btn btn-primary mt-3">Start Scanner</button>
                                </div>
                            </div>

                        </main>
                        <%@ include file="_nav.jsp" %>
                </div>

                <!-- STEP 2: Verification Overlay -->
                <div id="verifyOverlay">
                    <div class="verify-card">
                        <h3>&#x1F510; Step 2 – Verify Identity &amp; Location</h3>
                        <p class="sub">Both face recognition and GPS location must pass to mark attendance.</p>

                        <div class="info-row">
                            <div>
                                <div class="info-label">Teacher ID</div>
                                <div class="info-val">${sessionScope.teacherUser.teacherId}</div>
                            </div>
                            <div style="margin-left:auto; text-align:right;">
                                <div class="info-label">Name</div>
                                <div class="info-val" style="font-size:.85rem;">${sessionScope.teacherUser.name}</div>
                            </div>
                        </div>

                        <div class="badge-row">
                            <span id="faceBadge" class="vbadge vbadge-pending">&#x1F464; Face: Checking&#x2026;</span>
                            <span id="locationBadge" class="vbadge vbadge-pending">&#x1F4CD; Location: Checking&#x2026;</span>
                        </div>

                        <div id="faceBox">
                            <video id="faceVideo" autoplay muted playsinline></video>
                            <canvas id="faceCanvas"></canvas>
                        </div>
                        <div id="faceHint" class="face-hint">Loading face recognition models&#x2026;</div>

                        <div class="verify-input">
                            <label for="teacherIdInput">Enter Your Teacher ID</label>
                            <input id="teacherIdInput" type="number" min="1" placeholder="Example: ${sessionScope.teacherUser.teacherId}">
                        </div>

                        <button id="submitAttBtn" class="btn btn-primary btn-lg" disabled>&#x2713; Mark Attendance</button>
                        <div id="verifyResult" class="alert mt-3" style="display:none"></div>
                        <button id="cancelVerify" class="btn btn-outline">&#x2190; Cancel &amp; Re-scan</button>
                    </div>
                </div>

                <script src="https://unpkg.com/html5-qrcode"></script>
                <script src="https://cdn.jsdelivr.net/npm/face-api.js@0.22.2/dist/face-api.min.js"></script>
                <script>
                    var CTX_PATH = '${pageContext.request.contextPath}';
                    var MODEL_URL = 'https://justadudewhohacks.github.io/face-api.js/models';

                    document.getElementById('tab-scan') && document.getElementById('tab-scan').classList.add('active');

                    /* ────── STEP 1 – QR Scanner ────── */
                    var qrScanner = null;
                    var scannedToken = null;

                    var scanStatusEl = document.getElementById('scanStatus');
                    var startBtn = document.getElementById('startBtn');

                    function setScanStatus(msg, type) {
                        scanStatusEl.className = 'alert ' + (type || 'alert-info') + ' mt-3';
                        scanStatusEl.textContent = msg;
                    }

                    startBtn.addEventListener('click', function() {
                        if (!window.Html5Qrcode) {
                            setScanStatus('QR library not loaded. Check internet.', 'alert-danger');
                            return;
                        }
                        startBtn.disabled = true;
                        setScanStatus('Opening camera…', 'alert-info');
                        qrScanner = new Html5Qrcode('reader');
                        qrScanner.start({
                                facingMode: 'environment'
                            }, {
                                fps: 10,
                                qrbox: {
                                    width: 220,
                                    height: 220
                                }
                            },
                            onQRDecoded,
                            function() {}
                        ).then(function() {
                            setScanStatus('Scanner started. Point at the QR code.', 'alert-info');
                        }).catch(function() {
                            setScanStatus('Cannot access camera. Allow camera permission.', 'alert-danger');
                            startBtn.disabled = false;
                        });
                    });

                    function onQRDecoded(decodedText) {
                        try {
                            var payload = JSON.parse(decodedText);
                            if (!payload.token) {
                                setScanStatus('Invalid QR code. Scan the attendance QR only.', 'alert-danger');
                                return;
                            }
                            scannedToken = payload.token;
                            if (qrScanner) {
                                qrScanner.stop().then(function() {
                                    qrScanner = null;
                                });
                            }
                            setScanStatus('QR decoded! Proceed to identity verification.', 'alert-success');
                            openVerification();
                        } catch (e) {
                            setScanStatus('QR data is not valid for attendance.', 'alert-danger');
                        }
                    }

                    /* ────── STEP 2 – Face + Location ────── */
                    var overlay = document.getElementById('verifyOverlay');
                    var faceBadge = document.getElementById('faceBadge');
                    var locationBadge = document.getElementById('locationBadge');
                    var faceVideo = document.getElementById('faceVideo');
                    var faceCanvas = document.getElementById('faceCanvas');
                    var faceHint = document.getElementById('faceHint');
                    var submitAttBtn = document.getElementById('submitAttBtn');
                    var verifyResult = document.getElementById('verifyResult');
                    var teacherIdInput = document.getElementById('teacherIdInput');

                    var faceOK = false;
                    var locationOK = false;
                    var currentLat = null;
                    var currentLng = null;
                    var lastFaceDesc = null;
                    var faceLoop = null;
                    var faceCamStream = null;
                    var faceModelsReady = false;

                    function setBadge(el, state, text) {
                        el.className = 'vbadge vbadge-' + state;
                        el.textContent = text;
                    }

                    function checkReady() {
                        var enteredId = (teacherIdInput.value || '').trim();
                        var idReady = enteredId !== '' && !isNaN(parseInt(enteredId, 10));
                        submitAttBtn.disabled = !(faceOK && locationOK && lastFaceDesc !== null && idReady);
                    }

                    function openVerification() {
                        overlay.classList.add('show');
                        verifyResult.style.display = 'none';
                        faceOK = locationOK = false;
                        currentLat = currentLng = null;
                        lastFaceDesc = null;
                        teacherIdInput.value = '';
                        submitAttBtn.disabled = true;
                        submitAttBtn.textContent = '\u2713 Mark Attendance';
                        setBadge(faceBadge, 'pending', '\uD83E\uDDD1 Face: Checking\u2026');
                        setBadge(locationBadge, 'pending', '\uD83D\uDCCD Location: Checking\u2026');
                        startLocationCheck();
                        startFaceCamera();
                        initFaceRecognition();
                    }

                    teacherIdInput.addEventListener('input', checkReady);

                    /* GPS */
                    function startLocationCheck() {
                        if (!navigator.geolocation) {
                            setBadge(locationBadge, 'fail', 'GPS not supported');
                            return;
                        }
                        setBadge(locationBadge, 'pending', '\uD83D\uDCCD Getting GPS\u2026');
                        navigator.geolocation.getCurrentPosition(
                            function(pos) {
                                currentLat = pos.coords.latitude;
                                currentLng = pos.coords.longitude;
                                locationOK = true;
                                setBadge(locationBadge, 'ok', '\uD83D\uDCCD Location: Acquired \u2714');
                                checkReady();
                            },
                            function() {
                                locationOK = false;
                                setBadge(locationBadge, 'fail', '\uD83D\uDCCD Location: Denied \u2716');
                                showVerifyMsg('GPS location was denied. Allow location access and try again.', 'danger');
                            }, {
                                enableHighAccuracy: true,
                                timeout: 12000
                            }
                        );
                    }

                    /* Face recognition */
                    function initFaceRecognition() {
                        faceHint.textContent = 'Loading face recognition models\u2026';
                        Promise.all([
                            faceapi.nets.ssdMobilenetv1.loadFromUri(MODEL_URL),
                            faceapi.nets.faceLandmark68Net.loadFromUri(MODEL_URL),
                            faceapi.nets.faceRecognitionNet.loadFromUri(MODEL_URL)
                        ]).then(function() {
                            faceModelsReady = true;
                            faceHint.textContent = 'Face model loaded. Align your face in frame.';
                            if (faceVideo.srcObject && !faceLoop) {
                                runFaceLoop();
                            }
                        }).catch(function() {
                            setBadge(faceBadge, 'fail', '\uD83E\uDDD1 Face: Model error');
                            faceModelsReady = false;
                            faceHint.textContent = 'Camera may be on, but face model failed to load. Check internet.';
                        });
                    }

                    function startFaceCamera() {
                        if (!window.isSecureContext && location.hostname !== 'localhost' && location.hostname !== '127.0.0.1') {
                            setBadge(faceBadge, 'fail', '\uD83E\uDDD1 Face: HTTPS required');
                            faceHint.textContent = 'Camera needs HTTPS or localhost.';
                            return;
                        }

                        navigator.mediaDevices.getUserMedia({
                            video: {
                                facingMode: 'user'
                            }
                        }).then(function(stream) {
                            faceCamStream = stream;
                            faceVideo.srcObject = stream;
                            faceVideo.onloadedmetadata = function() {
                                faceCanvas.width = faceVideo.videoWidth || 320;
                                faceCanvas.height = faceVideo.videoHeight || 240;
                                if (faceModelsReady) {
                                    faceHint.textContent = 'Look straight at the camera\u2026';
                                    runFaceLoop();
                                } else {
                                    faceHint.textContent = 'Camera is on. Loading face model\u2026';
                                }
                            };
                        }).catch(function() {
                            setBadge(faceBadge, 'fail', '\uD83E\uDDD1 Face: Camera denied');
                            faceHint.textContent = 'Camera access denied. Allow camera and retry.';
                        });
                    }

                    function runFaceLoop() {
                        var sz = {
                            width: faceVideo.videoWidth || 320,
                            height: faceVideo.videoHeight || 240
                        };
                        faceapi.matchDimensions(faceCanvas, sz);
                        faceLoop = setInterval(function() {
                            faceapi.detectSingleFace(faceVideo, new faceapi.SsdMobilenetv1Options({
                                    minConfidence: 0.65
                                }))
                                .withFaceLandmarks()
                                .withFaceDescriptor()
                                .then(function(det) {
                                    var ctx = faceCanvas.getContext('2d');
                                    ctx.clearRect(0, 0, faceCanvas.width, faceCanvas.height);
                                    if (det) {
                                        var res = faceapi.resizeResults(det, sz);
                                        faceapi.draw.drawDetections(faceCanvas, res);
                                        faceapi.draw.drawFaceLandmarks(faceCanvas, res);
                                        lastFaceDesc = det.descriptor;
                                        faceOK = true;
                                        setBadge(faceBadge, 'ok', '\uD83E\uDDD1 Face: Detected \u2714');
                                        faceHint.textContent = 'Face detected! Click Mark Attendance.';
                                    } else {
                                        lastFaceDesc = null;
                                        faceOK = false;
                                        setBadge(faceBadge, 'pending', '\uD83E\uDDD1 Face: Align your face\u2026');
                                        faceHint.textContent = 'No face detected. Look straight at camera in good light.';
                                    }
                                    checkReady();
                                });
                        }, 500);
                    }

                    function stopFaceCam() {
                        if (faceLoop) {
                            clearInterval(faceLoop);
                            faceLoop = null;
                        }
                        if (faceCamStream) {
                            faceCamStream.getTracks().forEach(function(t) {
                                t.stop();
                            });
                            faceCamStream = null;
                        }
                    }

                    /* Submit */
                    submitAttBtn.addEventListener('click', function() {
                        if (!faceOK || !locationOK || !lastFaceDesc || !scannedToken) return;
                        submitAttBtn.disabled = true;
                        submitAttBtn.textContent = 'Verifying\u2026';
                        verifyResult.style.display = 'none';

                        var payload = {
                            token: scannedToken,
                            teacherId: parseInt(teacherIdInput.value, 10),
                            faceDescriptor: Array.from(lastFaceDesc),
                            lat: currentLat,
                            lng: currentLng
                        };

                        fetch(CTX_PATH + '/api/scan-qr', {
                            method: 'POST',
                            headers: {
                                'Content-Type': 'application/json'
                            },
                            body: JSON.stringify(payload)
                        }).then(function(res) {
                            return res.json();
                        }).then(function(json) {
                            if (json.success) {
                                stopFaceCam();
                                showVerifyMsg('\u2714 ' + json.message + '  (Time: ' + json.time + ')', 'success');
                                setTimeout(function() {
                                    location.href = CTX_PATH + '/teacher/dashboard';
                                }, 2200);
                            } else {
                                showVerifyMsg('\u2716 ' + json.message, 'danger');
                                submitAttBtn.disabled = false;
                                submitAttBtn.textContent = '\u2713 Mark Attendance';
                            }
                        }).catch(function() {
                            showVerifyMsg('Network error. Please try again.', 'danger');
                            submitAttBtn.disabled = false;
                            submitAttBtn.textContent = '\u2713 Mark Attendance';
                        });
                    });

                    document.getElementById('cancelVerify').addEventListener('click', function() {
                        stopFaceCam();
                        overlay.classList.remove('show');
                        scannedToken = null;
                        startBtn.disabled = false;
                        setScanStatus('Scan cancelled. Press Start to try again.', 'alert-info');
                    });

                    function showVerifyMsg(msg, type) {
                        verifyResult.className = 'alert alert-' + type + ' mt-3';
                        verifyResult.textContent = msg;
                        verifyResult.style.display = 'block';
                    }
                </script>
            </body>

            </html>