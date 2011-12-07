<cfcomponent extends="mxunit.framework.TestCase">

	<cfset variables.dsn = "nstree">
	<cfset variables.table = "testnst">
	<cfset variables.id = "id">
	<cfset variables.treeid = "treeid">
	<cfset variables.left = "lft">
	<cfset variables.right = "rgt">
	
	<cfset variables.datasource = createObject("component","com.DataSource").init(variables.dsn)>

	<!-------------------------------------------------------------------
	SETUP
	-------------------------------------------------------------------->

	<cffunction name="setUp" output="false" access="public" returntype="void" hint="">
		<cfset resetDatabase()>
	</cffunction>

	<!-------------------------------------------------------------------
	TESTS
	-------------------------------------------------------------------->

	<!--- TODO --->

	<!-------------------------------------------------------------------
	TEAR DOWN
	-------------------------------------------------------------------->

	<cffunction name="tearDown" output="false" access="public" returntype="void" hint="">
	</cffunction>
	
	<!-------------------------------------------------------------------
	PRIVATE
	-------------------------------------------------------------------->
	
	<cffunction name="getDatasource" output="false" access="private">
		<cfreturn variables.datasource>
	</cffunction>

	<cffunction name="getTreeId" output="false" access="private">
		<cfreturn 1>
	</cffunction>

	<cffunction name="resetDatabase" output="false" access="private">
		<cfquery datasource="#getDatasource().getName()#">
			delete from
			#variables.table#
		</cfquery>
	</cffunction>

	<cffunction name="newTable" output="false" access="private">
		<cfreturn createObject("component","com.nstree.NestedSetTreeTable").init(
						datasourceName=getDatasource().getName(),
						datasourceUsername=getDatasource().getUsername(),
						datasourcePassword=getDatasource().getPassword(),
						table=variables.table,
						treeid=variables.treeid,
						id=variables.id,
						left=variables.left,
						right=variables.right
					)>
	</cffunction>

	<cffunction name="newNST" output="false" access="private">
		<!--- <cfargument name="treeId" default="1"> --->
		<cfreturn newTable()>
		<!--- <cfreturn newTable().getNestedSetTree(arguments.treeId) --->
	</cffunction>

	<cffunction name="array" access="private" output="false">
		<cfset var arr = arrayNew(1)>
		<cfset var i = 0>
		<cfset var count = structCount(arguments)>
		<cfloop index="i" from="1" to="#structCount(arguments)#">
			<cfset arrayAppend(arr,arguments[i])>
		</cfloop>
		<cfreturn arr>
	</cffunction>
	
	<cffunction name="compareQueryAndState" output="false" access="private">
		<cfargument name="_query">
		<cfargument name="_state">
		<cfargument name="dump" default="false">
		<cfargument name="message" default="">
		<cfset var query = arguments._query>
		<cfset var state = arguments._state>
		<cfif arguments.dump>
			<cfoutput>#arguments.message#</cfoutput>
			<cfdump var="#state#">
			<cfdump var="#query#">
			<cfabort>
		</cfif>
		<cfif arrayLen(state) neq query.recordCount>
			<cfreturn false>
		</cfif>
		<cfloop query="query">
			<cfset queryTreeId = query[variables.treeid]>
			<cfset stateTreeId = state[currentRow][1]>
			<cfset queryId = query[variables.id]>
			<cfset stateId = state[currentRow][2]>
			<cfset queryLeft = query[variables.left]>
			<cfset stateLeft = state[currentRow][3]>
			<cfset queryRight = query[variables.right]>
			<cfset stateRight = state[currentRow][4]>
			<cfif queryTreeId neq stateTreeId
				or queryId neq stateId
				or queryLeft neq stateLeft
				or queryRight neq stateRight>
				<!--- <cfdump var="#query#">
				<cfdump var="#state#">
				<cfabort> --->
				<cfreturn false>
			</cfif>
		</cfloop>
		<cfreturn true>
	</cffunction>

	<cffunction name="assertDatabaseState" output="false" access="private">
		<cfargument name="stateArray">
		<cfargument name="dump" default="false">
		<cfargument name="message" default="">
		<cfset var state = arguments.stateArray>
		<cfset var query = "">
		<cfquery name="query" datasource="#getDatasource().getName()#">
			select
				#variables.treeid#,
				#variables.id#,
				#variables.right#,
				#variables.left#
			from #variables.table#
			order by
				#variables.id#
		</cfquery>
		<cfreturn compareQueryAndState(query,state,arguments.dump,arguments.message)>
	</cffunction>

</cfcomponent>

