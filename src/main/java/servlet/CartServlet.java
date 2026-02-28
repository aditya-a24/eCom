package servlet;

import jakarta.persistence.EntityManager;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import service.CartService;
import util.JPAUtil;

import java.io.IOException;

/**
 * NEW — Handle Add to Cart and Remove from Cart.
 * POST param: productId, action = "add" | "remove"
 */
public class CartServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || !"user".equals(session.getAttribute("role"))) {
            response.sendRedirect("login.jsp");
            return;
        }

        entity.User user = (entity.User) session.getAttribute("user");
        String pidParam  = request.getParameter("productId");
        String action    = request.getParameter("action"); // "add" or "remove"

        int productId;
        try {
            productId = Integer.parseInt(pidParam);
        } catch (NumberFormatException e) {
            response.sendRedirect("Dashboards/user-dashboard.jsp?error=invalidInput");
            return;
        }

        EntityManager em = JPAUtil.getEntityManager();
        try {
            CartService cs = new CartService(em);
            if ("remove".equals(action)) {
                cs.removeFromCart(user.getEmail(), productId);
                response.sendRedirect("Dashboards/user-dashboard.jsp?tab=cart&success=removed");
            } else {
                boolean ok = cs.addToCart(user.getEmail(), productId);
                response.sendRedirect("Dashboards/user-dashboard.jsp?tab=cart&success=" + (ok ? "added" : "unavailable"));
            }
        } finally {
            em.close();
        }
    }
}
