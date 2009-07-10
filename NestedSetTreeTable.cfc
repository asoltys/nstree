<!---

Nested Set Tree Library

Copyright (c) 2008, Kevan Stannard

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

	
ORIENTATION
-----------
  
      n0
	 / | \
   n1  N  n3
     /   \
   n4     n5
   
Directions from the perspective of the node N:
    n0: up / ancestor
	n1: previous (sibling)
	n3: next (sibling)
	n4: first (child)
	n5: last (child)

--->

<cfcomponent output="false">

	<!--- PRIVATE VARIABLES --->

	<cfset variables.datasource = structNew()>
	<cfset variables.tableName = "">
	<cfset variables.treeIdColName = "">
	<cfset variables.idColName = "">
	<cfset variables.leftColName = "">
	<cfset variables.rightColName = "">

	<!--- INITIALISATION --->

	<cffunction name="init" output="false" returntype="NestedSetTreeTable" hint="Initialises the Nested Set Tree.">
		<cfargument name="datasourceName" type="string" required="true" hint="The datasource name.">
		<cfargument name="datasourceUsername" type="string" required="false" default="" hint="The datasource username.">
		<cfargument name="datasourcePassword" type="string" required="false" default="" hint="The datasource password.">
		<cfargument name="table" type="string" required="true" hint="The name of the Nested Set Tree table.">
		<cfargument name="treeId" type="string" required="false" default="treeid" hint="The name of the Nested Set Tree Tree Id column.">
		<cfargument name="id" type="string" required="false" default="id" hint="The name of the Nested Set Tree Id column.">
		<cfargument name="left" type="string" required="false" default="lft" hint="The name of the Nested Set Tree Left column.">
		<cfargument name="right" type="string" required="false" default="rgt" hint="The name of the Nested Set Tree Right column.">
		<cfset variables.datasource.name = arguments.datasourceName>
		<cfset variables.datasource.username = arguments.datasourceUsername>
		<cfset variables.datasource.password = arguments.datasourcePassword>
		<cfset variables.tableName = arguments.table>
		<cfset variables.treeIdColName = arguments.treeId>
		<cfset variables.idColName = arguments.id>
		<cfset variables.leftColName = arguments.left>
		<cfset variables.rightColName = arguments.right>
		<cfreturn this>
	</cffunction>

	<!--- PUBLIC FUNCTIONS --->

	<cffunction name="getNestedSetTree" output="false" returntype="NestedSetTree" hint="Returns a Nested Set Tree for the specified tree id.">
		<cfargument name="treeId" type="numeric" required="false" default="0">
		<cfreturn createObject("component","NestedSetTree").init(this,arguments.treeId)>
	</cffunction>

	<cffunction name="deleteAllTrees" output="false" returntype="void" hint="Deletes all records of all trees.">
		<cfquery
			datasource="#variables.datasource.name#"
			username="#variables.datasource.username#"
			password="#variables.datasource.password#">
			delete
			from #getTableName()#
		</cfquery>
	</cffunction>
	
	<!--- PACKAGE FUNCTIONS --->

	<cffunction name="getTableName" output="false" returntype="string" access="package">
		<cfreturn variables.tableName>
	</cffunction>

	<cffunction name="getTreeIdColName" output="false" returntype="string" access="package">
		<cfreturn variables.treeIdColName>
	</cffunction>

	<cffunction name="getIdColName" output="false" returntype="string" access="package">
		<cfreturn variables.idColName>
	</cffunction>

	<cffunction name="getLeftColName" output="false" returntype="string" access="package">
		<cfreturn variables.leftColName>
	</cffunction>

	<cffunction name="getRightColName" output="false" returntype="string" access="package">
		<cfreturn variables.rightColName>
	</cffunction>

	<cffunction name="getDatasource" output="false" returntype="struct" access="package">
		<cfreturn variables.datasource>
	</cffunction>

</cfcomponent>

