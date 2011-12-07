<cfparam name="request.event.categoryId">

<cfimport prefix="ui" taglib="../mod/ui">

<ui:page>

<cfoutput>
<h1>New Node</h1>
<form action="index.cfm?action=savenode" method="post">
<input type="hidden" name="parentCategoryId" value="#request.event.categoryId#">
<input type="hidden" name="categoryId" value="0">
Node Name:
<input name="name"> <input type="submit" value="Save">
</form>
</cfoutput>

</ui:page>


