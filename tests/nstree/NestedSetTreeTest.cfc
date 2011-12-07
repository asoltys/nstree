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

	<cffunction name="setUp" output="false" access="public" returntype="void">
		<cfset resetDatabase()>
	</cffunction>

	<!-------------------------------------------------------------------
	TESTS
	-------------------------------------------------------------------->

	<cffunction name="testLockName" output="false">
		<cfset var nst1 = newNST(1)>
		<cfset var nst2 = newNST(2)>
		<cfset assertEquals(nst1.getLockName(),"NESTEDSETTREE-testnst-1")>
		<cfset assertEquals(nst2.getLockName(),"NESTEDSETTREE-testnst-2")>
		<cfset nst2.setLockName("alternatelockname")>
		<cfset assertEquals(nst2.getLockName(),"alternatelockname")>
	</cffunction>

	<cffunction name="testLockNameTimeout" output="false">
		<cfset var nst1 = newNST(1)>
		<cfset var nst2 = newNST(2)>
		<cfset assertEquals(nst1.getLockTimeout(),3)>
		<cfset assertEquals(nst2.getLockTimeout(),3)>
		<cfset nst2.setLockTimeout(5)>
		<cfset assertEquals(nst2.getLockTimeout(),5)>
	</cffunction>

	<cffunction name="testNewRootForOneTree" output="false">
		<cfset var nst = newNST()>
		<cfset nst.newRoot(1)>
		<cfset assertTrue(assertDatabaseState(
						array(
							array(1,1,1,2)
						)
					))>
	</cffunction>

	<cffunction name="testMultipleRootsForOneTree" output="false">
		<cfset var nst = newNST()>
		<cfset var errorCaught = false>
		<cfset nst.newRoot(1)>
		<cftry>
			<cfset nst.newRoot(2)>
			<cfcatch type="MultipleRoot">
				<cfset var errorCaught = true>
			</cfcatch>
		</cftry>
		<cfreturn errorCaught>
	</cffunction>

	<cffunction name="testRootForOneTree" output="false">
		<cfset var nst = newNST()>
		<cfset var root = 0>
		<cfset nst.newRoot(1)>
		<cfset root = nst.root()>
		<cfset assertTrue(root.getTreeId() eq 1)>
		<cfset assertTrue(root.getId() eq 1)>
		<cfset assertTrue(root.getLeft() eq 1)>
		<cfset assertTrue(root.getRight() eq 2)>
	</cffunction>

	<cffunction name="testNewFirstChild" output="false">
		<cfset var nst = newNST()>
		<cfset var root = nst.newRoot(1)>
		<cfset nst.newFirstChild(root,2)>
		<cfset assertTrue(assertDatabaseState(
						array(
							array(1,1,1,4),
							array(1,2,2,3)
						)
					))>
	</cffunction>

	<cffunction name="testNewFirstChildById" output="false">
		<cfset var nst = newNST()>
		<cfset var root = nst.newRoot(1)>
		<cfset nst.newFirstChild(1,2)>
		<cfset assertTrue(assertDatabaseState(
						array(
							array(1,1,1,4),
							array(1,2,2,3)
						)
					))>
	</cffunction>

	<cffunction name="testNewFirstChildNode" output="false">
		<cfset var nst = newNST()>
		<cfset var root = nst.newRoot(1)>
		<cfset var node = nst.newFirstChild(root,2)>
		<cfset assertTrue(node.getTreeId() eq 1)>
		<cfset assertTrue(node.getId() eq 2)>
		<cfset assertTrue(node.getLeft() eq 2)>
		<cfset assertTrue(node.getRight() eq 3)>
	</cffunction>

	<cffunction name="testNewFirstChildTwoChildren" output="false">
		<cfset var nst = newNST()>
		<cfset nst.newRoot(1)>
		<cfset nst.newFirstChild(nst.root(1),2)>
		<cfset nst.newFirstChild(nst.root(1),3)>
		<cfset assertTrue(assertDatabaseState(
						array(
							array(1,1,1,6),
							array(1,2,4,5),
							array(1,3,2,3)
						)
					))>
	</cffunction>

	<cffunction name="testNewFirstChildThreeChildren" output="false">
		<cfset var nst = newNST()>
		<cfset var root = nst.newRoot(1)>
		<cfset nst.newFirstChild(root,2)>
		<cfset nst.newFirstChild(root,3)>
		<cfset nst.newFirstChild(root,4)>
		<cfset assertTrue(assertDatabaseState(
						array(
							array(1,1,1,8),
							array(1,2,6,7),
							array(1,3,4,5),
							array(1,4,2,3)
						)
					))>
	</cffunction>

	<cffunction name="testNewFirstChildFiveNodes" output="false">
		<cfset var nst = newNST()>
		<cfset var node1 = 0>
		<cfset var node2 = 0>
		<cfset var node3 = 0>
		<cfset var node4 = 0>
		<cfset var node5 = 0>
		<cfset node1 = nst.newRoot(1)>
		<cfset node2 = nst.newFirstChild(node1,2)>
		<cfset node3 = nst.newFirstChild(node2,3)>
		<cfset node4 = nst.newLastChild(node2,4)>
		<cfset node5 = nst.newLastChild(node1,5)>
		<cfset assertTrue(assertDatabaseState(
						array(
							array(1,1,1,10),
							array(1,2,2,7),
							array(1,3,3,4),
							array(1,4,5,6),
							array(1,5,8,9)
						)
					))>
	</cffunction>

	<cffunction name="testNewLastChild" output="false">
		<cfset var nst = newNST()>
		<cfset nst.newRoot(1)>
		<cfset nst.newLastChild(nst.root(1),2)>
		<cfset assertTrue(assertDatabaseState(
						array(
							array(1,1,1,4),
							array(1,2,2,3)
						)
					))>
	</cffunction>

	<cffunction name="testNewLastChildById" output="false">
		<cfset var nst = newNST()>
		<cfset nst.newRoot(1)>
		<cfset nst.newLastChild(1,2)>
		<cfset assertTrue(assertDatabaseState(
						array(
							array(1,1,1,4),
							array(1,2,2,3)
						)
					))>
	</cffunction>

	<cffunction name="testNewLastChildNode" output="false">
		<cfset var nst = newNST()>
		<cfset var root = nst.newRoot(1)>
		<cfset var node = nst.newLastChild(root,2)>
		<cfset node = nst.newLastChild(root,3)>
		<cfset assertTrue(node.getTreeId() eq 1)>
		<cfset assertTrue(node.getId() eq 3)>
		<cfset assertTrue(node.getLeft() eq 4)>
		<cfset assertTrue(node.getRight() eq 5)>
	</cffunction>

	<cffunction name="testNewLastChildTwice" output="false">
		<cfset var nst = newNST()>
		<cfset var root = nst.newRoot(1)>
		<cfset nst.newLastChild(root,2)>
		<cfset nst.newLastChild(root,3)>
		<cfset assertTrue(assertDatabaseState(
						array(
							array(1,1,1,6),
							array(1,2,2,3),
							array(1,3,4,5)
						)
					))>
	</cffunction>

	<cffunction name="testNewLastChildNewFirstChild" output="false">
		<cfset var nst = newNST()>
		<cfset var root = nst.newRoot(1)>
		<cfset nst.newLastChild(root,2)>
		<cfset nst.newFirstChild(root,3)>
		<cfset assertTrue(assertDatabaseState(
						array(
							array(1,1,1,6),
							array(1,2,4,5),
							array(1,3,2,3)
						)
					))>
	</cffunction>

	<cffunction name="testGetNode" output="false">
		<cfset var nst = newNST()>
		<cfset var node = 0>
		<cfset var root = nst.newRoot(1)>
		<cfset nst.newFirstChild(root,2)>
		<cfset nst.newLastChild(root,3)>
		<cfset node = nst.getNode(2)>
		<cfset assertTrue(node.getId() eq 2)>
		<cfset assertTrue(node.getLeft() eq 2)>
		<cfset assertTrue(node.getRight() eq 3)>
	</cffunction>

	<cffunction name="testGetNodeFromDifferentTrees" output="false">
		<cfset var nst1 = newNST(1)>
		<cfset var nst2 = newNST(2)>
		<cfset var node = 0>
		<cfset var root1 = nst1.newRoot(1)>
		<cfset var root2 = nst2.newRoot(2)>
		<cfset nst1.newFirstChild(root1,2)>
		<cfset nst1.newLastChild(root1,3)>
		<cfset nst2.newFirstChild(root2,4)>
		<cfset nst2.newLastChild(root2,5)>
		<cfset node = nst1.getNode(2)>
		<cfset assertTrue(node.getTreeId() eq 1)>
		<cfset assertTrue(node.getId() eq 2)>
		<cfset assertTrue(node.getLeft() eq 2)>
		<cfset assertTrue(node.getRight() eq 3)>
		<cfset node = nst2.getNode(5)>
		<cfset assertTrue(node.getTreeId() eq 2)>
		<cfset assertTrue(node.getId() eq 5)>
		<cfset assertTrue(node.getLeft() eq 4)>
		<cfset assertTrue(node.getRight() eq 5)>
	</cffunction>

	<cffunction name="testMissingNode" output="false">
		<cfset var nst = newNST(1)>
		<cfset var node = 0>
		<cfset var root = nst.newRoot(1)>
		<cfset nst.newFirstChild(root,2)>
		<cfset nst.newLastChild(root,3)>
		<cfset node = nst.getNode(4)>
		<cfset assertEquals(node.getTreeId(),1)>
		<cfset assertEquals(node.getId(),0)>
		<cfset assertEquals(node.getLeft(),0)>
		<cfset assertEquals(node.getRight(),0)>
	</cffunction>

	<cffunction name="testNewPrevSibling" output="false">
		<cfset var nst = newNST(1)>
		<cfset var node = 0>
		<cfset var root = nst.newRoot(1)>
		<cfset nst.newLastChild(root,2)>
		<cfset nst.newLastChild(root,3)>
		<cfset node = nst.getNode(3)>
		<cfset nst.newPrevSibling(node,4)>
		<cfset assertTrue(assertDatabaseState(
						array(
							array(1,1,1,8),
							array(1,2,2,3),
							array(1,3,6,7),
							array(1,4,4,5)
						)
					))>
	</cffunction>

	<cffunction name="testNewPrevSiblingById" output="false">
		<cfset var nst = newNST(1)>
		<cfset var node = 0>
		<cfset var root = nst.newRoot(1)>
		<cfset nst.newLastChild(1,2)>
		<cfset nst.newLastChild(1,3)>
		<cfset nst.newPrevSibling(3,4)>
		<cfset assertTrue(assertDatabaseState(
						array(
							array(1,1,1,8),
							array(1,2,2,3),
							array(1,3,6,7),
							array(1,4,4,5)
						)
					))>
	</cffunction>

	<cffunction name="testNewPrevSiblingTwice" output="false">
		<cfset var nst = newNST(1)>
		<cfset var node = 0>
		<cfset var root = nst.newRoot(1)>
		<cfset nst.newLastChild(root,2)>
		<cfset nst.newLastChild(root,3)>
		<cfset node = nst.getNode(3)>
		<cfset nst.newPrevSibling(node,4)>
		<cfset nst.newPrevSibling(node,5)>
		<cfset assertTrue(assertDatabaseState(
						array(
							array(1,1,1,10),
							array(1,2,2,3),
							array(1,3,8,9),
							array(1,4,4,5),
							array(1,5,6,7)
						)
					))>
	</cffunction>

	<cffunction name="testNewNextSibling" output="false">
		<cfset var node = 0>
		<cfset var nst = newNST(1)>
		<cfset var root = nst.newRoot(1)>
		<cfset nst.newLastChild(root,2)>
		<cfset nst.newLastChild(root,3)>
		<cfset node = nst.getNode(2)>
		<cfset nst.newNextSibling(node,4)>
		<cfset assertTrue(assertDatabaseState(
						array(
							array(1,1,1,8),
							array(1,2,2,3),
							array(1,3,6,7),
							array(1,4,4,5)
						)
					))>
	</cffunction>

	<cffunction name="testNewNextSiblingById" output="false">
		<cfset var node = 0>
		<cfset var nst = newNST(1)>
		<cfset var root = nst.newRoot(1)>
		<cfset nst.newLastChild(1,2)>
		<cfset nst.newLastChild(1,3)>
		<cfset nst.newNextSibling(2,4)>
		<cfset assertTrue(assertDatabaseState(
						array(
							array(1,1,1,8),
							array(1,2,2,3),
							array(1,3,6,7),
							array(1,4,4,5)
						)
					))>
	</cffunction>

	<cffunction name="testNewNextSiblingTwice" output="false">
		<cfset var node = 0>
		<cfset var nst = newNST(1)>
		<cfset var root = nst.newRoot(1)>
		<cfset nst.newLastChild(root,2)>
		<cfset nst.newLastChild(root,3)>
		<cfset node = nst.getNode(2)>
		<cfset nst.newNextSibling(node,4)>
		<cfset nst.newNextSibling(node,5)>
		<cfset assertTrue(assertDatabaseState(
						array(
							array(1,1,1,10),
							array(1,2,2,3),
							array(1,3,8,9),
							array(1,4,6,7),
							array(1,5,4,5)
						)
					))>
	</cffunction>

	<cffunction name="testMoveToNextSibling" output="false">
		<cfset var nst = newNST(1)>
		<cfset var node1 = 0>
		<cfset var node2 = 0>
		<cfset var node3 = 0>
		<cfset var node4 = 0>
		<cfset var node5 = 0>
		<cfset node1 = nst.newRoot(1)>
		<cfset node2 = nst.newFirstChild(node1,2)>
		<cfset node3 = nst.newFirstChild(node2,3)>
		<cfset node4 = nst.newLastChild(node2,4)>
		<cfset node5 = nst.newLastChild(node1,5)>
		<cfset nst.moveToNextSibling(node2,node5)>
		<cfset assertTrue(assertDatabaseState(
						array(
							array(1,1,1,10),
							array(1,2,4,9),
							array(1,3,5,6),
							array(1,4,7,8),
							array(1,5,2,3)
						)
					))>
	</cffunction>

	<cffunction name="testMoveToNextSiblingById" output="false">
		<cfset var nst = newNST(1)>
		<cfset var node1 = 0>
		<cfset var node2 = 0>
		<cfset var node3 = 0>
		<cfset var node4 = 0>
		<cfset var node5 = 0>
		<cfset node1 = nst.newRoot(1)>
		<cfset node2 = nst.newFirstChild(1,2)>
		<cfset node3 = nst.newFirstChild(2,3)>
		<cfset node4 = nst.newLastChild(2,4)>
		<cfset node5 = nst.newLastChild(1,5)>
		<cfset nst.moveToNextSibling(2,5)>
		<cfset assertTrue(assertDatabaseState(
						array(
							array(1,1,1,10),
							array(1,2,4,9),
							array(1,3,5,6),
							array(1,4,7,8),
							array(1,5,2,3)
						)
					))>
	</cffunction>

	<cffunction name="testMoveToPrevSibling" output="false">
		<cfset var nst = newNST(1)>
		<cfset var node1 = 0>
		<cfset var node2 = 0>
		<cfset var node5 = 0>
		<cfset node1 = nst.newRoot(1)>
		<cfset node5 = nst.newFirstChild(node1,5)>
		<cfset node2 = nst.newLastChild(node1,2)>
		<cfset nst.newFirstChild(node2,3)>
		<cfset nst.newLastChild(node2,4)>
		<cfset nst.moveToPrevSibling(node2,node5)>
		<cfset assertTrue(assertDatabaseState(
						array(
							array(1,1,1,10),
							array(1,2,2,7),
							array(1,3,3,4),
							array(1,4,5,6),
							array(1,5,8,9)
						)
					))>
	</cffunction>

	<cffunction name="testMoveToPrevSiblingById" output="false">
		<cfset var nst = newNST(1)>
		<cfset var node1 = 0>
		<cfset var node2 = 0>
		<cfset var node5 = 0>
		<cfset node1 = nst.newRoot(1)>
		<cfset node5 = nst.newFirstChild(1,5)>
		<cfset node2 = nst.newLastChild(1,2)>
		<cfset nst.newFirstChild(2,3)>
		<cfset nst.newLastChild(2,4)>
		<cfset nst.moveToPrevSibling(2,5)>
		<cfset assertTrue(assertDatabaseState(
						array(
							array(1,1,1,10),
							array(1,2,2,7),
							array(1,3,3,4),
							array(1,4,5,6),
							array(1,5,8,9)
						)
					))>
	</cffunction>

	<cffunction name="testMoveToFirstChild" output="false">
		<cfset var nst = newNST(1)>
		<cfset var node1 = 0>
		<cfset var node2 = 0>
		<cfset var node3 = 0>
		<cfset var node4 = 0>
		<cfset var node5 = 0>
		<cfset node1 = nst.newRoot(1)>
		<cfset node5 = nst.newFirstChild(node1,5)>
		<cfset node2 = nst.newLastChild(node1,2)>
		<cfset node3 = nst.newFirstChild(node2,3)>
		<cfset node4 = nst.newLastChild(node2,4)>
		<cfset nst.moveToFirstChild(node2,node5)>
		<cfset assertTrue(assertDatabaseState(
						array(
							array(1,1,1,10),
							array(1,2,3,8),
							array(1,3,4,5),
							array(1,4,6,7),
							array(1,5,2,9)
						)
					))>
	</cffunction>

	<cffunction name="testMoveToFirstChildById" output="false">
		<cfset var nst = newNST(1)>
		<cfset var node1 = 0>
		<cfset var node2 = 0>
		<cfset var node3 = 0>
		<cfset var node4 = 0>
		<cfset var node5 = 0>
		<cfset node1 = nst.newRoot(1)>
		<cfset node5 = nst.newFirstChild(1,5)>
		<cfset node2 = nst.newLastChild(1,2)>
		<cfset node3 = nst.newFirstChild(2,3)>
		<cfset node4 = nst.newLastChild(2,4)>
		<cfset nst.moveToFirstChild(2,5)>
		<cfset assertTrue(assertDatabaseState(
						array(
							array(1,1,1,10),
							array(1,2,3,8),
							array(1,3,4,5),
							array(1,4,6,7),
							array(1,5,2,9)
						)
					))>
	</cffunction>

	<cffunction name="testMoveToFirstChild2" output="false">
		<cfset var nst = newNST(1)>
		<cfset var node1 = 0>
		<cfset var node2 = 0>
		<cfset var node3 = 0>
		<cfset var node4 = 0>
		<cfset var node5 = 0>
		<cfset node1 = nst.newRoot(1)>
		<cfset node5 = nst.newFirstChild(node1,5)>
		<cfset node2 = nst.newLastChild(node1,2)>
		<cfset node3 = nst.newFirstChild(node2,3)>
		<cfset node4 = nst.newLastChild(node2,4)>
		<cfset nst.moveToFirstChild(node2,node1)>
		<cfset assertTrue(assertDatabaseState(
						array(
							array(1,1,1,10),
							array(1,2,2,7),
							array(1,3,3,4),
							array(1,4,5,6),
							array(1,5,8,9)
						)
					))>
	</cffunction>

	<cffunction name="testMoveToLastChild" output="false">
		<cfset var nst = newNST(1)>
		<cfset var node1 = 0>
		<cfset var node2 = 0>
		<cfset var node3 = 0>
		<cfset var node4 = 0>
		<cfset var node5 = 0>
		<cfset node1 = nst.newRoot(1)>
		<cfset node5 = nst.newFirstChild(node1,5)>
		<cfset node2 = nst.newLastChild(node1,2)>
		<cfset node3 = nst.newFirstChild(node2,3)>
		<cfset node4 = nst.newLastChild(node2,4)>
		<cfset node5 = nst.moveToLastChild(node2,node5)>
		<cfset assertTrue(assertDatabaseState(
						array(
							array(1,1,1,10),
							array(1,2,3,8),
							array(1,3,4,5),
							array(1,4,6,7),
							array(1,5,2,9)
						)
					))>
	</cffunction>

	<cffunction name="testMoveToLastChildById" output="false">
		<cfset var nst = newNST(1)>
		<cfset var node1 = 0>
		<cfset var node2 = 0>
		<cfset var node3 = 0>
		<cfset var node4 = 0>
		<cfset var node5 = 0>
		<cfset node1 = nst.newRoot(1)>
		<cfset node5 = nst.newFirstChild(1,5)>
		<cfset node2 = nst.newLastChild(1,2)>
		<cfset node3 = nst.newFirstChild(2,3)>
		<cfset node4 = nst.newLastChild(2,4)>
		<cfset node5 = nst.moveToLastChild(2,5)>
		<cfset assertTrue(assertDatabaseState(
						array(
							array(1,1,1,10),
							array(1,2,3,8),
							array(1,3,4,5),
							array(1,4,6,7),
							array(1,5,2,9)
						)
					))>
	</cffunction>

	<cffunction name="testMoveToLastChild2" output="false">
		<cfset var nst = newNST(1)>
		<cfset var node1 = 0>
		<cfset var node2 = 0>
		<cfset var node3 = 0>
		<cfset var node4 = 0>
		<cfset var node5 = 0>
		<cfset var node6 = 0>
		<cfset var node7 = 0>
		<cfset node1 = nst.newRoot(1)>
		<cfset node5 = nst.newFirstChild(node1,5)>
		<cfset node2 = nst.newLastChild(node1,2)>
		<cfset node3 = nst.newFirstChild(node2,3)>
		<cfset node4 = nst.newLastChild(node2,4)>
		<cfset node6 = nst.newFirstChild(node5,6)>
		<cfset node7 = nst.newLastChild(node5,7)>
		<cfset nst.moveToLastChild(node2,node5)>
		<cfset assertTrue(assertDatabaseState(
						array(
							array(1,1,1,14),
							array(1,2,7,12),
							array(1,3,8,9),
							array(1,4,10,11),
							array(1,5,2,13),
							array(1,6,3,4),
							array(1,7,5,6)
						)
					))>
	</cffunction>

	<cffunction name="testDeleteTree" output="false">
		<cfset var nst = newNST(1)>
		<cfset var root = nst.newRoot(1)>
		<cfset node = nst.root(1)>
		<cfset assertTrue(node.getLeft() eq 1)>
		<cfset assertTrue(node.getRight() eq 2)>
		<cfset nst.deleteTree()>
		<cfset node = nst.root(1)>
		<cfset assertTrue(node.getLeft() eq 0)>
		<cfset assertTrue(node.getRight() eq 0)>
	</cffunction>

	<cffunction name="testDeleteNode" output="false">
		<cfset var nst = newNST(1)>
		<cfset var node1 = 0>
		<cfset var node2 = 0>
		<cfset var node3 = 0>
		<cfset var node4 = 0>
		<cfset var node5 = 0>
		<cfset var node6 = 0>
		<cfset node1 = nst.newRoot(1)>
		<cfset node2 = nst.newLastChild(node1,2)>
		<cfset node3 = nst.newLastChild(node1,3)>
		<cfset node4 = nst.newLastChild(node2,4)>
		<cfset node5 = nst.newLastChild(node2,5)>
		<cfset node6 = nst.newLastChild(node2,6)>
		<cfset nst.delete(node2)>
		<cfset assertTrue(assertDatabaseState(
						array(
							array(1,1,1,4),
							array(1,3,2,3)
						)
					))>
	</cffunction>

	<cffunction name="testDeleteNodeById" output="false">
		<cfset var nst = newNST(1)>
		<cfset var node1 = 0>
		<cfset var node2 = 0>
		<cfset var node3 = 0>
		<cfset var node4 = 0>
		<cfset var node5 = 0>
		<cfset var node6 = 0>
		<cfset node1 = nst.newRoot(1)>
		<cfset node2 = nst.newLastChild(1,2)>
		<cfset node3 = nst.newLastChild(1,3)>
		<cfset node4 = nst.newLastChild(2,4)>
		<cfset node5 = nst.newLastChild(2,5)>
		<cfset node6 = nst.newLastChild(2,6)>
		<cfset nst.delete(2)>
		<cfset assertTrue(assertDatabaseState(
						array(
							array(1,1,1,4),
							array(1,3,2,3)
						)
					))>
	</cffunction>

	<cffunction name="testFirstChild" output="false">
		<cfset var nst = newNST(1)>
		<cfset var node = 0>
		<cfset nst.newRoot(1)>
		<cfset nst.newFirstChild(nst.root(),2)>
		<cfset nst.newFirstChild(nst.root(),3)>
		<cfset nst.newFirstChild(nst.root(),4)>
		<cfset node = nst.firstChild(nst.root())>
		<cfset assertTrue(node.getId() eq 4)>
	</cffunction>

	<cffunction name="testFirstChildById" output="false">
		<cfset var nst = newNST(1)>
		<cfset var node = 0>
		<cfset nst.newRoot(1)>
		<cfset nst.newFirstChild(1,2)>
		<cfset nst.newFirstChild(1,3)>
		<cfset nst.newFirstChild(1,4)>
		<cfset node = nst.firstChild(1)>
		<cfset assertTrue(node.getId() eq 4)>
	</cffunction>

	<cffunction name="testLastChild" output="false">
		<cfset var nst = newNST(1)>
		<cfset var node = 0>
		<cfset nst.newRoot(1)>
		<cfset nst.newFirstChild(nst.root(),2)>
		<cfset nst.newFirstChild(nst.root(),3)>
		<cfset nst.newFirstChild(nst.root(),4)>
		<cfset node = nst.lastChild(nst.root())>
		<cfset assertTrue(node.getId() eq 2)>
	</cffunction>

	<cffunction name="testLastChildById" output="false">
		<cfset var nst = newNST(1)>
		<cfset var node = 0>
		<cfset nst.newRoot(1)>
		<cfset nst.newFirstChild(1,2)>
		<cfset nst.newFirstChild(1,3)>
		<cfset nst.newFirstChild(1,4)>
		<cfset node = nst.lastChild(1)>
		<cfset assertTrue(node.getId() eq 2)>
	</cffunction>

	<cffunction name="testPrevSiblingById" output="false">
		<cfset var nst = newNST(1)>
		<cfset var node = 0>
		<cfset nst.newRoot(1)>
		<cfset nst.newFirstChild(1,2)>
		<cfset nst.newFirstChild(1,3)>
		<cfset nst.newFirstChild(1,4)>
		<cfset node = nst.prevSibling(3)>
		<cfset assertEquals(node.getId(),4)>
	</cffunction>

	<cffunction name="testPrevSibling1" output="false">
		<cfset var nst = newNST(1)>
		<cfset var node = 0>
		<cfset nst.newRoot(1)>
		<cfset nst.newFirstChild(nst.root(),2)>
		<cfset nst.newFirstChild(nst.root(),3)>
		<cfset nst.newFirstChild(nst.root(),4)>
		<cfset node = nst.prevSibling(nst.getNode(3))>
		<cfset assertEquals(node.getId(),4)>
	</cffunction>

	<cffunction name="testPrevSibling2" output="false">
		<cfset var nst = newNST(1)>
		<cfset var node = 0>
		<cfset nst.newRoot(1)>
		<cfset nst.newLastChild(nst.root(),2)>
		<cfset nst.newLastChild(nst.root(),3)>
		<cfset nst.newLastChild(nst.root(),4)>
		<cfset node = nst.prevSibling(nst.getNode(2))>
		<cfset assertEquals(node.getId(),0)>
	</cffunction>

	<cffunction name="testNextSibling1" output="false">
		<cfset var nst = newNST()>
		<cfset var node = 0>
		<cfset nst.newRoot(1)>
		<cfset nst.newFirstChild(nst.root(),2)>
		<cfset nst.newFirstChild(nst.root(),3)>
		<cfset nst.newFirstChild(nst.root(),4)>
		<cfset node = nst.nextSibling(nst.getNode(3))>
		<cfset assertEquals(node.getId(),2)>
	</cffunction>

	<cffunction name="testNextSiblingById" output="false">
		<cfset var nst = newNST()>
		<cfset var node = 0>
		<cfset nst.newRoot(1)>
		<cfset nst.newFirstChild(1,2)>
		<cfset nst.newFirstChild(1,3)>
		<cfset nst.newFirstChild(1,4)>
		<cfset node = nst.nextSibling(3)>
		<cfset assertEquals(node.getId(),2)>
	</cffunction>

	<cffunction name="testAncestorById" output="false">
		<cfset var nst = newNST(1)>
		<cfset var node = 0>
		<cfset nst.newRoot(1)>
		<cfset nst.newFirstChild(1,2)>
		<cfset nst.newFirstChild(1,3)>
		<cfset nst.newFirstChild(1,4)>
		<cfset node = nst.ancestor(3)>
		<cfset assertEquals(node.getId(),1)>
	</cffunction>

	<cffunction name="testAncestor1" output="false">
		<cfset var nst = newNST(1)>
		<cfset var node = 0>
		<cfset nst.newRoot(1)>
		<cfset nst.newFirstChild(nst.root(),2)>
		<cfset nst.newFirstChild(nst.root(),3)>
		<cfset nst.newFirstChild(nst.root(),4)>
		<cfset node = nst.ancestor(nst.getNode(3))>
		<cfset assertEquals(node.getId(),1)>
	</cffunction>

	<cffunction name="testAncestor2" output="false">
		<cfset var nst = newNST(1)>
		<cfset var node = 0>
		<cfset nst.newRoot(1)>
		<cfset nst.newFirstChild(nst.root(),2)>
		<cfset nst.newFirstChild(nst.root(),3)>
		<cfset nst.newFirstChild(nst.root(),4)>
		<cfset node = nst.ancestor(nst.getNode(1))>
		<cfset assertEquals(node.getId(),0)>
	</cffunction>

	<cffunction name="testIsValidNode" output="false">
		<cfset var nst = newNST(1)>
		<cfset var node = 0>
		<cfset nst.newRoot(1)>
		<cfset nst.newFirstChild(nst.root(),2)>
		<cfset nst.newFirstChild(nst.root(),3)>
		<cfset nst.newFirstChild(nst.root(),4)>
		<cfset assertTrue(nst.isValidNode(nst.getNode(2)))>
		<cfset assertFalse(nst.isValidNode(nst.getNode(5)))>
	</cffunction>

	<cffunction name="testHasAncestor" output="false">
		<cfset var nst = newNST(1)>
		<cfset var node = 0>
		<cfset nst.newRoot(1)>
		<cfset nst.newFirstChild(nst.root(),2)>
		<cfset nst.newFirstChild(nst.root(),3)>
		<cfset nst.newFirstChild(nst.root(),4)>
		<cfset assertTrue(nst.hasAncestor(nst.getNode(2)))>
		<cfset assertTrue(nst.hasAncestor(nst.getNode(3)))>
		<cfset assertTrue(nst.hasAncestor(nst.getNode(4)))>
		<cfset assertFalse(nst.hasAncestor(nst.getNode(1)))>
	</cffunction>

	<cffunction name="testHasAncestorById" output="false">
		<cfset var nst = newNST(1)>
		<cfset var node = 0>
		<cfset nst.newRoot(1)>
		<cfset nst.newFirstChild(nst.root(),2)>
		<cfset nst.newFirstChild(nst.root(),3)>
		<cfset nst.newFirstChild(nst.root(),4)>
		<cfset assertTrue(nst.hasAncestor(2))>
		<cfset assertTrue(nst.hasAncestor(3))>
		<cfset assertTrue(nst.hasAncestor(4))>
		<cfset assertFalse(nst.hasAncestor(1))>
	</cffunction>

	<cffunction name="testHasPrevSibling" output="false">
		<cfset var nst = newNST(1)>
		<cfset var node = 0>
		<cfset nst.newRoot(1)>
		<cfset nst.newLastChild(nst.root(),2)>
		<cfset nst.newLastChild(nst.root(),3)>
		<cfset nst.newLastChild(nst.root(),4)>
		<cfset assertTrue(nst.hasPrevSibling(nst.getNode(3)))>
		<cfset assertTrue(nst.hasPrevSibling(nst.getNode(4)))>
		<cfset assertFalse(nst.hasPrevSibling(nst.getNode(2)))>
		<cfset assertFalse(nst.hasPrevSibling(nst.getNode(1)))>
	</cffunction>

	<cffunction name="testHasPrevSiblingById" output="false">
		<cfset var nst = newNST(1)>
		<cfset var node = 0>
		<cfset nst.newRoot(1)>
		<cfset nst.newLastChild(1,2)>
		<cfset nst.newLastChild(1,3)>
		<cfset nst.newLastChild(1,4)>
		<cfset assertTrue(nst.hasPrevSibling(3))>
		<cfset assertTrue(nst.hasPrevSibling(4))>
		<cfset assertFalse(nst.hasPrevSibling(2))>
		<cfset assertFalse(nst.hasPrevSibling(1))>
	</cffunction>

	<cffunction name="testHasNextSibling" output="false">
		<cfset var nst = newNST()>
		<cfset var node = 0>
		<cfset nst.newRoot(1)>
		<cfset nst.newLastChild(nst.root(),2)>
		<cfset nst.newLastChild(nst.root(),3)>
		<cfset nst.newLastChild(nst.root(),4)>
		<cfset assertTrue(nst.hasNextSibling(nst.getNode(2)))>
		<cfset assertTrue(nst.hasNextSibling(nst.getNode(3)))>
		<cfset assertFalse(nst.hasNextSibling(nst.getNode(4)))>
		<cfset assertFalse(nst.hasNextSibling(nst.getNode(1)))>
	</cffunction>

	<cffunction name="testHasNextSiblingById" output="false">
		<cfset var nst = newNST()>
		<cfset var node = 0>
		<cfset nst.newRoot(1)>
		<cfset nst.newLastChild(1,2)>
		<cfset nst.newLastChild(1,3)>
		<cfset nst.newLastChild(1,4)>
		<cfset assertTrue(nst.hasNextSibling(2))>
		<cfset assertTrue(nst.hasNextSibling(3))>
		<cfset assertFalse(nst.hasNextSibling(4))>
		<cfset assertFalse(nst.hasNextSibling(1))>
	</cffunction>

	<cffunction name="testHasChildren" output="false">
		<cfset var nst = newNST()>
		<cfset var node = 0>
		<cfset nst.newRoot(1)>
		<cfset nst.newLastChild(nst.root(),2)>
		<cfset nst.newLastChild(nst.root(),3)>
		<cfset nst.newLastChild(nst.root(),4)>
		<cfset assertTrue(nst.hasChildren(nst.getNode(1)))>
		<cfset assertFalse(nst.hasChildren(nst.getNode(2)))>
		<cfset assertFalse(nst.hasChildren(nst.getNode(3)))>
		<cfset assertFalse(nst.hasChildren(nst.getNode(4)))>
	</cffunction>

	<cffunction name="testHasChildrenById" output="false">
		<cfset var nst = newNST()>
		<cfset var node = 0>
		<cfset nst.newRoot(1)>
		<cfset nst.newLastChild(nst.root(),2)>
		<cfset nst.newLastChild(nst.root(),3)>
		<cfset nst.newLastChild(nst.root(),4)>
		<cfset assertTrue(nst.hasChildren(1))>
		<cfset assertFalse(nst.hasChildren(2))>
		<cfset assertFalse(nst.hasChildren(3))>
		<cfset assertFalse(nst.hasChildren(4))>
	</cffunction>

	<cffunction name="testIsRoot" output="false">
		<cfset var nst = newNST(1)>
		<cfset var node = 0>
		<cfset nst.newRoot(1)>
		<cfset nst.newLastChild(nst.root(),2)>
		<cfset nst.newLastChild(nst.root(),3)>
		<cfset nst.newLastChild(nst.root(),4)>
		<cfset assertTrue(nst.isRoot(nst.getNode(1)))>
		<cfset assertFalse(nst.isRoot(nst.getNode(2)))>
		<cfset assertFalse(nst.isRoot(nst.getNode(3)))>
		<cfset assertFalse(nst.isRoot(nst.getNode(4)))>
	</cffunction>

	<cffunction name="testIsRootById" output="false">
		<cfset var nst = newNST(1)>
		<cfset var node = 0>
		<cfset nst.newRoot(1)>
		<cfset nst.newLastChild(nst.root(),2)>
		<cfset nst.newLastChild(nst.root(),3)>
		<cfset nst.newLastChild(nst.root(),4)>
		<cfset assertTrue(nst.isRoot(1))>
		<cfset assertFalse(nst.isRoot(2))>
		<cfset assertFalse(nst.isRoot(3))>
		<cfset assertFalse(nst.isRoot(4))>
	</cffunction>

	<cffunction name="testIsLeaf" output="false">
		<cfset var nst = newNST(1)>
		<cfset var node = 0>
		<cfset nst.newRoot(1)>
		<cfset nst.newLastChild(nst.root(),2)>
		<cfset nst.newLastChild(nst.root(),3)>
		<cfset nst.newLastChild(nst.root(),4)>
		<cfset assertFalse(nst.isLeaf(nst.getNode(1)))>
		<cfset assertTrue(nst.isLeaf(nst.getNode(2)))>
		<cfset assertTrue(nst.isLeaf(nst.getNode(3)))>
		<cfset assertTrue(nst.isLeaf(nst.getNode(4)))>
	</cffunction>

	<cffunction name="testIsLeafById" output="false">
		<cfset var nst = newNST(1)>
		<cfset var node = 0>
		<cfset nst.newRoot(1)>
		<cfset nst.newLastChild(nst.root(),2)>
		<cfset nst.newLastChild(nst.root(),3)>
		<cfset nst.newLastChild(nst.root(),4)>
		<cfset assertFalse(nst.isLeaf(1))>
		<cfset assertTrue(nst.isLeaf(2))>
		<cfset assertTrue(nst.isLeaf(3))>
		<cfset assertTrue(nst.isLeaf(4))>
	</cffunction>

	<cffunction name="testIsChild" output="false">
		<cfset var nst = newNST(1)>
		<cfset var node1 = 0>
		<cfset var node2 = 0>
		<cfset nst.newRoot(1)>
		<cfset nst.newLastChild(nst.root(),2)>
		<cfset nst.newLastChild(nst.root(),3)>
		<cfset nst.newLastChild(nst.root(),4)>
		<cfset nst.newLastChild(nst.getNode(2),5)>
		<cfset nst.newLastChild(nst.getNode(2),6)>
		<cfset nst.newLastChild(nst.getNode(2),7)>
		<cfset assertTrue(nst.isChild(nst.getNode(6),nst.getNode(1)))>
		<cfset assertTrue(nst.isChild(nst.getNode(6),nst.getNode(2)))>
		<cfset assertFalse(nst.isChild(nst.getNode(2),nst.getNode(2)))>
	</cffunction>

	<cffunction name="testIsChildById" output="false">
		<cfset var nst = newNST(1)>
		<cfset var node1 = 0>
		<cfset var node2 = 0>
		<cfset nst.newRoot(1)>
		<cfset nst.newLastChild(nst.root(),2)>
		<cfset nst.newLastChild(nst.root(),3)>
		<cfset nst.newLastChild(nst.root(),4)>
		<cfset nst.newLastChild(nst.getNode(2),5)>
		<cfset nst.newLastChild(nst.getNode(2),6)>
		<cfset nst.newLastChild(nst.getNode(2),7)>
		<cfset assertTrue(nst.isChild(6,1))>
		<cfset assertTrue(nst.isChild(6,2))>
		<cfset assertFalse(nst.isChild(2,2))>
	</cffunction>

	<cffunction name="testIsChildOrEqual" output="false">
		<cfset var nst = newNST(1)>
		<cfset var node1 = 0>
		<cfset var node2 = 0>
		<cfset nst.newRoot(1)>
		<cfset nst.newLastChild(nst.root(),2)>
		<cfset nst.newLastChild(nst.root(),3)>
		<cfset nst.newLastChild(nst.root(),4)>
		<cfset nst.newLastChild(nst.getNode(2),5)>
		<cfset nst.newLastChild(nst.getNode(2),6)>
		<cfset nst.newLastChild(nst.getNode(2),7)>
		<cfset assertTrue(nst.isChildOrEqual(nst.getNode(6),nst.getNode(1)))>
		<cfset assertTrue(nst.isChildOrEqual(nst.getNode(6),nst.getNode(2)))>
		<cfset assertTrue(nst.isChildOrEqual(nst.getNode(2),nst.getNode(1)))>
		<cfset assertTrue(nst.isChildOrEqual(nst.getNode(2),nst.getNode(2)))>
		<cfset assertFalse(nst.isChildOrEqual(nst.getNode(2),nst.getNode(6)))>
	</cffunction>

	<cffunction name="testIsChildOrEqualById" output="false">
		<cfset var nst = newNST(1)>
		<cfset var node1 = 0>
		<cfset var node2 = 0>
		<cfset nst.newRoot(1)>
		<cfset nst.newLastChild(nst.root(),2)>
		<cfset nst.newLastChild(nst.root(),3)>
		<cfset nst.newLastChild(nst.root(),4)>
		<cfset nst.newLastChild(nst.getNode(2),5)>
		<cfset nst.newLastChild(nst.getNode(2),6)>
		<cfset nst.newLastChild(nst.getNode(2),7)>
		<cfset assertTrue(nst.isChildOrEqual(6,1))>
		<cfset assertTrue(nst.isChildOrEqual(6,2))>
		<cfset assertTrue(nst.isChildOrEqual(2,1))>
		<cfset assertTrue(nst.isChildOrEqual(2,2))>
		<cfset assertFalse(nst.isChildOrEqual(2,6))>
	</cffunction>

	<cffunction name="testIsEqual" output="false">
		<cfset var nst = newNST(1)>
		<cfset var node1 = 0>
		<cfset var node2 = 0>
		<cfset nst.newRoot(1)>
		<cfset nst.newLastChild(nst.root(),2)>
		<cfset nst.newLastChild(nst.root(),3)>
		<cfset nst.newLastChild(nst.root(),4)>
		<cfset nst.newLastChild(nst.getNode(2),5)>
		<cfset nst.newLastChild(nst.getNode(2),6)>
		<cfset nst.newLastChild(nst.getNode(2),7)>
		<cfset assertTrue(nst.isEqual(nst.getNode(6),nst.getNode(6)))>
		<cfset assertFalse(nst.isEqual(nst.getNode(1),nst.getNode(2)))>
	</cffunction>

	<cffunction name="testIsEqualById" output="false">
		<cfset var nst = newNST(1)>
		<cfset var node1 = 0>
		<cfset var node2 = 0>
		<cfset nst.newRoot(1)>
		<cfset nst.newLastChild(nst.root(),2)>
		<cfset nst.newLastChild(nst.root(),3)>
		<cfset nst.newLastChild(nst.root(),4)>
		<cfset nst.newLastChild(nst.getNode(2),5)>
		<cfset nst.newLastChild(nst.getNode(2),6)>
		<cfset nst.newLastChild(nst.getNode(2),7)>
		<cfset assertTrue(nst.isEqual(6,6))>
		<cfset assertFalse(nst.isEqual(1,2))>
	</cffunction>

	<cffunction name="testNumChildren" output="false">
		<cfset var nst = newNST(1)>
		<cfset nst.newRoot(1)>
		<cfset nst.newLastChild(nst.root(),2)>
		<cfset nst.newLastChild(nst.root(),3)>
		<cfset nst.newLastChild(nst.root(),4)>
		<cfset nst.newLastChild(nst.getNode(2),5)>
		<cfset nst.newLastChild(nst.getNode(2),6)>
		<cfset nst.newLastChild(nst.getNode(2),7)>
		<cfset assertEquals(nst.numChildren(nst.getNode(1)),6)>
		<cfset assertEquals(nst.numChildren(nst.getNode(2)),3)>
		<cfset assertEquals(nst.numChildren(nst.getNode(3)),0)>
	</cffunction>

	<cffunction name="testNumChildrenById" output="false">
		<cfset var nst = newNST(1)>
		<cfset nst.newRoot(1)>
		<cfset nst.newLastChild(nst.root(),2)>
		<cfset nst.newLastChild(nst.root(),3)>
		<cfset nst.newLastChild(nst.root(),4)>
		<cfset nst.newLastChild(nst.getNode(2),5)>
		<cfset nst.newLastChild(nst.getNode(2),6)>
		<cfset nst.newLastChild(nst.getNode(2),7)>
		<cfset assertEquals(nst.numChildren(1),6)>
		<cfset assertEquals(nst.numChildren(2),3)>
		<cfset assertEquals(nst.numChildren(3),0)>
	</cffunction>

	<cffunction name="testLevel" output="false">
		<cfset var nst = newNST(1)>
		<cfset nst.newRoot(1)>
		<cfset nst.newLastChild(nst.root(),2)>
		<cfset nst.newLastChild(nst.root(),3)>
		<cfset nst.newLastChild(nst.root(),4)>
		<cfset nst.newLastChild(nst.getNode(2),5)>
		<cfset nst.newLastChild(nst.getNode(2),6)>
		<cfset nst.newLastChild(nst.getNode(2),7)>
		<cfset assertEquals(nst.level(nst.getNode(1)),0)>
		<cfset assertEquals(nst.level(nst.getNode(2)),1)>
		<cfset assertEquals(nst.level(nst.getNode(3)),1)>
		<cfset assertEquals(nst.level(nst.getNode(4)),1)>
		<cfset assertEquals(nst.level(nst.getNode(5)),2)>
		<cfset assertEquals(nst.level(nst.getNode(6)),2)>
		<cfset assertEquals(nst.level(nst.getNode(7)),2)>
	</cffunction>

	<cffunction name="testLevelById" output="false">
		<cfset var nst = newNST(1)>
		<cfset nst.newRoot(1)>
		<cfset nst.newLastChild(nst.root(),2)>
		<cfset nst.newLastChild(nst.root(),3)>
		<cfset nst.newLastChild(nst.root(),4)>
		<cfset nst.newLastChild(nst.getNode(2),5)>
		<cfset nst.newLastChild(nst.getNode(2),6)>
		<cfset nst.newLastChild(nst.getNode(2),7)>
		<cfset assertEquals(nst.level(1),0)>
		<cfset assertEquals(nst.level(2),1)>
		<cfset assertEquals(nst.level(3),1)>
		<cfset assertEquals(nst.level(4),1)>
		<cfset assertEquals(nst.level(5),2)>
		<cfset assertEquals(nst.level(6),2)>
		<cfset assertEquals(nst.level(7),2)>
	</cffunction>

	<cffunction name="testGetSubtree" output="false">
		<cfset var nst = newNST(1)>
		<cfset var subtree = 0>
		<cfset nst.newRoot(1)>
		<cfset nst.newLastChild(nst.root(),2)>
		<cfset nst.newLastChild(nst.root(),3)>
		<cfset nst.newLastChild(nst.root(),4)>
		<cfset nst.newLastChild(nst.getNode(2),5)>
		<cfset nst.newLastChild(nst.getNode(2),6)>
		<cfset nst.newLastChild(nst.getNode(2),7)>
		<cfset subtree = nst.getSubtree(nst.getNode(2))>
		<cfset assertTrue(compareQueryAndState(
						subtree,
						array(
							array(1,2,2,9),
							array(1,5,3,4),
							array(1,6,5,6),
							array(1,7,7,8)
						),
						false
					))>
	</cffunction>

	<cffunction name="testGetSubtreeById" output="false">
		<cfset var nst = newNST(1)>
		<cfset var subtree = 0>
		<cfset nst.newRoot(1)>
		<cfset nst.newLastChild(nst.root(),2)>
		<cfset nst.newLastChild(nst.root(),3)>
		<cfset nst.newLastChild(nst.root(),4)>
		<cfset nst.newLastChild(nst.getNode(2),5)>
		<cfset nst.newLastChild(nst.getNode(2),6)>
		<cfset nst.newLastChild(nst.getNode(2),7)>
		<cfset subtree = nst.getSubtree(2)>
		<cfset assertTrue(compareQueryAndState(
						subtree,
						array(
							array(1,2,2,9),
							array(1,5,3,4),
							array(1,6,5,6),
							array(1,7,7,8)
						),
						false
					))>
	</cffunction>

	<cffunction name="testWalkPreorder" output="false">
		<cfset var nst = newNST(1)>
		<cfset var walk = 0>
		<cfset nst.newRoot(1)>
		<cfset nst.newLastChild(nst.root(),2)>
		<cfset nst.newLastChild(nst.root(),3)>
		<cfset nst.newLastChild(nst.root(),4)>
		<cfset nst.newLastChild(nst.getNode(2),5)>
		<cfset nst.newLastChild(nst.getNode(2),6)>
		<cfset nst.newLastChild(nst.getNode(2),7)>
		<cfset walk = nst.walkPreorder()>
		<cfset assertTrue(assertDatabaseState(
						array(
							array(1,1,1,14),
							array(1,2,2,9),
							array(1,3,10,11),
							array(1,4,12,13),
							array(1,5,3,4),
							array(1,6,5,6),
							array(1,7,7,8)
						),
						false
					))>
	</cffunction>

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
		<cfargument name="id" default="1">
		<cfreturn newTable().getNestedSetTree(arguments.id)>
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

