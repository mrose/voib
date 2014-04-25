<cfcomponent
displayname="rendercomponentview"
extends="voib.src.handler.basehandler"
accessors="TRUE"
hint="renders output by delegating to a component view">

	<cfproperty type="boolean" name="inhibitDebugOutput" hint="inhibits debug output when true" />
	<cfproperty type="any" name="writerComponent" hint="dotted path to the component or an instantiated instancet" />
	<cfproperty type="string" name="writerMethod" hint="method to be called for rendering" />
	<cfproperty type="struct" name="writerArgs" hint="additional arguments to be provided to the invoked method" />


	<cffunction name="init" access="public" returntype="rendercomponentview" output="FALSE" >
		<cfargument name="inhibitDebugOutput" type="boolean" required="FALSE" />
		<cfargument name="writerComponent" type="any" required="FALSE" />
		<cfargument name="writerMethod" type="string" required="FALSE" />
		<cfargument name="writerArgs" type="struct" required="FALSE" />

		<cfset setInhibitDebugOutput( structKeyExists( arguments, 'inhibitDebugOutput' ) ? arguments.inhibitDebugOutput : FALSE ) />
		<cfset setWriterComponent( structKeyExists( arguments, 'writerComponent' ) ? arguments.writerComponent : '' ) />
		<cfset setWriterMethod( structKeyExists( arguments, 'writerMethod' ) ? arguments.writerMethod : '' ) />
		<cfset setWriterArgs( structKeyExists( arguments, 'writerArgs' ) ? arguments.writerargs : { } ) />

		<cfset super.init() />
		<cfreturn this />
	</cffunction>


	<cffunction name="execute" access="public" output="FALSE">
		<cfset var result = request['voib'] />
		<cfset var out = "" />
		<cfset var args = getWriterArgs() />
		<cfset structAppend( args, result, TRUE ) />
		<cfset var c = getWriterComponent() />

		<cfif !acceptable() >
			<cfreturn>
		</cfif>

		<cfif ( isSimpleValue( getWriterComponent() ) && !len( getWriterComponent() ) ) >
			<cfthrow type="Method.MissingProperty" message='writerComponent is not initialized' />
		</cfif>

		<cfif ( isSimpleValue( c ) ) >
			<cfset c = createObject( 'component', c ) />
		</cfif>

		<!--- this one's a transient --->
		<!--- cflock name="bleh" type="exclusive" timeout="0" --->
			<cfif ( getInhibitDebugOutput() ) >
				<cfsetting showdebugoutput="FALSE" />
			</cfif>
			<cfset getPageContext().getOut().ClearBuffer() />
			<cfinvoke component="#c#" method="#getWriterMethod()#" returnvariable="out" argumentcollection="#args#"/>
			<cfset setOutput( out ) />
		<!--- /cflock --->
	</cffunction>

</cfcomponent>