package com.attendx.servlet.teacher;

import com.attendx.dao.TeacherDAO;
import com.attendx.model.Teacher;
import com.attendx.util.PasswordUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/teacher/login")
public class TeacherLoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("teacherUser") != null) {
            resp.sendRedirect(req.getContextPath() + "/teacher/dashboard");
            return;
        }
        req.getRequestDispatcher("/WEB-INF/views/teacher/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String email    = req.getParameter("email");
        String password = req.getParameter("password");

        if (email == null || email.isBlank() || password == null || password.isBlank()) {
            req.setAttribute("error", "Email and password are required.");
            req.getRequestDispatcher("/WEB-INF/views/teacher/login.jsp").forward(req, resp);
            return;
        }

        try {
            TeacherDAO dao     = new TeacherDAO();
            Teacher    teacher = dao.findByEmail(email.trim().toLowerCase());

            if (teacher != null && PasswordUtil.verifyPassword(password, teacher.getPasswordHash())) {
                HttpSession session = req.getSession(true);
                session.setAttribute("teacherUser", teacher);
                session.setMaxInactiveInterval(60 * 60 * 8); // 8 hours
                // First-time users must register their face before they can mark attendance
                if (teacher.getFaceDescriptor() == null) {
                    resp.sendRedirect(req.getContextPath() + "/teacher/capture-face");
                } else {
                    resp.sendRedirect(req.getContextPath() + "/teacher/dashboard");
                }
            } else {
                req.setAttribute("error", "Invalid email or password.");
                req.getRequestDispatcher("/WEB-INF/views/teacher/login.jsp").forward(req, resp);
            }
        } catch (Exception e) {
            req.setAttribute("error", "Login failed. Please try again.");
            req.getRequestDispatcher("/WEB-INF/views/teacher/login.jsp").forward(req, resp);
        }
    }
}
