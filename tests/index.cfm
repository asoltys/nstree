<cfparam name="url.output" default="extjs">
<cfinvoke
          component="mxunit.runner.DirectoryTestSuite"
          method="run"
          directory="#expandPath('/tests')#"
          componentPath="tests"
          recurse="true"
		  refreshcache="true"
          returnvariable="results" />

<cfoutput>#results.getResultsOutput(url.output)#</cfoutput>

