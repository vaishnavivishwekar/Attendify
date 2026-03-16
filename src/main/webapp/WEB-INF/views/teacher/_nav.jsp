<%-- Teacher bottom nav include --%>
    <nav class="bottom-nav">
        <a id="tab-dashboard" href="${pageContext.request.contextPath}/teacher/dashboard" class="nav-tab">
            <div class="nav-icon">&#x1F3E0;</div>
            <div class="nav-label">Home</div>
        </a>
        <a id="tab-scan" href="${pageContext.request.contextPath}/teacher/scan" class="nav-tab">
            <div class="nav-icon">&#x1F4F7;</div>
            <div class="nav-label">Scan</div>
        </a>
        <a id="tab-today" href="${pageContext.request.contextPath}/teacher/today" class="nav-tab">
            <div class="nav-icon">&#x23F1;</div>
            <div class="nav-label">Today</div>
        </a>
        <a id="tab-history" href="${pageContext.request.contextPath}/teacher/history" class="nav-tab">
            <div class="nav-icon">&#x1F4C5;</div>
            <div class="nav-label">History</div>
        </a>
        <a href="${pageContext.request.contextPath}/teacher/logout" class="nav-tab">
            <div class="nav-icon">&#x1F6AA;</div>
            <div class="nav-label">Logout</div>
        </a>
    </nav>