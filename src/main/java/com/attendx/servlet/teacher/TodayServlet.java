package com.attendx.servlet.teacher;

import com.attendx.dao.AttendanceDAO;
import com.attendx.dao.SettingsDAO;
import com.attendx.model.Attendance;
import com.attendx.model.Settings;
import com.attendx.model.Teacher;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Date;
import java.time.LocalDate;

@WebServlet("/teacher/today")
public class TodayServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Teacher teacher = (Teacher) req.getSession().getAttribute("teacherUser");
        try {
            Date       today   = Date.valueOf(LocalDate.now());
            Attendance record  = new AttendanceDAO().findByTeacherAndDate(teacher.getTeacherId(), today);
            Settings   settings = new SettingsDAO().get();

            req.setAttribute("todayRecord", record);
            req.setAttribute("today",       today.toString());
            req.setAttribute("settings",    settings);
        } catch (Exception e) {
            req.setAttribute("error", "Could not load today's data.");
        }
        req.getRequestDispatcher("/WEB-INF/views/teacher/today.jsp").forward(req, resp);
    }
}
