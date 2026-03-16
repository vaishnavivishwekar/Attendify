<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Dashboard – AttendX Admin</title>
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
            </head>

            <body>
                <div class="layout">
                    <%@ include file="sidebar.jsp" %>
                        <div class="main-content">
                            <%@ include file="topbar.jsp" %>
                                <div class="page-body">

                                    <!-- Stats -->
                                    <div class="stats-grid">
                                        <div class="stat-card blue">
                                            <div class="stat-icon">&#x1F468;&#x200D;&#x1F3EB;</div>
                                            <div class="stat-info">
                                                <div class="label">Total Teachers</div>
                                                <div class="value">${totalTeachers}</div>
                                            </div>
                                        </div>
                                        <div class="stat-card green">
                                            <div class="stat-icon">&#x2705;</div>
                                            <div class="stat-info">
                                                <div class="label">Present Today</div>
                                                <div class="value">${presentToday}</div>
                                            </div>
                                        </div>
                                        <div class="stat-card orange">
                                            <div class="stat-icon">&#x1F4CD;</div>
                                            <div class="stat-info">
                                                <div class="label">Marked OUT</div>
                                                <div class="value">${markedOut}</div>
                                            </div>
                                        </div>
                                        <div class="stat-card red">
                                            <div class="stat-icon">&#x274C;</div>
                                            <div class="stat-info">
                                                <div class="label">Absent Today</div>
                                                <div class="value">${absent}</div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Today's Attendance Table -->
                                    <div class="card">
                                        <div class="card-header">
                                            <span class="card-title">&#x1F4C5; Today's Attendance — ${today}</span>
                                            <a href="${pageContext.request.contextPath}/admin/reports" class="btn btn-outline" style="padding:6px 14px;font-size:12px">View Full Report</a>
                                        </div>
                                        <div class="table-wrap">
                                            <table>
                                                <thead>
                                                    <tr>
                                                        <th>#</th>
                                                        <th>Teacher</th>
                                                        <th>Department</th>
                                                        <th>IN Time</th>
                                                        <th>OUT Time</th>
                                                        <th>Duration</th>
                                                        <th>Status</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <c:choose>
                                                        <c:when test="${empty todayRecords}">
                                                            <tr>
                                                                <td colspan="7" style="text-align:center;color:#94a3b8;padding:32px">No attendance records yet for today.</td>
                                                            </tr>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <c:forEach var="r" items="${todayRecords}" varStatus="s">
                                                                <tr>
                                                                    <td>${s.count}</td>
                                                                    <td>${empty r.teacherName ? '—' : r.teacherName}</td>
                                                                    <td class="text-muted">${empty r.teacherDepartment ? '—' : r.teacherDepartment}</td>
                                                                    <td>
                                                                        <c:choose>
                                                                            <c:when test="${not empty r.inTime}">
                                                                                <span class="badge badge-in"><fmt:formatDate value="${r.inTime}" pattern="HH:mm"/></span>
                                                                            </c:when>
                                                                            <c:otherwise><span class="text-muted">—</span></c:otherwise>
                                                                        </c:choose>
                                                                    </td>
                                                                    <td>
                                                                        <c:choose>
                                                                            <c:when test="${not empty r.outTime}">
                                                                                <span class="badge badge-out"><fmt:formatDate value="${r.outTime}" pattern="HH:mm"/></span>
                                                                            </c:when>
                                                                            <c:otherwise><span class="text-muted">—</span></c:otherwise>
                                                                        </c:choose>
                                                                    </td>
                                                                    <td class="text-muted">
                                                                        <c:if test="${r.durationMinutes > 0}">
                                                                            ${r.durationMinutes / 60}h ${r.durationMinutes % 60}m
                                                                        </c:if>
                                                                        <c:if test="${r.durationMinutes == 0}">—</c:if>
                                                                    </td>
                                                                    <td>
                                                                        <c:choose>
                                                                            <c:when test="${r.status == 'PRESENT'}"><span class="badge badge-present">Present</span></c:when>
                                                                            <c:when test="${r.status == 'ABSENT'}"><span class="badge badge-absent">Absent</span></c:when>
                                                                            <c:otherwise><span class="badge badge-half">${r.status}</span></c:otherwise>
                                                                        </c:choose>
                                                                    </td>
                                                                </tr>
                                                            </c:forEach>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>

                                </div>
                        </div>
                </div>
                <script>
                    document.querySelectorAll('.nav-item').forEach(el => el.classList.remove('active'));
                    document.getElementById('nav-dashboard') ?.classList.add('active');
                </script>
            </body>

            </html>