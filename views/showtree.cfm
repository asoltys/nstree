<cfimport prefix="ui" taglib="../mod/ui">

<cfset subtree = categoryGateway.getCategoryTree()>
<cfset moveto = duplicate(subtree)>

<ui:page>

<cfoutput>

<h1>Nested Set Tree</h1>
<cfif subtree.recordCount eq 0>
	<p>
		No nodes found.
	</p>
	<p>
		<a href="index.cfm?action=newnode">Create a new root node.</a>
	</p>
<cfelse>
	<table class="tree">
	<tr>
		<th>Id</th>
		<th>Parent Id</th>
		<th>Level</th>
		<th>Left</th>
		<th>Right</th>
		<th>Name</th>
		<th>Delete</th>
		<th>New</th>
		<th>Move Up</th>
		<th>Move Down</th>
		<th>Move To</th>
	</tr>
	<cfloop query="subtree">
		<cfset subtreeLft = subtree.lft>
		<cfset subtreeRgt = subtree.rgt>
		<tr>
			<td>#categoryId#</td>
			<td>#parentCategoryId#</td>
			<td>#level#</td>
			<td>#lft#</td>
			<td>#rgt#</td>
			<td>
				#repeatString("&nbsp;&nbsp;&raquo;&nbsp;&nbsp;",level)#
				#categoryName#
			</td>
			<td>
				<a href="index.cfm?action=deletenode&categoryid=#categoryId#">Delete</a>
			</td>
			<td>
				<a href="index.cfm?action=newnode&categoryid=#categoryId#">New</a>
			</td>
			<td>
				<a href="index.cfm?action=moveup&categoryid=#categoryId#">Move Up</a>
			</td>
			<td>
				<a href="index.cfm?action=movedown&categoryid=#categoryId#">Move Down</a>
			</td>
			<td>
				<select class="mover">
					<option>Move to ...</option>
					<cfloop query="moveto">
						<cfset movetoLft = moveto.lft>
						<cfset movetoRgt = moveto.rgt>
						<cfset isParent = moveto.categoryId eq subtree.parentCategoryId>
						<cfset isChildOrSame = movetoLft gte subtreeLft and movetoRgt lte subtreeRgt>
						<cfset canMove = not isChildOrSame and not isParent>
						<cfset disabled = iif(canMove,de(""),de("disabled=""disabled"""))>
						<option value="#subtree.categoryId#|#moveto.categoryId#" #disabled#>
							#repeatString("&nbsp;&nbsp;&raquo;&nbsp;&nbsp;",level)#
							#categoryName#
						</option>
					</cfloop>
				</select>
			</td>
		</tr>
	</cfloop>
	</table>

	<h2>Simple List</h2>

	<cfset prevLevel = -1>
	<cfset currLevel = -1>
	<cfloop query="subtree">
		<cfset currLevel = level>
		<cfif currLevel gt prevLevel>
			<ul><li>#categoryName#
		<cfelseif currLevel lt prevLevel>
			<cfset tmp = prevLevel>
			<cfloop condition="tmp gt currLevel">
				</li></ul>
				<cfset tmp = tmp - 1>
			</cfloop>
			</li><li>#categoryName#
		<cfelse>
			</li><li>#categoryName#
		</cfif>
		<cfset prevLevel = level>
	</cfloop>
	<cfset tmp = currLevel>
	<cfloop condition="tmp ge 0">
		</li></ul>
		<cfset tmp = tmp - 1>
	</cfloop>

	<h2>jQuery List Tree</h2>
	
	<cfset prevLevel = -1>
	<cfset currLevel = -1>
	<cfloop query="subtree">
		<cfset currLevel = level>
		<cfif currLevel gt prevLevel>
			<cfif currLevel eq 0>
				<ul id="listtree" class="treeview-black">
				<li>#categoryName#
			<cfelse>
				<ul>
				<li>#categoryName#
			</cfif>
		<cfelseif currLevel lt prevLevel>
			<cfset tmp = prevLevel>
			<cfloop condition="tmp gt currLevel">
				</li></ul>
				<cfset tmp = tmp - 1>
			</cfloop>
			</li><li>#categoryName#
		<cfelse>
			</li><li>#categoryName#
		</cfif>
		<cfset prevLevel = level>
	</cfloop>
	<cfset tmp = currLevel>
	<cfloop condition="tmp ge 0">
		</li></ul>
		<cfset tmp = tmp - 1>
	</cfloop>

</cfif>

<script type="text/javascript">
$(document).ready(function(){
	
	$(".mover").change(function(){
		var moveVals = $(this).val();
		var moveArr = moveVals.split("|")
		var srcId = moveArr[0];
		var dstId = moveArr[1];
		document.location = "index.cfm?action=move&srcId=" + srcId + "&dstId=" + dstId;
	});

	$("##listtree").treeview({
		persist: "location",
		collapsed: true,
		unique: true
	});
	
});
</script>

</cfoutput>

</ui:page>


