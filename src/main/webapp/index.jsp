<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.ArrayList, entity.Product, entity.User, jakarta.persistence.EntityManager, util.JPAUtil, service.ProductService" %>
<%
    // ── Session-awareness ──────────────────────────────────────────────────────
    // Read the existing session WITHOUT creating a new one (getSession(false)).
    // This is critical: calling getSession() or getSession(true) on index.jsp
    // can cause the container to reset the session in some configurations.
    HttpSession existingSession = request.getSession(false);
    String role = (existingSession != null) ? (String) existingSession.getAttribute("role") : null;
    User   loggedUser = (existingSession != null) ? (User) existingSession.getAttribute("user") : null;
    boolean isLoggedIn = (role != null);

    // Resolve the correct dashboard URL for this role
    String dashboardUrl;
    if      ("user".equals(role))   dashboardUrl = "Dashboards/user-dashboard.jsp";
    else if ("vendor".equals(role)) dashboardUrl = "Dashboards/vendor-dashboard.jsp";
    else if ("admin".equals(role))  dashboardUrl = "Dashboards/admin-dashboard.jsp";
    else                             dashboardUrl = "login.jsp";

    // Convenience: "View All" / product-click destination
    String shopLink = isLoggedIn ? dashboardUrl : "login.jsp";

    // ── Products ───────────────────────────────────────────────────────────────
    EntityManager em = JPAUtil.getEntityManager();
    ProductService ps = new ProductService(em);
    List<Product> allProducts = ps.getAllProducts();
    List<Product> availableProducts = new ArrayList<>();
    for (Product p : allProducts) {
        if ("Available".equals(p.getStatus()) && p.getStock() > 0) {
            availableProducts.add(p);
        }
    }
    em.close();
    int total = availableProducts.size();
    List<Product> featured = availableProducts.subList(0, Math.min(8, total));
    List<Product> newArr   = total > 0 ? availableProducts.subList(Math.max(0, total - 8), total) : availableProducts;
    List<Product> popular  = availableProducts.subList(0, Math.min(6, total));
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>ShopNow — Premium Online Store</title>
  <link rel="stylesheet" href="css/theme.css">
  <link rel="stylesheet" href="css/landing.css">
</head>
<body>
<script>(function(){var t=localStorage.getItem('theme')||'light';document.documentElement.setAttribute('data-theme',t);})();</script>

<nav class="navbar">
  <a href="index.jsp" class="logo" style="text-decoration:none;">🛍️ ShopNow</a>
  <div class="nav-links">
    <% if (isLoggedIn) { %>
      <%-- Logged-in nav: greeting + dashboard link + logout --%>
      <span class="nav-greeting">
        Hey, <%= loggedUser != null ? loggedUser.getName() : role %>!
        &nbsp;<a href="<%= dashboardUrl %>" style="text-decoration:underline;">Dashboard</a>
      </span>
      <button class="theme-toggle" onclick="toggleTheme()" aria-label="Toggle dark mode">
        <span class="icon" id="themeIcon">🌙</span><span id="themeLabel">Dark</span>
      </button>
      <a href="LogoutServlet" class="btn btn-logout btn-sm">Logout</a>
    <% } else { %>
      <%-- Guest nav --%>
      <div class="dropdown">
        <a style="cursor:pointer;">Register ▼</a>
        <div class="dropdown-content">
          <a href="userRegister.jsp">👤 Register as User</a>
          <a href="vendorRegister.jsp">🏪 Register as Vendor</a>
        </div>
      </div>
      <a href="login.jsp" class="btn btn-primary btn-sm">Login</a>
      <button class="theme-toggle" onclick="toggleTheme()" aria-label="Toggle dark mode">
        <span class="icon" id="themeIcon">🌙</span><span id="themeLabel">Dark</span>
      </button>
    <% } %>
  </div>
</nav>

<% if ("success".equals(request.getParameter("logout"))) { %>
  <div class="alert alert-success lp-alert">You have been logged out successfully.</div>
<% } %>
<% if ("auth".equals(request.getParameter("error"))) { %>
  <div class="alert alert-danger lp-alert">Please login to continue.</div>
<% } %>

<!-- HERO -->
<section class="hero">
  <div class="hero-content">
    <h1>Everything You Love,<br>Delivered Fast 🚀</h1>
    <p>Discover thousands of products at unbeatable prices — electronics, fashion, home decor &amp; more.</p>
    <div class="hero-cta">
      <% if (isLoggedIn) { %>
        <a href="<%= dashboardUrl %>" class="btn-hero-primary">🛍️ Go to Shop</a>
      <% } else { %>
        <a href="login.jsp" class="btn-hero-primary">🛍️ Shop Now</a>
        <a href="userRegister.jsp" class="btn-hero-secondary">✨ Join Free</a>
      <% } %>
    </div>
  </div>
</section>

<!-- FEATURE STRIP -->
<div class="features-strip">
  <ul>
    <li><span>🚚</span> Free Shipping over ₹999</li>
    <li><span>🔒</span> Secure Payments</li>
    <li><span>↩️</span> 7-Day Easy Returns</li>
    <li><span>🎧</span> 24/7 Support</li>
    <li><span>⚡</span> Same-Day Dispatch</li>
  </ul>
</div>

<div class="lp-container">

  <!-- CATEGORIES -->
  <div class="section-gap">
    <div class="section-header"><h2>🗂️ Shop by Category</h2></div>
    <div class="categories-grid">
      <%-- Logged-in users go to CategoryServlet; guests are directed to login --%>
      <a class="cat-tile" href="<%= isLoggedIn ? "CategoryServlet?category=Electronics" : "login.jsp" %>"><span class="cat-icon">📱</span><span class="cat-name">Electronics</span></a>
      <a class="cat-tile" href="<%= isLoggedIn ? "CategoryServlet?category=Fashion"     : "login.jsp" %>"><span class="cat-icon">👗</span><span class="cat-name">Fashion</span></a>
      <a class="cat-tile" href="<%= isLoggedIn ? "CategoryServlet?category=Home"        : "login.jsp" %>"><span class="cat-icon">🏠</span><span class="cat-name">Home &amp; Living</span></a>
      <a class="cat-tile" href="<%= isLoggedIn ? "CategoryServlet?category=Beauty"      : "login.jsp" %>"><span class="cat-icon">💄</span><span class="cat-name">Beauty</span></a>
      <a class="cat-tile" href="<%= isLoggedIn ? "CategoryServlet?category=Gaming"      : "login.jsp" %>"><span class="cat-icon">🎮</span><span class="cat-name">Gaming</span></a>
      <a class="cat-tile" href="<%= isLoggedIn ? "CategoryServlet?category=Books"       : "login.jsp" %>"><span class="cat-icon">📚</span><span class="cat-name">Books</span></a>
      <a class="cat-tile" href="<%= isLoggedIn ? "CategoryServlet?category=Sports"      : "login.jsp" %>"><span class="cat-icon">🏋️</span><span class="cat-name">Sports</span></a>
      <a class="cat-tile" href="<%= isLoggedIn ? "CategoryServlet?category=Toys"        : "login.jsp" %>"><span class="cat-icon">🧸</span><span class="cat-name">Toys</span></a>
    </div>
  </div>

  <!-- FEATURED CAROUSEL -->
  <% if (!featured.isEmpty()) { %>
  <div class="section-gap">
    <div class="section-header">
      <h2>⭐ Featured Products</h2>
      <a href="<%= shopLink %>">View All →</a>
    </div>
    <div class="carousel-wrapper" id="cw-featured">
      <button class="c-btn c-prev" data-carousel="featured">&#8249;</button>
      <div class="c-track" id="ct-featured">
        <% for (Product p : featured) {
               boolean ins = "Available".equals(p.getStatus()) && p.getStock() > 0;
               String pi = p.getPrimaryImage(); String[] ai = p.getAllImages(); %>
        <div class="c-slide"><div class="product-card" onclick="location.href='ProductDetailServlet?productId=<%=p.getId()%>'">
          <div class="product-img-wrap">
            <% if (pi != null && !pi.isEmpty()) { %><img src="<%=pi%>" alt="<%=p.getName()%>" id="pimg-f-<%=p.getId()%>">
            <% if (ai.length > 1) { %><div class="img-gallery"><% for(int g=0;g<Math.min(ai.length,3);g++){%><img class="img-thumb" src="<%=ai[g].trim()%>" onclick="event.stopPropagation();swapImg('pimg-f-<%=p.getId()%>','<%=ai[g].trim()%>')" alt="img<%=g+1%>"><%}%></div><%}%>
            <% } else { %><div class="img-placeholder">🛍️</div><% } %>
            <% if (!ins) { %><div class="oos-overlay"><span class="oos-label">Out of Stock</span></div><% } %>
          </div>
          <div class="product-card-body">
            <h3 class="product-name"><%=p.getName()%></h3>
            <p class="product-desc"><%=p.getDescription()!=null?p.getDescription():""%></p>
            <p class="product-price">₹<%=String.format("%.2f",p.getPrice())%></p>
            <p class="product-stock">📦 Stock: <%=p.getStock()%></p>
          </div>
          <div class="product-card-footer">
            <span class="badge <%=ins?"badge-success":"badge-danger"%>"><%=ins?"✅ Available":"❌ Out of Stock"%></span>
            <a href="<%=ins?"ProductDetailServlet?productId="+p.getId():"#"%>" class="btn btn-primary btn-sm<%=!ins?" btn-oos":""%>" <%=!ins?"onclick=\"return false;\" aria-disabled=\"true\"":""%>>⚡ Buy Now</a>
          </div>
        </div></div>
        <% } %>
      </div>
      <button class="c-btn c-next" data-carousel="featured">&#8250;</button>
    </div>
    <div class="c-dots" id="cd-featured"></div>
  </div>
  <% } %>

  <!-- NEW ARRIVALS CAROUSEL -->
  <% if (!newArr.isEmpty()) { %>
  <div class="section-gap">
    <div class="section-header">
      <h2>🆕 New Arrivals</h2>
      <a href="<%= shopLink %>">View All →</a>
    </div>
    <div class="carousel-wrapper" id="cw-newarr">
      <button class="c-btn c-prev" data-carousel="newarr">&#8249;</button>
      <div class="c-track" id="ct-newarr">
        <% for (Product p : newArr) { boolean ins = "Available".equals(p.getStatus()) && p.getStock() > 0; String pi = p.getPrimaryImage(); String[] ai = p.getAllImages(); %>
        <div class="c-slide"><div class="product-card" onclick="location.href='ProductDetailServlet?productId=<%=p.getId()%>'">
          <div class="product-img-wrap">
            <% if (pi != null && !pi.isEmpty()) { %><img src="<%=pi%>" alt="<%=p.getName()%>" id="pimg-n-<%=p.getId()%>">
            <% if (ai.length > 1) { %><div class="img-gallery"><% for(int g=0;g<Math.min(ai.length,3);g++){%><img class="img-thumb" src="<%=ai[g].trim()%>" onclick="event.stopPropagation();swapImg('pimg-n-<%=p.getId()%>','<%=ai[g].trim()%>')" alt="img<%=g+1%>"><%}%></div><%}%>
            <% } else { %><div class="img-placeholder">🆕</div><% } %>
            <% if (!ins) { %><div class="oos-overlay"><span class="oos-label">Out of Stock</span></div><% } %>
          </div>
          <div class="product-card-body">
            <h3 class="product-name"><%=p.getName()%></h3>
            <p class="product-desc"><%=p.getDescription()!=null?p.getDescription():""%></p>
            <p class="product-price">₹<%=String.format("%.2f",p.getPrice())%></p>
            <p class="product-stock">📦 Stock: <%=p.getStock()%></p>
          </div>
          <div class="product-card-footer">
            <span class="badge <%=ins?"badge-success":"badge-danger"%>"><%=ins?"✅ Available":"❌ Out of Stock"%></span>
            <a href="<%=ins?"ProductDetailServlet?productId="+p.getId():"#"%>" class="btn btn-primary btn-sm<%=!ins?" btn-oos":""%>" <%=!ins?"onclick=\"return false;\" aria-disabled=\"true\"":""%>>⚡ Buy Now</a>
          </div>
        </div></div>
        <% } %>
      </div>
      <button class="c-btn c-next" data-carousel="newarr">&#8250;</button>
    </div>
    <div class="c-dots" id="cd-newarr"></div>
  </div>
  <% } %>

  <!-- PROMO BANNER -->
  <div class="promo-banner">
    <div>
      <h3>🎉 Limited Time Offer!</h3>
      <p>Get extra 20% off on your first order. Use code <strong>WELCOME20</strong></p>
    </div>
    <% if (isLoggedIn) { %>
    <a href="<%= dashboardUrl %>" class="btn-white">🚀 Shop Now</a>
    <% } else { %>
    <a href="userRegister.jsp" class="btn-white">🚀 Claim Offer</a>
    <% } %>
  </div>

  <!-- POPULAR CAROUSEL -->
  <% if (!popular.isEmpty()) { %>
  <div class="section-gap">
    <div class="section-header">
      <h2>🔥 Popular Items</h2>
      <a href="<%= shopLink %>">View All →</a>
    </div>
    <div class="carousel-wrapper" id="cw-popular">
      <button class="c-btn c-prev" data-carousel="popular">&#8249;</button>
      <div class="c-track" id="ct-popular">
        <% for (Product p : popular) { boolean ins = "Available".equals(p.getStatus()) && p.getStock() > 0; String pi = p.getPrimaryImage(); String[] ai = p.getAllImages(); %>
        <div class="c-slide"><div class="product-card" onclick="location.href='ProductDetailServlet?productId=<%=p.getId()%>'">
          <div class="product-img-wrap">
            <% if (pi != null && !pi.isEmpty()) { %><img src="<%=pi%>" alt="<%=p.getName()%>" id="pimg-p-<%=p.getId()%>">
            <% if (ai.length > 1) { %><div class="img-gallery"><% for(int g=0;g<Math.min(ai.length,3);g++){%><img class="img-thumb" src="<%=ai[g].trim()%>" onclick="event.stopPropagation();swapImg('pimg-p-<%=p.getId()%>','<%=ai[g].trim()%>')" alt="img<%=g+1%>"><%}%></div><%}%>
            <% } else { %><div class="img-placeholder">🔥</div><% } %>
            <% if (!ins) { %><div class="oos-overlay"><span class="oos-label">Out of Stock</span></div><% } %>
          </div>
          <div class="product-card-body">
            <h3 class="product-name"><%=p.getName()%></h3>
            <p class="product-desc"><%=p.getDescription()!=null?p.getDescription():""%></p>
            <p class="product-price">₹<%=String.format("%.2f",p.getPrice())%></p>
            <p class="product-stock">📦 Stock: <%=p.getStock()%></p>
          </div>
          <div class="product-card-footer">
            <span class="badge <%=ins?"badge-success":"badge-danger"%>"><%=ins?"✅ Available":"❌ Out of Stock"%></span>
            <a href="<%=ins?"ProductDetailServlet?productId="+p.getId():"#"%>" class="btn btn-primary btn-sm<%=!ins?" btn-oos":""%>" <%=!ins?"onclick=\"return false;\" aria-disabled=\"true\"":""%>>⚡ Buy Now</a>
          </div>
        </div></div>
        <% } %>
      </div>
      <button class="c-btn c-next" data-carousel="popular">&#8250;</button>
    </div>
    <div class="c-dots" id="cd-popular"></div>
  </div>
  <% } %>


  <!-- ALL PRODUCTS -->
  <div class="section-gap">
    <div class="section-header">
      <h2>🛍️ All Products</h2>
      <a href="<%= shopLink %>">Browse in Shop →</a>
    </div>
    <% if (availableProducts.isEmpty()) { %>
      <div class="empty-state" style="padding:40px 20px;">😔 No products available right now. Check back soon!</div>
    <% } else { %>
    <div style="display:grid;grid-template-columns:repeat(auto-fill,minmax(210px,1fr));gap:20px;">
      <% for (Product p : availableProducts) {
           boolean ins2 = "Available".equals(p.getStatus()) && p.getStock() > 0;
           String pi2 = p.getPrimaryImage();
      %>
      <div class="product-card" onclick="location.href='ProductDetailServlet?productId=<%=p.getId()%>'" style="cursor:pointer;">
        <div class="product-img-wrap">
          <% if (pi2 != null && !pi2.isEmpty()) { %>
            <img src="<%=pi2%>" alt="<%=p.getName()%>">
          <% } else { %><div class="img-placeholder">🛍️</div><% } %>
          <% if (!ins2) { %><div class="oos-overlay"><span class="oos-label">Out of Stock</span></div><% } %>
        </div>
        <div class="product-card-body">
          <h3 class="product-name"><%=p.getName()%></h3>
          <p class="product-desc"><%=p.getDescription()!=null?p.getDescription():""%></p>
          <p class="product-price">₹<%=String.format("%.2f",p.getPrice())%></p>
        </div>
        <div class="product-card-footer">
          <span class="badge <%=ins2?"badge-success":"badge-danger"%>"><%=ins2?"✅ In Stock":"❌ Out of Stock"%></span>
          <a href="ProductDetailServlet?productId=<%=p.getId()%>" class="btn btn-primary btn-sm" onclick="event.stopPropagation();">View Details</a>
        </div>
      </div>
      <% } %>
    </div>
    <% } %>
  </div>



</div><!-- /lp-container -->

<!-- FOOTER -->
<footer>
  <div class="footer-grid">
    <div class="footer-brand">
      <div class="logo-text">🛍️ ShopNow</div>
      <p>Your one-stop destination for premium products at great prices.</p>
    </div>
    <div class="footer-col">
      <h4>Company</h4>
      <a href="#">About Us</a><a href="#">Careers</a><a href="#">Press</a>
    </div>
    <div class="footer-col">
      <h4>Support</h4>
      <a href="#">Help Center</a><a href="#">Track Order</a><a href="#">Returns</a>
    </div>
    <div class="footer-col">
      <h4>Account</h4>
      <% if (isLoggedIn) { %>
        <a href="<%= dashboardUrl %>">My Dashboard</a>
        <a href="LogoutServlet">Logout</a>
      <% } else { %>
        <a href="login.jsp">Sign In</a>
        <a href="userRegister.jsp">Register</a>
        <a href="vendorRegister.jsp">Sell with Us</a>
      <% } %>
    </div>
  </div>
  <div class="footer-bottom">© 2025 ShopNow. All rights reserved. &nbsp;·&nbsp; Privacy Policy &nbsp;·&nbsp; Terms of Service</div>
</footer>

<script>
  (function(){
    var t = localStorage.getItem('theme') || 'light';
    document.documentElement.setAttribute('data-theme', t);
    updateToggle(t);
  })();
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

  // Carousel prev/next navigation — index-based, scroll by visible slides
  (function() {
    var carouselState = {};

    function getVisibleCount(track) {
      if (!track || !track.children.length) return 1;
      var trackWidth = track.parentElement.clientWidth - 80; // subtract arrow widths
      var slideWidth = track.children[0].offsetWidth + 16;
      return Math.max(1, Math.floor(trackWidth / slideWidth));
    }

    function scrollToIndex(trackId, index) {
      var track = document.getElementById(trackId);
      if (!track || !track.children.length) return;
      var total = track.children.length;
      index = Math.max(0, Math.min(index, total - 1));
      carouselState[trackId] = index;
      var slideWidth = track.children[0].offsetWidth + 16;
      track.scrollTo({ left: index * slideWidth, behavior: 'smooth' });
    }

    document.addEventListener('DOMContentLoaded', function() {
      document.querySelectorAll('.c-btn').forEach(function(btn) {
        btn.addEventListener('click', function() {
          var key = this.getAttribute('data-carousel');
          var trackId = 'ct-' + key;
          var track = document.getElementById(trackId);
          if (!track) return;
          var current = carouselState[trackId] || 0;
          var step    = getVisibleCount(track);
          var dir     = this.classList.contains('c-prev') ? -1 : 1;
          scrollToIndex(trackId, current + dir * step);
        });
      });
    });
  })();
</script>
</body>
</html>
