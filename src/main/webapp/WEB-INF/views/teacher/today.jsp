<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Today Attendance – AttendX</title>
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/teacher.css">
            </head>

            <body>
                <div class="app-shell">
                    <%@ include file="_header.jsp" %>
                        <main class="page-content">

                            <div class="att-status-card">
                                <div class="date-label">Date • ${today}</div>
                                <div class="status-text">Today's Attendance</div>
                                <div class="time-row">
                                    <div class="time-item">
                                        <div class="label">IN Time</div>
                                        <div class="value">
                                            <c:if test="${not empty todayRecord.inTime}">
                                                <fmt:formatDate value="${todayRecord.inTime}" pattern="HH:mm" />
                                            </c:if>
                                            <c:if test="${empty todayRecord.inTime}">--:--</c:if>
                                        </div>
                                    </div>
                                    <div class="time-item">
                                        <div class="label">OUT Time</div>
                                        <div class="value">
                                            <c:if test="${not empty todayRecord.outTime}">
                                                <fmt:formatDate value="${todayRecord.outTime}" pattern="HH:mm" />
                                            </c:if>
                                            <c:if test="${empty todayRecord.outTime}">--:--</c:if>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="card">
                                <div class="card-header"><span class="card-title">&#x1F4CD; Mark OUT Attendance</span></div>
                                <div class="card-body">

                                    <div id="gpsIndicator" class="gps-indicator">
                                        <span class="gps-dot" id="gpsDot"></span>
                                        <span id="gpsText">Waiting for action...</span>
                                    </div>

                                    <c:choose>
                                        <c:when test="${empty todayRecord}">
                                            <div class="alert alert-warning">You have not marked IN yet. Please scan the daily QR code first.</div>
                                            <a href="${pageContext.request.contextPath}/teacher/scan" class="btn btn-primary">Go to Scan Page</a>
                                        </c:when>
                                        <c:when test="${not empty todayRecord.outTime}">
                                            <div class="alert alert-success">
                                                OUT already marked at
                                                <fmt:formatDate value="${todayRecord.outTime}" pattern="HH:mm" />.
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <button id="markOutBtn" class="btn btn-success btn-lg">Mark OUT (Verify GPS)</button>
                                        </c:otherwise>
                                    </c:choose>

                                    <div id="outStatus" class="alert alert-info mt-3">School location must match within allowed radius (${settings.allowedRadius}m).</div>
                                </div>
                            </div>

                        </main>
                        <%@ include file="_nav.jsp" %>
                </div>

                <script>
                    document.getElementById('tab-today') ?.classList.add('active');

                    const btn = document.getElementById('markOutBtn');
                    const statusEl = document.getElementById('outStatus');
                    const gpsDot = document.getElementById('gpsDot');
                    const gpsText = document.getElementById('gpsText');

                    function setStatus(msg, type) {
                        statusEl.className = 'alert ' + (type || 'alert-info') + ' mt-3';
                        statusEl.textContent = msg;
                    }

                    function setGpsState(text, state) {
                        gpsText.textContent = text;
                        gpsDot.className = 'gps-dot';
                        if (state) gpsDot.classList.add(state);
                    }

                    async function markOut(lat, lng) {
                        const res = await fetch('${pageContext.request.contextPath}/api/mark-out', {
                            method: 'POST',
                            headers: {
                                'Content-Type': 'application/json'
                            },
                            body: JSON.stringify({
                                lat,
                                lng
                            })
                        });
                        return await res.json();
                    }

                    if (btn) {
                        btn.addEventListener('click', () => {
                            if (!navigator.geolocation) {
                                setStatus('Geolocation is not supported by your browser.', 'alert-danger');
                                return;
                            }

                            btn.disabled = true;
                            btn.innerHTML = '<span class="spinner"></span> Verifying location...';
                            setGpsState('Locating your current position...', 'locating');
                            setStatus('Please keep GPS and internet enabled.', 'alert-info');

                            navigator.geolocation.getCurrentPosition(async(pos) => {
                                const lat = pos.coords.latitude;
                                const lng = pos.coords.longitude;

                                setGpsState('Location captured. Checking school radius...', 'found');

                                try {
                                    const result = await markOut(lat, lng);
                                    if (result.success) {
                                        setStatus(result.message + ' (' + result.time + ')', 'alert-success');
                                        btn.innerHTML = 'OUT Marked';
                                        setTimeout(() => location.reload(), 1400);
                                    } else {
                                        setStatus(result.message, 'alert-danger');
                                        btn.disabled = false;
                                        btn.innerHTML = 'Mark OUT (Verify GPS)';
                                    }
                                } catch (e) {
                                    setStatus('Server error while marking OUT. Try again.', 'alert-danger');
                                    btn.disabled = false;
                                    btn.innerHTML = 'Mark OUT (Verify GPS)';
                                }
                            }, (err) => {
                                let msg = 'Could not retrieve location.';
                                if (err.code === 1) msg = 'Location permission denied. Please allow location access.';
                                if (err.code === 2) msg = 'Location unavailable. Move to open area and retry.';
                                if (err.code === 3) msg = 'Location request timed out. Retry.';
                                setGpsState(msg, '');
                                setStatus(msg, 'alert-danger');
                                btn.disabled = false;
                                btn.innerHTML = 'Mark OUT (Verify GPS)';
                            }, {
                                enableHighAccuracy: true,
                                timeout: 15000,
                                maximumAge: 0
                            });
                        });
                    }
                </script>
            </body>

            </html>