package com.attendx.servlet.teacher;

import com.attendx.dao.AttendanceDAO;
import com.attendx.model.Attendance;
import com.attendx.model.Teacher;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/teacher/history")
public class HistoryServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Teacher teacher = (Teacher) req.getSession().getAttribute("teacherUser");
        try {
            List<Attendance> records = new AttendanceDAO().findByTeacher(teacher.getTeacherId());
            req.setAttribute("records", records);
        } catch (Exception e) {
            req.setAttribute("error", "Could not load attendance history.");
        }
        req.getRequestDispatcher("/WEB-INF/views/teacher/history.jsp").forward(req, resp);
    }
}
