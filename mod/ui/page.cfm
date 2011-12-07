
<cfif thisTag.executionMode eq "start">

<cfoutput>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
<link rel="stylesheet" type="text/css" href="css/nstree.css" />
<link rel="stylesheet" type="text/css" href="js/jquery-treeview/jquery.treeview.css" />
<script type="text/javascript" src="js/jquery-1.2.1.pack.js"></script>
<script type="text/javascript" src="js/jquery-treeview/jquery.treeview.pack.js"></script>
</head>
<body>
<div id="container">
<div id="nav">
	<a href="index.cfm?action=showtree">Demo Home</a>
	|
	<a href="index.cfm?action=reindex">Reindex Existing Table</a>
</div>
</cfoutput>

<cfelse>

<cfoutput>
</div>
</body>
</html>
</cfoutput>

</cfif>
