<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, entity.Product, entity.User" %>
<%
    // ── Auth guard ─────────────────────────────────────────────────────────────
    // CategoryServlet already guards this page, but we double-check in case of
    // direct URL access so the session is never invalidated here.
    HttpSession sess = request.getSession(false);
    String role = (sess != null) ? (String) sess.getAttribute("role") : null;
    if (role == null || role.equals("admin")) {
        response.sendRedirect("login.jsp");
        return;
    }

    User currentUser = (User) sess.getAttribute("user");
    String categoryName = (String) request.getAttribute("categoryName");
    if (categoryName == null) categoryName = "All";

    @SuppressWarnings("unchecked")
    List<Product> products = (List<Product>) request.getAttribute("products");
    if (products == null) products = new java.util.ArrayList<>();

    // Dashboard URL for "Back" link
    String dashboardUrl;
    if      ("vendor".equals(role)) dashboardUrl = "Dashboards/vendor-dashboard.jsp";
    else if ("admin".equals(role))  dashboardUrl = "Dashboards/admin-dashboard.jsp";
    else                             dashboardUrl = "Dashboards/user-dashboard.jsp";

    // Category icons for display
    java.util.Map<String,String> catIcons = new java.util.LinkedHashMap<>();
    catIcons.put("Electronics","📱"); catIcons.put("Fashion","👗"); catIcons.put("Home","🏠");
    catIcons.put("Beauty","💄"); catIcons.put("Gaming","🎮"); catIcons.put("Books","📚");
    catIcons.put("Sports","🏋️"); catIcons.put("Toys","🧸");
    String catIcon = catIcons.getOrDefault(categoryName, "🗂️");
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title><%= catIcon %> <%= categoryName %> — ShopNow</title>
  <link rel="stylesheet" href="css/theme.css">
  <link rel="stylesheet" href="css/dashboard-extras.css">
  <style>
    .category-header {
      padding: 28px 0 16px;
      display: flex;
      align-items: center;
      gap: 14px;
      flex-wrap: wrap;
    }
    .category-header h1 {
      font-size: 1.7rem;
      font-weight: 800;
      color: var(--text-primary);
      margin: 0;
    }
    .category-header .back-link {
      margin-left: auto;
      font-size: 0.9rem;
      color: var(--accent);
      text-decoration: none;
      padding: 6px 14px;
      border: 1px solid var(--accent);
      border-radius: var(--radius-xs);
      transition: background .2s;
    }
    .category-header .back-link:hover { background: var(--accent); color: #fff; }
    .category-pills {
      display: flex;
      gap: 8px;
      flex-wrap: wrap;
      margin-bottom: 24px;
    }
    .cat-pill {
      padding: 6px 14px;
      border-radius: 999px;
      border: 1.5px solid var(--border);
      font-size: 0.85rem;
      text-decoration: none;
      color: var(--text-secondary);
      background: var(--card-bg);
      transition: all .18s;
    }
    .cat-pill:hover, .cat-pill.active {
      background: var(--accent);
      border-color: var(--accent);
      color: #fff;
    }
    .results-count {
      font-size: 0.9rem;
      color: var(--text-secondary);
      margin-bottom: 16px;
    }
    .product-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
      gap: 20px;
    }
    .empty-category {
      text-align: center;
      padding: 60px 20px;
      color: var(--text-secondary);
    }
    .empty-category h2 { margin-bottom: 12px; }
  </style>
</head>
<body>
<script>(function(){var t=localStorage.getItem('theme')||'light';document.documentElement.setAttribute('data-theme',t);updateToggle(t);})();</script>

<nav class="navbar">
  <a href="index.jsp" class="logo" style="text-decoration:none;">🛍️ ShopNow</a>
  <div class="nav-links">
    <span class="nav-greeting">Hey, <%= currentUser != null ? currentUser.getName() : role %>!</span>
    <button class="theme-toggle" onclick="toggleTheme()"><span class="icon" id="themeIcon">🌙</span><span id="themeLabel">Dark</span></button>
    <a href="LogoutServlet" class="btn btn-logout btn-sm">Logout</a>
  </div>
</nav>

<div class="container">

  <div class="category-header">
    <span style="font-size:2rem;"><%= catIcon %></span>
    <h1><%= categoryName %></h1>
    <a href="<%= dashboardUrl %>" class="back-link">← Back to Shop</a>
  </div>

  <%-- Category quick-nav pills --%>
  <div class="category-pills">
    <a class="cat-pill <%= "All".equals(categoryName) ? "active" : "" %>"        href="CategoryServlet?category=All">🗂️ All</a>
    <a class="cat-pill <%= "Electronics".equals(categoryName) ? "active" : "" %>" href="CategoryServlet?category=Electronics">📱 Electronics</a>
    <a class="cat-pill <%= "Fashion".equals(categoryName) ? "active" : "" %>"     href="CategoryServlet?category=Fashion">👗 Fashion</a>
    <a class="cat-pill <%= "Home".equals(categoryName) ? "active" : "" %>"        href="CategoryServlet?category=Home">🏠 Home</a>
    <a class="cat-pill <%= "Beauty".equals(categoryName) ? "active" : "" %>"      href="CategoryServlet?category=Beauty">💄 Beauty</a>
    <a class="cat-pill <%= "Gaming".equals(categoryName) ? "active" : "" %>"      href="CategoryServlet?category=Gaming">🎮 Gaming</a>
    <a class="cat-pill <%= "Books".equals(categoryName) ? "active" : "" %>"       href="CategoryServlet?category=Books">📚 Books</a>
    <a class="cat-pill <%= "Sports".equals(categoryName) ? "active" : "" %>"      href="CategoryServlet?category=Sports">🏋️ Sports</a>
    <a class="cat-pill <%= "Toys".equals(categoryName) ? "active" : "" %>"        href="CategoryServlet?category=Toys">🧸 Toys</a>
  </div>

  <p class="results-count"><%= products.size() %> product<%= products.size() != 1 ? "s" : "" %> found in <strong><%= categoryName %></strong></p>

  <% if (products.isEmpty()) { %>
    <div class="empty-category">
      <h2>😔 No products in this category yet</h2>
      <p>Check back soon, or browse other categories above.</p>
      <a href="<%= dashboardUrl %>" class="btn btn-primary btn-sm" style="margin-top:16px;">← Browse All Products</a>
    </div>
  <% } else { %>
    <div class="product-grid">
    <% for (Product p : products) {
         boolean inStock = "Available".equals(p.getStatus()) && p.getStock() > 0;
         String primaryImg = p.getPrimaryImage();
         String[] allImgs  = p.getAllImages();
    %>
      <div class="product-card" onclick="location.href='ProductDetailServlet?productId=<%= p.getId() %>'" style="cursor:pointer;">
        <div class="product-img-wrap">
          <% if (primaryImg != null && !primaryImg.isEmpty()) { %>
            <img src="<%= primaryImg %>" alt="<%= p.getName() %>" id="cimg-<%= p.getId() %>">
            <% if (allImgs.length > 1) { %>
            <div class="img-gallery">
              <% for (int gi = 0; gi < Math.min(allImgs.length, 3); gi++) { %>
                <img class="img-thumb" src="<%= allImgs[gi].trim() %>"
                     onclick="swapImg('cimg-<%= p.getId() %>','<%= allImgs[gi].trim() %>')"
                     alt="img<%= gi+1 %>">
              <% } %>
            </div>
            <% } %>
          <% } else { %>
            <div class="img-placeholder">🛍️</div>
          <% } %>
          <% if (!inStock) { %><div class="oos-overlay"><span class="oos-label">Out of Stock</span></div><% } %>
        </div>
        <div class="product-card-body">
          <h3 class="product-name"><%= p.getName() %></h3>
          <p class="product-desc"><%= p.getDescription() != null ? p.getDescription() : "" %></p>
          <p class="product-price">₹<%= String.format("%.2f", p.getPrice()) %></p>
          <p class="product-stock">📦 Stock: <%= p.getStock() %></p>
        </div>
        <div class="product-card-footer">
          <span class="badge <%= inStock ? "badge-success" : "badge-danger" %>">
            <%= inStock ? "✅ Available" : "❌ Out of Stock" %>
          </span>
          <% if ("user".equals(role)) { %>
          <div style="display:flex;gap:8px;">
            <% if (inStock) { %>
            <form action="CartServlet" method="post" style="display:inline;" onclick="event.stopPropagation();">
              <input type="hidden" name="productId" value="<%= p.getId() %>">
              <input type="hidden" name="action" value="add">
              <button type="submit" class="btn btn-secondary btn-sm">🛒 Cart</button>
            </form>
            <form action="BuyNowServlet" method="post" style="display:inline;" onclick="event.stopPropagation();"
                  onsubmit="return confirm('Buy <%= p.getName().replace("'","\\'") %> for ₹<%= String.format("%.2f", p.getPrice()) %>?');">
              <input type="hidden" name="productId" value="<%= p.getId() %>">
              <button type="submit" class="btn btn-primary btn-sm">⚡ Buy Now</button>
            </form>
            <% } else { %>
            <button class="btn btn-secondary btn-sm" disabled style="opacity:.45;cursor:not-allowed;">🛒 Cart</button>
            <button class="btn btn-primary btn-sm" disabled style="opacity:.45;cursor:not-allowed;">⚡ Buy Now</button>
            <% } %>
          </div>
          <% } else if ("vendor".equals(role)) { %>
            <%-- Vendors browse only — no cart/buy actions --%>
            <span style="font-size:.8rem;color:var(--text-secondary);">Vendor view</span>
          <% } %>
        </div>
      </div>
    <% } %>
    </div>
  <% } %>

</div>

<script>
  function toggleTheme() {
    var c = document.documentElement.getAttribute('data-theme') || 'light';
    var n = c === 'dark' ? 'light' : 'dark';
    document.documentElement.setAttribute('data-theme', n);
    localStorage.setItem('theme', n);
    updateToggle(n);
  }
  function updateToggle(t) {
    var i = document.getElementById('themeIcon'), l = document.getElementById('themeLabel');
    if(i) i.textContent = t === 'dark' ? '☀️' : '🌙';
    if(l) l.textContent = t === 'dark' ? 'Light' : 'Dark';
  }
  function swapImg(id, src) { var el = document.getElementById(id); if (el) el.src = src; }
</script>
</body>
</html>
