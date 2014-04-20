component extends="voib.tests.src.baseTest" {
// TODO: tests for api for command creation and processing


	public void function setUp() {
	// we do not use setup since the context uses the request scope.
	}


	public void function testInit() {
		// is the correct type
		context = new voib.src.context();
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


	// you can set the logging level of the default logger
	// loglevel must be one of: debug|info|warn|error|fatal|nil
	/**
	* @mxunit:expectedException InvalidArgumentException
	*/
	public void function testSetLogLevel() {
		structDelete( request, 'voib' );
		context = new voib.src.context( loglevel='foobar');
	}


	// logging functions
	public void function testLogging() {
		structDelete( request, 'voib' );
		context = new voib.src.context(); // default loglevel is 'nil'
		assert( !context.isDebugEnabled() );
		assert( !context.isInfoEnabled() );
		assert( !context.isWarnEnabled() );
		assert( !context.isErrorEnabled() );
		assert( !context.isFatalEnabled() );

		structDelete( request, 'voib' );
		context = new voib.src.context( loglevel='debug' );
		assert( context.isDebugEnabled() );
		assert( context.isInfoEnabled() );
		assert( context.isWarnEnabled() );
		assert( context.isErrorEnabled() );
		assert( context.isFatalEnabled() );

		structDelete( request, 'voib' );
		context = new voib.src.context( loglevel='info' );
		assert( !context.isDebugEnabled() );
		assert( context.isInfoEnabled() );
		assert( context.isWarnEnabled() );
		assert( context.isErrorEnabled() );
		assert( context.isFatalEnabled() );

		structDelete( request, 'voib' );
		context = new voib.src.context( loglevel='warn' );
		assert( !context.isDebugEnabled() );
		assert( !context.isInfoEnabled() );
		assert( context.isWarnEnabled() );
		assert( context.isErrorEnabled() );
		assert( context.isFatalEnabled() );

		structDelete( request, 'voib' );
		context = new voib.src.context( loglevel='error' );
		assert( !context.isDebugEnabled() );
		assert( !context.isInfoEnabled() );
		assert( !context.isWarnEnabled() );
		assert( context.isErrorEnabled() );
		assert( context.isFatalEnabled() );

		structDelete( request, 'voib' );
		context = new voib.src.context( loglevel='fatal' );
		assert( !context.isDebugEnabled() );
		assert( !context.isInfoEnabled() );
		assert( !context.isWarnEnabled() );
		assert( !context.isErrorEnabled() );
		assert( context.isFatalEnabled() );
	}


	// command factory functions

	// can dispatch
	public void function testDefaultDispatch() {
		context = new voib.src.context();
		var result = context.dispatch(); // dispatch the default command
		assert( result );
		debug( result );
	}


	// newCommand can create Commands depending on the arguments provided:
	public void function testNewCommand() {
		// public any newCommand( any name, struct args, string access )

		// should create a default Command when no arguments are provided


		// if the first argument is a Command , returns it

		// if the first argument is a struct, should create a Command

		// if the first argument is an array of valid elements, should return an array of Commands

		// if the first argument is a string, should create a Command using the other arguments too

		// if none of the above, should create a default Command
		
	}


	// enstackCommand places command(s) on the top of the operating deque
	public void function testEnstackCommand() {

		// should create and place a default Command on top of the deque when no arguments are provided

		// if the first argument is a Command , should create and place it on top of the deque

		// if the first argument is a struct, should create a Command and place it on top of the deque

		// if the first argument is an array of valid elements, should create and place an array of Commands on top of the deque

		// if the first argument is a string, should create and place a Command on top of the deque using the other arguments too

		// if none of the above, should create and place a default Command on top of the deque


	}


	// enqueueCommand places command(s) on the top of the operating deque
	public void function testEnqueueCommand() {

		// should create and place a default Command on the bottom of the deque when no arguments are provided

		// if the first argument is a Command, should create and place it on the bottom of the deque

		// if the first argument is a struct, should create a Command and place it on the bottom of the deque

		// if the first argument is an array of valid elements, should create and place an array of Commands on the bottom of the deque

		// if the first argument is a string, should create and place a Command on the bottom of the deque using the other arguments too

		// if none of the above, should create and place a default Command on the bottom of the deque


	}


/*



	private createCommand
	private newCommands
	clearCommands
	dequeueCommand
	hasCommands
	destackCommand
	peekCommand
	sizeCommands



*/


	// candy data API

	public void function testMapHandlers() {
		fail( 'todo, or maybe not' );
		// setHandlers[]
		// then mapping
		// then hasHandlers
	}


}