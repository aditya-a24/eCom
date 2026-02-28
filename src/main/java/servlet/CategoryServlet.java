package servlet;

import entity.Product;
import jakarta.persistence.EntityManager;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import service.ProductService;
import util.JPAUtil;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 * CategoryServlet — filters products by category keyword and forwards to category.jsp.
 *
 * Access rules:
 *   - Requires an active session with role "user" or "vendor".
 *   - Guests are redirected to login.
 *   - No session is created or destroyed here.
 *
 * URL: /CategoryServlet?category=Electronics
 */
public class CategoryServlet extends HttpServlet {

    /**
     * Keyword map: category name → keywords to match against product name/description (case-insensitive).
     */
    private static final java.util.Map<String, String[]> CATEGORY_KEYWORDS = new java.util.LinkedHashMap<>();

    static {
        CATEGORY_KEYWORDS.put("Electronics", new String[]{"phone","laptop","tablet","tv","camera","headphone","speaker","charger","battery","electronic","computer","monitor","keyboard","mouse","cable","usb","smartwatch","drone"});
        CATEGORY_KEYWORDS.put("Fashion",     new String[]{"shirt","jeans","dress","kurta","saree","shoes","sandal","jacket","coat","fashion","clothing","wear","bag","purse","belt","hat","cap","scarf","trouser","skirt"});
        CATEGORY_KEYWORDS.put("Home",        new String[]{"furniture","sofa","bed","chair","table","lamp","curtain","pillow","blanket","kitchen","utensil","decor","shelf","cabinet","home","living","mattress","rug","carpet"});
        CATEGORY_KEYWORDS.put("Beauty",      new String[]{"cream","lipstick","makeup","perfume","shampoo","conditioner","moisturizer","serum","foundation","eyeliner","blush","skincare","haircare","beauty","lotion","soap","facewash"});
        CATEGORY_KEYWORDS.put("Gaming",      new String[]{"game","gaming","console","playstation","xbox","controller","joystick","headset","gpu","graphics","mouse","keyboard","monitor","pc","streaming"});
        CATEGORY_KEYWORDS.put("Books",       new String[]{"book","novel","textbook","magazine","comic","storybook","fiction","nonfiction","guide","manual","journal","diary","notebook","pen","pencil","stationery"});
        CATEGORY_KEYWORDS.put("Sports",      new String[]{"sports","cricket","football","basketball","tennis","badminton","gym","fitness","yoga","cycling","running","shoe","jersey","glove","bat","ball","racket","dumbbell","treadmill"});
        CATEGORY_KEYWORDS.put("Toys",        new String[]{"toy","doll","puzzle","lego","game","board game","bicycle","scooter","rc car","action figure","stuffed","plush","kids","children","baby","play"});
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ── Auth guard: only logged-in users and vendors may browse categories ──
        HttpSession session = request.getSession(false);
        String role = (session != null) ? (String) session.getAttribute("role") : null;

        if (role == null || role.equals("admin")) {
            // Guests → login; admins have their own dashboard
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String category = request.getParameter("category");
        if (category == null || category.isBlank()) {
            category = "All";
        }

        // ── Fetch and filter products ──────────────────────────────────────────
        EntityManager em = JPAUtil.getEntityManager();
        List<Product> filtered = new ArrayList<>();
        try {
            ProductService ps = new ProductService(em);
            List<Product> all = ps.getAllProducts();

            String[] keywords = CATEGORY_KEYWORDS.get(category);

            for (Product p : all) {
                if (!"Available".equals(p.getStatus()) || p.getStock() <= 0) continue;

                if (keywords == null) {
                    // "All" or unknown category — include everything available
                    filtered.add(p);
                } else {
                    // Primary: match stored category field (exact, case-insensitive)
                    if (category.equalsIgnoreCase(p.getCategory())) {
                        filtered.add(p);
                        continue;
                    }
                    // Fallback: keyword match for products without a stored category
                    if (p.getCategory() == null || p.getCategory().isBlank()) {
                        String searchText = ((p.getName() != null ? p.getName() : "") + " "
                                           + (p.getDescription() != null ? p.getDescription() : "")).toLowerCase();
                        for (String kw : keywords) {
                            if (searchText.contains(kw.toLowerCase())) {
                                filtered.add(p);
                                break;
                            }
                        }
                    }
                }
            }
        } finally {
            em.close();
        }

        // ── Forward to category view ───────────────────────────────────────────
        request.setAttribute("categoryName", category);
        request.setAttribute("products", filtered);
        request.getRequestDispatcher("/category.jsp").forward(request, response);
    }
}
