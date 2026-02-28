package servlet;

import entity.Product;
import jakarta.persistence.EntityManager;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import service.ProductService;
import util.JPAUtil;

import java.io.IOException;

/**
 * NEW — "Buy Now": immediately decrement stock by 1 and redirect.
 * If stock hits 0, product auto-becomes OutOfStock via entity logic.
 */
public class BuyNowServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || !"user".equals(session.getAttribute("role"))) {
            response.sendRedirect("login.jsp");
            return;
        }

        String pidParam = request.getParameter("productId");
        int productId;
        try {
            productId = Integer.parseInt(pidParam);
        } catch (NumberFormatException e) {
            response.sendRedirect("Dashboards/user-dashboard.jsp?error=invalidInput");
            return;
        }

        EntityManager em = JPAUtil.getEntityManager();
        try {
            ProductService ps = new ProductService(em);
            Product product = ps.getProductById(productId);

            if (product == null || !"Available".equals(product.getStatus()) || product.getStock() <= 0) {
                response.sendRedirect("Dashboards/user-dashboard.jsp?error=unavailable");
                return;
            }

            // Decrement stock by 1 (entity handles OutOfStock automatically)
            boolean ok = ps.updateStock(productId, product.getStock() - 1);
            response.sendRedirect("Dashboards/user-dashboard.jsp?success=" + (ok ? "purchased" : "fail"));
        } finally {
            em.close();
        }
    }
}
