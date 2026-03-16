package com.attendx.servlet.admin;

import com.attendx.dao.AttendanceDAO;
import com.attendx.dao.TeacherDAO;
import com.attendx.model.Attendance;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Date;
import java.time.LocalDate;
import java.util.List;

@WebServlet("/admin/dashboard")
public class AdminDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            Date today = Date.valueOf(LocalDate.now());
            TeacherDAO teacherDAO = new TeacherDAO();
            AttendanceDAO attDAO  = new AttendanceDAO();

            int totalTeachers  = teacherDAO.countActive();
            int presentToday   = attDAO.countByDateWithIn(today);
            int markedOut      = attDAO.countByDateWithOut(today);
            int absent         = totalTeachers - presentToday;

            List<Attendance> todayRecords = attDAO.findByDateForAdmin(today);

            req.setAttribute("totalTeachers", totalTeachers);
            req.setAttribute("presentToday",  presentToday);
            req.setAttribute("markedOut",     markedOut);
            req.setAttribute("absent",        absent);
            req.setAttribute("todayRecords",  todayRecords);
            req.setAttribute("today",         today.toString());

            req.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp").forward(req, resp);
        } catch (Exception e) {
            req.setAttribute("error", "Failed to load dashboard: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp").forward(req, resp);
        }
    }
}
