package servlet;

import entity.User;
import jakarta.persistence.EntityManager;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import service.UserService;
import util.JPAUtil;

import java.io.IOException;

public class LoginServlet extends HttpServlet {

    private static final String ADMIN_EMAIL    = "admin@admin.com";
    private static final String ADMIN_PASSWORD = "admin123";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email    = request.getParameter("email");
        String password = request.getParameter("password");


        if (ADMIN_EMAIL.equals(email) && ADMIN_PASSWORD.equals(password)) {
            HttpSession session = request.getSession();
            session.setAttribute("role",  "admin");
            session.setAttribute("admin", email);
            response.sendRedirect("Dashboards/admin-dashboard.jsp");
            return;
        }

        EntityManager em = JPAUtil.getEntityManager();
        try {
            UserService userService = new UserService(em);
            User user = userService.login(email, password);

            if (user == null) {
                // Stay on login page — forward with error attribute
                request.setAttribute("errorMsg", "Invalid email or password. Please try again.");
                request.getRequestDispatcher("login.jsp").forward(request, response);
                return;
            }

            // Vendor pending-approval check
            if ("vendor".equals(user.getRole()) && !user.isVerified()) {
                request.setAttribute("errorMsg", "Your vendor account is pending admin approval.");
                request.getRequestDispatcher("login.jsp").forward(request, response);
                return;
            }

            HttpSession session = request.getSession();
            session.setAttribute("user", user);
            session.setAttribute("role", user.getRole());

            switch (user.getRole()) {
                case "user":   response.sendRedirect("Dashboards/user-dashboard.jsp");   break;
                case "vendor": response.sendRedirect("Dashboards/vendor-dashboard.jsp"); break;
                case "admin":  response.sendRedirect("Dashboards/admin-dashboard.jsp");  break;
                default:       response.sendRedirect("index.jsp");
            }
        } finally {
            em.close();
        }
    }
}
