<!--- <cfimport prefix="ui" taglib="../mod/ui"> --->

<cfset dsn = "nstree">
<cfset table = "testnst">
<cfset treeid = "treeid">
<cfset id = "id">
<cfset left = "lft">
<cfset right = "rgt">
	
<cfset datasource = createObject("component","com.DataSource").init(dsn)>

<cffunction name="getDatasource" output="false" access="private">
	<cfreturn datasource>
</cffunction>

<cffunction name="resetDatabase" output="false" access="private">
	<cfquery datasource="#getDatasource().getName()#">
		delete from
		#table#
	</cfquery>
</cffunction>

<cffunction name="newTable" output="false" access="private">
	<cfreturn createObject("component","com.nstree.NestedSetTreeTable").init(
					datasourceName=getDatasource().getName(),
					datasourceUsername=getDatasource().getUsername(),
					datasourcePassword=getDatasource().getPassword(),
					table=table,
					treeid=treeid,
					id=id,
					left=left,
					right=right
				)>
	
</cffunction>

<cffunction name="newNST" output="false" access="private">
	<cfreturn newTable().getNestedSetTree(1)>
</cffunction>

<cfset nst = newNST()>

<cflock name="#nst.getLockName()#" timeout="5">
<cfquery name="subtree" datasource="#getDatasource().getName()#">
	select
		d.*,
		(
			select count(*)
			from #table# d2
			where
				treeid = 1
				and d2.lft < nst.lft
				and d2.rgt > nst.rgt
		) as level,
		nst.lft,
		nst.rgt
	from
		#table# d
		inner join #table# nst on d.id = nst.id
	where
		nst.treeid = 1
	order by
		nst.lft
</cfquery>
</cflock>

<ui:page>

<cfoutput>
<h1>Nested Set Tree</h1>
<cfif subtree.recordCount eq 0>
	<p>
		No nodes found.
	</p>
	<!--- <p>
		<a href="/index.cfm?action=newnode">Create a new root node.</a>
	</p> --->
<cfelse>
	<table class="tree" border="1">
	<tr>
		<th>Tree Id</th>
		<th>Id</th>
		<th>Level</th>
		<th>Left</th>
		<th>Right</th>
		<th></th>
	</tr>
	<cfloop query="subtree">

		<tr>
			<td>#treeid#</td>
			<td>#id#</td>
			<td>#level#</td>
			<td>#lft#</td>
			<td>#rgt#</td>
			<td>
				#repeatString("&nbsp;&nbsp;&raquo;&nbsp;&nbsp;",level)#
				#id#
			</td>
		</tr>
	</cfloop>
	</table>

</cfif>

</cfoutput>

</ui:page>

