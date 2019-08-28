<%@ page import="cn.kiiwii.framework.controller.User" %>
<%
    String user = session.getAttribute("user") == null ? "" : session.getAttribute("user").toString();
    System.out.println("jsp上的user是："+user);
%>
<html>
<body>
<h2>Hello World!</h2>
<br/>
${object}
<br/>
${sessionId}
<br/>
<%=user%>
<br/>
${users}
</body>
</html>
