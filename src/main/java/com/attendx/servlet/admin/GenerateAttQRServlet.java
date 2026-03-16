package com.attendx.servlet.admin;

import com.attendx.dao.QRSessionDAO;
import com.attendx.dao.SettingsDAO;
import com.attendx.model.QRSession;
import com.attendx.model.Settings;
import com.attendx.util.QRUtil;
import org.json.JSONObject;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Date;
import java.sql.Time;
import java.time.LocalDate;
import java.util.UUID;

@WebServlet("/admin/generate-att-qr")
public class GenerateAttQRServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            Settings settings = new SettingsDAO().get();
            req.setAttribute("settings", settings);
            req.getRequestDispatcher("/WEB-INF/views/admin/generate-att-qr.jsp").forward(req, resp);
        } catch (Exception e) {
            req.setAttribute("error", "Failed to load settings: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/admin/generate-att-qr.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            Settings settings = new SettingsDAO().get();

            String inTimeStr    = req.getParameter("inTime");
            String lunchTimeStr = req.getParameter("lunchTime");
            String outTimeStr   = req.getParameter("outTime");

            QRSessionDAO dao = new QRSessionDAO();
            dao.deactivateAll();

            String token = UUID.randomUUID().toString().replace("-", "");
            Date today   = Date.valueOf(LocalDate.now());

            QRSession session = new QRSession();
            session.setToken(token);
            session.setSessionDate(today);
            session.setInTime(inTimeStr    != null && !inTimeStr.isBlank()    ? Time.valueOf(inTimeStr + ":00")    : settings != null ? settings.getMorningInTime() : null);
            session.setLunchTime(lunchTimeStr != null && !lunchTimeStr.isBlank() ? Time.valueOf(lunchTimeStr + ":00") : settings != null ? settings.getLunchTime()      : null);
            session.setOutTime(outTimeStr   != null && !outTimeStr.isBlank()   ? Time.valueOf(outTimeStr   + ":00")   : settings != null ? settings.getOutTime()        : null);
            if (settings != null) {
                session.setSchoolLat(settings.getSchoolLat());
                session.setSchoolLong(settings.getSchoolLong());
            }
            dao.create(session);

            // Build QR payload JSON
            JSONObject payload = new JSONObject();
            payload.put("type",  "ATTENDANCE");
            payload.put("token", token);
            payload.put("date",  today.toString());

            String qrBase64 = QRUtil.generateBase64QR(payload.toString(), 300, 300);

            req.setAttribute("qrBase64", qrBase64);
            req.setAttribute("session",  session);
            req.setAttribute("settings", settings);
            req.getRequestDispatcher("/WEB-INF/views/admin/generate-att-qr.jsp").forward(req, resp);
        } catch (Exception e) {
            req.setAttribute("error", "Failed to generate QR: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/admin/generate-att-qr.jsp").forward(req, resp);
        }
    }
}
