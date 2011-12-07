<cfparam name="request.event.datasourceName" default="nstree">
<cfparam name="request.event.datasourceUsername" default="">
<cfparam name="request.event.datasourcePassword" default="">
<cfparam name="request.event.nstTableName" default="categoryNST">
<cfparam name="request.event.nstTreeIdColumnName" default="treeId">
<cfparam name="request.event.nstIdColumnName" default="id">
<cfparam name="request.event.nstLeftColumnName" default="lft">
<cfparam name="request.event.nstRightColumnName" default="rgt">
<cfparam name="request.event.sourceTableName" default="category">
<cfparam name="request.event.sourceParentIdColumnName" default="parentCategoryId">
<cfparam name="request.event.sourceIdColumnName" default="categoryId">
<cfparam name="request.event.sourceRootId" default="1">
<cfparam name="request.event.treeId" default="1">
<cfparam name="request.event.submitted" default="false">

<cfimport prefix="ui" taglib="../mod/ui">

<ui:page>

<cfoutput>

<h1>Reindex Table</h1>

<p>
	This utility takes an existing ajacency list hierarchy table 
	(that has Id and ParentId columns)
	and creates the corresponding partner records in a nested
	set tree table (that has TreeId, Id, Left and Right columns).
</p>

<cfif request.event.submitted>
	<div style="background-color:##fdd;padding:1em;margin-bottom:1em;">
		Reindexing Complete
	</div>
</cfif>

<style type="text/css">
table.formtable {
	border-top:1px solid ##ddd;
	border-collapse:collapse;
	margin-bottom:1em;
}
table.formtable td {
	vertical-align:top;
	padding:0.3em;
	border-bottom:1px solid ##ddd;
}
</style>

<form action="index.cfm" method="get">
<input type="hidden" name="action" value="runReindex">
<input type="hidden" name="submitted" value="true">

<table class="formtable">
<tr>
	<td>Datasource Name</td>
	<td><input name="datasourceName" value="#request.event.datasourceName#"></td>
	<td>Name of the datasource</td>
</tr>
<tr>
	<td>Datasource User Name</td>
	<td><input name="datasourceUsername" value="#request.event.datasourceUsername#"></td>
	<td>Username of the datasource. Leave blank your username/password is configured in the ColdFusion administrator.</td>
</tr>
<tr>
	<td>Datasource Password</td>
	<td><input name="datasourcePassword" type="password" value="#request.event.datasourcePassword#"></td>
	<td>Password of the datasource. Leave blank your username/password is configured in the ColdFusion administrator.</td>
</tr>
<tr>
	<td>NST Table Name</td>
	<td><input name="nstTableName" value="#request.event.nstTableName#"></td>
	<td>Name of the Nested Set Tree table (e.g. CategoryNST)</td>
</tr>
<tr>
	<td>NST Tree Id Column</td>
	<td><input name="nstTreeIdColumnName"  value="#request.event.nstTreeIdColumnName#"></td>
	<td>Name of the Nested Set Tree table TREE ID column</td>
</tr>
<tr>
	<td>NST Id Column</td>
	<td><input name="nstIdColumnName"  value="#request.event.nstIdColumnName#"></td>
	<td>Name of the Nested Set Tree table ID column</td>
</tr>
<tr>
	<td>NST Left Column</td>
	<td><input name="nstLeftColumnName"  value="#request.event.nstLeftColumnName#"></td>
	<td>Name of the Nested Set Tree LEFT column</td>
</tr>
<tr>
	<td>NST Right Column</td>
	<td><input name="nstRightColumnName"  value="#request.event.nstRightColumnName#"></td>
	<td>Name of the Nested Set Tree RIGHT column</td>
</tr>
<tr>
	<td>Source Table Name</td>
	<td><input name="sourceTableName"  value="#request.event.sourceTableName#"></td>
	<td>Name of the source data table (e.g. category)</td>
</tr>
<tr>
	<td>Source Parent Id Column</td>
	<td><input name="sourceParentIdColumnName"  value="#request.event.sourceParentIdColumnname#"></td>
	<td>Name of the source data table PARENT ID column (e.g. categoryParentId)</td>
</tr>
<tr>
	<td>Source Id Column</td>
	<td><input name="sourceIdColumnName"  value="#request.event.sourceIdColumnName#"></td>
	<td>Name of the source data table ID column (e.g. categoryId)</td>
</tr>
<tr>
	<td>Source Root Record Id</td>
	<td><input name="sourceRootId"  value="#request.event.sourceRootId#"></td>
	<td>The ID of the root data record in the source table. If you have many root records then use a different TREE ID for each.</td>
</tr>
<tr>
	<td>Tree Id</td>
	<td><input name="treeId"  value="#request.event.treeId#"></td>
	<td>The ID to use to uniquely identify this tree of nodes. If you only have one tree to convert, then leave this as the value 1.</td>
</tr>
</table>

<button type="Submit">Go</button>

</form>

</cfoutput>

</ui:page>

