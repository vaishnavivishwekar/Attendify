package com.attendx.servlet.admin;

import com.attendx.dao.AttendanceDAO;
import com.attendx.model.Attendance;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Date;
import java.time.LocalDate;
import java.util.List;

@WebServlet("/admin/reports")
public class AttendanceReportsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            String fromParam = req.getParameter("from");
            String toParam   = req.getParameter("to");

            Date from = fromParam != null && !fromParam.isBlank()
                    ? Date.valueOf(fromParam)
                    : Date.valueOf(LocalDate.now().withDayOfMonth(1)); // start of month
            Date to   = toParam != null && !toParam.isBlank()
                    ? Date.valueOf(toParam)
                    : Date.valueOf(LocalDate.now());

            AttendanceDAO dao = new AttendanceDAO();
            List<Attendance> records = dao.findForReport(from, to);

            req.setAttribute("records", records);
            req.setAttribute("from",    from.toString());
            req.setAttribute("to",      to.toString());
            req.getRequestDispatcher("/WEB-INF/views/admin/reports.jsp").forward(req, resp);
        } catch (Exception e) {
            req.setAttribute("error", "Failed to load reports: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/admin/reports.jsp").forward(req, resp);
        }
    }
}
