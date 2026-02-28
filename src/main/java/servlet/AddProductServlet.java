package servlet;

import entity.Product;
import jakarta.persistence.EntityManager;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import service.ProductService;
import util.JPAUtil;

import java.io.IOException;

public class AddProductServlet extends HttpServlet {

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

        String name        = request.getParameter("name");
        String description = request.getParameter("description");
        String priceStr    = request.getParameter("price");
        String stockStr    = request.getParameter("stock");
        String category    = request.getParameter("category");

        double price;
        int stock;
        try {
            price = Double.parseDouble(priceStr);
            stock = Integer.parseInt(stockStr);
            if (price < 0 || stock < 0) throw new NumberFormatException();
        } catch (NumberFormatException e) {
            response.sendRedirect("Dashboards/vendor-dashboard.jsp?error=invalidInput");
            return;
        }

        Product product = new Product();
        product.setName(name);
        product.setDescription(description);
        product.setPrice(price);
        product.setVendorEmail(vendor.getEmail());
        product.setStock(stock); // triggers auto-status
        if (category != null && !category.isBlank()) {
            product.setCategory(category.trim());
        }

        String imageUrls = request.getParameter("imageUrls");
        if (imageUrls != null && !imageUrls.isBlank()) {
            product.setImageUrls(imageUrls.trim());
        }

        EntityManager em = JPAUtil.getEntityManager();
        try {
            ProductService ps = new ProductService(em);
            boolean ok = ps.addProduct(product);
            response.sendRedirect("Dashboards/vendor-dashboard.jsp?success=" + (ok ? "added" : "fail"));
        } finally {
            em.close();
        }
    }
}
