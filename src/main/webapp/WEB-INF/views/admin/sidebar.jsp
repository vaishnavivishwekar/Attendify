<%-- Admin sidebar include fragment --%>
    <div class="overlay" id="overlay" onclick="closeSidebar()"></div>
    <nav class="sidebar" id="sidebar">
        <div class="sidebar-logo">
            <div class="logo-icon">A</div>
            <div>
                <div class="logo-text">AttendX</div>
                <div class="logo-sub">Admin Panel</div>
            </div>
        </div>

        <div class="sidebar-nav">
            <div class="nav-section-title">Main</div>
            <a id="nav-dashboard" class="nav-item" href="${pageContext.request.contextPath}/admin/dashboard">
                <span class="nav-icon">&#x1F3E0;</span> Dashboard
            </a>
            <a id="nav-reports" class="nav-item" href="${pageContext.request.contextPath}/admin/reports">
                <span class="nav-icon">&#x1F4CA;</span> Reports
            </a>

            <div class="nav-section-title" style="margin-top:12px">QR Codes</div>
            <a id="nav-reg-qr" class="nav-item" href="${pageContext.request.contextPath}/admin/generate-reg-qr">
                <span class="nav-icon">&#x1F4F1;</span> Registration QR
            </a>
            <a id="nav-att-qr" class="nav-item" href="${pageContext.request.contextPath}/admin/generate-att-qr">
                <span class="nav-icon">&#x1F4F7;</span> Attendance QR
            </a>

            <div class="nav-section-title" style="margin-top:12px">Configuration</div>
            <a id="nav-settings" class="nav-item" href="${pageContext.request.contextPath}/admin/settings">
                <span class="nav-icon">&#x2699;</span> Settings
            </a>
        </div>

        <div class="sidebar-footer">
            <div class="admin-card">
                <div class="admin-avatar">${sessionScope.adminUser.substring(0,1).toUpperCase()}</div>
                <div class="admin-info">
                    <div class="name">${sessionScope.adminUser}</div>
                    <div class="role">Administrator</div>
                </div>
            </div>
            <a href="${pageContext.request.contextPath}/admin/logout" class="logout-btn">
      &#x1F6AA; Logout
    </a>
        </div>
    </nav>