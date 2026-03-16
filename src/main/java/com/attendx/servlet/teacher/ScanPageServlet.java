package com.attendx.servlet.teacher;

import com.attendx.dao.AttendanceDAO;
import com.attendx.model.Attendance;
import com.attendx.model.Teacher;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Date;
import java.time.LocalDate;

/** Shows the camera-based QR scan page. */
@WebServlet("/teacher/scan")
public class ScanPageServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Teacher teacher = (Teacher) req.getSession().getAttribute("teacherUser");
        try {
            Date       today  = Date.valueOf(LocalDate.now());
            Attendance record = new AttendanceDAO().findByTeacherAndDate(teacher.getTeacherId(), today);
            req.setAttribute("todayRecord", record);
        } catch (Exception e) {
            req.setAttribute("error", "Could not load attendance data.");
        }
        req.getRequestDispatcher("/WEB-INF/views/teacher/scan.jsp").forward(req, resp);
    }
}
