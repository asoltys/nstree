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

	<!--- PRIVATE VARIABLES --->
	
	<cfset variables.table = 0>
	<cfset variables.treeId = 0>
	<cfset variables.lockName = "">
	<cfset variables.lockTimeout = 3>

	<!--- INITIALISATION --->

	<cffunction name="init" output="false" returntype="NestedSetTree">
		<cfargument name="table" type="NestedSetTreeTable" required="true">
		<cfargument name="treeId" type="numeric" required="true">
		<cfset variables.table = arguments.table>
		<cfset variables.treeId = arguments.treeId>
		<cfset variables.datasource = variables.table.getDatasource()>
		<cfset setLockName(createLockName())>
		<cfreturn this>
	</cffunction>

	<!--- LOCKING --->

	<cffunction name="setLockName" output="false" returntype="void" hint="Sets the lock name.">
		<cfargument name="lockName">
		<cfset variables.lockName = arguments.lockName>
	</cffunction>

	<cffunction name="getLockName" output="false" returntype="string" hint="Returns the lock name.">
		<cfreturn variables.lockName>
	</cffunction>

	<cffunction name="setLockTimeout" output="false" returntype="void" hint="Sets the lock timeout.">
		<cfargument name="lockTimeout">
		<cfset variables.lockTimeout = arguments.lockTimeout>
	</cffunction>

	<cffunction name="getLockTimeout" output="false" returntype="numeric" hint="Returns the lock timeout (seconds).">
		<cfreturn variables.lockTimeout>
	</cffunction>

	<!--- TREE --->

	<cffunction name="getTreeId" output="false" returntype="numeric" hint="Returns the tree Id.">
		<cfreturn variables.treeId>
	</cffunction>

	<!--- INDEX BUILDER --->

	<cffunction name="rebuildIndex" output="false" returntype="void" hint="Rebuilds the Nested Set Tree index.">
		<cfargument name="primaryTable" required="true">
		<cfargument name="primaryTableId" required="true">
		<cfargument name="primaryTableParentId" required="true">
		<cfargument name="rootId" required="true">
		<cfset deleteTree()>
		<cfset createIndexRecord(arguments)>
	</cffunction>

	<!--- NODE CREATION --->

	<cffunction name="newRoot" output="false" returntype="Node" hint="Creates a new root record and returns the node with left=1 and right=2.">
		<cfargument name="id" type="numeric" required="true">
		<cfset var node = 0>
		<cflock name="#getLockName()#" type="exclusive" timeout="#getLockTimeout()#">
			<cfif isValidNode(root())>
				<cfthrow type="MultipleRoot" message="A tree may only have one root node.">
			</cfif>
			<cfset node = newNode(arguments.id,1,2)>
			<cfset insertNew(node)>
		</cflock>
		<cfreturn node>
	</cffunction>

	<cffunction name="newFirstChild" output="false" returntype="Node" hint="Creates a new first child.">
		<cfargument name="_parent" type="any" required="true">
		<cfargument name="_childId" type="numeric" required="true">
		<cfset var node = 0>
		<cfset var parent = 0>
		<cflock name="#getLockName()#" type="exclusive" timeout="#getLockTimeout()#">
			<cfset parent = loadNode(arguments._parent)>
			<cfif not isValidNode(parent)>
				<cfthrow type="InvalidNode" message="NewFirstChild: The parent node is invalid.">
			</cfif>
			<cfset node = newNode(
									arguments._childId,
									parent.getLeft() + 1,
									parent.getLeft() + 2
								)>
			<cfset shiftRLValues(node.getLeft(),2)>
			<cfset insertNew(node)>
			<cfset parent.invalidate()>
		</cflock>
		<cfreturn node>
	</cffunction>

	<cffunction name="newLastChild" output="false" returntype="Node" hint="Creates a new last child.">
		<cfargument name="_parent" type="any" required="true">
		<cfargument name="_childId" type="numeric" required="true">
		<cfset var node = 0>
		<cfset var parent = 0>
		<cflock name="#getLockName()#" type="exclusive" timeout="#getLockTimeout()#">
			<cfset parent = loadNode(arguments._parent)>
			<cfif not isValidNode(parent)>
				<cfthrow type="InvalidNode" message="NewLastChild: The parent node is invalid.">
			</cfif>
			<cfset node = newNode(
									arguments._childId,
									parent.getRight(),
									parent.getRight() + 1
								)>
			<cfset shiftRLValues(node.getLeft(),2)>
			<cfset insertNew(node)>
			<cfset parent.invalidate()>
		</cflock>
		<cfreturn node>
	</cffunction>

	<cffunction name="newPrevSibling" output="false" returntype="Node" hint="Creates a new previous sibling.">
		<cfargument name="_parent" type="any" required="true">
		<cfargument name="_childId" type="numeric" required="true">
		<cfset var node = 0>
		<cfset var parent = 0>
		<cflock name="#getLockName()#" type="exclusive" timeout="#getLockTimeout()#">
			<cfset parent = loadNode(arguments._parent)>
			<cfif not isValidNode(parent)>
				<cfthrow type="InvalidNode" message="NewPrevSibling: The parent node is invalid.">
			</cfif>
			<cfset node = newNode(
											arguments._childId,
											parent.getLeft(),
											parent.getLeft() + 1
										)>
			<cfset shiftRLValues(node.getLeft(),2)>
			<cfset insertNew(node)>
			<cfset parent.invalidate()>
		</cflock>
		<cfreturn node>
	</cffunction>

	<cffunction name="newNextSibling" output="false" returntype="Node" hint="Creates a new next sibling.">
		<cfargument name="_parent" type="any" required="true">
		<cfargument name="_childId" type="numeric" required="true">
		<cfset var node = 0>
		<cfset var parent = 0>
		<cflock name="#getLockName()#" type="exclusive" timeout="#getLockTimeout()#">
			<cfset parent = loadNode(arguments._parent)>
			<cfif not isValidNode(parent)>
				<cfthrow type="InvalidNode" message="NewNextSibling: The parent node is invalid.">
			</cfif>
			<cfset node = newNode(
										arguments._childId,
										parent.getRight() + 1,
										parent.getRight() + 2
									)>
			<cfset shiftRLValues(node.getLeft(),2)>
			<cfset insertNew(node)>
		</cflock>
		<cfreturn node>
	</cffunction>
	
	<!--- TREE REORGANISATION --->
	<!--- All moveTo functions return the new position of the moved subtree. --->

	<cffunction name="moveToNextSibling" output="false" returntype="struct" hint="Moves the node 'src' and all its children (subtree) so that it is the next sibling of 'dst'.">
		<cfargument name="_src" type="any" required="true">
		<cfargument name="_dst" type="any" required="true">
		<cfset var pos = 0>
		<cfset var src = 0>
		<cfset var dst = 0>
		<cflock name="#getLockName()#" type="exclusive" timeout="#getLockTimeout()#">
			<cfset src = loadNode(arguments._src)>
			<cfif not isValidNode(src)>
				<cfthrow type="InvalidNode" message="MoveToNextSibling: The ""src"" node (#nodeToString(arguments.src)#) is invalid.">
			</cfif>
			<cfset dst = loadNode(arguments._dst)>
			<cfif not isValidNode(dst)>
				<cfthrow type="InvalidNode" message="MoveToNextSibling: The ""dst"" node (#nodeToString(arguments.dst)#) is invalid.">
			</cfif>
			<cfif isChild(dst,src)>
				<cfthrow type="InvalidMove" message="MoveToNextSibling: The ""src"" node #nodeToString(arguments.src)# cannot be moved into its subtree at node ""dst"" #nodeToString(arguments.dst)#.">
			</cfif>
			<cfset pos = moveSubtree(src,dst.getRight()+1)>
			<cfset src.invalidate()>
			<cfset dst.invalidate()>
		</cflock>
		<cfreturn pos>
	</cffunction>

	<cffunction name="moveToPrevSibling" output="false" returntype="struct" hint="Moves the node 'src' and all its children (subtree) so that it is the previous sibling of 'dst'.">
		<cfargument name="_src" type="any" required="true">
		<cfargument name="_dst" type="any" required="true">
		<cfset var pos = 0>
		<cfset var src = 0>
		<cfset var dst = 0>
		<cflock name="#getLockName()#" type="exclusive" timeout="#getLockTimeout()#">
			<cfset src = loadNode(arguments._src)>
			<cfif not isValidNode(src)>
				<cfthrow type="InvalidNode" message="MoveToPrevSibling: The ""src"" node (#nodeToString(src)#) is invalid.">
			</cfif>
			<cfset dst = loadNode(arguments._dst)>
			<cfif not isValidNode(dst)>
				<cfthrow type="InvalidNode" message="MoveToPrevSibling: The ""dst"" node (#nodeToString(dst)#) is invalid.">
			</cfif>
			<cfif isChild(dst,src)>
				<cfthrow type="InvalidMove" message="MoveToPrevSibling: The ""src"" node #nodeToString(src)# cannot be moved into its subtree at node ""dst"" #nodeToString(dst)#.">
			</cfif>
			<cfset pos = moveSubtree(src,dst.getLeft())>
			<cfset src.invalidate()>
			<cfset dst.invalidate()>
		</cflock>
		<cfreturn pos>
	</cffunction>		

	<cffunction name="moveToFirstChild" output="false" returntype="struct" hint="Moves the node 'src' and all its children (subtree) so that it is the first child of 'dst'.">
		<cfargument name="_src" type="any" required="true">
		<cfargument name="_dst" type="any" required="true">
		<cfset var pos = 0>
		<cfset var src = 0>
		<cfset var dst = 0>
		<cflock name="#getLockName()#" type="exclusive" timeout="#getLockTimeout()#">
			<cfset src = loadNode(arguments._src)>
			<cfif not isValidNode(src)>
				<cfthrow type="InvalidNode" message="MoveToFirstChild: The ""src"" node (#nodeToString(src)#) is invalid.">
			</cfif>
			<cfset dst = loadNode(arguments._dst)>
			<cfif not isValidNode(dst)>
				<cfthrow type="InvalidNode" message="MoveToFirstChild: The ""dst"" node (#nodeToString(dst)#) is invalid.">
			</cfif>
			<cfif isChild(dst,src)>
				<cfthrow type="InvalidMove" message="MoveToFirstChild: The ""src"" node #nodeToString(src)# cannot be moved into its subtree at node ""dst"" #nodeToString(dst)#.">
			</cfif>
			<cfset pos = moveSubtree(src,dst.getLeft() + 1)>
			<cfset src.invalidate()>
			<cfset dst.invalidate()>
		</cflock>
		<cfreturn pos>
	</cffunction>		

	<cffunction name="moveToLastChild" output="false" returntype="struct" hint="Moves the node 'src' and all its children (subtree) so that it is the last child of 'dst'.">
		<cfargument name="_src" type="any" required="true">
		<cfargument name="_dst" type="any" required="true">
		<cfset var pos = 0>
		<cfset var src = 0>
		<cfset var dst = 0>
		<cflock name="#getLockName()#" type="exclusive" timeout="#getLockTimeout()#">
			<cfset src = loadNode(arguments._src)>
			<cfif not isValidNode(src)>
				<cfthrow type="InvalidNode" message="MoveToLastChild: The ""src"" node #nodeToString(src)# is invalid.">
			</cfif>
			<cfset dst = loadNode(arguments._dst)>
			<cfif not isValidNode(dst)>
				<cfthrow type="InvalidNode" message="MoveToLastChild: The ""dst"" node #nodeToString(dst)# is invalid.">
			</cfif>
			<cfif isChild(dst,src)>
				<cfthrow type="InvalidMove" message="MoveToLastChild: The ""src"" node #nodeToString(src)# cannot be moved into its subtree at node ""dst"" #nodeToString(arguments.dst)#.">
			</cfif>
			<cfset pos = moveSubtree(src,dst.getRight())>
			<cfset src.invalidate()>
			<cfset dst.invalidate()>
		</cflock>
		<cfreturn pos>
	</cffunction>

	<!--- TREE DESTRUCTORS--->

	<cffunction name="deleteTree" output="false" returntype="void" hint="Deletes all records of the specified tree">
		<cflock name="#getLockName()#" type="exclusive" timeout="#getLockTimeout()#">
			<cfquery
				datasource="#variables.datasource.name#"
				username="#variables.datasource.username#"
				password="#variables.datasource.password#">
				delete
				from #getTableName()#
				where
					#getTreeIdColName()# = <cfqueryparam cfsqltype="cf_sql_integer" value="#getTreeId()#">
			</cfquery>
		</cflock>
	</cffunction>

	<cffunction name="delete" output="false" returntype="void" hint="Deletes the node and all its children (subtree).">
		<cfargument name="_node" type="any" required="true">
		<cfset var node = 0>
		<cfset var leftAnchor = 0>
		<cfset var where = "">
		<cflock name="#getLockName()#" type="exclusive" timeout="#getLockTimeout()#">
			<cfset node = loadNode(arguments._node)>
			<cfif isValidNode(node)>
				<cfset leftAnchor = node.getLeft()>
				<cfquery
					datasource="#variables.datasource.name#"
					username="#variables.datasource.username#"
					password="#variables.datasource.password#">
					delete
					from #getTableName()#
					where
						#getTreeIdColName()# = <cfqueryparam cfsqltype="cf_sql_integer" value="#getTreeId()#">
						and #getLeftColName()# >= <cfqueryparam cfsqltype="cf_sql_integer" value="#node.getLeft()#">
						and #getRightColName()# <= <cfqueryparam cfsqltype="cf_sql_integer" value="#node.getRight()#">
				</cfquery>
				<cfset shiftRLValues(node.getRight() + 1, node.getLeft() - node.getRight() - 1)>
			</cfif>
			<cfset node.invalidate()>
		</cflock>
	</cffunction>

	<!--- TREE QUERIES --->
	<!--- The following functions return a node. For nodes that don't exist, a node with left=0 and right=0 is returned. --->

	<cffunction name="getNode" output="false" returntype="Node" hint="Returns the node with the specified id.">
		<cfargument name="id" type="numeric" required="true">
		<cfset var node = 0>
		<cflock name="#getLockName()#" type="readonly" timeout="#getLockTimeout()#">
			<cfset node = getNodeWhere(getIdColName() & "=" & arguments.id)>
		</cflock>
		<cfreturn node>
	</cffunction>

	<cffunction name="root" output="false" returntype="Node" hint="Returns the tree's root node.">
		<cfset var node = 0>
		<cflock name="#getLockName()#" type="readonly" timeout="#getLockTimeout()#">
			<cfset node = getNodeWhereLeft(1)>
		</cflock>
		<cfreturn node>
	</cffunction>

	<cffunction name="firstChild" output="false" returntype="Node" hint="Returns the first child of the specified node.">
		<cfargument name="_parent" type="any" required="true">
		<cfset var node = 0>
		<cfset var parent = 0>
		<cflock name="#getLockName()#" type="readonly" timeout="#getLockTimeout()#">
			<cfset parent = loadNode(arguments._parent)>
			<cfif not isValidNode(parent)>
				<cfthrow type="InvalidNode" message="FirstChild: The parent node is invalid.">
			</cfif>
			<cfset node = getNodeWhereLeft(parent.getLeft()+1)>
		</cflock>
		<cfreturn node>
	</cffunction>

	<cffunction name="lastChild" output="false" returntype="Node" hint="Returns the last child of the specified node.">	
		<cfargument name="_parent" type="any" required="true">
		<cfset var node = 0>
		<cfset var parent = 0>
		<cflock name="#getLockName()#" type="readonly" timeout="#getLockTimeout()#">
			<cfset parent = loadNode(arguments._parent)>
			<cfif not isValidNode(parent)>
				<cfthrow type="InvalidNode" message="LastChild: The parent node is invalid.">
			</cfif>
			<cfset node = getNodeWhereRight(parent.getRight()-1)>
		</cflock>
		<cfreturn node>
	</cffunction>

	<cffunction name="prevSibling" output="false" returntype="Node" hint="Returns the previous sibling of the specified node.">
		<cfargument name="_node" type="any" required="true">
		<cfset var node = 0>
		<cfset var sibling = 0>
		<cflock name="#getLockName()#" type="readonly" timeout="#getLockTimeout()#">
			<cfset node = loadNode(arguments._node)>
			<cfif not isValidNode(node)>
				<cfthrow type="InvalidNode" message="PrevSibling: The specified node is invalid.">
			</cfif>
			<cfset sibling = getNodeWhereRight(node.getLeft()-1)>
		</cflock>
		<cfreturn sibling>
	</cffunction>

	<cffunction name="nextSibling" output="false" returntype="Node" hint="Returns the next sibling of the specified node.">
		<cfargument name="_node" type="any" required="true">
		<cfset var node = 0>
		<cfset var sibling = 0>
		<cflock name="#getLockName()#" type="readonly" timeout="#getLockTimeout()#">
			<cfset node = loadNode(arguments._node)>
			<cfif not isValidNode(node)>
				<cfthrow type="InvalidNode" message="NextSibling: The specified node is invalid.">
			</cfif>
			<cfset sibling = getNodeWhereLeft(node.getRight()+1)>
		</cflock>
		<cfreturn sibling>
	</cffunction>

	<cffunction name="ancestor" output="false" returntype="Node" hint="Returns the ancestor of the specified node.">
		<cfargument name="_node" type="any" required="true">
		<cfset var node = 0>
		<cfset var where = "">
		<cfset var ancestor = 0>
		<cflock name="#getLockName()#" type="readonly" timeout="#getLockTimeout()#">
			<cfset node = loadNode(arguments._node)>
			<cfif not isValidNode(node)>
				<cfthrow type="InvalidNode" message="Ancestor: The specified node is invalid.">
			</cfif>
			<cfsavecontent variable="where">
				<cfoutput>
				#getLeftColName()# < #node.getLeft()#
				and #getRightColName()# > #node.getRight()#
				order by #getRightColName()#
				</cfoutput>
			</cfsavecontent>
			<cfset ancestor = getNodeWhere(where)>
		</cflock>
		<cfreturn ancestor>
	</cffunction>

	<!--- TREE BOOLEAN FUNCTIONS --->
	<!--- The following functions return a boolean value. --->

	<cffunction name="isValidNode" output="false" returntype="boolean" hint="Returns true if the node is a valid node. Only checks if left-value < right-value (does no db-query).">
		<cfargument name="node" type="Node" required="true">
		<cfreturn arguments.node.getLeft() lt arguments.node.getRight()>
	</cffunction>		

	<cffunction name="hasAncestor" output="false" returntype="boolean" hint="Returns true if the node has an ancestor.">	
		<cfargument name="node" type="any" required="true">
		<cfreturn isValidNode(ancestor(arguments.node))>
	</cffunction>		

	<cffunction name="hasPrevSibling" output="false" returntype="boolean" hint="Returns true if the node has a previous sibling.">
		<cfargument name="node" type="any" required="true">
		<cfreturn isValidNode(prevSibling(arguments.node))>
	</cffunction>		

	<cffunction name="hasNextSibling" output="false" returntype="boolean" hint="Returns true if the node has a next sibling.">
		<cfargument name="_node" type="any" required="true">
		<cfreturn isValidNode(nextSibling(arguments._node))>
	</cffunction>		

	<cffunction name="hasChildren" output="false" returntype="boolean" hint="Returns true if the node has children.">
		<cfargument name="_node" type="any" required="true">
		<cfset var node = arguments._node>
		<cfif not isObject(node)>
			<cflock name="#getLockName()#" type="readonly" timeout="#getLockTimeout()#">
				<cfset node = loadNode(node)>
			</cflock>
		</cfif>
		<cfreturn (node.getRight() - node.getLeft()) gt 1>
	</cffunction>		

	<cffunction name="isRoot" output="false" returntype="boolean" hint="Returns true if the node is the root node.">
		<cfargument name="_node" type="any" required="true">
		<cfset var node = arguments._node>
		<cfif not isObject(node)>
			<cflock name="#getLockName()#" type="readonly" timeout="#getLockTimeout()#">
				<cfset node = loadNode(node)>
			</cflock>
		</cfif>
		<cfreturn node.getLeft() eq 1>
	</cffunction>		

	<cffunction name="isLeaf" output="false" returntype="boolean" hint="Returns true if the node is a leaf node.">
		<cfargument name="_node" type="any" required="true">
		<cfset var node = arguments._node>
		<cfif not isObject(node)>
			<cflock name="#getLockName()#" type="readonly" timeout="#getLockTimeout()#">
				<cfset node = loadNode(node)>
			</cflock>
		</cfif>
		<cfreturn (node.getRight() - node.getLeft()) eq 1>
	</cffunction>		

	<cffunction name="isChild" output="false" returntype="boolean" hint="Returns true, if 'node1' is a direct child or in the subtree of 'node2'.">
		<cfargument name="_node1" type="any" required="true">
		<cfargument name="_node2" type="any" required="true">
		<cfset var node1 = arguments._node1>
		<cfset var node2 = arguments._node2>
		<cfif not isObject(node1) or not isObject(node2)>
			<cflock name="#getLockName()#" type="readonly" timeout="#getLockTimeout()#">
				<cfif not isObject(node1)>
					<cfset node1 = loadNode(node1)>
				</cfif>
				<cfif not isObject(node2)>
					<cfset node2 = loadNode(node2)>
				</cfif>
			</cflock>			
		</cfif>
		<cfif not isValidNode(node1)>
			<cfthrow type="InvalidNode" message="IsChild: Node #nodeToString(node1)# is invalid.">
		</cfif>
		<cfif not isValidNode(node2)>
			<cfthrow type="InvalidNode" message="IsChild: Node #nodeToString(node2)# is invalid.">
		</cfif>
		<cfreturn (
				(node1.getLeft() gt node2.getLeft()) and
				(node1.getRight() lt node2.getRight())
			)>
	</cffunction>

	<cffunction name="isChildOrEqual" output="false" returntype="boolean" hint="Returns true if node1 is equal to or is a child of node 2">	
		<cfargument name="_node1" type="any" required="true">
		<cfargument name="_node2" type="any" required="true">
		<cfset var node1 = arguments._node1>
		<cfset var node2 = arguments._node2>
		<cfif not isObject(node1) or not isObject(node2)>
			<cflock name="#getLockName()#" type="readonly" timeout="#getLockTimeout()#">
				<cfif not isObject(node1)>
					<cfset node1 = loadNode(node1)>
				</cfif>
				<cfif not isObject(node2)>
					<cfset node2 = loadNode(node2)>
				</cfif>
			</cflock>			
		</cfif>
		<cfif not isValidNode(node1)>
			<cfthrow type="InvalidNode" message="IsChildOrEqual: Node #nodeToString(node1)# is invalid.">
		</cfif>
		<cfif not isValidNode(node2)>
			<cfthrow type="InvalidNode" message="IsChildOrEqual: Node #nodeToString(node2)# is invalid.">
		</cfif>
		<cfreturn (
				(node1.getTreeId() eq node2.getTreeId()) and
				(node1.getLeft() ge node2.getLeft()) and
				(node1.getRight() le node2.getRight())
			)>
	</cffunction>		

	<cffunction name="isEqual" output="false" returntype="boolean" hint="Returns true if node1 and node 2 represent the same node.">
		<cfargument name="_node1" type="any" required="true">
		<cfargument name="_node2" type="any" required="true">
		<cfset var node1 = arguments._node1>
		<cfset var node2 = arguments._node2>
		<cfif not isObject(node1) or not isObject(node2)>
			<cflock name="#getLockName()#" type="readonly" timeout="#getLockTimeout()#">
				<cfif not isObject(node1)>
					<cfset node1 = loadNode(node1)>
				</cfif>
				<cfif not isObject(node2)>
					<cfset node2 = loadNode(node2)>
				</cfif>
			</cflock>			
		</cfif>
		<cfif not isValidNode(node1)>
			<cfthrow type="InvalidNode" message="IsEqual: Node #nodeToString(node1)# is invalid.">
		</cfif>
		<cfif not isValidNode(node2)>
			<cfthrow type="InvalidNode" message="IsEqual: Node #nodeToString(node2)# is invalid.">
		</cfif>
		<cfreturn (
				(node1.getTreeId() eq node2.getTreeId()) and
				(node1.getId() eq node2.getId()) and
				(node1.getLeft() eq node2.getLeft()) and
				(node1.getRight() eq node2.getRight())
			)>
	</cffunction>		

	<!--- TREE NUMERIC FUNCTIONS --->
	<!--- The following functions return an integer value --->

	<cffunction name="numChildren" output="false" returntype="numeric" hint="Returns a count of all children in the subtree of the node.">
		<cfargument name="_node" type="any" required="true" hint="Type: struct|numeric.">
		<cfset var node = arguments._node>
		<cfif not isObject(node)>
			<cflock name="#getLockName()#" type="readonly" timeout="#getLockTimeout()#">
				<cfset node = loadNode(node)>
			</cflock>
		</cfif>
		<cfif not isValidNode(node)>
			<cfthrow type="InvalidNode" message="NumChildren: The specified node is invalid.">
		</cfif>
		<cfreturn ((node.getRight() - node.getLeft() - 1)/2)>
	</cffunction>

	<cffunction name="level" output="false" returntype="numeric" hint="Returns node level (root level = 0).">
		<cfargument name="_node" type="any" required="true">
		<cfset var q = "">
		<cfset var node = 0>
		<cflock name="#getLockName()#" type="readonly" timeout="#getLockTimeout()#">
			<cfset node = loadNode(arguments._node)>
			<cfif not isValidNode(node)>
				<cfthrow type="InvalidNode" message="Level: The specified node is invalid.">
			</cfif>
			<cfquery
				name="q"
				datasource="#variables.datasource.name#"
				username="#variables.datasource.username#"
				password="#variables.datasource.password#">
				select count(*) as level
				from #getTableName()#
				where
					#getTreeIdColName()# = <cfqueryparam cfsqltype="cf_sql_integer" value="#getTreeId()#">
					and #getLeftColName()# < <cfqueryparam cfsqltype="cf_sql_integer" value="#node.getLeft()#">
					and #getRightColName()# > <cfqueryparam cfsqltype="cf_sql_integer" value="#node.getRight()#">
			</cfquery>
		</cflock>
		<cfreturn q.level>
	</cffunction>

	<!--- TREE QUERY FUNCTIONS --->
	<!--- The following functions return a query --->

	<cffunction name="getSubtree" output="false" returntype="query" hint="Returns the subtree of the specified node.">
		<cfargument name="_node" type="any" required="true">
		<cfset var q = 0>
		<cfset var node = 0>
		<cflock name="#getLockName()#" type="readonly" timeout="#getLockTimeout()#">
			<cfset node = loadNode(arguments._node)>
			<cfif not isValidNode(node)>
				<cfthrow type="InvalidNode" message="GetSubtree: The specified node is invalid.">
			</cfif>
			<cfquery
				name="q"
				datasource="#variables.datasource.name#"
				username="#variables.datasource.username#"
				password="#variables.datasource.password#">
				select
					#getTreeIdColName()#,
					#getIdColName()#,
					#getLeftColName()#,
					#getRightColName()#
				from
					#getTableName()#
				where
					#getTreeIdColName()# = <cfqueryparam cfsqltype="cf_sql_integer" value="#getTreeId()#">
					and #getLeftColName()# >= <cfqueryparam cfsqltype="cf_sql_integer" value="#node.getLeft()#">
					and #getRightColName()# <= <cfqueryparam cfsqltype="cf_sql_integer" value="#node.getRight()#">
				order by
					#getLeftColName()#
			</cfquery>
		</cflock>
		<cfreturn q>
	</cffunction>

	<cffunction name="walkPreorder" output="false" returntype="query" hint="Returns a preorder walk of the tree">
		<cfset var q = 0>
		<cflock name="#getLockName()#" type="readonly" timeout="#getLockTimeout()#">
			<cfquery
				name="q"
				datasource="#variables.datasource.name#"
				username="#variables.datasource.username#"
				password="#variables.datasource.password#">
				select
					#getTreeIdColName()#,
					#getIdColName()#,
					#getLeftColName()#,
					#getRightColName()#
				from
					#getTableName()#
				where
					#getTreeIdColName()# = <cfqueryparam cfsqltype="cf_sql_integer" value="#getTreeId()#">
				order by
					#getLeftColName()#
			</cfquery>
		</cflock>
		<cfreturn q>
	</cffunction>

	<!--- PRIVATE FUNCTIONS --->

	<cffunction name="getTableName" output="false" access="private" returntype="string">
		<cfreturn variables.table.getTableName()>
	</cffunction>

	<cffunction name="getTreeIdColName" output="false" returntype="string" access="private">
		<cfreturn variables.table.getTreeIdColName()>
	</cffunction>

	<cffunction name="getIdColName" output="false" returntype="string" access="private">
		<cfreturn variables.table.getIdColName()>
	</cffunction>

	<cffunction name="getLeftColName" output="false" returntype="string" access="private">
		<cfreturn variables.table.getLeftColName()>
	</cffunction>

	<cffunction name="getRightColName" output="false" returntype="string" access="private">
		<cfreturn variables.table.getRightColName()>
	</cffunction>

	<cffunction name="createLockName" output="false" returntype="string" access="private" hint="Creates a lock name for this tree.">
		<cfreturn "NESTEDSETTREE-" & getTableName() & "-" & getTreeId()>
	</cffunction>
	
	<cffunction name="newNode" output="false" returntype="Node" access="private" hint="Creates a new node.">
		<cfargument name="id" type="numeric" required="false" default="0">
		<cfargument name="left" type="numeric" required="false" default="0">
		<cfargument name="right" type="numeric" required="false" default="0">
		<cfreturn createObject("component","Node").init(
									this,
									arguments.id,
									arguments.left,
									arguments.right
								)>
	</cffunction>

	<cffunction name="insertNew" output="false" returntype="Node" access="private" hint="Creates a new record.">
		<cfargument name="node" type="any" required="true">
		<cfquery
			datasource="#variables.datasource.name#"
			username="#variables.datasource.username#"
			password="#variables.datasource.password#">
			insert into #getTableName()#
			(
				#getTreeIdColName()#,
				#getIdColName()#,
				#getLeftColName()#,
				#getRightColName()#
			)
			values
			(
				<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.node.getTreeId()#">,
				<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.node.getId()#">,
				<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.node.getLeft()#">,
				<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.node.getRight()#">
			)
		</cfquery>
		<cfreturn arguments.node>
	</cffunction>

	<cffunction name="moveSubtree" output="false" returntype="struct" access="private" hint="Moves a subtree to a the target position">
		<cfargument name="src" type="Node" required="true" hint="The source node/subtree">
		<cfargument name="to" type="numeric" required="true" hint="The destination left-value">
		<cfset var newPos = "">
		<cfset var srcLeft = arguments.src.getLeft()>
		<cfset var srcRight = arguments.src.getRight()>
		<cfset var treeId = arguments.src.getTreeId()>
		<cfset var treeSize = srcRight - srcLeft + 1>
		<!--- make space in the destination range --->
		<cfset shiftRLValues(arguments.to,treeSize)>
		<!--- src was shifted too? --->
		<cfif srcLeft ge arguments.to>
			<cfset srcLeft = srcLeft + treeSize>
			<cfset srcRight = srcRight + treeSize>
		</cfif>
		<!--- now there's enough room next to target to move the subtree --->
	  	<cfset newPos = shiftRLRange(srcLeft, srcRight, arguments.to - srcLeft)>
	  	<!--- correct values after source --->
	  	<cfset shiftRLValues(srcRight + 1, -treeSize)>
	  	<!--- dst was shifted too? --->
	  	<cfif srcLeft le arguments.to>
		  	<cfset newPos.left = newpos.left - treesize>
		  	<cfset newPos.right = newpos.right - treesize>
		</cfif>
		<cfreturn newPos>
	</cffunction>

	<cffunction name="shiftRLRange" output="false" returntype="struct" access="private" hint="Adds 'delta' to all left and right values that are >= 'first' and <= 'last'. 'delta' can also be negative. Returns the shifted first/last values as struct.">
		<cfargument name="first" type="numeric" required="true">
		<cfargument name="last" type="numeric" required="true">
		<cfargument name="delta" type="numeric" required="true">
		<cfset var newPos = 0>
		<cfquery
			datasource="#variables.datasource.name#"
			username="#variables.datasource.username#"
			password="#variables.datasource.password#">
			update #getTableName()#
			set #getLeftColName()# = #getLeftColName()# + (#arguments.delta#)
			where
				#getTreeIdColName()# = <cfqueryparam cfsqltype="cf_sql_integer" value="#getTreeId()#">
				and #getLeftColName()# >= <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.first#">
				and #getLeftColName()# <= <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.last#">
		</cfquery>
		<cfquery
			datasource="#variables.datasource.name#"
			username="#variables.datasource.username#"
			password="#variables.datasource.password#">
			update #getTableName()#
			set #getRightColName()# = #getRightColName()# + (#arguments.delta#)
			where
				#getTreeIdColName()# = <cfqueryparam cfsqltype="cf_sql_integer" value="#getTreeId()#">
				and #getRightColName()# >= <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.first#">
				and #getRightColName()# <= <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.last#">
		</cfquery>
		<cfset newPos = structNew()>
		<cfset newPos.left = arguments.first + arguments.delta>
		<cfset newPos.right = arguments.last + arguments.delta>	
		<cfreturn newPos>
	</cffunction>

	<cffunction name="shiftRLValues" output="false" returntype="void" access="private" hint="Shifts the right and left index values after the position 'first'.">
		<cfargument name="first" type="numeric" required="true">
		<cfargument name="delta" type="numeric" required="true">
		<cfquery
			datasource="#variables.datasource.name#"
			username="#variables.datasource.username#"
			password="#variables.datasource.password#">
			update #getTableName()#
			set
				#getLeftColName()# = #getLeftColName()# + <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.delta#">
			where
				#getTreeIdColName()# = <cfqueryparam cfsqltype="cf_sql_integer" value="#getTreeId()#">
				and #getLeftColName()# >= <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.first#">
		</cfquery>
		<cfquery
			datasource="#variables.datasource.name#"
			username="#variables.datasource.username#"
			password="#variables.datasource.password#">
			update #getTableName()#
			set
				#getRightColName()# = #getRightColName()# + <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.delta#">
			where
				#getTreeIdColName()# = <cfqueryparam cfsqltype="cf_sql_integer" value="#getTreeId()#">
				and #getRightColName()# >= <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.first#">
		</cfquery>
	</cffunction>

	<cffunction name="nodeToString" output="false" returntype="String" access="private" hint="Returns a string representation of a node.">
		<cfargument name="node" type="Node" required="true">
		<cfreturn arguments.node.toStringValue()>
	</cffunction>

	<cffunction name="getNodeWhere" output="false" returntype="Node" access="private" hint="Returns the first node that matches the 'whereclause'. The WHERE-caluse can optionally contain ORDER BY or LIMIT clauses too.">
		<cfargument name="whereClause" type="string" required="true">
		<cfset var q = "">
		<cfset var id = 0>
		<cfset var lft = 0>
		<cfset var rgt = 0>
		<!--- Note that this query just returns the first row. --->
		<cfquery 
			name="q"
			maxrows="1"
			datasource="#variables.datasource.name#"
			username="#variables.datasource.username#"
			password="#variables.datasource.password#">
			select
				#getTreeIdColName()#,
				#getIdColName()#,
				#getLeftColName()#,
				#getRightColName()#
			from
				#getTableName()#
			where
				#getTreeIdColName()# = <cfqueryparam cfsqltype="cf_sql_integer" value="#getTreeId()#">
				and #preserveSingleQuotes(arguments.whereClause)#
		</cfquery>
		<cfif q.recordCount eq 1>
			<cfset id = q[getIdColName()]>
			<cfset lft = q[getLeftColName()]>
			<cfset rgt = q[getRightColName()]>
		</cfif>
		<cfreturn newNode(id,lft,rgt)>
	</cffunction>

	<cffunction name="getNodeWhereLeft" output="false" returntype="Node" access="private" hint="Returns the node that matches the left value 'left'.">
		<cfargument name="left" type="numeric" required="true">
		<cfreturn getNodeWhere(getLeftColName() & "=" & arguments.left)>
	</cffunction>

	<cffunction name="getNodeWhereRight" output="false" returntype="Node" access="private" hint="Returns the node that matches the right value 'right'.">
		<cfargument name="right" type="numeric" required="true">
		<cfreturn getNodeWhere(getRightColName() & "=" & arguments.right)>
	</cffunction>

	<cffunction name="loadNode" output="false" returntype="Node" access="private" hint="Returns a node.">
		<cfargument name="_node" type="any" required="true" hint="Type: Node|numeric">
		<cfset var node = 0>
		<cfif isObject(arguments._node)>
			<cfset node = arguments._node.reload()>
		<cfelseif isNumeric(arguments._node)>
			<cfset node = getNode(arguments._node)>
		<cfelse>
			<cfthrow type="InvalidNodeType" message="Cannot load node, it must be either a Node or an integer id value.">
		</cfif>
		<cfreturn node>
	</cffunction>

	<cffunction name="createIndexRecord" output="false" returntype="void" access="private" hint="Creates index builder records.">
		<cfargument name="config" type="struct" required="true">
		<cfargument name="nodeId" type="numeric" required="false" default="0">
		<cfset var cfg = arguments.config>
		<cfset var id = arguments.nodeId>
		<cfset var q = 0>
		<cfset var parentNode = 0>
		<cfset var childId = 0>
		<cfif id eq 0>
			<!--- If this is the first time this is being run then create a new root node. --->
			<cfset id = cfg.rootId>
			<cfset newRoot(id)>
			<cfset createIndexRecord(cfg,id)>
		<cfelse>
			<cfquery
				name="q"
				datasource="#variables.datasource.name#"
				username="#variables.datasource.username#"
				password="#variables.datasource.password#">
				select
					#cfg.primaryTableId#,
					#cfg.primaryTableParentId#
				from
					#cfg.primaryTable#
				where
					#cfg.primaryTableParentId# = <cfqueryparam cfsqltype="cf_sql_integer" value="#id#">
			</cfquery>
			<cfset parentNode = getNode(id)>
			<cfloop query="q">
				<cfset childId = q[cfg.primaryTableId][q.currentRow]>
				<cfset newLastChild(parentNode,childId)>
				<cfset createIndexRecord(cfg,childId)>
			</cfloop>
		</cfif>
	</cffunction>

</cfcomponent>

