package servlet;

import entity.Product;
import jakarta.persistence.EntityManager;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import service.ProductService;
import util.JPAUtil;

import java.io.IOException;

/**
 * ProductDetailServlet — loads a single product and forwards to product-detail.jsp.
 *
 * URL: /ProductDetailServlet?productId=123
 *
 * Access: guests are shown a read-only view (no cart/buy buttons).
 *         Logged-in users see Add to Cart + Buy Now.
 */
public class ProductDetailServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pidParam = request.getParameter("productId");
        if (pidParam == null || pidParam.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/index.jsp");
            return;
        }

        int productId;
        try {
            productId = Integer.parseInt(pidParam.trim());
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/index.jsp");
            return;
        }

        EntityManager em = JPAUtil.getEntityManager();
        try {
            ProductService ps = new ProductService(em);
            Product product = ps.getProductById(productId);

            if (product == null) {
                response.sendRedirect(request.getContextPath() + "/index.jsp?error=notFound");
                return;
            }

            request.setAttribute("product", product);
            request.getRequestDispatcher("/product-detail.jsp").forward(request, response);
        } finally {
            em.close();
        }
    }
}
