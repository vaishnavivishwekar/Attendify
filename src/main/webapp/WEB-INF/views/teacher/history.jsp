<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Attendance History – AttendX</title>
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/teacher.css">
            </head>

            <body>
                <div class="app-shell">
                    <%@ include file="_header.jsp" %>
                        <main class="page-content">

                            <div class="card">
                                <div class="card-header"><span class="card-title">&#x1F4C5; My Attendance History</span></div>
                                <div class="card-body">
                                    <c:if test="${not empty error}">
                                        <div class="alert alert-danger">&#x26A0; ${error}</div>
                                    </c:if>

                                    <c:choose>
                                        <c:when test="${empty records}">
                                            <div class="alert alert-info">No attendance history found yet.</div>
                                        </c:when>
                                        <c:otherwise>
                                            <ul class="history-list">
                                                <c:forEach var="r" items="${records}">
                                                    <li class="history-item">
                                                        <div class="dot ${r.status == 'PRESENT' ? 'dot-present' : (r.status == 'ABSENT' ? 'dot-absent' : 'dot-half')}"></div>
                                                        <div style="flex:1">
                                                            <div class="history-date">${r.attendanceDate}</div>
                                                            <div class="history-times">
                                                                IN:
                                                                <c:if test="${not empty r.inTime}">
                                                                    <fmt:formatDate value="${r.inTime}" pattern="HH:mm" />
                                                                </c:if>
                                                                <c:if test="${empty r.inTime}">--:--</c:if>
                                                                &nbsp; | &nbsp; OUT:
                                                                <c:if test="${not empty r.outTime}">
                                                                    <fmt:formatDate value="${r.outTime}" pattern="HH:mm" />
                                                                </c:if>
                                                                <c:if test="${empty r.outTime}">--:--</c:if>
                                                            </div>
                                                        </div>
                                                        <div>
                                                            <c:choose>
                                                                <c:when test="${r.status == 'PRESENT'}"><span class="badge badge-present">Present</span></c:when>
                                                                <c:when test="${r.status == 'ABSENT'}"><span class="badge badge-absent">Absent</span></c:when>
                                                                <c:otherwise><span class="badge badge-in">${r.status}</span></c:otherwise>
                                                            </c:choose>
                                                        </div>
                                                    </li>
                                                </c:forEach>
                                            </ul>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>

                        </main>
                        <%@ include file="_nav.jsp" %>
                </div>
                <script>
                    document.getElementById('tab-history') ?.classList.add('active');
                </script>
            </body>

            </html>