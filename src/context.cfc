component
displayname="voib.src.context"
accessors="TRUE"
hint="an invocation context" {


	property name="mapping" setter="FALSE";
	property name="logger" setter="FALSE"; // currently logging is a native function


	import voib.src.*;
//	import voib.src.di.*;
//	import voib.src.mapping.*;


	public context function init( struct args ) {
		params( structKeyExists( arguments, 'args' ) ? arguments.args : { } );
		variables.logger = new voib.src.logger( request['voib']['loglevel'] );
//		variables.mapping = new multicastmapping( request['voib']['registry'] );
		return this;
	}



	// dispatch or any verb? use onMissingMethod to make the verb a noun?
//	public any function dispatch() hint="takes multiple duck-typed arguments" {
	public any function onMissingMethod( missingMethodName, missingMethodArguments ) {


//		return getResult();
	}



	// ---------------------- API for logging ------------------------ //

	private string function logID() { return "[uid:#request['voib']['id']#] "; }

	public void function debug( required any message ) { getLogger().debug( logID() & arguments.message ); }
	public void function info( required any message )  { getLogger().info( logID() & arguments.message ); }
	public void function warn( required any message )  { getLogger().warn( logID() & arguments.message ); }
	public void function error( required any message ) { getLogger().error( logID() & arguments.message ); }
	public void function fatal( required any message ) { getLogger().fatal( logID() & arguments.message ); }

	public boolean function isDebugEnabled() { return getLogger().isDebugEnabled(); }
	public boolean function isInfoEnabled() { return getLogger().isInfoEnabled(); }
	public boolean function isWarnEnabled() { return getLogger().isWarnEnabled(); }
	public boolean function isErrorEnabled() { return getLogger().isErrorEnabled(); }
	public boolean function isFatalEnabled() { return getLogger().isFatalEnabled(); }



	private void function params( required struct args ) {
		if ( !structKeyExists( request, 'voib' ) ) {
			request['voib'] = args;
			param name="request['voib']['data']" default="#{ }#";
			param name="request['voib']['type']" default="";
			param name="request['voib']['message']" default="OK";
			param name="request['voib']['detail']" default="";
			param name="request['voib']['extendedInfo']" default="";
			param name="request['voib']['code']" default="200";
			param name="request['voib']['severity']" default="information";
			param name="request['voib']['invocationControl']" default="next";
			param name="request['voib']['invocationDepth']" default="0";
			param name="request['voib']['processingSequence']" default="0";
			param name="request['voib']['executedCommands']" default="#[ ]#";
			param name="request['voib']['maximumCommands']" default="100";
			param name="request['voib']['maximumDepth']" default="100";
			param name="request['voib']['throwOnException']" default="FALSE";
			param name="request['voib']['output']" default="";
			param name="request['voib']['loglevel']" default="debug";
			param name="request['voib']['registry']" default="#new voib.src.di.baseregistry()#";
			param name="request['voib']['id']" default="#createUUID()#";
		}
	}

}