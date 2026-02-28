package servlet;

import entity.User;
import jakarta.persistence.EntityManager;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import service.UserService;
import util.JPAUtil;

import java.io.IOException;

public class UserRegisterServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String name     = request.getParameter("name");
        String email    = request.getParameter("email");
        String password = request.getParameter("password");

        // Basic server-side validation
        if (name == null || name.trim().isEmpty() ||
            email == null || email.trim().isEmpty() ||
            password == null || password.length() < 6) {

            request.setAttribute("errorMsg", "Please fill all fields. Password must be at least 6 characters.");
            request.getRequestDispatcher("userRegister.jsp").forward(request, response);
            return;
        }

        EntityManager em = JPAUtil.getEntityManager();
        try {
            UserService userService = new UserService(em);
            boolean success = userService.register(new User(name.trim(), email.trim(), password, "user"));

            if (success) {
                // Redirect to login with success flag
                response.sendRedirect("login.jsp?registered=1");
            } else {
                // Stay on page — email already exists
                request.setAttribute("errorMsg", "An account with this email already exists.");
                request.getRequestDispatcher("userRegister.jsp").forward(request, response);
            }
        } finally {
            em.close();
        }
    }
}
