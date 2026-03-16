package com.attendx.servlet.admin;

import com.attendx.dao.SettingsDAO;
import com.attendx.model.Settings;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Time;

@WebServlet("/admin/settings")
public class SettingsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            Settings settings = new SettingsDAO().get();
            req.setAttribute("settings", settings);
            req.getRequestDispatcher("/WEB-INF/views/admin/settings.jsp").forward(req, resp);
        } catch (Exception e) {
            req.setAttribute("error", "Failed to load settings: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/admin/settings.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            SettingsDAO dao      = new SettingsDAO();
            Settings    existing = dao.get();
            Settings    s        = existing != null ? existing : new Settings();

            s.setSchoolName(sanitize(req.getParameter("schoolName"), "My School"));
            s.setSchoolLat(parseDouble(req.getParameter("schoolLat"),   0.0));
            s.setSchoolLong(parseDouble(req.getParameter("schoolLong"),  0.0));
            s.setAllowedRadius(parseInt(req.getParameter("allowedRadius"), 100));

            String inT    = req.getParameter("morningInTime");
            String lunchT = req.getParameter("lunchTime");
            String outT   = req.getParameter("outTime");

            s.setMorningInTime(inT    != null && !inT.isBlank()    ? Time.valueOf(inT    + ":00") : Time.valueOf("07:30:00"));
            s.setLunchTime    (lunchT != null && !lunchT.isBlank() ? Time.valueOf(lunchT + ":00") : Time.valueOf("12:00:00"));
            s.setOutTime      (outT   != null && !outT.isBlank()   ? Time.valueOf(outT   + ":00") : Time.valueOf("16:30:00"));

            dao.save(s);
            resp.sendRedirect(req.getContextPath() + "/admin/settings?saved=true");
        } catch (Exception e) {
            req.setAttribute("error", "Failed to save settings: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/admin/settings.jsp").forward(req, resp);
        }
    }

    private String sanitize(String val, String def) {
        return (val != null && !val.isBlank()) ? val.trim() : def;
    }

    private double parseDouble(String val, double def) {
        try { return Double.parseDouble(val); } catch (Exception e) { return def; }
    }

    private int parseInt(String val, int def) {
        try { return Integer.parseInt(val); } catch (Exception e) { return def; }
    }
}
