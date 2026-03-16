package com.attendx.servlet.teacher;

import com.attendx.model.Teacher;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

/** GET /teacher/capture-face – shows the one-time face registration page. */
@WebServlet("/teacher/capture-face")
public class CaptureFaceServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Teacher teacher = (Teacher) req.getSession().getAttribute("teacherUser");
        if (teacher.getFaceDescriptor() != null) {
            // Already registered face – allow re-capture from dashboard settings
            req.setAttribute("recapture", true);
        }
        req.getRequestDispatcher("/WEB-INF/views/teacher/capture-face.jsp").forward(req, resp);
    }
}
