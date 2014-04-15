component extends="voib.tests.src.baseTest" {
// TODO: tests for api for command creation and processing


	public void function setUp() {
	// we do not use setup since the context uses the request scope.
	}


	public void function testInit() {
		// is the correct type
		var logger = new voib.src.requestLogger('debug'); 
		context = new voib.src.context( { 'logger'=logger } );
		assert( isInstanceOf( context, 'voib.src.context' ) );
		debug( context );
		debug( request );

		// has a result property whose default is TRUE
		assert( context.getResult() );

		// has a mapping property of type voib.src.mapping.basemapping
		assert( isInstanceOf( context.getMapping(), 'voib.src.mapping.basemapping' ) );

		// has a logger property of type voib.src.logger
		assert( isInstanceOf( context.getLogger(), 'voib.src.logger' ) );

		// has a throwOnException property of type boolean
		assert( isBoolean( context.getThrowOnException() ) );

		// has global control elements exist in the request scope
		assert( structKeyExists( request, 'voib' ) );
		assert( structKeyExists( request['voib'], 'id' ) );
		assert( structKeyExists( request['voib'], 'code' ) );
		assert( structKeyExists( request['voib'], 'data' ) );
		assert( structKeyExists( request['voib'], 'executedCommands' ) );
		assert( structKeyExists( request['voib'], 'exceptions' ) );
		assert( structKeyExists( request['voib'], 'invocationControl' ) );
		assert( structKeyExists( request['voib'], 'invocationDepth' ) );
		assert( structKeyExists( request['voib'], 'maximumCommands' ) );
		assert( structKeyExists( request['voib'], 'maximumDepth' ) );
		assert( structKeyExists( request['voib'], 'message' ) );
		assert( structKeyExists( request['voib'], 'output' ) );
		assert( structKeyExists( request['voib'], 'processingSequence' ) );

		// assures reasonable default values are provided
		assert( isStruct( request['voib']['data'] ) );
		assert( isValid( 'UUID', request['voib']['id'] ) );
		assert( request['voib']['code'] == '200' );
		assert( isArray( request['voib']['executedCommands'] ) );
		assert( isArray( request['voib']['exceptions'] ) );
		assert( request['voib']['invocationControl'] == 'next' );
		assert( request['voib']['invocationDepth'] == '0' );
		assert( isNumeric( request['voib']['maximumCommands'] ) );
		assert( isNumeric( request['voib']['maximumDepth'] ) );
		assert( request['voib']['message'] == 'OK' );
		assert( request['voib']['processingSequence'] == '0' );
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



	public void function testMapHandlers() {
		fail( 'todo, or maybe not' );
		// setHandlers[]
		// then mapping
		// then hasHandlers
	}



	// can dispatch
	public void function testDefaultDispatch() {
		context = new voib.src.context();
		var result = context.dispatch();
		assert( result );
		debug( result );
	}


}