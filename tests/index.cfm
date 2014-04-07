<cfsetting showdebugoutput="false" />

<cfinvoke component="mxunit.runner.DirectoryTestSuite"
	method="run"
	directory="#expandPath('/voib/tests/src')#"
	componentPath="voib.tests.src"
	recurse="true"
	returnvariable="results" />

<cfoutput> #results.getResultsOutput('extjs')# </cfoutput>