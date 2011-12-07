<cfcomponent output="false">
	
	<cfsetting enablecfoutputonly="true">
	<cfsetting requesttimeout="300">
	<cfsetting showdebugoutput="false">

	<cfset this.name = "nstreetests">

	<cffunction name="initialise" output="false">
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
