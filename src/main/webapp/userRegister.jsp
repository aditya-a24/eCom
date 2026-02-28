<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Register — ShopNow</title>
  <link rel="stylesheet" href="css/theme.css">
  <link rel="stylesheet" href="css/dashboard-extras.css">
</head>
<body class="login-page">
<div class="login-card">
  <div style="font-size:2.5rem;margin-bottom:6px;">👤</div>
  <h2>Create Account</h2>
  <span class="subtitle">Register as a shopper</span>

  <% String errMsg = (String) request.getAttribute("errorMsg"); %>
  <% if (errMsg != null) { %>
    <div class="error-msg">⚠️ <%= errMsg %></div>
  <% } %>

  <form action="UserRegisterServlet" method="post" novalidate>
    <div class="form-group">
      <label>Full Name</label>
      <input type="text" name="name" placeholder="John Doe" required
             value="<%= request.getParameter("name") != null ? request.getParameter("name") : "" %>">
    </div>
    <div class="form-group">
      <label>Email Address</label>
      <input type="email" name="email" placeholder="you@example.com" required
             value="<%= request.getParameter("email") != null ? request.getParameter("email") : "" %>">
    </div>
    <div class="form-group">
      <label>Password <small style="color:var(--text-muted)">(min 6 characters)</small></label>
      <input type="password" name="password" placeholder="••••••••" required>
    </div>
    <button type="submit">Create Account →</button>
  </form>

  <div class="footer-links">
    <p>Already have an account? <a href="login.jsp">Sign In</a></p>
    <p>Selling products? <a href="vendorRegister.jsp">Register as Vendor</a></p>
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
