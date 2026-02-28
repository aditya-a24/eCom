package servlet;

import entity.Product;
import jakarta.persistence.EntityManager;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import service.ProductService;
import util.JPAUtil;

import java.io.IOException;

public class DeleteProductServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException { doPost(request, response); }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String role    = (session != null) ? (String) session.getAttribute("role") : null;
        boolean isAdmin  = "admin".equals(role);
        boolean isVendor = "vendor".equals(role);

        if (!isAdmin && !isVendor) {
            response.sendRedirect("index.jsp?error=auth");
            return;
        }

        // Accept productId or id param
        String idParam = request.getParameter("productId");
        if (idParam == null || idParam.isEmpty()) idParam = request.getParameter("id");

        int productId;
        try {
            productId = Integer.parseInt(idParam);
        } catch (Exception e) {
            response.sendRedirect(isAdmin
                ? "Dashboards/admin-dashboard.jsp?error=invalidInput"
                : "Dashboards/vendor-dashboard.jsp?error=invalidInput");
            return;
        }

        EntityManager em = JPAUtil.getEntityManager();
        try {
            ProductService ps = new ProductService(em);
            Product product = ps.getProductById(productId);

            if (product == null) {
                response.sendRedirect(isAdmin
                    ? "Dashboards/admin-dashboard.jsp?error=notFound"
                    : "Dashboards/vendor-dashboard.jsp?error=notFound");
                return;
            }

            if (isVendor) {
                String vendorEmail = ((entity.User) session.getAttribute("user")).getEmail();
                if (!vendorEmail.equals(product.getVendorEmail())) {
                    response.sendRedirect("Dashboards/vendor-dashboard.jsp?error=unauthorized");
                    return;
                }
            }

            // Admin: force delete. Vendor: only if OutOfStock.
            boolean deleted = ps.deleteProduct(product, isAdmin);
            if (deleted) {
                response.sendRedirect(isAdmin
                    ? "Dashboards/admin-dashboard.jsp?success=deleted"
                    : "Dashboards/vendor-dashboard.jsp?success=deleted");
            } else {
                // Vendor tried to delete an Available product
                response.sendRedirect("Dashboards/vendor-dashboard.jsp?error=cannotDelete");
            }
        } finally {
            em.close();
        }
    }
}
