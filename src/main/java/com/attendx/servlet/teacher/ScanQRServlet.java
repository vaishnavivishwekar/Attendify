package com.attendx.servlet.teacher;

import com.attendx.dao.AttendanceDAO;
import com.attendx.dao.QRSessionDAO;
import com.attendx.dao.SettingsDAO;
import com.attendx.dao.TeacherDAO;
import com.attendx.model.Attendance;
import com.attendx.model.QRSession;
import com.attendx.model.Settings;
import com.attendx.model.Teacher;
import org.json.JSONArray;
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
 * POST /api/scan-qr
 * Body: { "token": "...", "faceDescriptor": [...128 floats...], "lat": 0.0, "lng": 0.0 }
 *
 * Validates:
 *   1. Teacher is authenticated
 *   2. QR token is valid and for today
 *   3. Not already marked IN today
 *   4. GPS coordinates within allowed school radius  (Haversine)
 *   5. Face descriptor matches stored descriptor      (Euclidean distance ≤ 0.55)
 */
@WebServlet("/api/scan-qr")
public class ScanQRServlet extends HttpServlet {

    /** Face similarity threshold – lower is stricter. 0.55 is recommended. */
    private static final double FACE_THRESHOLD = 0.55;

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
            // ── Parse request body ──
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = req.getReader().readLine()) != null) sb.append(line);
            JSONObject body = new JSONObject(sb.toString());

            String    token          = body.optString("token", "").trim();
            int       enteredTeacherId= body.optInt("teacherId", -1);
            JSONArray fdArr          = body.optJSONArray("faceDescriptor");
            double    submittedLat   = body.optDouble("lat",  Double.NaN);
            double    submittedLng   = body.optDouble("lng",  Double.NaN);

            // ── 1. Basic validation ──
            if (token.isEmpty()) {
                out.print(error("QR token is missing."));
                return;
            }
            if (enteredTeacherId <= 0) {
                out.print(error("Teacher ID is required."));
                return;
            }
            if (enteredTeacherId != teacher.getTeacherId()) {
                out.print(error("Entered Teacher ID does not match your account."));
                return;
            }
            if (fdArr == null || fdArr.length() != 128) {
                out.print(error("Face data is missing or invalid. Please retry."));
                return;
            }
            if (Double.isNaN(submittedLat) || Double.isNaN(submittedLng)) {
                out.print(error("Location data is missing. Enable GPS and retry."));
                return;
            }

            // ── 2. Face descriptor required ──
            Teacher freshTeacher = new TeacherDAO().findById(teacher.getTeacherId());
            String storedFd = freshTeacher != null ? freshTeacher.getFaceDescriptor() : null;
            if (storedFd == null || storedFd.isEmpty()) {
                out.print(error("Your face is not registered. Ask admin or register your face first."));
                return;
            }

            // ── 3. QR session validation ──
            QRSession qrSession = new QRSessionDAO().findByToken(token);
            if (qrSession == null) {
                out.print(error("Invalid or expired QR code. Ask admin to generate a new one."));
                return;
            }
            Date today  = Date.valueOf(LocalDate.now());
            Date qrDate = qrSession.getSessionDate();
            if (!today.equals(qrDate)) {
                out.print(error("This QR code is for " + qrDate + " and cannot be used today."));
                return;
            }

            // ── 4. Duplicate check ──
            AttendanceDAO attDAO   = new AttendanceDAO();
            Attendance    existing = attDAO.findByTeacherAndDate(teacher.getTeacherId(), today);
            if (existing != null) {
                out.print(error("You have already marked IN attendance today at "
                        + existing.getInTime().toString().substring(11, 16) + "."));
                return;
            }

            // ── 5. Location check (Haversine) ──
            Settings settings = new SettingsDAO().get();
            if (settings == null) {
                out.print(error("School settings not configured. Contact admin."));
                return;
            }
            double schoolLat    = settings.getSchoolLat();
            double schoolLng    = settings.getSchoolLong();
            int    allowedMeters= settings.getAllowedRadius();

            // If school coordinates are not configured (still 0,0) skip location check
            if (schoolLat != 0.0 || schoolLng != 0.0) {
                double distMeters = haversineMeters(submittedLat, submittedLng, schoolLat, schoolLng);
                if (distMeters > allowedMeters) {
                    out.print(error(String.format(
                            "You are %.0fm away from school. Must be within %dm to mark attendance.",
                            distMeters, allowedMeters)));
                    return;
                }
            }

            // ── 6. Face verification (Euclidean distance) ──
            float[] stored    = parseDescriptor(storedFd);
            float[] submitted = parseDescriptorArray(fdArr);
            if (stored == null || submitted == null) {
                out.print(error("Face descriptor data is corrupt. Please re-register your face."));
                return;
            }
            double faceDist = euclideanDistance(stored, submitted);
            if (faceDist > FACE_THRESHOLD) {
                out.print(error("Face recognition failed: the face captured does not match your registered face. (distance=" + String.format("%.3f", faceDist) + ")"));
                return;
            }

            // ── 7. Mark attendance ──
            Timestamp now = Timestamp.valueOf(LocalDateTime.now());
            attDAO.markIn(teacher.getTeacherId(), today, now);

            JSONObject resp2 = new JSONObject();
            resp2.put("success", true);
            resp2.put("message", "Attendance marked successfully!");
            resp2.put("time",    now.toString().substring(11, 16));
            out.print(resp2.toString());

        } catch (Exception e) {
            out.print(error("Server error: " + e.getMessage()));
        }
    }

    // ─────────────────────────────────────────────
    // Helpers
    // ─────────────────────────────────────────────

    /** Haversine formula – returns distance in metres between two lat/lng points. */
    private double haversineMeters(double lat1, double lng1, double lat2, double lng2) {
        final double R = 6_371_000; // Earth radius in metres
        double phi1 = Math.toRadians(lat1);
        double phi2 = Math.toRadians(lat2);
        double dPhi = Math.toRadians(lat2 - lat1);
        double dLam = Math.toRadians(lng2 - lng1);
        double a = Math.sin(dPhi / 2) * Math.sin(dPhi / 2)
                 + Math.cos(phi1) * Math.cos(phi2)
                 * Math.sin(dLam / 2) * Math.sin(dLam / 2);
        return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    }

    /** Parse a JSON-string "[f1,f2,...f128]" into a float array. */
    private float[] parseDescriptor(String jsonStr) {
        try {
            JSONArray arr = new JSONArray(jsonStr);
            if (arr.length() != 128) return null;
            float[] d = new float[128];
            for (int i = 0; i < 128; i++) d[i] = (float) arr.getDouble(i);
            return d;
        } catch (Exception e) {
            return null;
        }
    }

    /** Parse a JSONArray directly into a float array. */
    private float[] parseDescriptorArray(JSONArray arr) {
        try {
            if (arr.length() != 128) return null;
            float[] d = new float[128];
            for (int i = 0; i < 128; i++) d[i] = (float) arr.getDouble(i);
            return d;
        } catch (Exception e) {
            return null;
        }
    }

    /** Euclidean distance between two 128-D face descriptors. */
    private double euclideanDistance(float[] a, float[] b) {
        double sum = 0;
        for (int i = 0; i < a.length; i++) {
            double diff = a[i] - b[i];
            sum += diff * diff;
        }
        return Math.sqrt(sum);
    }

    private String error(String msg) {
        return new JSONObject().put("success", false).put("message", msg).toString();
    }
}
