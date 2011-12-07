<!---

Nested Set Tree Library

Copyright (C) 2009, Kevan Stannard

LICENSE
-------

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

CREDIT
------ 

Originally based on PHP nstrees library:
    Author:  Rolf Brugger, edutech
    Version: 0.02, 5. April 2005
    URL:     http://www.edutech.ch/contribution/nstrees
  
DB-Model by Joe Celko (http://www.celko.com/)

--->

<cfcomponent output="false">
	
	<cfset variables.name = "" />
	<cfset variables.username = "" />
	<cfset variables.password = "" />
	
	<cffunction name="init" access="public" output="false">
		<cfargument name="name" required="true" />
		<cfargument name="username" required="false" default="" />
		<cfargument name="password" required="false" default="" />
		<cfset setName(arguments.name) />
		<cfset setUsername(arguments.username) />
		<cfset setPassword(arguments.password) />
		<cfreturn this />
	</cffunction>

	<cffunction name="setName" output="false">
		<cfargument name="name" required="true" />
		<cfset variables.name = arguments.name />
	</cffunction>

	<cffunction name="setUsername" output="false">
		<cfargument name="username" required="false" default="" />
		<cfset variables.username = arguments.username />
	</cffunction>

	<cffunction name="setPassword" output="false">
		<cfargument name="password" required="false" default="" />
		<cfset variables.password = arguments.password />
	</cffunction>
	
	<cffunction name="getName" output="false">
		<cfreturn variables.name />
	</cffunction>

	<cffunction name="getUsername" output="false">
		<cfreturn variables.username />
	</cffunction>

	<cffunction name="getPassword" output="false">
		<cfreturn variables.password />
	</cffunction>

</cfcomponent>

