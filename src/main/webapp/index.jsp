<%@ page contentType="text/html;charset=UTF-8" %>
    <!DOCTYPE html>
    <html lang="en">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>AttendX – QR Teacher Attendance System</title>
        <style>
             :root {
                --p: #4f46e5;
                --bg: #f8fafc;
                --d: #0f172a;
                --m: #64748b;
                --w: #fff;
                --b: #e2e8f0;
            }
            
            * {
                box-sizing: border-box;
                margin: 0;
                padding: 0;
                font-family: 'Segoe UI', system-ui, sans-serif
            }
            
            body {
                background: radial-gradient(circle at top right, #a5b4fc 0%, #eef2ff 35%, #f8fafc 70%);
                min-height: 100vh;
                color: var(--d)
            }
            
            .wrap {
                max-width: 980px;
                margin: 0 auto;
                padding: 28px 18px 40px
            }
            
            .hero {
                padding: 24px 0 12px
            }
            
            .brand {
                font-size: 40px;
                font-weight: 900;
                letter-spacing: -.03em;
                color: var(--p)
            }
            
            .sub {
                margin-top: 8px;
                font-size: 16px;
                color: var(--m);
                max-width: 740px;
                line-height: 1.6
            }
            
            .grid {
                margin-top: 26px;
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
                gap: 18px
            }
            
            .card {
                background: var(--w);
                border: 1px solid var(--b);
                border-radius: 16px;
                padding: 24px;
                box-shadow: 0 10px 25px rgba(15, 23, 42, .06)
            }
            
            .title {
                font-size: 22px;
                font-weight: 800
            }
            
            .txt {
                margin-top: 8px;
                color: var(--m);
                line-height: 1.6;
                font-size: 14px
            }
            
            .btn {
                margin-top: 16px;
                display: inline-block;
                padding: 11px 16px;
                border-radius: 10px;
                text-decoration: none;
                font-weight: 700
            }
            
            .primary {
                background: var(--p);
                color: #fff
            }
            
            .ghost {
                background: #fff;
                color: var(--p);
                border: 1px solid #c7d2fe
            }
            
            .note {
                margin-top: 22px;
                background: #ecfeff;
                border: 1px solid #bae6fd;
                color: #0c4a6e;
                padding: 12px 14px;
                border-radius: 10px;
                font-size: 13px
            }
        </style>
    </head>

    <body>
        <div class="wrap">
            <div class="hero">
                <div class="brand">AttendX</div>
                <div class="sub">Web-based QR Code Teacher Attendance Management System. Teachers scan a daily QR to mark IN and use GPS-verified mark OUT from their dashboard.</div>
            </div>

            <div class="grid">
                <div class="card">
                    <div class="title">Admin Portal</div>
                    <div class="txt">Generate teacher registration QR and daily attendance QR, configure attendance times and school GPS coordinates, and monitor attendance reports.</div>
                    <a class="btn primary" href="${pageContext.request.contextPath}/admin/login">Open Admin Login</a>
                </div>
                <div class="card">
                    <div class="title">Teacher Portal</div>
                    <div class="txt">Register via registration QR, login, scan daily QR for IN attendance, mark OUT with location verification, and view personal attendance history.</div>
                    <a class="btn ghost" href="${pageContext.request.contextPath}/teacher/login">Open Teacher Login</a>
                </div>
            </div>

            <div class="note">
                First-time setup: run the schema in <strong>src/main/resources/schema.sql</strong> and configure MySQL credentials in <strong>src/main/resources/db.properties</strong>.
            </div>
        </div>
    </body>

    </html>