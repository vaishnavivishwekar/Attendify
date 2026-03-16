<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Registration QR – AttendX Admin</title>
            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
        </head>

        <body>
            <div class="layout">
                <%@ include file="sidebar.jsp" %>
                    <div class="main-content">
                        <%@ include file="topbar.jsp" %>
                            <div class="page-body">

                                <div class="card" style="max-width:600px">
                                    <div class="card-header">
                                        <span class="card-title">&#x1F4F1; Teacher Registration QR Code</span>
                                    </div>
                                    <div class="card-body">

                                        <c:if test="${not empty error}">
                                            <div class="alert alert-danger">&#x26A0; ${error}</div>
                                        </c:if>

                                        <div class="alert alert-info">
                                            &#x2139; A new Registration QR has been generated. Teachers scan this QR with their phone to access the registration form. Previous QR tokens are automatically deactivated.
                                        </div>

                                        <c:if test="${not empty qrBase64}">
                                            <div class="qr-container">
                                                <img class="qr-img" src="data:image/png;base64,${qrBase64}" alt="Teacher Registration QR Code">
                                                <div style="text-align:center">
                                                    <p class="fw-600" style="font-size:13px">Scan to Register</p>
                                                    <p class="text-muted" style="font-size:11px;word-break:break-all;max-width:300px">${regUrl}</p>
                                                </div>

                                                <!-- Download link -->
                                                <a id="dlBtn" download="registration-qr.png" href="data:image/png;base64,${qrBase64}" class="btn btn-outline" style="width:auto">
                &#x2B07; Download QR Image
              </a>
                                            </div>
                                        </c:if>

                                        <div class="mt-4">
                                            <a href="${pageContext.request.contextPath}/admin/generate-reg-qr" class="btn btn-primary" style="width:auto">
               &#x1F504; Regenerate QR Code
            </a>
                                        </div>

                                        <div style="margin-top:20px;padding:14px;background:#f8fafc;border-radius:10px;font-size:13px">
                                            <strong>How to use:</strong>
                                            <ol style="margin-top:8px;padding-left:18px;line-height:2">
                                                <li>Display this QR code on a screen or print it out.</li>
                                                <li>Teachers scan it using their phone camera.</li>
                                                <li>Their browser opens the registration form automatically.</li>
                                                <li>After completing registration they can log in.</li>
                                            </ol>
                                        </div>
                                    </div>
                                </div>

                            </div>
                    </div>
            </div>
            <script>
                document.querySelectorAll('.nav-item').forEach(el => el.classList.remove('active'));
                document.getElementById('nav-reg-qr') ?.classList.add('active');
            </script>
        </body>

        </html>