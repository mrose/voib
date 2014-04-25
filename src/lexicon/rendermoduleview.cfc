<cfcomponent
displayname="rendermoduleview"
extends="voib.src.handler.basehandler"
accessors="TRUE"
hint="renders output by delegating to an cfmodule view">

	<cfproperty type="boolean" name="inhibitDebugOutput" hint="inhibits debug output when true" />
	<cfproperty type="string" name="writerLocation" hint="absolute path to the included file used to write to output" />


	<cffunction name="init" access="public" returntype="rendermoduleview" output="FALSE" >
		<cfargument name="inhibitDebugOutput" type="boolean" required="FALSE" />
		<cfargument name="writerLocation" type="string" required="FALSE" />
		<cfset setInhibitDebugOutput( structKeyExists( arguments, 'inhibitDebugOutput' ) ? arguments.inhibitDebugOutput : FALSE ) />
		<cfset setWriterLocation( structKeyExists( arguments, 'writerLocation' ) ? arguments.writerLocation : '' ) />
		<cfset super.init() />
		<cfreturn this />
	</cffunction>


	<cffunction name="execute" access="public" output="FALSE">
		<cfset var result = request['voib'] />
		<cfset var out = "" />

		<cfif !acceptable() >
			<cfreturn>
		</cfif>

		<cfif ( !len( getWriterLocation() ) ) >
			<cfthrow type="Method.MissingProperty" message='writerLocation cannot be blank' />
		</cfif>

		<!--- this one's a transient --->
		<!--- cflock name="foo" type="exclusive" timeout="0" --->
			<cfif ( getInhibitDebugOutput() ) >
				<cfsetting showdebugoutput="FALSE" />
			</cfif>
			<cfset getPageContext().getOut().ClearBuffer() />
			<cfoutput><cfsavecontent variable="out"><cfmodule template="#getWriterLocation()#" result="#arguments.result#" /></cfsavecontent></cfoutput>
			<cfset setOutput( out ) />
		<!--- /cflock --->
	</cffunction>

</cfcomponent>