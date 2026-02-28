<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, entity.User, entity.Product, service.UserService, service.ProductService, util.JPAUtil, jakarta.persistence.EntityManager" %>
<%
  if (session == null || !"admin".equals(session.getAttribute("role"))) {
    response.sendRedirect("../login.jsp");
    return;
  }
  EntityManager em = JPAUtil.getEntityManager();
  UserService    us = new UserService(em);
  ProductService ps = new ProductService(em);

  List<User>    users    = us.getAllUsers();
  List<User>    vendors  = us.getAllVendors();
  List<Product> products = ps.getAllProducts();

  long verifiedVendors = vendors.stream().filter(User::isVerified).count();
  long availableProds  = products.stream().filter(p -> "Available".equals(p.getStatus())).count();
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Admin Dashboard — ShopNow</title>
  <link rel="stylesheet" href="../css/theme.css">
  <link rel="stylesheet" href="../css/dashboard-extras.css">
</head>
<body>

<nav class="navbar">
  <a href="../index.jsp" class="logo" style="text-decoration:none;">🛍️ ShopNow</a>
  <div class="nav-links">
    <span class="nav-greeting">👑 Admin Panel</span>
    <button class="theme-toggle" onclick="toggleTheme()"><span class="icon" id="themeIcon">🌙</span><span id="themeLabel">Dark</span></button>
    <a href="../LogoutServlet" class="btn btn-logout btn-sm">Logout</a>
  </div>
</nav>

<%
  String sParam = request.getParameter("success");
  String eParam = request.getParameter("error");
%>
<% if ("deleted".equals(sParam))   { %><div class="alert alert-success">✅ Deleted successfully.</div><% }
   else if ("verified".equals(sParam))  { %><div class="alert alert-success">✅ Vendor verified.</div><% }
   else if ("revoked".equals(sParam))   { %><div class="alert alert-warning">⚠️ Vendor verification revoked.</div><% }
   else if ("updated".equals(sParam))   { %><div class="alert alert-success">✅ Product updated successfully.</div><% }
   if ("invalidInput".equals(eParam))  { %><div class="alert alert-danger">❌ Invalid input provided.</div><% }
   else if ("notFound".equals(eParam)) { %><div class="alert alert-danger">❌ Record not found.</div><% } %>

<div class="dashboard-container">

  <!-- Stats -->
  <div class="stats-row">
    <div class="stat-card"><div class="stat-number"><%= users.size() %></div><div class="stat-label">Users</div></div>
    <div class="stat-card"><div class="stat-number"><%= vendors.size() %></div><div class="stat-label">Vendors</div></div>
    <div class="stat-card"><div class="stat-number"><%= verifiedVendors %></div><div class="stat-label">Verified</div></div>
    <div class="stat-card"><div class="stat-number"><%= products.size() %></div><div class="stat-label">Products</div></div>
    <div class="stat-card"><div class="stat-number"><%= availableProds %></div><div class="stat-label">Available</div></div>
  </div>

  <!-- ═══ USERS SECTION ══════════════════════════════════════════ -->
  <div class="section-card">
    <div class="section-title">👥 Users (<%= users.size() %>)</div>
    <% if (users.isEmpty()) { %>
      <div class="empty-state">No users registered yet.</div>
    <% } else { %>
    <div class="table-wrapper">
    <table class="styled-table">
      <thead><tr><th>Name</th><th>Email</th><th>Action</th></tr></thead>
      <tbody>
      <% for (User u : users) { %>
        <tr>
          <td class="name-cell"><%= u.getName() %></td>
          <td><%= u.getEmail() %></td>
          <td class="action-cell">
            <form action="../DeleteUserServlet" method="post" style="display:inline;"
                  onsubmit="return confirm('Delete user <%= u.getName().replace("'","\'") %>?');">
              <input type="hidden" name="id" value="<%= u.getId() %>">
              <button type="submit" class="btn btn-danger btn-sm">🗑️ Delete</button>
            </form>
          </td>
        </tr>
      <% } %>
      </tbody>
    </table>
    </div>
    <% } %>
  </div>

  <!-- ═══ VENDORS SECTION ════════════════════════════════════════ -->
  <div class="section-card">
    <div class="section-title">🏪 Vendors (<%= vendors.size() %>)</div>
    <% if (vendors.isEmpty()) { %>
      <div class="empty-state">No vendors registered yet.</div>
    <% } else { %>
    <div class="table-wrapper">
    <table class="styled-table">
      <thead><tr><th>Name</th><th>Email</th><th>Status</th><th>Actions</th></tr></thead>
      <tbody>
      <% for (User v : vendors) { %>
        <tr>
          <td class="name-cell"><%= v.getName() %></td>
          <td><%= v.getEmail() %></td>
          <td>
            <span class="badge <%= v.isVerified() ? "badge-success" : "badge-warning" %>">
              <%= v.isVerified() ? "✅ Verified" : "⏳ Pending" %>
            </span>
          </td>
          <td class="action-cell">
            <% if (!v.isVerified()) { %>
              <form action="../VerifyVendorServlet" method="post" style="display:inline;">
                <input type="hidden" name="vendorId" value="<%= v.getId() %>">
                <input type="hidden" name="action"   value="verify">
                <button type="submit" class="btn btn-success btn-sm">✅ Verify</button>
              </form>
            <% } else { %>
              <form action="../VerifyVendorServlet" method="post" style="display:inline;">
                <input type="hidden" name="vendorId" value="<%= v.getId() %>">
                <input type="hidden" name="action"   value="revoke">
                <button type="submit" class="btn btn-warning btn-sm"
                        onclick="return confirm('Revoke verification for <%= v.getName().replace("'","\'") %>?')">
                  🔒 Revoke
                </button>
              </form>
            <% } %>
            <form action="../DeleteUserServlet" method="post" style="display:inline;"
                  onsubmit="return confirm('Delete vendor <%= v.getName().replace("'","\'") %>?');">
              <input type="hidden" name="id" value="<%= v.getId() %>">
              <button type="submit" class="btn btn-danger btn-sm">🗑️ Delete</button>
            </form>
          </td>
        </tr>
      <% } %>
      </tbody>
    </table>
    </div>
    <% } %>
  </div>

  <!-- ═══ PRODUCTS SECTION ═══════════════════════════════════════ -->
  <div class="section-card">
    <div class="section-title">📦 All Products (<%= products.size() %>)</div>
    <% if (products.isEmpty()) { %>
      <div class="empty-state">No products listed yet.</div>
    <% } else { %>
    <div class="table-wrapper">
    <table class="styled-table">
      <thead>
        <tr><th>Name</th><th>Price</th><th>Description</th><th>Stock</th><th>Status</th><th>Vendor</th><th>Actions</th></tr>
      </thead>
      <tbody>
      <% for (Product p : products) {
           String vRowId = "pv-" + p.getId();
           String eRowId = "pe-" + p.getId(); %>
        <!-- View Row -->
        <tr id="<%= vRowId %>">
          <td class="name-cell"><%= p.getName() %></td>
          <td class="price-cell">₹<%= String.format("%.2f", p.getPrice()) %></td>
          <td class="desc-cell"><%= p.getDescription() %></td>
          <td><strong><%= p.getStock() %></strong></td>
          <td><span class="badge <%= "Available".equals(p.getStatus()) ? "badge-success" : "badge-danger" %>">
            <%= p.getStatus() %></span>
          </td>
          <td style="font-size:.8rem;color:var(--text-muted)"><%= p.getVendorEmail() %></td>
          <td class="action-cell">
            <button onclick="adminToggleEdit(<%= p.getId() %>)" class="btn btn-warning btn-sm">✏️ Edit</button>
            <form action="../DeleteProductServlet" method="post" style="display:inline;"
                  onsubmit="return confirm('Delete product <%= p.getName().replace("'","\'") %>?');">
              <input type="hidden" name="productId" value="<%= p.getId() %>">
              <button type="submit" class="btn btn-danger btn-sm">🗑️ Delete</button>
            </form>
          </td>
        </tr>
        <!-- Edit Row -->
        <tr id="<%= eRowId %>" class="edit-row" style="display:none;">
          <td colspan="7">
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
              </div>
              <div class="edit-form-actions">
                <button type="submit" class="btn btn-primary btn-sm">💾 Save</button>
                <button type="button" onclick="adminToggleEdit(<%= p.getId() %>)" class="btn btn-secondary btn-sm">Cancel</button>
              </div>
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

<script>
  (function(){var s=localStorage.getItem('theme')||'light';document.documentElement.setAttribute('data-theme',s);updateToggle(s);})();
  function toggleTheme(){var c=document.documentElement.getAttribute('data-theme')||'light';var n=c==='dark'?'light':'dark';document.documentElement.setAttribute('data-theme',n);localStorage.setItem('theme',n);updateToggle(n);}
  function updateToggle(t){var i=document.getElementById('themeIcon'),l=document.getElementById('themeLabel');if(i)i.textContent=t==='dark'?'☀️':'🌙';if(l)l.textContent=t==='dark'?'Light':'Dark';}
  function adminToggleEdit(id) {
    var vr = document.getElementById('pv-'+id);
    var er = document.getElementById('pe-'+id);
    var hidden = er.style.display === 'none';
    er.style.display = hidden ? 'table-row' : 'none';
    vr.style.opacity  = hidden ? '0.4' : '1';
  }
</script>
</body>
</html>
<%  em.close(); %>
