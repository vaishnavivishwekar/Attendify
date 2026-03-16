package com.attendx.servlet.teacher;

import com.attendx.dao.TeacherDAO;
import com.attendx.model.Teacher;
import org.json.JSONArray;
import org.json.JSONObject;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;

/**
 * POST /api/save-face
 * Body: { "faceDescriptor": [ 128 floats ] }
 * Saves the teacher's face descriptor to the database.
 */
@WebServlet("/api/save-face")
public class SaveFaceServlet extends HttpServlet {

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
            JSONArray  arr  = body.optJSONArray("faceDescriptor");

            if (arr == null || arr.length() != 128) {
                out.print(error("Invalid face descriptor – must be 128 values."));
                return;
            }

            // Validate all entries are numbers
            for (int i = 0; i < arr.length(); i++) {
                arr.getDouble(i); // throws if not a number
            }

            new TeacherDAO().updateFaceDescriptor(teacher.getTeacherId(), arr.toString());

            // Update the session object so the redirect check in login works
            teacher.setFaceDescriptor(arr.toString());
            session.setAttribute("teacherUser", teacher);

            out.print(new JSONObject().put("success", true)
                    .put("message", "Face registered successfully.").toString());

        } catch (Exception e) {
            out.print(error("Could not save face data: " + e.getMessage()));
        }
    }

    private String error(String msg) {
        return new JSONObject().put("success", false).put("message", msg).toString();
    }
}
