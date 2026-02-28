<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.ArrayList, entity.Product, entity.User, entity.CartItem, service.ProductService, service.CartService, util.JPAUtil, jakarta.persistence.EntityManager" %>
<%
  if (session == null || !"user".equals(session.getAttribute("role"))) {
    response.sendRedirect("../login.jsp");
    return;
  }

  User currentUser = (User) session.getAttribute("user");

  EntityManager em = JPAUtil.getEntityManager();
  ProductService ps = new ProductService(em);
  CartService    cs = new CartService(em);

  List<Product>  products  = ps.getAllProducts();
  List<CartItem> cartItems = cs.getCartItems(currentUser.getEmail());

  // Resolve product details for cart items
  List<Object[]> cartDetails = new ArrayList<>();
  double cartTotal = 0.0;
  for (CartItem ci : cartItems) {
    Product cp = ps.getProductById(ci.getProductId());
    if (cp != null) {
      cartDetails.add(new Object[]{ci, cp});
      cartTotal += cp.getPrice() * ci.getQuantity();
    }
  }
  em.close();

  // Which tab to show
  String activeTab = request.getParameter("tab");
  if (activeTab == null) activeTab = "shop";
  String sParam = request.getParameter("success");
  String eParam = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Shop — ShopNow</title>
  <link rel="stylesheet" href="../css/theme.css">
  <link rel="stylesheet" href="../css/dashboard-extras.css">
</head>
<body>

<nav class="navbar">
  <a href="../index.jsp" class="logo" style="text-decoration:none;">🛍️ ShopNow</a>
  <div class="nav-links">
    <span class="nav-greeting">Hey, <%= currentUser.getName() %>!</span>
    <button class="theme-toggle" onclick="toggleTheme()"><span class="icon" id="themeIcon">🌙</span><span id="themeLabel">Dark</span></button>
    <a href="../LogoutServlet" class="btn btn-logout btn-sm">Logout</a>
  </div>
</nav>

<% if ("purchased".equals(sParam))    { %><div class="alert alert-success">✅ Purchase successful! Your order is being processed.</div><% }
   else if ("added".equals(sParam))   { %><div class="alert alert-success">🛒 Item added to your cart.</div><% }
   else if ("removed".equals(sParam)) { %><div class="alert alert-info">🗑️ Item removed from cart.</div><% }
   if ("unavailable".equals(eParam))  { %><div class="alert alert-danger">❌ This product is currently unavailable or out of stock.</div><% }
   else if ("invalidInput".equals(eParam)) { %><div class="alert alert-danger">❌ Invalid request.</div><% } %>

<div class="container">
  <!-- Tabs -->
  <div class="tabs">
    <button class="tab-btn <%= "shop".equals(activeTab) ? "active" : "" %>"
            onclick="switchTab('shop')">
      🛍️ Shop
      <% if (!products.isEmpty()) { %><span class="cart-count"><%= products.size() %></span><% } %>
    </button>
    <button class="tab-btn <%= "cart".equals(activeTab) ? "active" : "" %>"
            onclick="switchTab('cart')">
      🛒 My Cart
      <% if (!cartItems.isEmpty()) { %><span class="cart-count"><%= cartItems.size() %></span><% } %>
    </button>
  </div>

  <!-- ═══ SHOP TAB ═══════════════════════════════════════════════ -->
  <div id="tab-shop" class="tab-panel <%= "shop".equals(activeTab) ? "active" : "" %>">
    <% if (products.isEmpty()) { %>
      <div class="empty-state">😔 No products available right now. Check back later!</div>
    <% } else { %>
    <div class="product-grid">
      <% for (Product p : products) {
           boolean inStock = "Available".equals(p.getStatus()) && p.getStock() > 0;
           String primaryImg = p.getPrimaryImage();
           String[] allImgs  = p.getAllImages();
      %>
        <div class="product-card" onclick="location.href='../ProductDetailServlet?productId=<%= p.getId() %>'" style="cursor:pointer;">
          <%-- Product Image --%>
          <div class="product-img-wrap">
            <% if (primaryImg != null && !primaryImg.isEmpty()) { %>
              <img src="<%= primaryImg %>" alt="<%= p.getName() %>" id="dimg-<%= p.getId() %>">
              <% if (allImgs.length > 1) { %>
              <div class="img-gallery">
                <% for (int gi = 0; gi < Math.min(allImgs.length, 3); gi++) { %>
                  <img class="img-thumb" src="<%= allImgs[gi].trim() %>"
                       onclick="swapImg('dimg-<%= p.getId() %>','<%= allImgs[gi].trim() %>')"
                       alt="img<%= gi+1 %>">
                <% } %>
              </div>
              <% } %>
            <% } else { %>
              <div class="img-placeholder">🛍️</div>
            <% } %>
            <% if (!inStock) { %>
              <div class="oos-overlay"><span class="oos-label">Out of Stock</span></div>
            <% } %>
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
            <div style="display:flex;gap:8px;">
              <%-- Add to Cart — disabled when OOS --%>
              <% if (inStock) { %>
              <form action="../CartServlet" method="post" style="display:inline;" onclick="event.stopPropagation();">
                <input type="hidden" name="productId" value="<%= p.getId() %>">
                <input type="hidden" name="action" value="add">
                <button type="submit" class="btn btn-secondary btn-sm">🛒 Cart</button>
              </form>
              <% } else { %>
              <button type="button" class="btn btn-secondary btn-sm" style="opacity:.45;cursor:not-allowed;" disabled>🛒 Cart</button>
              <% } %>
              <%-- Buy Now — disabled when OOS --%>
              <% if (inStock) { %>
              <form action="../BuyNowServlet" method="post" style="display:inline;" onclick="event.stopPropagation();"
                    onsubmit="return confirm('Buy <%= p.getName().replace("'","\'") %> for ₹<%= String.format("%.2f", p.getPrice()) %>?');">
                <input type="hidden" name="productId" value="<%= p.getId() %>">
                <button type="submit" class="btn btn-primary btn-sm">⚡ Buy Now</button>
              </form>
              <% } else { %>
              <button type="button" class="btn btn-primary btn-sm" style="opacity:.45;cursor:not-allowed;" disabled>⚡ Buy Now</button>
              <% } %>
            </div>
          </div>
        </div>
      <% } %>
    </div>
    <% } %>
  </div>

  <!-- ═══ CART TAB ════════════════════════════════════════════════ -->
  <div id="tab-cart" class="tab-panel <%= "cart".equals(activeTab) ? "active" : "" %>">
    <% if (cartDetails.isEmpty()) { %>
      <div class="empty-state">
        🛒 Your cart is empty.<br>
        <button class="btn btn-primary btn-sm" onclick="switchTab('shop')" style="margin-top:14px;">Browse Products</button>
      </div>
    <% } else { %>
    <div class="table-wrapper" style="margin-bottom:20px;">
    <table class="styled-table">
      <thead><tr><th>Product</th><th>Unit Price</th><th>Qty</th><th>Subtotal</th><th>Action</th></tr></thead>
      <tbody>
      <% for (Object[] row : cartDetails) {
           CartItem ci = (CartItem) row[0];
           Product  cp = (Product)  row[1]; %>
        <tr>
          <td class="name-cell"><%= cp.getName() %></td>
          <td class="price-cell">₹<%= String.format("%.2f", cp.getPrice()) %></td>
          <td><strong><%= ci.getQuantity() %></strong></td>
          <td class="price-cell">₹<%= String.format("%.2f", cp.getPrice() * ci.getQuantity()) %></td>
          <td class="action-cell">
            <form action="../CartServlet" method="post" style="display:inline;" onclick="event.stopPropagation();">
              <input type="hidden" name="productId" value="<%= cp.getId() %>">
              <input type="hidden" name="action"    value="remove">
              <button type="submit" class="btn btn-danger btn-sm">🗑️ Remove</button>
            </form>
          </td>
        </tr>
      <% } %>
      </tbody>
      <tfoot>
        <tr style="background:var(--accent-light);">
          <td colspan="3" style="font-weight:700;padding:12px 16px;color:var(--text-primary);">🧾 Total</td>
          <td style="font-weight:800;font-size:1.1rem;padding:12px 16px;" class="price-cell">
            ₹<%= String.format("%.2f", cartTotal) %>
          </td>
          <td></td>
        </tr>
      </tfoot>
    </table>
    </div>
    <div style="display:flex;gap:12px;flex-wrap:wrap;justify-content:flex-end;">
      <button class="btn btn-secondary" onclick="switchTab('shop')">← Continue Shopping</button>
      <button class="btn btn-primary btn-lg" onclick="alert('Checkout coming soon! Your cart is saved.')">
        ✅ Checkout (₹<%= String.format("%.2f", cartTotal) %>)
      </button>
    </div>
    <% } %>
  </div>

</div>

<script>
  (function(){var s=localStorage.getItem('theme')||'light';document.documentElement.setAttribute('data-theme',s);updateToggle(s);})();
  function toggleTheme(){var c=document.documentElement.getAttribute('data-theme')||'light';var n=c==='dark'?'light':'dark';document.documentElement.setAttribute('data-theme',n);localStorage.setItem('theme',n);updateToggle(n);}
  function updateToggle(t){var i=document.getElementById('themeIcon'),l=document.getElementById('themeLabel');if(i)i.textContent=t==='dark'?'☀️':'🌙';if(l)l.textContent=t==='dark'?'Light':'Dark';}
  function swapImg(id, src) { var el = document.getElementById(id); if (el) el.src = src; }

  function switchTab(name) {
    document.querySelectorAll('.tab-btn').forEach(function(b){ b.classList.remove('active'); });
    document.querySelectorAll('.tab-panel').forEach(function(p){ p.classList.remove('active'); });
    document.querySelector('[onclick="switchTab(\''+name+'\')"]').classList.add('active');
    document.getElementById('tab-'+name).classList.add('active');
    // Update URL without reload
    var url = new URL(window.location.href);
    url.searchParams.set('tab', name);
    history.replaceState(null, '', url);
  }
</script>
</body>
</html>
