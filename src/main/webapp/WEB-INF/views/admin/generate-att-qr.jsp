<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Attendance QR – AttendX Admin</title>
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
            </head>

            <body>
                <div class="layout">
                    <%@ include file="sidebar.jsp" %>
                        <div class="main-content">
                            <%@ include file="topbar.jsp" %>
                                <div class="page-body">

                                    <div class="card">
                                        <div class="card-header">
                                            <span class="card-title">&#x1F4F7; Generate Daily Attendance QR</span>
                                        </div>
                                        <div class="card-body">
                                            <c:if test="${not empty error}">
                                                <div class="alert alert-danger">&#x26A0; ${error}</div>
                                            </c:if>

                                            <form method="post" action="${pageContext.request.contextPath}/admin/generate-att-qr">
                                                <div class="form-grid">
                                                    <div class="form-group">
                                                        <label class="form-label">Morning IN Time</label>
                                                        <input type="time" class="form-control" name="inTime" value="<fmt:formatDate value='${settings.morningInTime}' pattern='HH:mm'/>" required>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="form-label">Lunch Time</label>
                                                        <input type="time" class="form-control" name="lunchTime" value="<fmt:formatDate value='${settings.lunchTime}' pattern='HH:mm'/>" required>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="form-label">OUT Time</label>
                                                        <input type="time" class="form-control" name="outTime" value="<fmt:formatDate value='${settings.outTime}' pattern='HH:mm'/>" required>
                                                    </div>
                                                </div>
                                                <div class="mt-4">
                                                    <button type="submit" class="btn btn-primary">
                                &#x1F680; Generate New Daily Attendance QR
                            </button>
                                                </div>
                                            </form>

                                            <c:if test="${not empty qrBase64}">
                                                <hr style="margin:24px 0;border:none;border-top:1px solid #e2e8f0">
                                                <div class="alert alert-success">&#x2705; Daily attendance QR generated successfully.</div>

                                                <div class="qr-container">
                                                    <img class="qr-img" src="data:image/png;base64,${qrBase64}" alt="Daily Attendance QR">

                                                    <div style="text-align:center;max-width:520px">
                                                        <p class="fw-600">Session Details</p>
                                                        <p class="text-muted" style="margin-top:6px;font-size:12px">
                                                            Date: ${session.sessionDate} | IN:
                                                            <fmt:formatDate value="${session.inTime}" pattern="HH:mm" /> | Lunch:
                                                            <fmt:formatDate value="${session.lunchTime}" pattern="HH:mm" /> | OUT:
                                                            <fmt:formatDate value="${session.outTime}" pattern="HH:mm" />
                                                        </p>
                                                        <p class="text-muted" style="font-size:12px">
                                                            Location: ${settings.schoolLat}, ${settings.schoolLong}
                                                        </p>
                                                    </div>

                                                    <a download="attendance-qr-${session.sessionDate}.png" href="data:image/png;base64,${qrBase64}" class="btn btn-outline" style="width:auto">
                                &#x2B07; Download QR Image
                            </a>
                                                </div>
                                            </c:if>
                                        </div>
                                    </div>

                                </div>
                        </div>
                </div>
                <script>
                    document.querySelectorAll('.nav-item').forEach(el => el.classList.remove('active'));
                    document.getElementById('nav-att-qr') ?.classList.add('active');
                </script>
            </body>

            </html>