<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Login — ShopNow</title>
  <link rel="stylesheet" href="css/theme.css">
  <link rel="stylesheet" href="css/dashboard-extras.css">
</head>
<body class="login-page">

<div class="login-card">
  <div style="font-size:2.8rem; margin-bottom:6px;">🛍️</div>
  <h2>Welcome Back</h2>
  <span class="subtitle">Sign in to your account</span>

  <%-- Server-side forward error (stay on page) --%>
  <% String errMsg = (String) request.getAttribute("errorMsg"); %>
  <% if (errMsg != null) { %>
    <div class="error-msg">⚠️ <%= errMsg %></div>
  <% } %>

  <%-- Registration success flags --%>
  <% if ("1".equals(request.getParameter("registered"))) { %>
    <div class="success-msg">🎉 Registration successful! Please sign in.</div>
  <% } %>
  <% if ("1".equals(request.getParameter("vendorPending"))) { %>
    <div class="alert-warning" style="border-radius:var(--radius-xs);padding:10px 14px;font-size:.88rem;margin:8px 0;background:var(--warning-bg);color:var(--warning-text);border-left:4px solid var(--warning);">
      ⏳ Your vendor account has been submitted. Please wait for admin approval before logging in.
    </div>
  <% } %>

  <form action="LoginServlet" method="post" novalidate>
    <div class="form-group">
      <label for="email">Email Address</label>
      <input type="email" id="email" name="email" placeholder="you@example.com" required autofocus>
    </div>
    <div class="form-group">
      <label for="password">Password</label>
      <input type="password" id="password" name="password" placeholder="••••••••" required>
    </div>
    <button type="submit">Sign In →</button>
  </form>

  <div class="footer-links">
    <p>Don't have an account?
      <a href="userRegister.jsp">Register as User</a>
      <span class="divider">|</span>
      <a href="vendorRegister.jsp">Register as Vendor</a>
    </p>
    <p style="margin-top:10px;"><a href="index.jsp">← Back to Store</a></p>
  </div>

  <div style="margin-top:20px;">
    <button class="theme-toggle" onclick="toggleTheme()">
      <span class="icon" id="themeIcon">🌙</span><span id="themeLabel">Dark Mode</span>
    </button>
  </div>
</div>

<script>
  (function() {
    var saved = localStorage.getItem('theme') || 'light';
    document.documentElement.setAttribute('data-theme', saved);
    updateToggle(saved);
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
    if(i) i.textContent = t==='dark'?'☀️':'🌙';
    if(l) l.textContent = t==='dark'?'Light Mode':'Dark Mode';
  }
</script>
</body>
</html>
