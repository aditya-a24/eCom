<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="entity.Product, entity.User" %>
<%
    // ── Session awareness ──────────────────────────────────────────────────────
    HttpSession existingSession = request.getSession(false);
    String role      = (existingSession != null) ? (String) existingSession.getAttribute("role") : null;
    User   loggedUser= (existingSession != null) ? (User)   existingSession.getAttribute("user")  : null;
    boolean isUser   = "user".equals(role);
    boolean isLoggedIn = (role != null);

    // Dashboard URL
    String dashboardUrl;
    if      ("user".equals(role))   dashboardUrl = "Dashboards/user-dashboard.jsp";
    else if ("vendor".equals(role)) dashboardUrl = "Dashboards/vendor-dashboard.jsp";
    else if ("admin".equals(role))  dashboardUrl = "Dashboards/admin-dashboard.jsp";
    else                             dashboardUrl = "login.jsp";

    Product p = (Product) request.getAttribute("product");
    if (p == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    boolean inStock  = "Available".equals(p.getStatus()) && p.getStock() > 0;
    String  primary  = p.getPrimaryImage();
    String[] allImgs = p.getAllImages();
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title><%= p.getName() %> — ShopNow</title>
  <link rel="stylesheet" href="css/theme.css">
  <link rel="stylesheet" href="css/dashboard-extras.css">
  <style>
    .detail-container {
      max-width: 960px;
      margin: 40px auto;
      padding: 0 20px 60px;
    }
    .breadcrumb {
      font-size: .85rem;
      color: var(--text-secondary);
      margin-bottom: 28px;
    }
    .breadcrumb a { color: var(--accent); text-decoration: none; }
    .breadcrumb a:hover { text-decoration: underline; }
    .detail-grid {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 40px;
      align-items: start;
    }
    @media (max-width: 680px) { .detail-grid { grid-template-columns: 1fr; } }

    /* Image gallery */
    .detail-main-img {
      width: 100%;
      aspect-ratio: 1;
      object-fit: cover;
      border-radius: var(--radius-md, 12px);
      border: 1px solid var(--border);
      background: var(--card-bg);
    }
    .detail-img-placeholder {
      width: 100%;
      aspect-ratio: 1;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 5rem;
      border-radius: var(--radius-md, 12px);
      border: 1px solid var(--border);
      background: var(--card-bg);
    }
    .detail-thumbs {
      display: flex;
      gap: 10px;
      margin-top: 12px;
      flex-wrap: wrap;
    }
    .detail-thumb {
      width: 72px;
      height: 72px;
      object-fit: cover;
      border-radius: 8px;
      border: 2px solid var(--border);
      cursor: pointer;
      transition: border-color .2s;
    }
    .detail-thumb:hover, .detail-thumb.active { border-color: var(--accent); }

    /* Info panel */
    .detail-category-badge {
      display: inline-block;
      font-size: .78rem;
      padding: 4px 12px;
      border-radius: 999px;
      background: var(--accent-light, #eef2ff);
      color: var(--accent);
      font-weight: 600;
      margin-bottom: 12px;
    }
    .detail-name {
      font-size: 1.75rem;
      font-weight: 800;
      color: var(--text-primary);
      margin: 0 0 10px;
      line-height: 1.25;
    }
    .detail-price {
      font-size: 2rem;
      font-weight: 800;
      color: var(--accent);
      margin: 0 0 16px;
    }
    .detail-stock-info {
      font-size: .9rem;
      color: var(--text-secondary);
      margin-bottom: 8px;
    }
    .detail-desc {
      font-size: .97rem;
      color: var(--text-primary);
      line-height: 1.7;
      margin: 20px 0;
      padding: 16px;
      background: var(--card-bg);
      border-radius: 8px;
      border: 1px solid var(--border);
      white-space: pre-wrap;
      word-break: break-word;
    }
    .detail-actions {
      display: flex;
      gap: 14px;
      margin-top: 24px;
      flex-wrap: wrap;
    }
    .detail-actions .btn {
      flex: 1;
      min-width: 140px;
      padding: 14px 20px;
      font-size: 1rem;
      font-weight: 700;
      text-align: center;
    }
    .oos-banner {
      background: #fff3cd;
      color: #856404;
      border: 1px solid #ffc107;
      border-radius: 8px;
      padding: 12px 16px;
      margin-top: 20px;
      font-weight: 600;
    }
    .vendor-note {
      font-size: .8rem;
      color: var(--text-secondary);
      margin-top: 12px;
    }
  </style>
</head>
<body>
<script>(function(){var t=localStorage.getItem('theme')||'light';document.documentElement.setAttribute('data-theme',t);updateToggle(t);})();</script>

<nav class="navbar">
  <a href="index.jsp" class="logo" style="text-decoration:none;">🛍️ ShopNow</a>
  <div class="nav-links">
    <% if (isLoggedIn) { %>
      <span class="nav-greeting">Hey, <%= loggedUser != null ? loggedUser.getName() : role %>!
        &nbsp;<a href="<%= dashboardUrl %>" style="text-decoration:underline;">Dashboard</a>
      </span>
      <button class="theme-toggle" onclick="toggleTheme()"><span class="icon" id="themeIcon">🌙</span><span id="themeLabel">Dark</span></button>
      <a href="LogoutServlet" class="btn btn-logout btn-sm">Logout</a>
    <% } else { %>
      <a href="login.jsp" class="btn btn-primary btn-sm">Login</a>
      <button class="theme-toggle" onclick="toggleTheme()"><span class="icon" id="themeIcon">🌙</span><span id="themeLabel">Dark</span></button>
    <% } %>
  </div>
</nav>

<div class="detail-container">

  <div class="breadcrumb">
    <a href="index.jsp">🏠 Home</a>
    <% if (p.getCategory() != null && !p.getCategory().isBlank() && isLoggedIn) { %>
      &nbsp;›&nbsp;<a href="CategoryServlet?category=<%= p.getCategory() %>"><%= p.getCategory() %></a>
    <% } else if (p.getCategory() != null && !p.getCategory().isBlank()) { %>
      &nbsp;›&nbsp;<%= p.getCategory() %>
    <% } %>
    &nbsp;›&nbsp;<strong><%= p.getName() %></strong>
  </div>

  <div class="detail-grid">

    <!-- LEFT: Images -->
    <div>
      <% if (primary != null && !primary.isEmpty()) { %>
        <img src="<%= primary %>" alt="<%= p.getName() %>" id="mainImg" class="detail-main-img">
        <% if (allImgs.length > 1) { %>
        <div class="detail-thumbs">
          <% for (int i = 0; i < allImgs.length; i++) { String img = allImgs[i].trim(); if (img.isEmpty()) continue; %>
            <img src="<%= img %>" alt="img<%= i+1 %>"
                 class="detail-thumb <%= i == 0 ? "active" : "" %>"
                 onclick="selectImg(this, '<%= img %>')"
                 id="thumb-<%= i %>">
          <% } %>
        </div>
        <% } %>
      <% } else { %>
        <div class="detail-img-placeholder">🛍️</div>
      <% } %>
    </div>

    <!-- RIGHT: Info -->
    <div>
      <% if (p.getCategory() != null && !p.getCategory().isBlank()) { %>
        <span class="detail-category-badge">🗂️ <%= p.getCategory() %></span>
      <% } %>

      <h1 class="detail-name"><%= p.getName() %></h1>
      <p class="detail-price">₹<%= String.format("%.2f", p.getPrice()) %></p>

      <p class="detail-stock-info">
        <% if (inStock) { %>
          <span class="badge badge-success">✅ In Stock</span>
          &nbsp; <span>📦 <%= p.getStock() %> units available</span>
        <% } else { %>
          <span class="badge badge-danger">❌ Out of Stock</span>
        <% } %>
      </p>

      <% if (p.getDescription() != null && !p.getDescription().isBlank()) { %>
        <div class="detail-desc"><%= p.getDescription() %></div>
      <% } %>

      <% if (!inStock) { %>
        <div class="oos-banner">😔 This product is currently out of stock. Check back soon!</div>
      <% } else if (isUser) { %>
        <div class="detail-actions">
          <form action="CartServlet" method="post" style="flex:1;display:flex;">
            <input type="hidden" name="productId" value="<%= p.getId() %>">
            <input type="hidden" name="action" value="add">
            <button type="submit" class="btn btn-secondary" style="width:100%;">🛒 Add to Cart</button>
          </form>
          <form action="BuyNowServlet" method="post" style="flex:1;display:flex;"
                onsubmit="return confirm('Buy <%= p.getName().replace("'", "\\'") %> for ₹<%= String.format("%.2f", p.getPrice()) %>?');">
            <input type="hidden" name="productId" value="<%= p.getId() %>">
            <button type="submit" class="btn btn-primary" style="width:100%;">⚡ Buy Now</button>
          </form>
        </div>
      <% } else if (!isLoggedIn) { %>
        <div class="detail-actions">
          <a href="login.jsp" class="btn btn-primary" style="text-align:center;">🔐 Login to Purchase</a>
        </div>
      <% } else { %>
        <p class="vendor-note">👀 Vendor / Admin view — purchase actions not available here.</p>
      <% } %>

      <p class="vendor-note" style="margin-top:20px;">
        <a href="javascript:history.back()" style="color:var(--accent);">← Go Back</a>
      </p>
    </div>

  </div>
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
  function selectImg(el, src) {
    var main = document.getElementById('mainImg');
    if (main) main.src = src;
    document.querySelectorAll('.detail-thumb').forEach(function(t){ t.classList.remove('active'); });
    el.classList.add('active');
  }
</script>
</body>
</html>
