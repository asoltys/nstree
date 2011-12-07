<cfset request.event = structNew()>
<cfset structAppend(request.event,form)>
<cfset structAppend(request.event,url)>

<cfparam name="request.event.action" default="showtree">

<cfset categoryGateway = application.app.categoryGateway>

<cfswitch expression="#request.event.action#">
	<cfcase value="newnode">
		<cfparam name="request.event.categoryId" default="0">
		<cfinclude template="views/node.cfm">
	</cfcase>
	<cfcase value="savenode">
		<cfset cat = structNew()>
		<cfset cat.categoryId = request.event.categoryId>
		<cfset cat.parentCategoryId = request.event.parentCategoryId>
		<cfset cat.categoryName = request.event.name>
		<cfset categoryGateway.saveCategory(cat)>
		<cflocation url="index.cfm" addtoken="false">
	</cfcase>
	<cfcase value="deletenode">
		<cfset categoryGateway.deleteCategory(request.event.categoryId)>
		<cflocation url="index.cfm" addtoken="false">
	</cfcase>
	<cfcase value="moveup">
		<cfset categoryGateway.moveCategoryUp(request.event.categoryId)>
		<cflocation url="index.cfm" addtoken="false">
	</cfcase>
	<cfcase value="movedown">
		<cfset categoryGateway.moveCategoryDown(request.event.categoryId)>
		<cflocation url="index.cfm" addtoken="false">
	</cfcase>
	<cfcase value="move">
		<cfset categoryGateway.moveCategory(request.event.srcId,request.event.dstId)>
		<cflocation url="index.cfm" addtoken="false">
	</cfcase>
	<cfcase value="showtree">
		<cfinclude template="views/showtree.cfm">
	</cfcase>
	<cfcase value="rebuild">
		<cfset categoryGateway.rebuildCategoryIndex()>
		<cflocation url="index.cfm" addtoken="false">
	</cfcase>
	<cfcase value="reindex">
		<cfinclude template="views/reindex.cfm">
	</cfcase>
	<cfcase value="runReindex">
		<cfset indexer = createObject("component","com.Indexer").init(argumentCollection=request.event)>
		<cfset indexer.start()>
		<cfset data = structCopy(request.event)>
		<cfset structDelete(data,"action")>
		<cfset urlParams = "">
		<cfloop item="key" collection="#data#">
			<cfset urlParams = urlParams & "&" & lCase(key) & "=" & data[key]>
		</cfloop>
		<cflocation url="index.cfm?action=reindex#urlParams#" addtoken="false">
	</cfcase>
</cfswitch>

