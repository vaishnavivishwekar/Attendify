package com.attendx.servlet.teacher;

import com.attendx.dao.RegTokenDAO;
import com.attendx.dao.TeacherDAO;
import com.attendx.model.Teacher;
import com.attendx.util.PasswordUtil;
import org.json.JSONArray;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/teacher/register")
public class TeacherRegisterServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String regToken = req.getParameter("regToken");
        if (regToken == null || regToken.isBlank()) {
            req.setAttribute("error", "Invalid or missing registration token. Please scan the registration QR code from your admin.");
            req.getRequestDispatcher("/WEB-INF/views/teacher/register.jsp").forward(req, resp);
            return;
        }
        try {
            boolean valid = new RegTokenDAO().isValid(regToken);
            if (!valid) {
                req.setAttribute("error", "Registration link has expired or is invalid. Ask your admin to generate a new QR code.");
            } else {
                req.setAttribute("regToken", regToken);
            }
        } catch (Exception e) {
            req.setAttribute("error", "Registration service unavailable. Please try again.");
        }
        req.getRequestDispatcher("/WEB-INF/views/teacher/register.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String regToken  = req.getParameter("regToken");
        String name      = req.getParameter("name");
        String email     = req.getParameter("email");
        String phone     = req.getParameter("phone");
        String dept      = req.getParameter("department");
        String password  = req.getParameter("password");
        String password2 = req.getParameter("confirmPassword");
        String faceDescriptor = req.getParameter("faceDescriptor");

        // Normalize user input once to avoid mismatches across checks/insert/login
        String normalizedName  = name  == null ? "" : name.trim();
        String normalizedEmail = email == null ? "" : email.trim().toLowerCase();
        String normalizedPhone = phone == null ? "" : phone.trim();
        String normalizedDept  = dept  == null ? "" : dept.trim();

        req.setAttribute("regToken", regToken);

        // Validation
        if (normalizedName.isBlank() || normalizedEmail.isBlank()
                || password == null || password.isBlank()) {
            req.setAttribute("error", "Name, email, and password are required.");
            req.getRequestDispatcher("/WEB-INF/views/teacher/register.jsp").forward(req, resp);
            return;
        }
        if (!isValidFaceDescriptor(faceDescriptor)) {
            req.setAttribute("error", "Face registration is required. Please capture 8 face images before submitting.");
            req.getRequestDispatcher("/WEB-INF/views/teacher/register.jsp").forward(req, resp);
            return;
        }
        if (!password.equals(password2)) {
            req.setAttribute("error", "Passwords do not match.");
            req.getRequestDispatcher("/WEB-INF/views/teacher/register.jsp").forward(req, resp);
            return;
        }
        if (password.length() < 6) {
            req.setAttribute("error", "Password must be at least 6 characters.");
            req.getRequestDispatcher("/WEB-INF/views/teacher/register.jsp").forward(req, resp);
            return;
        }

        try {
            RegTokenDAO regDAO = new RegTokenDAO();
            if (!regDAO.isValid(regToken)) {
                req.setAttribute("error", "Registration token is invalid or expired.");
                req.getRequestDispatcher("/WEB-INF/views/teacher/register.jsp").forward(req, resp);
                return;
            }

            TeacherDAO teacherDAO = new TeacherDAO();
                if (teacherDAO.emailExists(normalizedEmail)) {
                req.setAttribute("error", "An account with this email already exists.");
                req.getRequestDispatcher("/WEB-INF/views/teacher/register.jsp").forward(req, resp);
                return;
            }

            Teacher t = new Teacher(
                    normalizedName,
                    normalizedEmail,
                    normalizedPhone,
                    normalizedDept,
                    PasswordUtil.hashPassword(password)
            );
            t.setFaceDescriptor(faceDescriptor);

            int teacherId = teacherDAO.create(t);
            resp.sendRedirect(req.getContextPath() + "/teacher/login?registered=true&teacherId=" + teacherId);
        } catch (Exception e) {
            req.setAttribute("error", "Registration failed: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/teacher/register.jsp").forward(req, resp);
        }
    }

    private boolean isValidFaceDescriptor(String descriptorJson) {
        if (descriptorJson == null || descriptorJson.isBlank()) {
            return false;
        }
        try {
            JSONArray arr = new JSONArray(descriptorJson);
            if (arr.length() != 128) {
                return false;
            }
            for (int i = 0; i < arr.length(); i++) {
                arr.getDouble(i);
            }
            return true;
        } catch (Exception ex) {
            return false;
        }
    }
}
