<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, entity.Product, entity.User, service.ProductService, util.JPAUtil, jakarta.persistence.EntityManager" %>
<%
  if (session == null || !"vendor".equals(session.getAttribute("role"))) {
    response.sendRedirect("../login.jsp");
    return;
  }
  User vendor = (User) session.getAttribute("user");
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Vendor Dashboard — ShopNow</title>
  <link rel="stylesheet" href="../css/theme.css">
  <link rel="stylesheet" href="../css/dashboard-extras.css">
</head>
<body>

<nav class="navbar">
  <a href="../index.jsp" class="logo" style="text-decoration:none;">🛍️ ShopNow</a>
  <div class="nav-links">
    <span class="nav-greeting">🏪 <%= vendor.getName() %></span>
    <button class="theme-toggle" onclick="toggleTheme()"><span class="icon" id="themeIcon">🌙</span><span id="themeLabel">Dark</span></button>
    <a href="../LogoutServlet" class="btn btn-logout btn-sm">Logout</a>
  </div>
</nav>

<% if (!vendor.isVerified()) { %>
  <!-- ═══ PENDING APPROVAL STATE ════════════════════════════════ -->
  <div class="dashboard-container">
    <div class="pending-banner">
      <span class="pending-icon">⏳</span>
      <h2>Approval Pending</h2>
      <p>Your vendor account is awaiting admin verification.<br>
         You will be able to manage products once an admin approves your account.<br>
         Please check back later or contact support.</p>
    </div>
  </div>
<% } else { %>

  <%
    String sParam = request.getParameter("success");
    String eParam = request.getParameter("error");
  %>
  <% if ("added".equals(sParam))        { %><div class="alert alert-success">✅ Product added successfully!</div><% }
     else if ("updated".equals(sParam)) { %><div class="alert alert-success">✅ Product updated successfully!</div><% }
     else if ("deleted".equals(sParam)) { %><div class="alert alert-success">✅ Product deleted.</div><% }
     else if ("stockUpdated".equals(sParam)){ %><div class="alert alert-success">✅ Stock updated successfully!</div><% }
     if ("invalidInput".equals(eParam)) { %><div class="alert alert-danger">❌ Invalid input. Please check your values.</div><% }
     else if ("cannotDelete".equals(eParam)) { %><div class="alert alert-danger">❌ You can only delete out-of-stock products.</div><% }
     else if ("notFound".equals(eParam)){ %><div class="alert alert-danger">❌ Product not found.</div><% }
     else if ("unauthorized".equals(eParam)){ %><div class="alert alert-danger">❌ Unauthorized action.</div><% } %>

  <%
    EntityManager em = JPAUtil.getEntityManager();
    ProductService ps = new ProductService(em);
    List<Product> products = ps.getProductsByVendor(vendor.getEmail());
    em.close();
    long inStockCount = products.stream().filter(p->"Available".equals(p.getStatus())).count();
  %>

  <div class="dashboard-container">

    <!-- Stats -->
    <div class="stats-row">
      <div class="stat-card"><div class="stat-number"><%= products.size() %></div><div class="stat-label">Total Products</div></div>
      <div class="stat-card"><div class="stat-number"><%= inStockCount %></div><div class="stat-label">In Stock</div></div>
      <div class="stat-card"><div class="stat-number"><%= products.size() - inStockCount %></div><div class="stat-label">Out of Stock</div></div>
    </div>

    <!-- ═══ ADD PRODUCT ══════════════════════════════════════════ -->
    <div class="section-card">
      <div class="section-title">➕ Add New Product</div>
      <form action="../AddProductServlet" method="post" class="inline-form">
        <div class="form-group" style="flex:2;min-width:140px;">
          <label>Product Name</label>
          <input type="text" name="name" placeholder="e.g. Wireless Headphones" required class="form-input">
        </div>
        <div class="form-group" style="flex:2;min-width:140px;">
          <label>Description</label>
          <input type="text" name="description" placeholder="Short description..." required class="form-input">
        </div>
        <div class="form-group" style="min-width:120px;">
          <label>Price (₹)</label>
          <input type="number" name="price" placeholder="0.00" required step="0.01" min="0" class="form-input">
        </div>
        <div class="form-group" style="min-width:100px;">
          <label>Stock Qty</label>
          <input type="number" name="stock" placeholder="0" required min="0" class="form-input">
        </div>
        <div class="form-group" style="min-width:140px;">
          <label>Category <span style="color:var(--danger,#dc3545);">*</span></label>
          <select name="category" required class="form-input">
            <option value="" disabled selected>Select…</option>
            <option value="Electronics">📱 Electronics</option>
            <option value="Fashion">👗 Fashion</option>
            <option value="Home">🏠 Home &amp; Living</option>
            <option value="Beauty">💄 Beauty</option>
            <option value="Gaming">🎮 Gaming</option>
            <option value="Books">📚 Books</option>
            <option value="Sports">🏋️ Sports</option>
            <option value="Toys">🧸 Toys</option>
          </select>
        </div>
        <div class="form-group" style="min-width:200px;flex:2;">
          <label>Image URLs <small style="color:var(--text-muted);font-weight:400;">(comma-separated, first = main)</small></label>
          <input type="text" name="imageUrls" placeholder="https://... , https://..." class="form-input">
        </div>
        <div class="form-group" style="justify-content:flex-end;">
          <label>&nbsp;</label>
          <button type="submit" class="btn btn-primary">Add Product</button>
        </div>
      </form>
    </div>

    <!-- ═══ PRODUCTS TABLE ══════════════════════════════════════ -->
    <div class="section-card">
      <div class="section-title">📦 Your Products (<%= products.size() %>)</div>
      <% if (products.isEmpty()) { %>
        <div class="empty-state">You have no products yet. Add your first one above!</div>
      <% } else { %>
      <div class="table-wrapper">
      <table class="styled-table">
        <thead>
          <tr><th>Name</th><th>Price</th><th>Description</th><th>Stock</th><th>Status</th><th>Actions</th></tr>
        </thead>
        <tbody>
        <% for (Product p : products) { %>
          <!-- View Row -->
          <tr id="vrow-<%= p.getId() %>">
            <td class="name-cell"><%= p.getName() %></td>
            <td class="price-cell">₹<%= String.format("%.2f", p.getPrice()) %></td>
            <td class="desc-cell"><%= p.getDescription() %></td>
            <td>
              <strong><%= p.getStock() %></strong>
            </td>
            <td>
              <span class="badge <%= "Available".equals(p.getStatus()) ? "badge-success" : "badge-danger" %>">
                <%= "Available".equals(p.getStatus()) ? "✅ In Stock" : "❌ Out of Stock" %>
              </span>
            </td>
            <td class="action-cell">
              <button onclick="vendorToggleEdit(<%= p.getId() %>)" class="btn btn-warning btn-sm">✏️ Edit</button>
              <button onclick="vendorToggleStock(<%= p.getId() %>)" class="btn btn-info btn-sm">📊 Stock</button>
              <% if ("OutOfStock".equals(p.getStatus())) { %>
              <form action="../DeleteProductServlet" method="post" style="display:inline;"
                    onsubmit="return confirm('Delete product <%= p.getName().replace("'","\'") %>?');">
                <input type="hidden" name="productId" value="<%= p.getId() %>">
                <button type="submit" class="btn btn-danger btn-sm">🗑️ Delete</button>
              </form>
              <% } %>
            </td>
          </tr>
          <!-- Edit Details Row -->
          <tr id="erow-<%= p.getId() %>" class="edit-row" style="display:none;">
            <td colspan="6">
              <form action="../UpdateProductServlet" method="post" class="edit-form">
                <input type="hidden" name="productId" value="<%= p.getId() %>">
                <div class="edit-form-grid">
                  <div class="form-group">
                    <label>Name</label>
                    <input type="text" name="name" value="<%= p.getName() %>" required class="form-input">
                  </div>
                  <div class="form-group">
                    <label>Price (₹)</label>
                    <input type="number" name="price" value="<%= p.getPrice() %>" required step="0.01" min="0" class="form-input">
                  </div>
                  <div class="form-group">
                    <label>Description</label>
                    <input type="text" name="description" value="<%= p.getDescription() %>" required class="form-input">
                  </div>
                  <div class="form-group">
                    <label>Category</label>
                    <select name="category" class="form-input">
                      <option value="">-- Unchanged --</option>
                      <option value="Electronics" <%= "Electronics".equals(p.getCategory()) ? "selected" : "" %>>📱 Electronics</option>
                      <option value="Fashion"     <%= "Fashion".equals(p.getCategory())     ? "selected" : "" %>>👗 Fashion</option>
                      <option value="Home"        <%= "Home".equals(p.getCategory())        ? "selected" : "" %>>🏠 Home &amp; Living</option>
                      <option value="Beauty"      <%= "Beauty".equals(p.getCategory())      ? "selected" : "" %>>💄 Beauty</option>
                      <option value="Gaming"      <%= "Gaming".equals(p.getCategory())      ? "selected" : "" %>>🎮 Gaming</option>
                      <option value="Books"       <%= "Books".equals(p.getCategory())       ? "selected" : "" %>>📚 Books</option>
                      <option value="Sports"      <%= "Sports".equals(p.getCategory())      ? "selected" : "" %>>🏋️ Sports</option>
                      <option value="Toys"        <%= "Toys".equals(p.getCategory())        ? "selected" : "" %>>🧸 Toys</option>
                    </select>
                  </div>
                  <div class="form-group" style="flex:2;">
                    <label>Image URLs <small style="color:var(--text-muted);font-weight:400;">(comma-separated)</small></label>
                    <input type="text" name="imageUrls" value="<%= p.getImageUrls() != null ? p.getImageUrls() : "" %>" class="form-input" placeholder="https://...">
                  </div>
                </div>
                <div class="edit-form-actions">
                  <button type="submit" class="btn btn-primary btn-sm">💾 Save Changes</button>
                  <button type="button" onclick="vendorToggleEdit(<%= p.getId() %>)" class="btn btn-secondary btn-sm">Cancel</button>
                </div>
              </form>
            </td>
          </tr>
          <!-- Edit Stock Row -->
          <tr id="srow-<%= p.getId() %>" class="edit-row" style="display:none;">
            <td colspan="6">
              <form action="../UpdateStockServlet" method="post" class="edit-form">
                <input type="hidden" name="productId" value="<%= p.getId() %>">
                <div style="display:flex;align-items:flex-end;gap:14px;flex-wrap:wrap;">
                  <div class="form-group" style="min-width:180px;">
                    <label>New Stock Quantity <small style="color:var(--text-muted)">(0 = Out of Stock)</small></label>
                    <input type="number" name="stock" value="<%= p.getStock() %>" required min="0" class="form-input">
                  </div>
                  <div style="display:flex;gap:8px;margin-bottom:1px;">
                    <button type="submit" class="btn btn-success btn-sm">📊 Update Stock</button>
                    <button type="button" onclick="vendorToggleStock(<%= p.getId() %>)" class="btn btn-secondary btn-sm">Cancel</button>
                  </div>
                </div>
                <p style="font-size:.78rem;color:var(--text-muted);margin-top:6px;">
                  ⚠️ Setting stock to 0 will automatically mark this product as <strong>Out of Stock</strong>.
                </p>
              </form>
            </td>
          </tr>
        <% } %>
        </tbody>
      </table>
      </div>
      <% } %>
    </div>
  </div>
<% } %>

<script>
  (function(){var s=localStorage.getItem('theme')||'light';document.documentElement.setAttribute('data-theme',s);updateToggle(s);})();
  function toggleTheme(){var c=document.documentElement.getAttribute('data-theme')||'light';var n=c==='dark'?'light':'dark';document.documentElement.setAttribute('data-theme',n);localStorage.setItem('theme',n);updateToggle(n);}
  function updateToggle(t){var i=document.getElementById('themeIcon'),l=document.getElementById('themeLabel');if(i)i.textContent=t==='dark'?'☀️':'🌙';if(l)l.textContent=t==='dark'?'Light':'Dark';}

  function closeAll(id) {
    ['erow-','srow-'].forEach(function(pfx){
      var r=document.getElementById(pfx+id);
      if(r){ r.style.display='none'; }
    });
    var v=document.getElementById('vrow-'+id);
    if(v) v.style.opacity='1';
  }
  function vendorToggleEdit(id) {
    var er=document.getElementById('erow-'+id), open=er.style.display==='none';
    closeAll(id);
    if(open){ er.style.display='table-row'; document.getElementById('vrow-'+id).style.opacity='0.4'; }
  }
  function vendorToggleStock(id) {
    var sr=document.getElementById('srow-'+id), open=sr.style.display==='none';
    closeAll(id);
    if(open){ sr.style.display='table-row'; document.getElementById('vrow-'+id).style.opacity='0.4'; }
  }
</script>
</body>
</html>
