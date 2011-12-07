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

	<cfset variables.config = 0>
	<cfset variables.table = 0>

	<cffunction name="init" output="false">
		<cfargument name="datasourceName">
		<cfargument name="datasourceUserName">
		<cfargument name="datasourcePassword">
		<cfargument name="nstTableName">
		<cfargument name="nstTreeIdColumnName">
		<cfargument name="nstIdColumnName">
		<cfargument name="nstLeftColumnName">
		<cfargument name="nstRightColumnName">
		<cfargument name="sourceTableName">
		<cfargument name="sourceParentIdColumnName">
		<cfargument name="sourceIdColumnName">
		<cfargument name="sourceRootId">
		<cfargument name="treeId">
		<cfset variables.config = duplicate(arguments)>
		<cfset variables.table = createObject("component","nstree.NestedSetTreeTable").init(
										arguments.datasourceName,
										arguments.datasourceUsername,
										arguments.datasourcePassword,
										arguments.nstTableName,
										arguments.nstTreeIdColumnName,
										arguments.nstIdColumnName,
										arguments.nstLeftColumnName,
										arguments.nstRightColumnName
									)>
		<cfreturn this>
	</cffunction>

	<cffunction name="start" output="false">
		<cfset var nst = variables.table.getNestedSetTree(variables.config.treeId)>
		<cfset nst.rebuildIndex(
							variables.config.sourceTableName,
							variables.config.sourceIdColumnName,
							variables.config.sourceParentIdColumnName,
							variables.config.sourceRootId
						)>
	</cffunction>

</cfcomponent>
