package servlet;

import entity.User;
import jakarta.persistence.EntityManager;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import service.UserService;
import util.JPAUtil;

import java.io.IOException;

public class VendorRegisterServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String vendorName = request.getParameter("vendorName");
        String email      = request.getParameter("email");
        String password   = request.getParameter("password");

        if (vendorName == null || vendorName.trim().isEmpty() ||
            email == null || email.trim().isEmpty() ||
            password == null || password.length() < 6) {

            request.setAttribute("errorMsg", "Please fill all fields. Password must be at least 6 characters.");
            request.getRequestDispatcher("vendorRegister.jsp").forward(request, response);
            return;
        }

        EntityManager em = JPAUtil.getEntityManager();
        try {
            UserService userService = new UserService(em);
            // User constructor sets verified=false for vendors automatically
            boolean success = userService.register(new User(vendorName.trim(), email.trim(), password, "vendor"));

            if (success) {
                // Inform them approval is needed — redirect to login with special flag
                response.sendRedirect("login.jsp?vendorPending=1");
            } else {
                request.setAttribute("errorMsg", "An account with this email already exists.");
                request.getRequestDispatcher("vendorRegister.jsp").forward(request, response);
            }
        } finally {
            em.close();
        }
    }
}
