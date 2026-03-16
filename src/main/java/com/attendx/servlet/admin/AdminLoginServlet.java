package com.attendx.servlet.admin;

import com.attendx.dao.AdminDAO;
import com.attendx.util.PasswordUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/admin/login")
public class AdminLoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // If already logged in, redirect to dashboard
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("adminUser") != null) {
            resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
            return;
        }
        req.getRequestDispatcher("/WEB-INF/views/admin/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String username = req.getParameter("username");
        String password = req.getParameter("password");

        if (username == null || username.isBlank() || password == null || password.isBlank()) {
            req.setAttribute("error", "Please enter username and password.");
            req.getRequestDispatcher("/WEB-INF/views/admin/login.jsp").forward(req, resp);
            return;
        }

        try {
            AdminDAO dao = new AdminDAO();
            String hash = dao.getPasswordHash(username.trim());
            if (hash != null && PasswordUtil.verifyPassword(password, hash)) {
                HttpSession session = req.getSession(true);
                session.setAttribute("adminUser", username.trim());
                session.setMaxInactiveInterval(60 * 60); // 1 hour
                resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
            } else {
                req.setAttribute("error", "Invalid username or password.");
                req.getRequestDispatcher("/WEB-INF/views/admin/login.jsp").forward(req, resp);
            }
        } catch (Exception e) {
            req.setAttribute("error", "An error occurred. Please try again.");
            req.getRequestDispatcher("/WEB-INF/views/admin/login.jsp").forward(req, resp);
        }
    }
}
