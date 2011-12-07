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

	<cffunction name="setUp" output="false" access="public" returntype="void" hint="">
		<cfset resetDatabase()>
	</cffunction>

	<!-------------------------------------------------------------------
	TESTS
	-------------------------------------------------------------------->

	<cffunction name="testNewFirstChild" output="false">
		<cfset var nst = newNST()>
		<cfset var root = nst.newRoot(1)>
		<cfset root.newFirstChild(2)>
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
		<cfset var node = root.newFirstChild(2)>
		<cfset assertTrue(node.getTreeId() eq 1)>
		<cfset assertTrue(node.getId() eq 2)>
		<cfset assertTrue(node.getLeft() eq 2)>
		<cfset assertTrue(node.getRight() eq 3)>
	</cffunction>

	<cffunction name="testNewFirstChildTwoChildren" output="false">
		<cfset var nst = newNST()>
		<cfset var root = nst.newRoot(1)>
		<cfset root.newFirstChild(2)>
		<cfset root.newFirstChild(3)>
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
		<cfset root.newFirstChild(2)>
		<cfset root.newFirstChild(3)>
		<cfset root.newFirstChild(4)>
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
		<cfset node2 = node1.newFirstChild(2)>
		<cfset node3 = node2.newFirstChild(3)>
		<cfset node4 = node2.newLastChild(4)>
		<cfset node5 = node1.newLastChild(5)>
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
		<cfset var root = nst.newRoot(1)>
		<cfset root.newLastChild(2)>
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
		<cfset var node = root.newLastChild(2)>
		<cfset node = root.newLastChild(3)>
		<cfset assertTrue(node.getTreeId() eq 1)>
		<cfset assertTrue(node.getId() eq 3)>
		<cfset assertTrue(node.getLeft() eq 4)>
		<cfset assertTrue(node.getRight() eq 5)>
	</cffunction>

	<cffunction name="testNewLastChildTwice" output="false">
		<cfset var nst = newNST()>
		<cfset var root = nst.newRoot(1)>
		<cfset root.newLastChild(2)>
		<cfset root.newLastChild(3)>
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
		<cfset root.newLastChild(2)>
		<cfset root.newFirstChild(3)>
		<cfset assertTrue(assertDatabaseState(
						array(
							array(1,1,1,6),
							array(1,2,4,5),
							array(1,3,2,3)
						)
					))>
	</cffunction>

	<cffunction name="testNewPrevSibling" output="false">
		<cfset var nst = newNST(1)>
		<cfset var node = 0>
		<cfset var root = nst.newRoot(1)>
		<cfset node = root.newLastChild(2)>
		<cfset node = root.newLastChild(3)>
		<cfset node.newPrevSibling(4)>
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
		<cfset node = root.newLastChild(2)>
		<cfset node = root.newLastChild(3)>
		<cfset node.newPrevSibling(4)>
		<cfset node.newPrevSibling(5)>
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
		<cfset var node2 = 0>
		<cfset var node3 = 0>
		<cfset var nst = newNST(1)>
		<cfset var root = nst.newRoot(1)>
		<cfset node2 = root.newLastChild(2)>
		<cfset node3 = root.newLastChild(3)>
		<cfset node2.newNextSibling(4)>
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
		<cfset var node2 = 0>
		<cfset var node3 = 0>
		<cfset var nst = newNST(1)>
		<cfset var root = nst.newRoot(1)>
		<cfset node2 = nst.newLastChild(root,2)>
		<cfset node3 = nst.newLastChild(root,3)>
		<cfset node2.newNextSibling(4)>
		<cfset node2.newNextSibling(5)>
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
		<cfset node2 = node1.newFirstChild(2)>
		<cfset node3 = node2.newFirstChild(3)>
		<cfset node4 = node2.newLastChild(4)>
		<cfset node5 = node1.newLastChild(5)>
		<cfset node2.moveToNextSibling(node5)>
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
		<cfset node2 = node1.newFirstChild(2)>
		<cfset node3 = node2.newFirstChild(3)>
		<cfset node4 = node2.newLastChild(4)>
		<cfset node5 = node1.newLastChild(5)>
		<cfset node2.moveToNextSibling(5)>
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
		<cfset node5 = node1.newFirstChild(5)>
		<cfset node2 = node1.newLastChild(2)>
		<cfset node2.newFirstChild(3)>
		<cfset node2.newLastChild(4)>
		<cfset node2.moveToPrevSibling(node5)>
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
		<cfset node5 = node1.newFirstChild(5)>
		<cfset node2 = node1.newLastChild(2)>
		<cfset node2.newFirstChild(3)>
		<cfset node2.newLastChild(4)>
		<cfset node2.moveToPrevSibling(5)>
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
		<cfset node5 = node1.newFirstChild(5)>
		<cfset node2 = node1.newLastChild(2)>
		<cfset node3 = node2.newFirstChild(3)>
		<cfset node4 = node2.newLastChild(4)>
		<cfset node2.moveToFirstChild(node5)>
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
		<cfset node5 = node1.newFirstChild(5)>
		<cfset node2 = node1.newLastChild(2)>
		<cfset node3 = node2.newFirstChild(3)>
		<cfset node4 = node2.newLastChild(4)>
		<cfset node2.moveToFirstChild(5)>
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
		<cfset node5 = node1.newFirstChild(5)>
		<cfset node2 = node1.newLastChild(2)>
		<cfset node3 = node2.newFirstChild(3)>
		<cfset node4 = node2.newLastChild(4)>
		<cfset node2.moveToFirstChild(node1)>
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
		<cfset node5 = node1.newFirstChild(5)>
		<cfset node2 = node1.newLastChild(2)>
		<cfset node3 = node2.newFirstChild(3)>
		<cfset node4 = node2.newLastChild(4)>
		<cfset node5 = node2.moveToLastChild(node5)>
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

	<cffunction name="testMoveToLastChildId" output="false">
		<cfset var nst = newNST(1)>
		<cfset var node1 = 0>
		<cfset var node2 = 0>
		<cfset var node3 = 0>
		<cfset var node4 = 0>
		<cfset var node5 = 0>
		<cfset node1 = nst.newRoot(1)>
		<cfset node5 = node1.newFirstChild(5)>
		<cfset node2 = node1.newLastChild(2)>
		<cfset node3 = node2.newFirstChild(3)>
		<cfset node4 = node2.newLastChild(4)>
		<cfset node5 = node2.moveToLastChild(5)>
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
		<cfset node5 = node1.newFirstChild(5)>
		<cfset node2 = node1.newLastChild(2)>
		<cfset node3 = node2.newFirstChild(3)>
		<cfset node4 = node2.newLastChild(4)>
		<cfset node6 = node5.newFirstChild(6)>
		<cfset node7 = node5.newLastChild(7)>
		<cfset node2.moveToLastChild(node5)>
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

	<cffunction name="testDeleteNode" output="false">
		<cfset var nst = newNST(1)>
		<cfset var node1 = 0>
		<cfset var node2 = 0>
		<cfset var node3 = 0>
		<cfset var node4 = 0>
		<cfset var node5 = 0>
		<cfset var node6 = 0>
		<cfset node1 = nst.newRoot(1)>
		<cfset node2 = node1.newLastChild(2)>
		<cfset node3 = node1.newLastChild(3)>
		<cfset node4 = node2.newLastChild(4)>
		<cfset node5 = node2.newLastChild(5)>
		<cfset node6 = node2.newLastChild(6)>
		<cfset node2.delete()>
		<cfset assertTrue(assertDatabaseState(
						array(
							array(1,1,1,4),
							array(1,3,2,3)
						)
					))>
	</cffunction>

	<cffunction name="testFirstChild" output="false">
		<cfset var nst = newNST(1)>
		<cfset var node1 = 0>
		<cfset var node = 0>
		<cfset node1 = nst.newRoot(1)>
		<cfset node1.newFirstChild(2)>
		<cfset node1.newFirstChild(3)>
		<cfset node1.newFirstChild(4)>
		<cfset node = nst.root().firstChild()>
		<cfset assertTrue(node.getId() eq 4)>
	</cffunction>

	<cffunction name="testLastChild" output="false">
		<cfset var nst = newNST(1)>
		<cfset var node = 0>
		<cfset var root = nst.newRoot(1)>
		<cfset root.newFirstChild(2)>
		<cfset root.newFirstChild(3)>
		<cfset root.newFirstChild(4)>
		<cfset node = nst.root().lastChild()>
		<cfset assertTrue(node.getId() eq 2)>
	</cffunction>

	<cffunction name="testPrevSibling1" output="false">
		<cfset var nst = newNST(1)>
		<cfset var node = 0>
		<cfset var root = nst.newRoot(1)>
		<cfset root.newFirstChild(2)>
		<cfset root.newFirstChild(3)>
		<cfset root.newFirstChild(4)>
		<cfset node = nst.getNode(3).prevSibling()>
		<cfset assertEquals(node.getId(),4)>
	</cffunction>

	<cffunction name="testPrevSibling2" output="false">
		<cfset var nst = newNST(1)>
		<cfset var node = 0>
		<cfset var root = nst.newRoot(1)>
		<cfset root.newLastChild(2)>
		<cfset root.newLastChild(3)>
		<cfset root.newLastChild(4)>
		<cfset node = nst.getNode(2).prevSibling()>
		<cfset assertEquals(node.getId(),0)>
	</cffunction>

	<cffunction name="testNextSibling1" output="false">
		<cfset var nst = newNST()>
		<cfset var node = 0>
		<cfset var root = nst.newRoot(1)>
		<cfset root.newFirstChild(2)>
		<cfset root.newFirstChild(3)>
		<cfset root.newFirstChild(4)>
		<cfset node = nst.getNode(3).nextSibling()>
		<cfset assertEquals(node.getId(),2)>
	</cffunction>

	<cffunction name="testAncestor1" output="false">
		<cfset var nst = newNST(1)>
		<cfset var node = 0>
		<cfset var root = nst.newRoot(1)>
		<cfset root.newFirstChild(2)>
		<cfset root.newFirstChild(3)>
		<cfset root.newFirstChild(4)>
		<cfset node = nst.getNode(3).ancestor()>
		<cfset assertEquals(node.getId(),1)>
	</cffunction>

	<cffunction name="testAncestor2" output="false">
		<cfset var nst = newNST(1)>
		<cfset var node = 0>
		<cfset var root = nst.newRoot(1)>
		<cfset root.newFirstChild(2)>
		<cfset root.newFirstChild(3)>
		<cfset root.newFirstChild(4)>
		<cfset node = nst.getNode(1).ancestor()>
		<cfset assertEquals(node.getId(),0)>
	</cffunction>

	<cffunction name="testIsValidNode" output="false">
		<cfset var nst = newNST(1)>
		<cfset var node = 0>
		<cfset var root = nst.newRoot(1)>
		<cfset root.newFirstChild(2)>
		<cfset root.newFirstChild(3)>
		<cfset root.newFirstChild(4)>
		<cfset assertTrue(nst.getNode(2).isValidNode())>
		<cfset assertFalse(nst.getNode(5).isValidNode())>
	</cffunction>

	<cffunction name="testHasAncestor" output="false">
		<cfset var nst = newNST(1)>
		<cfset var node = 0>
		<cfset var root = nst.newRoot(1)>
		<cfset root.newFirstChild(2)>
		<cfset root.newFirstChild(3)>
		<cfset root.newFirstChild(4)>
		<cfset assertTrue(nst.getNode(2).hasAncestor())>
		<cfset assertTrue(nst.getNode(3).hasAncestor())>
		<cfset assertTrue(nst.getNode(4).hasAncestor())>
		<cfset assertFalse(nst.getNode(1).hasAncestor())>
	</cffunction>

	<cffunction name="testHasPrevSibling" output="false">
		<cfset var nst = newNST(1)>
		<cfset var node = 0>
		<cfset var root = nst.newRoot(1)>
		<cfset root.newLastChild(2)>
		<cfset root.newLastChild(3)>
		<cfset root.newLastChild(4)>
		<cfset assertTrue(nst.getNode(3).hasPrevSibling())>
		<cfset assertTrue(nst.getNode(4).hasPrevSibling())>
		<cfset assertFalse(nst.getNode(2).hasPrevSibling())>
		<cfset assertFalse(nst.getNode(1).hasPrevSibling())>
	</cffunction>

	<cffunction name="testHasNextSibling" output="false">
		<cfset var nst = newNST()>
		<cfset var node = 0>
		<cfset var root = nst.newRoot(1)>
		<cfset root.newLastChild(2)>
		<cfset root.newLastChild(3)>
		<cfset root.newLastChild(4)>
		<cfset assertTrue(nst.getNode(2).hasNextSibling())>
		<cfset assertTrue(nst.getNode(3).hasNextSibling())>
		<cfset assertFalse(nst.getNode(4).hasNextSibling())>
		<cfset assertFalse(nst.getNode(1).hasNextSibling())>
	</cffunction>

	<cffunction name="testHasChildren" output="false">
		<cfset var nst = newNST()>
		<cfset var node = 0>
		<cfset nst.newRoot(1)>
		<cfset nst.newLastChild(nst.root(),2)>
		<cfset nst.newLastChild(nst.root(),3)>
		<cfset nst.newLastChild(nst.root(),4)>
		<cfset assertTrue(nst.getNode(1).hasChildren())>
		<cfset assertFalse(nst.getNode(2).hasChildren())>
		<cfset assertFalse(nst.getNode(3).hasChildren())>
		<cfset assertFalse(nst.getNode(4).hasChildren())>
	</cffunction>

	<cffunction name="testIsRoot" output="false">
		<cfset var nst = newNST(1)>
		<cfset var node = 0>
		<cfset nst.newRoot(1)>
		<cfset nst.newLastChild(nst.root(),2)>
		<cfset nst.newLastChild(nst.root(),3)>
		<cfset nst.newLastChild(nst.root(),4)>
		<cfset assertTrue(nst.getNode(1).isRoot())>
		<cfset assertFalse(nst.getNode(2).isRoot())>
		<cfset assertFalse(nst.getNode(3).isRoot())>
		<cfset assertFalse(nst.getNode(4).isRoot())>
	</cffunction>

	<cffunction name="testIsLeaf" output="false">
		<cfset var nst = newNST(1)>
		<cfset var node = 0>
		<cfset nst.newRoot(1)>
		<cfset nst.newLastChild(nst.root(),2)>
		<cfset nst.newLastChild(nst.root(),3)>
		<cfset nst.newLastChild(nst.root(),4)>
		<cfset assertFalse(nst.getNode(1).isLeaf())>
		<cfset assertTrue(nst.getNode(2).isLeaf())>
		<cfset assertTrue(nst.getNode(3).isLeaf())>
		<cfset assertTrue(nst.getNode(4).isLeaf())>
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
		<cfset assertTrue(nst.getNode(6).isChild(nst.getNode(1)))>
		<cfset assertTrue(nst.getNode(6).isChild(nst.getNode(2)))>
		<cfset assertFalse(nst.getNode(2).isChild(nst.getNode(2)))>
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
		<cfset assertTrue(nst.getNode(6).isChildOrEqual(nst.getNode(1)))>
		<cfset assertTrue(nst.getNode(6).isChildOrEqual(nst.getNode(2)))>
		<cfset assertTrue(nst.getNode(2).isChildOrEqual(nst.getNode(1)))>
		<cfset assertTrue(nst.getNode(2).isChildOrEqual(nst.getNode(2)))>
		<cfset assertFalse(nst.getNode(2).isChildOrEqual(nst.getNode(6)))>
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
		<cfset assertTrue(nst.getNode(6).isChildOrEqual(1))>
		<cfset assertTrue(nst.getNode(6).isChildOrEqual(2))>
		<cfset assertTrue(nst.getNode(2).isChildOrEqual(1))>
		<cfset assertTrue(nst.getNode(2).isChildOrEqual(2))>
		<cfset assertFalse(nst.getNode(2).isChildOrEqual(6))>
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
		<cfset assertTrue(nst.getNode(6).isEqual(nst.getNode(6)))>
		<cfset assertFalse(nst.getNode(1).isEqual(nst.getNode(2)))>
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
		<cfset assertTrue(nst.getNode(6).isEqual(6))>
		<cfset assertFalse(nst.getNode(1).isEqual(2))>
	</cffunction>

	<cffunction name="testNumChildren" output="false">
		<cfset var nst = newNST(1)>
		<cfset nst.newRoot(1)>
		<cfset nst.newLastChild(nst.root(),2)>
		<!---
		<cfset nst.newLastChild(nst.root(),3)>
		<cfset nst.newLastChild(nst.root(),4)>
		<cfset nst.newLastChild(nst.getNode(2),5)>
		<cfset nst.newLastChild(nst.getNode(2),6)>
		<cfset nst.newLastChild(nst.getNode(2),7)>
		<cfset assertEquals(nst.getNode(1).numChildren(),6)>
		<cfset assertEquals(nst.getNode(2).numChildren(),3)>
		<cfset assertEquals(nst.getNode(3).numChildren(),0)>
		--->
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
		<cfset assertEquals(nst.getNode(1).level(),0)>
		<cfset assertEquals(nst.getNode(2).level(),1)>
		<cfset assertEquals(nst.getNode(3).level(),1)>
		<cfset assertEquals(nst.getNode(4).level(),1)>
		<cfset assertEquals(nst.getNode(5).level(),2)>
		<cfset assertEquals(nst.getNode(6).level(),2)>
		<cfset assertEquals(nst.getNode(7).level(),2)>
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
		<cfset subtree = nst.getNode(2).getSubtree()>
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

