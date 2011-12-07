<cfcomponent output="false">
	
	<cfsetting enablecfoutputonly="true">

	<cfset this.name = "nstree">

	<cffunction name="initialise" output="false">
		<cfset var datasource = createObject("component","com.DataSource").init("nstree")>
		<cfset var categoryGateway = createObject("component","com.CategoryGateway").init(datasource)>
		<cflock scope="Application" type="exclusive" timeout="5">
			<cfset application.app = structNew()>
			<cfset application.app.categoryGateway = categoryGateway>
		</cflock>
	</cffunction>

	<cffunction name="onApplicationStart" output="false">
		<cfset initialise()>
	</cffunction>

	<cffunction name="onRequestStart" output="false">
		<cfargument name="page">
		<cfif structKeyExists(url,"reinit")>
			<cfset initialise()>
		</cfif>
	</cffunction>

</cfcomponent>