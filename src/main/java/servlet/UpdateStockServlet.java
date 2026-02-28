package servlet;

import jakarta.persistence.EntityManager;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import service.ProductService;
import util.JPAUtil;
import entity.Product;

import java.io.IOException;

/**
 * NEW — Vendor: update the stock of one of their products.
 * Stock → 0 triggers automatic status change to OutOfStock via entity logic.
 */
public class UpdateStockServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || !"vendor".equals(session.getAttribute("role"))) {
            response.sendRedirect("index.jsp?error=auth");
            return;
        }

        entity.User vendor = (entity.User) session.getAttribute("user");
        if (!vendor.isVerified()) {
            response.sendRedirect("Dashboards/vendor-dashboard.jsp");
            return;
        }

        String pidParam   = request.getParameter("productId");
        String stockParam = request.getParameter("stock");

        int productId, newStock;
        try {
            productId = Integer.parseInt(pidParam);
            newStock  = Integer.parseInt(stockParam);
            if (newStock < 0) throw new NumberFormatException("negative");
        } catch (NumberFormatException e) {
            response.sendRedirect("Dashboards/vendor-dashboard.jsp?error=invalidInput");
            return;
        }

        EntityManager em = JPAUtil.getEntityManager();
        try {
            ProductService ps = new ProductService(em);
            Product product = ps.getProductById(productId);

            if (product == null || !vendor.getEmail().equals(product.getVendorEmail())) {
                response.sendRedirect("Dashboards/vendor-dashboard.jsp?error=notFound");
                return;
            }

            boolean ok = ps.updateStock(productId, newStock);
            response.sendRedirect("Dashboards/vendor-dashboard.jsp?success=" + (ok ? "stockUpdated" : "fail"));
        } finally {
            em.close();
        }
    }
}
