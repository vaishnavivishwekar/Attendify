<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Teacher Dashboard – AttendX</title>
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/teacher.css">
            </head>

            <body>
                <div class="app-shell">
                    <%@ include file="_header.jsp" %>
                        <main class="page-content">

                            <div class="att-status-card">
                                <div class="date-label">Today • ${today}</div>
                                <div class="status-text">
                                    <c:choose>
                                        <c:when test="${not empty todayRecord and not empty todayRecord.outTime}">Attendance Completed</c:when>
                                        <c:when test="${not empty todayRecord}">IN Marked</c:when>
                                        <c:otherwise>Not Marked Yet</c:otherwise>
                                    </c:choose>
                                </div>
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
                                <div class="card-header"><span class="card-title">Quick Actions</span></div>
                                <div class="card-body">
                                    <a href="${pageContext.request.contextPath}/teacher/scan" class="btn btn-primary">&#x1F4F7; Scan Daily QR to Mark IN</a>
                                    <a href="${pageContext.request.contextPath}/teacher/today" class="btn btn-success mt-3">&#x1F4CD; Open Today Tab to Mark OUT</a>
                                    <a href="${pageContext.request.contextPath}/teacher/history" class="btn btn-outline mt-3">&#x1F4C5; View Attendance History</a>
                                    <a href="${pageContext.request.contextPath}/teacher/capture-face" class="btn btn-outline mt-3">&#x1F9D1;&#x200D;&#x1F4BB; Update Face Registration</a>
                                </div>
                            </div>

                        </main>
                        <%@ include file="_nav.jsp" %>
                </div>
                <script>
                    document.getElementById('tab-dashboard')?.classList.add('active');
                </script>
            </body>

            </html>