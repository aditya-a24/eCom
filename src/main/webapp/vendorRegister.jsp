<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Vendor Registration — ShopNow</title>
  <link rel="stylesheet" href="css/theme.css">
  <link rel="stylesheet" href="css/dashboard-extras.css">
</head>
<body class="login-page">
<div class="login-card">
  <div style="font-size:2.5rem;margin-bottom:6px;">🏪</div>
  <h2>Vendor Registration</h2>
  <span class="subtitle">Register to sell on ShopNow</span>

  <% String errMsg = (String) request.getAttribute("errorMsg"); %>
  <% if (errMsg != null) { %>
    <div class="error-msg">⚠️ <%= errMsg %></div>
  <% } %>

  <div class="alert-info" style="border-radius:var(--radius-xs);padding:10px 14px;font-size:.82rem;margin:8px 0;background:var(--info-bg);color:var(--info-text);border-left:4px solid var(--info);">
    ℹ️ After registration, an admin must verify your account before you can log in.
  </div>

  <form action="VendorRegisterServlet" method="post" novalidate>
    <div class="form-group">
      <label>Business / Vendor Name</label>
      <input type="text" name="vendorName" placeholder="My Awesome Store" required
             value="<%= request.getParameter("vendorName") != null ? request.getParameter("vendorName") : "" %>">
    </div>
    <div class="form-group">
      <label>Email Address</label>
      <input type="email" name="email" placeholder="vendor@business.com" required
             value="<%= request.getParameter("email") != null ? request.getParameter("email") : "" %>">
    </div>
    <div class="form-group">
      <label>Password <small style="color:var(--text-muted)">(min 6 characters)</small></label>
      <input type="password" name="password" placeholder="••••••••" required>
    </div>
    <button type="submit">Submit for Approval →</button>
  </form>

  <div class="footer-links">
    <p>Already have an account? <a href="login.jsp">Sign In</a></p>
    <p>Shopping? <a href="userRegister.jsp">Register as User</a></p>
  </div>

  <div style="margin-top:20px;">
    <button class="theme-toggle" onclick="toggleTheme()">
      <span class="icon" id="themeIcon">🌙</span><span id="themeLabel">Dark Mode</span>
    </button>
  </div>
</div>
<script>
  (function(){var s=localStorage.getItem('theme')||'light';document.documentElement.setAttribute('data-theme',s);updateToggle(s);})();
  function toggleTheme(){var c=document.documentElement.getAttribute('data-theme')||'light';var n=c==='dark'?'light':'dark';document.documentElement.setAttribute('data-theme',n);localStorage.setItem('theme',n);updateToggle(n);}
  function updateToggle(t){var i=document.getElementById('themeIcon'),l=document.getElementById('themeLabel');if(i)i.textContent=t==='dark'?'☀️':'🌙';if(l)l.textContent=t==='dark'?'Light Mode':'Dark Mode';}
</script>
</body>
</html>
