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

	<cfset variables._datasource = 0>
	<cfset variables._nstable = 0>
	<cfset variables._nst = 0>

	<cffunction name="init" output="false">
		<cfargument name="datasource">
		<cfset variables._datasource = arguments.datasource>
		<!---
		<cfset variables._nst = createObject("component","nstree.NestedSetTreeTable").init(
										getDatasource().getName(),
										getDatasource().getUsername(),
										getDatasource().getPassword(),
										"categoryNST",
										"treeId",
										"id",
										"lft",
										"rgt"
									).getNestedSetTree()>
		--->
		<cfset variables._nst = createObject("component","nstree.NestedSetTreeTable").init(
									datasourceName=getDatasource().getName(),
									table="categoryNST"
								).getNestedSetTree()>
		<cfreturn this>
	</cffunction>

	<cffunction name="getCategory" output="false">
		<cfargument name="categoryId">
		<!--- Read only lock. --->
		<cflock name="#nst().getLockName()#" timeout="#nst().getLockTimeout()#" type="readonly">
			<cfquery
				name="q"
				datasource="#getDatasource().getName()#"
				username="#getDatasource().getUsername()#"
				password="#getDatasource().getPassword()#">
				select *
				from category
				where
					categoryId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.categoryId#">
			</cfquery>
		</cflock>
		<cfreturn q>
	</cffunction>

	<cffunction name="saveCategory" output="false">
		<cfargument name="category">
		<cfset var cat = arguments.category>
		<cfif cat.categoryId gt 0>
			<cfset cat = updateCategory(cat)>
		<cfelse>
			<cfset cat = createCategory(cat)>
		</cfif>
		<cfreturn cat>
	</cffunction>

	<cffunction name="updateCategory" output="false">
		<cfargument name="category">
		<cfset var cat = arguments.category>
		<cfset var q = 0>
		<cfset var oldParentCategoryId = 0>
		<cfset var newParentCategoryId = cat.parentCategoryId>
		<cfset q = getCategory(cat.categoryId)>
		<cfset oldParentCategoryId = q.parentCategoryId>
		<!--- Exclusive lock to change the data --->
		<cflock name="#nst().getLockName()#" timeout="#nst().getLockTimeout()#" type="exclusive">
			<!--- Transaction to ensure atomic database changes. --->
			<cftransaction>
				<cfquery
					datasource="#getDatasource().getName()#"
					username="#getDatasource().getUsername()#"
					password="#getDatasource().getPassword()#"
					result="q">
					update category
					set
						parentCategoryId = <cfqueryparam cfsqltype="cf_sql_integer" value="#cat.parentCategoryId#">,
						categoryName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#cat.categoryName#">
					where
						categoryId = <cfqueryparam cfsqltype="cf_sql_integer" value="#cat.categoryId#">
				</cfquery>
				<!--- If the parent was changed, then also move the node in the NST table. --->
				<cfif newParentCategoryId neq oldParentCategoryId>
					<cfset nst().moveToLastChild(cat.categoryId,newParentCategoryId)>
				</cfif>
			</cftransaction>
		</cflock>
		<cfreturn cat>
	</cffunction>

	<cffunction name="createCategory" output="false">
		<cfargument name="category">
		<cfset var cat = arguments.category>
		<cfset var q = 0>
		<cfset var parentNode = 0>
		<!--- Exclusive lock for a new record. --->
		<cflock name="#nst().getLockName()#" timeout="#nst().getLockTimeout()#" type="exclusive">
			<!--- Transaction to ensure atomic database changes. --->
			<cftransaction>
				<cfquery
					datasource="#getDatasource().getName()#"
					username="#getDatasource().getUsername()#"
					password="#getDatasource().getPassword()#">
					insert into category
					(
						parentCategoryId,
						categoryName
					)
					values
					(
						<cfqueryparam cfsqltype="cf_sql_integer" value="#cat.parentCategoryId#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#cat.categoryName#">
					)
				</cfquery>
				<cfquery
					name="q"
					datasource="#getDatasource().getName()#"
					username="#getDatasource().getUsername()#"
					password="#getDatasource().getPassword()#">
					select max(categoryId) as maxCategoryId
					from category
				</cfquery>
				<cfset cat.categoryId = q.maxCategoryId>
				<!--- If the parent category is 0 then assume this is a new root node.
				Otherwise make this node the last child of the specified parent. --->
				<cfif cat.parentCategoryId gt 0>
					<cfset nst().newLastChild(cat.parentCategoryId,cat.categoryId)>
				<cfelse>
					<cfset nst().newRoot(cat.categoryId)>
				</cfif>
			</cftransaction>
		</cflock>
		<cfreturn cat>
	</cffunction>

	<cffunction name="deleteCategory" output="false">
		<cfargument name="categoryId">
		<cfset var node = 0>
		<!--- Exclusive lock to delete record. --->
		<cflock name="#nst().getLockName()#" timeout="#nst().getLockTimeout()#" type="exclusive">
			<cfset node = nst().getNode(arguments.categoryId)>
			<cfif node.getId() gt 0>
				<!--- Transaction to ensure atomic database changes. --->
				<cftransaction>
					<cfquery
						datasource="#getDatasource().getName()#"
						username="#getDatasource().getUsername()#"
						password="#getDatasource().getPassword()#">
						delete cat
						from
							category cat
							inner join categoryNST nst on cat.categoryId = nst.id
						where
							nst.lft >= <cfqueryparam cfsqltype="cf_sql_integer" value="#node.getLeft()#">
							and nst.rgt <= <cfqueryparam cfsqltype="cf_sql_integer" value="#node.getRight()#">
					</cfquery>
					<cfset nst().delete(node)>
				</cftransaction>
			</cfif>
		</cflock>
	</cffunction>

	<cffunction name="getRootCategory" output="false">
		<cfset var q = 0>
		<!--- Read only lock. --->
		<cflock name="#nst().getLockName()#" timeout="#nst().getLockTimeout()#" type="readonly">
			<cfquery
				name="q"
				datasource="#getDatasource().getName()#"
				username="#getDatasource().getUsername()#"
				password="#getDatasource().getPassword()#">
				select *
				from category
				where parentCategoryId = <cfqueryparam cfsqltype="cf_sql_integer" value="0">
			</cfquery>
		</cflock>
		<cfreturn q>
	</cffunction>

	<cffunction name="getCategoryChildren" output="false">
		<cfargument name="categoryId">
		<cfset var q = 0>
		<!--- Read only lock. --->
		<cflock name="#nst().getLockName()#" timeout="#nst().getLockTimeout()#" type="readonly">
			<cfquery
				name="q"
				datasource="#getDatasource().getName()#"
				username="#getDatasource().getUsername()#"
				password="#getDatasource().getPassword()#">
				select
					d.*
				from
					category d
					inner join categoryNST nst on d.categoryId = nst.id
				where
					d.parentCategoryId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.categoryId#">
				order by
					nst.lft
			</cfquery>
		</cflock>
		<cfreturn q>
	</cffunction>

	<cffunction name="getCategoryTree" output="false">
		<cfset var q = 0>
		<!--- Read only lock. --->
		<cflock name="#nst().getLockName()#" timeout="#nst().getLockTimeout()#" type="readonly">
			<cfquery
				name="q"
				datasource="#getDatasource().getName()#"
				username="#getDatasource().getUsername()#"
				password="#getDatasource().getPassword()#">
				select
					c.*,
					(
						select count(*)
						from categoryNST nst2
						where
							nst2.lft < nst.lft
							and nst2.rgt > nst.rgt
					) as level,
					nst.lft,
					nst.rgt
				from
					category c
					inner join categoryNST nst on c.categoryId = nst.id
				order by
					nst.lft
			</cfquery>
		</cflock>
		<cfreturn q>
	</cffunction>

	<cffunction name="getCategorySubtree" output="false">
		<cfargument name="categoryId" type="numeric" required="true">
		<cfargument name="includeRootNode" type="boolean" required="false" default="true">
		<cfset var q = 0>
		<cfset var node = 0>
		<!--- Read only lock. --->
		<cflock name="#nst().getLockName()#" timeout="#nst().getLockTimeout()#" type="readonly">
			<cfset node = nst().getNode(arguments.categoryId)>
			<cfquery
				name="q"
				datasource="#getDatasource().getName()#"
				username="#getDatasource().getUsername()#"
				password="#getDatasource().getPassword()#">
				select
					c.*,
					(
						select count(*)
						from categoryNST nst2
						where
							nst2.lft < nst.lft
							and nst2.rgt > nst.rgt
					) as level,
					nst.lft,
					nst.rgt
				from
					category c
					inner join categoryNST nst on c.categoryId = nst.id
				where
					<cfif arguments.includeRootNode>
						nst.lft >= <cfqueryparam cfsqltype="cf_sql_integer" value="#node.getLeft()#">
					<cfelse>
						nst.lft > <cfqueryparam cfsqltype="cf_sql_integer" value="#node.getLeft()#">
					</cfif>
					and nst.rgt <= <cfqueryparam cfsqltype="cf_sql_integer" value="#node.getRight()#">
				order by
					nst.lft
			</cfquery>
		</cflock>
		<cfreturn q>
	</cffunction>

	<cffunction name="moveCategoryUp" output="false">
		<cfargument name="categoryId">
		<cfset var prevNode = 0>
		<!--- Exclusive lock. --->
		<cflock name="#nst().getLockName()#" timeout="#nst().getLockTimeout()#" type="exclusive">
			<cftransaction>
				<cfset prevNode = nst().prevSibling(arguments.categoryId)>
				<cfif prevNode.getId() gt 0>
					<cfset nst().moveToPrevSibling(arguments.categoryId,prevNode.getId())>
				</cfif>
			</cftransaction>
		</cflock>
	</cffunction>

	<cffunction name="moveCategoryDown" output="false">
		<cfargument name="categoryId">
		<cfset var nextNode = 0>
		<cflock name="#nst().getLockName()#" timeout="#nst().getLockTimeout()#" type="exclusive">
			<cftransaction>
				<cfset nextNode = nst().nextSibling(arguments.categoryId)>
				<cfif nextNode.getId() gt 0>
					<cfset nst().moveToNextSibling(arguments.categoryId,nextNode.getId())>
				</cfif>
			</cftransaction>
		</cflock>
	</cffunction>

	<cffunction name="moveCategory" output="false">
		<cfargument name="srcId">
		<cfargument name="dstId">
		<cfset var moveAllowed = false>
		<!--- If the destination node is a child of the source node, then the move is not permitted. --->
		<cflock name="#nst().getLockName()#" timeout="#nst().getLockTimeout()#" type="readonly">
			<cfset moveAllowed = not nst().isChildOrEqual(arguments.dstId,arguments.srcId)>
		</cflock>
		<cfif not moveAllowed>
			<cfreturn>
		</cfif>
		<cflock name="#nst().getLockName()#" timeout="#nst().getLockTimeout()#" type="exclusive">
			<cftransaction>
				<cfquery
					datasource="#getDatasource().getName()#"
					username="#getDatasource().getUsername()#"
					password="#getDatasource().getPassword()#">
					update category
					set parentCategoryId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.dstId#">
					where categoryId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.srcId#">
				</cfquery>
				<cfset nst().moveToLastChild(arguments.srcId,arguments.dstId)>
			</cftransaction>
		</cflock>
	</cffunction>

	<cffunction name="rebuildCategoryIndex" output="false">
		<cfset var cat = getRootCategory()>
		<cfset nst().rebuildIndex("category","categoryId","parentCategoryId",cat.categoryId)>
	</cffunction>

	<cffunction name="nst" output="false" access="private">
		<cfreturn variables._nst>
	</cffunction>

	<cffunction name="getDatasource" output="false" access="private">
		<cfreturn variables._datasource>
	</cffunction>

</cfcomponent>
