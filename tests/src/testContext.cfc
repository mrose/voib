component extends="voib.tests.src.baseTest" {


	public void function setUp() {
	// we do not use setup since the context uses the request scope.
	}


	public void function testInit() {
		// is the correct type
		var logger = new voib.src.requestLogger('debug'); 
		context = new voib.src.context( { 'logger'=logger, 'foo'='bar' } );
		assert( isInstanceOf( context, 'voib.src.context' ) );
		debug( context );
		debug( request );


		// has a mapping property
		assert( isInstanceOf( context.getMapping(), 'voib.src.mapping.basemapping' ) );

		// has a logger property
		assert( isInstanceOf( context.getLogger(), 'voib.src.logger' ) );

		// assures minimum control struct defaults exist in the request scope
		// uses provided args including any arbitrary keys and values in control struct instead of defaults
		assert( structKeyExists( request, 'voib' ) );
		assert( structKeyExists( request['voib'], 'data' ) );
		assert( structKeyExists( request['voib'], 'type' ) );
		assert( structKeyExists( request['voib'], 'message' ) );
		assert( structKeyExists( request['voib'], 'detail' ) );
		assert( structKeyExists( request['voib'], 'extendedInfo' ) );
		assert( structKeyExists( request['voib'], 'code' ) );
		assert( structKeyExists( request['voib'], 'severity' ) );
		assert( structKeyExists( request['voib'], 'invocationControl' ) );
		assert( structKeyExists( request['voib'], 'invocationDepth' ) );
		assert( structKeyExists( request['voib'], 'processingSequence' ) );
		assert( structKeyExists( request['voib'], 'executedCommands' ) );
		assert( structKeyExists( request['voib'], 'maximumCommands' ) );
		assert( structKeyExists( request['voib'], 'maximumDepth' ) );
		assert( structKeyExists( request['voib'], 'throwOnException' ) );
		assert( structKeyExists( request['voib'], 'output' ) );
		assert( structKeyExists( request['voib'], 'logger' ) );
		assert( structKeyExists( request['voib'], 'mapping' ) );
		assert( structKeyExists( request['voib'], 'id' ) );
		assert( structKeyExists( request['voib'], 'foo' ) );

		// assures reasonable default values are provided
		assert( isStruct( request['voib']['data'] ) );
		assert( request['voib']['message'] == 'OK' );
		assert( request['voib']['code'] == '200' );
		assert( request['voib']['severity'] == 'information' );
		assert( request['voib']['invocationControl'] == 'next' );
		assert( request['voib']['invocationDepth'] == '0' );
		assert( request['voib']['processingSequence'] == '0' );
		assert( isArray( request['voib']['executedCommands'] ) );
		assert( isNumeric( request['voib']['maximumCommands'] ) );
		assert( isNumeric( request['voib']['maximumDepth'] ) );
		assert( isBoolean( request['voib']['throwOnException'] ) );
		assert( isObject( request['voib']['logger'] ) );
		assert( isObject( request['voib']['mapping'] ) );
		assert( isValid( 'UUID', request['voib']['id'] ) );
		assert( request['voib']['foo'] == 'bar' );
	}


	// provides logging functions with the loglevel defined at initialization (defaults to 'nil')
	public void function testLogging() {
		structDelete( request, 'voib' );
		context = new voib.src.context();
		assert( !context.isDebugEnabled() );
		assert( !context.isInfoEnabled() );
		assert( !context.isWarnEnabled() );
		assert( !context.isErrorEnabled() );
		assert( !context.isFatalEnabled() );
	}


	// can dispatch
/*
	public void function testDefaultDispatch() {
		context = new voib.src.context();
		var result = context.dispatch();
		debug( result );
	}
*/

}