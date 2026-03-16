package com.attendx.servlet.teacher;

import com.attendx.dao.AttendanceDAO;
import com.attendx.dao.SettingsDAO;
import com.attendx.model.Attendance;
import com.attendx.model.Settings;
import com.attendx.model.Teacher;
import com.attendx.util.GeoUtil;
import org.json.JSONObject;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Date;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * JSON API endpoint – marks OUT attendance after verifying GPS location.
 * POST /api/mark-out  { "lat": 12.34, "lng": 56.78 }
 */
@WebServlet("/api/mark-out")
public class MarkOutServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("teacherUser") == null) {
            out.print(error("Not authenticated."));
            return;
        }

        Teacher teacher = (Teacher) session.getAttribute("teacherUser");

        try {
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = req.getReader().readLine()) != null) sb.append(line);

            JSONObject body = new JSONObject(sb.toString());
            double teacherLat = body.optDouble("lat", Double.NaN);
            double teacherLng = body.optDouble("lng", Double.NaN);

            if (Double.isNaN(teacherLat) || Double.isNaN(teacherLng)) {
                out.print(error("Could not get your location. Please enable GPS and try again."));
                return;
            }

            Date today = Date.valueOf(LocalDate.now());
            AttendanceDAO attDAO  = new AttendanceDAO();
            Attendance    record  = attDAO.findByTeacherAndDate(teacher.getTeacherId(), today);

            if (record == null) {
                out.print(error("You have not marked IN attendance today. Please scan the QR code first."));
                return;
            }
            if (record.getOutTime() != null) {
                out.print(error("You have already marked OUT today at "
                        + record.getOutTime().toString().substring(11, 16) + "."));
                return;
            }

            Settings settings = new SettingsDAO().get();
            if (settings == null || (settings.getSchoolLat() == 0.0 && settings.getSchoolLong() == 0.0)) {
                out.print(error("School coordinates are not configured. Please ask the admin to set up location settings."));
                return;
            }

            double distance = GeoUtil.calculateDistance(
                    teacherLat, teacherLng,
                    settings.getSchoolLat(), settings.getSchoolLong());

            if (distance > settings.getAllowedRadius()) {
                out.print(error(String.format(
                        "You are %.0f m away from school. You must be within %d m to mark OUT.",
                        distance, settings.getAllowedRadius())));
                return;
            }

            Timestamp now = Timestamp.valueOf(LocalDateTime.now());
            attDAO.markOut(record.getId(), now, teacherLat, teacherLng);

            JSONObject respBody = new JSONObject();
            respBody.put("success",  true);
            respBody.put("message",  "OUT attendance marked successfully!");
            respBody.put("time",     now.toString().substring(11, 16));
            respBody.put("distance", String.format("%.0f", distance));
            out.print(respBody.toString());

        } catch (Exception e) {
            out.print(error("Server error: " + e.getMessage()));
        }
    }

    private String error(String msg) {
        return new JSONObject().put("success", false).put("message", msg).toString();
    }
}
