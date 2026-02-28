package servlet;

import entity.Product;
import jakarta.persistence.EntityManager;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import service.ProductService;
import util.JPAUtil;

import java.io.IOException;

/**
 * Handles product update from BOTH vendor-dashboard and admin-dashboard.
 * Vendor: can update only own products.
 * Admin:  can update any product.
 */
public class UpdateProductServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String role = (session != null) ? (String) session.getAttribute("role") : null;
        boolean isAdmin  = "admin".equals(role);
        boolean isVendor = "vendor".equals(role);

        if (!isAdmin && !isVendor) {
            response.sendRedirect("index.jsp?error=auth");
            return;
        }

        String pidParam = request.getParameter("productId");
        if (pidParam == null || pidParam.isEmpty()) {
            response.sendRedirect(isAdmin
                ? "Dashboards/admin-dashboard.jsp?error=invalidInput"
                : "Dashboards/vendor-dashboard.jsp?error=invalidInput");
            return;
        }

        int productId;
        try {
            productId = Integer.parseInt(pidParam);
        } catch (NumberFormatException e) {
            response.sendRedirect(isAdmin
                ? "Dashboards/admin-dashboard.jsp?error=invalidInput"
                : "Dashboards/vendor-dashboard.jsp?error=invalidInput");
            return;
        }

        String name        = request.getParameter("name");
        String description = request.getParameter("description");
        String priceStr    = request.getParameter("price");

        double price;
        try {
            price = Double.parseDouble(priceStr);
            if (price < 0) throw new NumberFormatException();
        } catch (NumberFormatException e) {
            response.sendRedirect(isAdmin
                ? "Dashboards/admin-dashboard.jsp?error=invalidInput"
                : "Dashboards/vendor-dashboard.jsp?error=invalidInput");
            return;
        }

        EntityManager em = JPAUtil.getEntityManager();
        try {
            ProductService ps = new ProductService(em);
            Product product = ps.getProductById(productId);

            // Vendor ownership check
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

            product.setName(name);
            product.setDescription(description);
            product.setPrice(price);
            // Update imageUrls if provided
            String imageUrls = request.getParameter("imageUrls");
            if (imageUrls != null) {
                product.setImageUrls(imageUrls.isBlank() ? null : imageUrls.trim());
            }
            // Update category if provided
            String category = request.getParameter("category");
            if (category != null && !category.isBlank()) {
                product.setCategory(category.trim());
            }
            // NOTE: stock & status NOT changed here — use UpdateStockServlet for that

            boolean ok = ps.updateProduct(product);
            response.sendRedirect(isAdmin
                ? "Dashboards/admin-dashboard.jsp?success=updated"
                : "Dashboards/vendor-dashboard.jsp?success=updated");
        } finally {
            em.close();
        }
    }
}
