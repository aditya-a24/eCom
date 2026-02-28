package servlet;

import entity.User;
import jakarta.persistence.EntityManager;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import service.UserService;
import util.JPAUtil;

import java.io.IOException;


public class UpdateUserServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        // Only admin can update users
        if (session == null || !"admin".equals(session.getAttribute("role"))) {
            response.sendRedirect("index.jsp?error=3"); // Not authorized
            return;
        }

        int userId = Integer.parseInt(request.getParameter("userId"));
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String role = request.getParameter("role");

        EntityManager em = JPAUtil.getEntityManager();
        try {
            UserService userService = new UserService(em);

            User user = userService.getUserById(userId); // we need a method in UserService to fetch by ID
            if (user != null) {
                user.setName(name);
                user.setEmail(email);
                if (password != null && !password.trim().isEmpty()) {
                    user.setPassword(password);
                }
                user.setRole(role);

                boolean updated = userService.updateUser(user); // we need updateUser method in UserService
                if (updated) {
                    response.sendRedirect("Dashboards/admin-dashboard.jsp?success=2");
                } else {
                    response.sendRedirect("Dashboards/admin-dashboard.jsp?error=2");
                }
            } else {
                response.sendRedirect("Dashboards/admin-dashboard.jsp?error=3");
            }

        } finally {
            em.close();
        }
    }
}