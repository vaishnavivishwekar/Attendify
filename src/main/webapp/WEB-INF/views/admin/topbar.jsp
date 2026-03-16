<%-- Admin topbar include fragment --%>
    <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
        <jsp:useBean id="now" class="java.util.Date" />
        <div class="topbar">
            <div style="display:flex;align-items:center;gap:12px">
                <div class="hamburger" id="hamburger" onclick="openSidebar()">
                    <span></span><span></span><span></span>
                </div>
                <div class="topbar-title">Admin Dashboard</div>
            </div>
            <div class="topbar-right">
                <span class="badge-date">
      <fmt:formatDate value="${now}" pattern="EEE, dd MMM yyyy"/>
    </span>
            </div>
        </div>
        <script>
            function openSidebar() {
                document.getElementById('sidebar').classList.add('open');
                document.getElementById('overlay').classList.add('show');
            }

            function closeSidebar() {
                document.getElementById('sidebar').classList.remove('open');
                document.getElementById('overlay').classList.remove('show');
            }
        </script>