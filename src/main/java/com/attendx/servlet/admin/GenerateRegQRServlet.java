package com.attendx.servlet.admin;

import com.attendx.dao.RegTokenDAO;
import com.attendx.util.QRUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.UUID;

@WebServlet("/admin/generate-reg-qr")
public class GenerateRegQRServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            // Deactivate old tokens and create a new one
            RegTokenDAO dao = new RegTokenDAO();
            dao.deactivateAll();

            String token = UUID.randomUUID().toString().replace("-", "");
            dao.create(token);

            // Build the registration URL embedded in the QR
            String baseUrl = req.getScheme() + "://" + req.getServerName()
                    + (req.getServerPort() == 80 || req.getServerPort() == 443 ? "" : ":" + req.getServerPort())
                    + req.getContextPath();
            String regUrl = baseUrl + "/teacher/register?regToken=" + token;

            String qrBase64 = QRUtil.generateBase64QR(regUrl, 300, 300);

            req.setAttribute("qrBase64", qrBase64);
            req.setAttribute("regUrl",   regUrl);
            req.setAttribute("token",    token);
            req.getRequestDispatcher("/WEB-INF/views/admin/generate-reg-qr.jsp").forward(req, resp);
        } catch (Exception e) {
            req.setAttribute("error", "Failed to generate QR: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/admin/generate-reg-qr.jsp").forward(req, resp);
        }
    }
}
