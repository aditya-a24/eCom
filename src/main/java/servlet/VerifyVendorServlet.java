package servlet;

import jakarta.persistence.EntityManager;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import service.UserService;
import util.JPAUtil;

import java.io.IOException;

/**
 * NEW — Admin only: verify or revoke a vendor.
 * POST param: vendorId, action = "verify" | "revoke"
 */
public class VerifyVendorServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || !"admin".equals(session.getAttribute("role"))) {
            response.sendRedirect("index.jsp?error=auth");
            return;
        }

        String idParam = request.getParameter("vendorId");
        String action  = request.getParameter("action"); // "verify" or "revoke"

        int vendorId;
        try {
            vendorId = Integer.parseInt(idParam);
        } catch (NumberFormatException e) {
            response.sendRedirect("Dashboards/admin-dashboard.jsp?error=invalidInput");
            return;
        }

        EntityManager em = JPAUtil.getEntityManager();
        try {
            UserService us = new UserService(em);
            boolean ok;
            if ("revoke".equals(action)) {
                ok = us.revokeVendor(vendorId);
            } else {
                ok = us.verifyVendor(vendorId);
            }
            response.sendRedirect("Dashboards/admin-dashboard.jsp?success=" + (ok ? action + "d" : "fail"));
        } finally {
            em.close();
        }
    }
}
