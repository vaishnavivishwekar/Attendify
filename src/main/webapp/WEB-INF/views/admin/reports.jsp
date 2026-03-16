<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Attendance Reports – AttendX Admin</title>
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
                                            <span class="card-title">&#x1F4CA; Attendance Reports</span>
                                        </div>
                                        <div class="card-body">
                                            <c:if test="${not empty error}">
                                                <div class="alert alert-danger">&#x26A0; ${error}</div>
                                            </c:if>

                                            <form method="get" action="${pageContext.request.contextPath}/admin/reports" class="form-grid">
                                                <div class="form-group">
                                                    <label class="form-label">From Date</label>
                                                    <input type="date" class="form-control" name="from" value="${from}">
                                                </div>
                                                <div class="form-group">
                                                    <label class="form-label">To Date</label>
                                                    <input type="date" class="form-control" name="to" value="${to}">
                                                </div>
                                                <div class="form-group" style="align-self:end">
                                                    <button type="submit" class="btn btn-primary">Filter Report</button>
                                                </div>
                                            </form>
                                        </div>
                                    </div>

                                    <div class="card">
                                        <div class="card-header">
                                            <span class="card-title">Report Records</span>
                                            <span class="text-muted">${from} to ${to}</span>
                                        </div>
                                        <div class="table-wrap">
                                            <table>
                                                <thead>
                                                    <tr>
                                                        <th>#</th>
                                                        <th>Date</th>
                                                        <th>Teacher</th>
                                                        <th>Department</th>
                                                        <th>IN</th>
                                                        <th>OUT</th>
                                                        <th>Status</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <c:choose>
                                                        <c:when test="${empty records}">
                                                            <tr>
                                                                <td colspan="7" style="text-align:center;padding:30px;color:#94a3b8">No records found.</td>
                                                            </tr>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <c:forEach var="r" items="${records}" varStatus="s">
                                                                <tr>
                                                                    <td>${s.count}</td>
                                                                    <td>${r.attendanceDate}</td>
                                                                    <td>${r.teacherName}</td>
                                                                    <td>${r.teacherDepartment}</td>
                                                                    <td>
                                                                        <c:if test="${not empty r.inTime}">
                                                                            <fmt:formatDate value="${r.inTime}" pattern="HH:mm" />
                                                                        </c:if>
                                                                    </td>
                                                                    <td>
                                                                        <c:if test="${not empty r.outTime}">
                                                                            <fmt:formatDate value="${r.outTime}" pattern="HH:mm" />
                                                                        </c:if>
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
                    document.getElementById('nav-reports') ?.classList.add('active');
                </script>
            </body>

            </html>