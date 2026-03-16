<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Settings – AttendX Admin</title>
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
            </head>

            <body>
                <div class="layout">
                    <%@ include file="sidebar.jsp" %>
                        <div class="main-content">
                            <%@ include file="topbar.jsp" %>
                                <div class="page-body">

                                    <div class="card" style="max-width:900px">
                                        <div class="card-header">
                                            <span class="card-title">&#x2699; Attendance Parameters & School Location</span>
                                        </div>
                                        <div class="card-body">
                                            <c:if test="${param.saved == 'true'}">
                                                <div class="alert alert-success">&#x2705; Settings saved successfully.</div>
                                            </c:if>
                                            <c:if test="${not empty error}">
                                                <div class="alert alert-danger">&#x26A0; ${error}</div>
                                            </c:if>

                                            <form method="post" action="${pageContext.request.contextPath}/admin/settings">
                                                <div class="form-grid">
                                                    <div class="form-group">
                                                        <label class="form-label">School Name</label>
                                                        <input type="text" class="form-control" name="schoolName" value="${settings.schoolName}" required>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="form-label">School Latitude</label>
                                                        <input type="number" step="0.00000001" class="form-control" name="schoolLat" value="${settings.schoolLat}" required>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="form-label">School Longitude</label>
                                                        <input type="number" step="0.00000001" class="form-control" name="schoolLong" value="${settings.schoolLong}" required>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="form-label">Allowed Radius (meters)</label>
                                                        <input type="number" min="10" max="1000" class="form-control" name="allowedRadius" value="${settings.allowedRadius}" required>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="form-label">Morning IN Time</label>
                                                        <input type="time" class="form-control" name="morningInTime" value="<fmt:formatDate value='${settings.morningInTime}' pattern='HH:mm'/>" required>
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
                                                    <button type="submit" class="btn btn-primary">Save Settings</button>
                                                </div>
                                            </form>

                                            <div class="alert alert-warning mt-4">
                                                &#x1F4CD; OUT attendance uses browser GPS and will be accepted only if the teacher is within configured radius of school coordinates.
                                            </div>
                                        </div>
                                    </div>

                                </div>
                        </div>
                </div>
                <script>
                    document.querySelectorAll('.nav-item').forEach(el => el.classList.remove('active'));
                    document.getElementById('nav-settings') ?.classList.add('active');
                </script>
            </body>

            </html>