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

<!---
Before:
                  1
                 / \
                /   \
               /     \
              /       \
             /         \
            2           3
           / \         / \
          /   \       /   \
         4     5     6     7
        / \   / \   / \   / \
       8   9 10 11 12 13 14 15
--->

<cflock name="nstlock" type="exclusive" timeout="3">
	<cfset resetDatabase()>
</cflock>

<cfset nst = newNST()>
<cfset node = 0>
<cfset numThreads = 1000>
<cfset node1 = nst.newRoot(1)>
<cfset node2 = nst.newLastChild(node1,2)>
<cfset node3 = nst.newLastChild(node1,3)>
<cfset node4 = nst.newLastChild(node2,4)>
<cfset node5 = nst.newLastChild(node2,5)>
<cfset node6 = nst.newLastChild(node3,6)>
<cfset node7 = nst.newLastChild(node3,7)>
<cfset nst.newLastChild(node4,8)>
<cfset nst.newLastChild(node4,9)>
<cfset nst.newLastChild(node5,10)>
<cfset nst.newLastChild(node5,11)>
<cfset nst.newLastChild(node6,12)>
<cfset nst.newLastChild(node6,13)>
<cfset nst.newLastChild(node7,14)>
<cfset nst.newLastChild(node7,15)>

<cflog text="------ STARTING WITH #numThreads# THREADS ------">
	
<cfloop index="i" from="1" to="#numThreads#">
	<cfthread name="thread#i#" action="run" threadid="#i#">
		<cfset sleep(500)>
		<cfset nst.moveToNextSibling(node2,node3)>
		<cfset sleep(500)>
		<cfset nst.moveToNextSibling(node3,node2)>
		<cfset sleep(500)>
		<cfset nst.moveToLastChild(node2,node3)>
		<cfset sleep(500)>
		<cfset nst.moveToFirstChild(node2,node1)>
		<cfset sleep(500)>
	</cfthread>
</cfloop>

