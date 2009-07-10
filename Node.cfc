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

	<cfset variables.tree = 0>
	<cfset variables.id = 0>
	<cfset variables.left = 0>
	<cfset variables.right = 0>

	<cffunction name="init" output="false" returntype="Node">
		<cfargument name="tree" type="NestedSetTree" required="true">
		<cfargument name="id" type="numeric" required="false" default="0">
		<cfargument name="left" type="numeric" required="false" default="0">
		<cfargument name="right" type="numeric" required="false" default="0">
		<cfset setTree(arguments.tree)>
		<cfset setId(arguments.id)>
		<cfset setLeft(arguments.left)>
		<cfset setRight(arguments.right)>
		<cfreturn this>
	</cffunction>

	<cffunction name="toStruct" output="false" returntype="struct">
		<cfset var s = structNew()>
		<cfset s.treeId = getTreeId()>
		<cfset s.id = getId()>
		<cfset s.left = getLeft()>
		<cfset s.right = getRight()>
		<cfreturn s>
	</cffunction>

	<cffunction name="toStringValue" output="false" returntype="string">
		<cfreturn "{" & getTreeId() & "," & getId() & "," & getLeft() & "," & getRight() & "}">
	</cffunction>

	<cffunction name="getTree" output="false" returntype="NestedSetTree">
		<cfreturn variables.tree>
	</cffunction>

	<cffunction name="getTreeId" output="false" returntype="numeric">
		<cfreturn getTree().getTreeId()>
	</cffunction>

	<cffunction name="getId" output="false" returntype="numeric">
		<cfreturn variables.id>
	</cffunction>

	<cffunction name="getLeft" output="false" returntype="numeric">
		<cfreturn variables.left>
	</cffunction>

	<cffunction name="getRight" output="false" returntype="numeric">
		<cfreturn variables.right>
	</cffunction>

	<cffunction name="setTree" output="false" returntype="void">
		<cfargument name="tree" type="NestedSetTree" required="true">
		<cfset variables.tree = arguments.tree>
	</cffunction>

	<cffunction name="setId" output="false" returntype="void">
		<cfargument name="id" type="numeric" required="true">
		<cfset variables.id = arguments.id>
	</cffunction>

	<cffunction name="setLeft" output="false" returntype="void">
		<cfargument name="left" type="numeric" required="true">
		<cfset variables.left = arguments.left>
	</cffunction>

	<cffunction name="setRight" output="false" returntype="void">
		<cfargument name="right" type="numeric" required="true">
		<cfset variables.right = arguments.right>
	</cffunction>

	<cffunction name="reload" output="false" returntype="Node">
		<cfset var node = getTree().getNode(getId())>
		<cfset setLeft(node.getLeft())>
		<cfset setRight(node.getRight())>
		<cfreturn node>
	</cffunction>

	<cffunction name="invalidate" output="false" returntype="void">
		<cfset setLeft(0)>
		<cfset setRight(0)>
	</cffunction>

	<!--- PUBLIC TREE FUNCTIONS --->

	<cffunction name="newFirstChild" output="false" returntype="Node">
		<cfargument name="id" type="numeric" required="true">
		<cfreturn getTree().newFirstChild(this,arguments.id)>
	</cffunction>

	<cffunction name="newLastChild" output="false" returntype="Node">
		<cfargument name="id" type="numeric" required="true">
		<cfreturn getTree().newLastChild(this,arguments.id)>
	</cffunction>
	
	<cffunction name="newPrevSibling" output="false" returntype="Node">
		<cfargument name="id" type="numeric" required="true">
		<cfreturn getTree().newPrevSibling(this,arguments.id)>
	</cffunction>

	<cffunction name="newNextSibling" output="false" returntype="Node">
		<cfargument name="id" type="numeric" required="true">
		<cfreturn getTree().newNextSibling(this,arguments.id)>
	</cffunction>

	<cffunction name="moveToNextSibling" output="false" returntype="struct">
		<cfargument name="dst" type="any" required="true">
		<cfreturn getTree().moveToNextSibling(this,arguments.dst)>
	</cffunction>
	
	<cffunction name="moveToPrevSibling" output="false" returntype="struct">
		<cfargument name="dst" type="any" required="true">
		<cfreturn getTree().moveToPrevSibling(this,arguments.dst)>
	</cffunction>

	<cffunction name="moveToFirstChild" output="false" returntype="struct">
		<cfargument name="dst" type="any" required="true">
		<cfreturn getTree().moveToFirstChild(this,arguments.dst)>
	</cffunction>

	<cffunction name="moveToLastChild" output="false" returntype="struct">
		<cfargument name="dst" type="any" required="true">
		<cfreturn getTree().moveToLastChild(this,arguments.dst)>
	</cffunction>

	<cffunction name="delete" output="false" returntype="void">
		<cfset getTree().delete(this)>
	</cffunction>

	<cffunction name="firstChild" output="false" returntype="Node">
		<cfreturn getTree().firstChild(this)>
	</cffunction>
	
	<cffunction name="lastChild" output="false" returntype="Node">
		<cfreturn getTree().lastChild(this)>
	</cffunction>
	
	<cffunction name="prevSibling" output="false" returntype="Node">
		<cfreturn getTree().prevSibling(this)>
	</cffunction>

	<cffunction name="nextSibling" output="false" returntype="Node">
		<cfreturn getTree().nextSibling(this)>
	</cffunction>

	<cffunction name="ancestor" output="false" returntype="Node">
		<cfreturn getTree().ancestor(this)>
	</cffunction>

	<cffunction name="isValidNode" output="false" returntype="boolean">
		<cfreturn getTree().isValidNode(this)>
	</cffunction>

	<cffunction name="hasAncestor" output="false" returntype="boolean">
		<cfreturn getTree().hasAncestor(this)>
	</cffunction>

	<cffunction name="hasPrevSibling" output="false" returntype="boolean">
		<cfreturn getTree().hasPrevSibling(this)>
	</cffunction>

	<cffunction name="hasNextSibling" output="false" returntype="boolean">
		<cfreturn getTree().hasNextSibling(this)>
	</cffunction>

	<cffunction name="hasChildren" output="false" returntype="boolean">
		<cfreturn getTree().hasChildren(this)>
	</cffunction>
	
	<cffunction name="isRoot" output="false" returntype="boolean">
		<cfreturn getTree().isRoot(this)>
	</cffunction>
	
	<cffunction name="isLeaf" output="false" returntype="boolean">
		<cfreturn getTree().isLeaf(this)>
	</cffunction>

	<cffunction name="isChild" output="false" returntype="boolean">
		<cfargument name="node" type="Node" required="true">
		<cfreturn getTree().isChild(this,arguments.node)>
	</cffunction>

	<cffunction name="isChildOrEqual" output="false" returntype="boolean">
		<cfargument name="node" type="any" required="true">
		<cfreturn getTree().isChildOrEqual(this,arguments.node)>
	</cffunction>
	
	<cffunction name="isEqual" output="false" returntype="boolean">
		<cfargument name="node" type="any" required="true">
		<cfreturn getTree().isEqual(this,arguments.node)>
	</cffunction>

	<cffunction name="numChildren" output="false" returntype="numeric">
		<cfreturn getTree().numChildren(this)>
	</cffunction>
	
	<cffunction name="level" output="false" returntype="numeric">
		<cfreturn getTree().level(this)>
	</cffunction>

	<cffunction name="getSubtree" output="false" returntype="query">
		<cfreturn getTree().getSubtree(this)>
	</cffunction>

</cfcomponent>

