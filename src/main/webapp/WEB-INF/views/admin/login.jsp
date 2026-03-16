<%@ page contentType="text/html;charset=UTF-8" %>

    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Admin Login – AttendX</title>
            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
        </head>

        <body>
            <div class="login-page">
                <div class="login-card">
                    <div class="login-logo">
                        <div class="brand">&#x1F4CB; AttendX</div>
                        <div class="sub">QR Attendance Management System</div>
                    </div>
                    <h2 class="login-title">Admin Login</h2>
                    <p class="login-sub">Sign in to manage attendance and teachers.</p>

                    <c:if test="${not empty error}">
                        <div class="alert alert-danger">&#x26A0; ${error}</div>
                    </c:if>
                    
                   
                   

                    <form method="post" action="${pageContext.request.contextPath}/admin/login" autocomplete="off">
                        <div class="form-group mt-4">
                            <label class="form-label" for="username">Username</label>
                            <input id="username" name="username" type="text" class="form-control" placeholder="Enter admin username" required autofocus value="${param.username}">
                        </div>
                        <div class="form-group mt-4">
                            <label class="form-label" for="password">Password</label>
                            <input id="password" name="password" type="password" class="form-control" placeholder="Enter password" required>
                        </div>
                        <button type="submit" class="btn btn-primary full-width mt-4 btn-lg">
                &#x1F511; Sign In
            </button>
                    </form>

                    <p class="text-muted mt-4" style="text-align:center;font-size:12px">
                        Default credentials: <strong>admin</strong> / <strong>Admin@123</strong>
                    </p>
                </div>
            </div>
        </body>

        </html>