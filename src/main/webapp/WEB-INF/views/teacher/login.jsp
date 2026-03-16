<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Teacher Login – AttendX</title>
            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/teacher.css">
        </head>

        <body>
            <div class="auth-page">
                <div class="auth-header">
                    <div class="brand">AttendX</div>
                    <div class="tagline">Teacher Attendance Portal</div>
                </div>
                <div class="auth-body">
                    <h2 class="auth-title">Teacher Login</h2>
                    <p class="auth-sub">Sign in to mark attendance.</p>

                    <c:if test="${param.registered == 'true'}">
                        <div class="alert alert-success">
                            &#x2705; Registration successful.
                            <c:if test="${not empty param.teacherId}">
                                Your Teacher ID is <strong>${param.teacherId}</strong>.
                            </c:if>
                            Please login.
                        </div>
                    </c:if>

                    <c:if test="${not empty error}">
                        <div class="alert alert-danger">&#x26A0; ${error}</div>
                    </c:if>

                    <form method="post" action="${pageContext.request.contextPath}/teacher/login">
                        <div class="form-group">
                            <label class="form-label">Email</label>
                            <input type="email" name="email" class="form-control" required autofocus>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Password</label>
                            <input type="password" name="password" class="form-control" required>
                        </div>
                        <button type="submit" class="btn btn-primary btn-lg mt-3">Login</button>
                    </form>

                    <p class="text-center mt-4" style="font-size:13px">
                        Need an account? Scan Registration QR from admin.
                    </p>
                </div>
            </div>
        </body>

        </html>