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

		// has a registry property of type any
		assert( isValid( 'component', context.getRegistry() ) );

		// has a defaultHandlers property which defaults to an empty array
		assert( isArray( context.getDefaultHandlers() ) );
		assert( arrayIsEmpty( context.getDefaultHandlers() ) );

		// has a logger property of type voib.src.logger
		assert( isInstanceOf( context.getLogger(), 'voib.src.logger' ) );

		// has a throwOnException property of type boolean
		assert( isBoolean( context.getThrowOnException() ) );

		// has global control elements which exist in the request scope
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


	// you can set the default logger's logging level to one of: debug|info|warn|error|fatal|nil
	/**
	* @mxunit:expectedException InvalidArgumentException
	*/
	public void function testSetLogLevel() hint="you can set the logging level" {
		structDelete( request, 'voib' );
		context = new voib.src.context( loglevel='foobar');
	}


	// logging functions

	public void function testNilLogging() {
		structDelete( request, 'voib' );
		context = new voib.src.context(); // default loglevel is 'nil'
		assert( !context.isDebugEnabled() );
		assert( !context.isInfoEnabled() );
		assert( !context.isWarnEnabled() );
		assert( !context.isErrorEnabled() );
		assert( !context.isFatalEnabled() );
	}


	public void function testDebugLogging() {
		structDelete( request, 'voib' );
		context = new voib.src.context( loglevel='debug' );
		assert( context.isDebugEnabled() );
		assert( context.isInfoEnabled() );
		assert( context.isWarnEnabled() );
		assert( context.isErrorEnabled() );
		assert( context.isFatalEnabled() );
	}


	public void function testInfoLogging() {
		structDelete( request, 'voib' );
		context = new voib.src.context( loglevel='info' );
		assert( !context.isDebugEnabled() );
		assert( context.isInfoEnabled() );
		assert( context.isWarnEnabled() );
		assert( context.isErrorEnabled() );
		assert( context.isFatalEnabled() );
	}


	public void function testWarnLogging() {
		structDelete( request, 'voib' );
		context = new voib.src.context( loglevel='warn' );
		assert( !context.isDebugEnabled() );
		assert( !context.isInfoEnabled() );
		assert( context.isWarnEnabled() );
		assert( context.isErrorEnabled() );
		assert( context.isFatalEnabled() );
	}


	public void function testErrorLogging() {
		structDelete( request, 'voib' );
		context = new voib.src.context( loglevel='error' );
		assert( !context.isDebugEnabled() );
		assert( !context.isInfoEnabled() );
		assert( !context.isWarnEnabled() );
		assert( context.isErrorEnabled() );
		assert( context.isFatalEnabled() );
	}


	public void function testFatalLogging() {
		structDelete( request, 'voib' );
		context = new voib.src.context( loglevel='fatal' );
		assert( !context.isDebugEnabled() );
		assert( !context.isInfoEnabled() );
		assert( !context.isWarnEnabled() );
		assert( !context.isErrorEnabled() );
		assert( context.isFatalEnabled() );
	}


	// can dispatch
	public void function testDefaultDispatch() {
		structDelete( request, 'voib' );
		context = new voib.src.context();
		var result = context.dispatch(); // dispatch the default command
		assert( result );
		debug( result );
	}


/* WILL NOT DO - FUNCTIONAL
	// dispatches a new, child context when the parent is processing
	public void function testDispatchChildWhenAlreadyProcessing() {
		structDelete( request, 'voib' );
		context = new voib.src.context();
//		var result = context.dispatch(); // dispatch the default command
		fail( 'todo - functional?' );
//		assert( result );
//		debug( result );
	}
*/

	// command factory functions


/*
	newCommand can create Commands depending on the arguments provided:
	public any newCommand( any name, struct args, string access )
	- should create a default Command when no arguments are provided
	- if the first argument is a Command , returns it
	- if the first argument is a struct, should create a Command
	- if the first argument is an array of valid elements, should return an array of Commands
	- if the first argument is a string, should create a Command using the other arguments too
	- if none of the above, should create a default Command
*/

	// should return the default Command if there are no arguments provided
	public void function testNewCommandReturnsDefaultOnNoArgs() {
		structDelete( request, 'voib' );
		context = new voib.src.context();
		var cmd = context.newCommand();
		assert( isInstanceOf( cmd, 'voib.src.command' ) );
		assert( cmd.getName() == 'default' ); 
		assert( isStruct( cmd.getArgs() ) );
		assert( structIsEmpty( cmd.getArgs() ) );
		assert( cmd.getAccess() == 'private' );
		assert( isArray( cmd.getHandlers() ) );
		assert( arrayIsEmpty( cmd.getHandlers() ) );
	}



	// should return the default Command if provided a blank argumentCollection
	public void function testNewCommandReturnsDefaultOnEmptyArgumentCollection() {
		structDelete( request, 'voib' );
		context = new voib.src.context();
		var cmd = context.newCommand( argumentCollection=arguments );
		assert( isInstanceOf( cmd, 'voib.src.command' ) );
		assert( cmd.getName() == 'default' ); 
		assert( isStruct( cmd.getArgs() ) );
		assert( structIsEmpty( cmd.getArgs() ) );
		assert( cmd.getAccess() == 'private' );
		assert( isArray( cmd.getHandlers() ) );
		assert( arrayIsEmpty( cmd.getHandlers() ) );
	}



	// should create a Command from defaults, provided the name of the command
	public void function testCreateCommandFromStringName() {
		structDelete( request, 'voib' );
		context = new voib.src.context();
		var cmd = context.newCommand( 'LetItBe' );
		assert( isInstanceOf( cmd, 'voib.src.command' ) );
		assert( cmd.getName() == 'LetItBe' ); 
		assert( isStruct( cmd.getArgs() ) );
		assert( structIsEmpty( cmd.getArgs() ) );
		assert( cmd.getAccess() == 'private' );
		assert( isArray( cmd.getHandlers() ) );
		assert( arrayIsEmpty( cmd.getHandlers() ) );
	}



	// should return a Command from a qualifying struct
	public void function testNewCommandReturnsCommandFromStruct() {
		structDelete( request, 'voib' );
		context = new voib.src.context();
		var cmd = context.newCommand( { name="LetItBe", args={}, access="public" } );
		assert( isInstanceOf( cmd, 'voib.src.command' ) );
		assert( cmd.getName() == 'LetItBe' ); 
		assert( isStruct( cmd.getArgs() ) );
		assert( structIsEmpty( cmd.getArgs() ) );
		assert( cmd.getAccess() == 'public' );
		assert( isArray( cmd.getHandlers() ) );
		assert( arrayIsEmpty( cmd.getHandlers() ) );
	}



	// should return a Command or a subclass of Command untouched
	public void function testNewCommandReturnsCommandFromCommand() {
		structDelete( request, 'voib' );
		context = new voib.src.context();
		var cmdB = context.newCommand( { name="LetItBe", args={ A="b", C="d" }, access="public" } );
		var handler = new voib.src.handler.basehandler();
		handler.setName( 'IAmTheWalrus' );
		cmdB.setHandlers( handler );
		cmdB.setMemento( { "theBeatles"='John,Paul,George,Ringo' } );

		var cmd = context.newCommand( cmdB );
		debug( cmd );
		debug( cmd.getHandlers() );

		assert( isInstanceOf( cmd, 'voib.src.command' ) );
		assert( cmd.getName() == 'LetItBe' ); 
		assert( isStruct( cmd.getArgs() ) );
		assert( cmd.getArg( 'A' ) == 'b' );
		assert( cmd.getArg( 'C') == 'd' );
		assert( cmd.getAccess() == 'public' );
		assert( isArray( cmd.getHandlers() ) );
		assert( cmd.getHandlerNames() == 'IAmTheWalrus' );
		assert( isStruct( cmd.getMemento() ) );
		assert( structKeyExists( cmd.getMemento(), 'theBeatles' ) );
	}


	// should return an array of Commands from a qualifying array
	public void function testNewCommandReturnsCommandsFromArray() {
		structDelete( request, 'voib' );
		context = new voib.src.context();
		var cmd1 = 'IDigAPony' ;
		var cmd2 = { name='FoolOnTheHill' };
		var cmd3 = context.newCommand( { name="LetItBe", args={}, access="public" } );
		var cmd4 = {};
		var cmds = [ cmd1, cmd2, cmd3, cmd4 ];

		var returnedCommands = context.newCommand( cmds );
		debug( returnedCommands );
		assert( isObject( returnedCommands[1] ) );
		assert( isInstanceOf( returnedCommands[1], 'voib.src.command' ) );
		assert( returnedCommands[1].getName() == 'IDigAPony' );
		assert( returnedCommands[1].getAccess() == 'private' );

		assert( isObject( returnedCommands[2] ) );
		assert( isInstanceOf( returnedCommands[2], 'voib.src.command' ) );
		assert( returnedCommands[2].getName() == 'FoolOnTheHill' );
		assert( returnedCommands[2].getAccess() == 'private' );

		assert( isObject( returnedCommands[3] ) );
		assert( isInstanceOf( returnedCommands[3], 'voib.src.command' ) );
		assert( returnedCommands[3].getName() == 'LetItBe' );
		assert( isStruct( returnedCommands[3].getArgs() ) );
		assert( returnedCommands[3].getAccess() == "public" );

		assert( isObject( returnedCommands[4] ) );
		assert( isInstanceOf( returnedCommands[4], 'voib.src.command' ) );
		assert( returnedCommands[4].getName() == 'default' );
		assert( returnedCommands[4].getAccess() == 'private' );

	}


	// should return a Command from a string name
	public void function testNewCommandReturnsCommandFromString() {
		structDelete( request, 'voib' );
		context = new voib.src.context();
		var cmd = context.newCommand( 'LetItBe' );
		assert( isObject( cmd ) );
		assert( isInstanceOf( cmd, 'voib.src.command' ) );
		assert( cmd.getName() == 'LetItBe' ); 
		assert( isStruct( cmd.getArgs() ) );
		assert( cmd.getAccess() == 'private' );
	}


	// should create and place a command on top of the deque for processing
	// immediately after the successful conclusion of the current command, if any
	public void function testEnstackCommand() {
		structDelete( request, 'voib' );
		context = new voib.src.context();
		var cmd1 = 'IDigAPony' ;
		var cmd2 = { name='FoolOnTheHill' };
		var cmd3 = context.newCommand( { name="LetItBe", args={}, access='public' } );
		var cmd4 = {};
		var cmd5 = new voib.src.command( 'Yesterday' );
		var cmds = [ cmd1, cmd2, cmd3, cmd4, cmd5 ];

		// using a string name
		context.enstackCommand( cmds[1] );
		var deque = context.getDeque();
		assert( deque.size() == 1 );
		var command = deque.peek();
		// debug( command );
		assert( command.getName() == 'IDigAPony' );

		// using a struct
		context.enstackCommand( cmds[2] );
		var deque = context.getDeque();
		assert( deque.size() == 2 );
		var command = deque.peek();
		// debug( command );
		assert( command.getName() == 'FoolOnTheHill' );

		// using a command created by the context
		context.enstackCommand( cmds[3] );
		var deque = context.getDeque();
		assert( deque.size() == 3 );
		var command = deque.peek();
		// debug( command );
		assert( command.getName() == 'LetItBe' );

		// using the default
		context.enstackCommand( cmds[4] );
		var deque = context.getDeque();
		assert( deque.size() == 4 );
		var command = deque.peek();
		// debug( command );
		assert( command.getName() == 'default' );

		// using a command created by you
		context.enstackCommand( cmds[5] );
		var deque = context.getDeque();
		assert( deque.size() == 5 );
		var command = deque.peek();
		// debug( command );
		assert( command.getName() == 'Yesterday' );

		// using an array of any of the above
		// NOTE: if you enstack an array, the order is preserved
		structDelete( request, 'voib' );
		context = new voib.src.context();
		context.enstackCommand( cmds );
		var deque = context.getDeque();
		assert( deque.size() == 5 );
		var command = deque.peek();
		// debug( command );
		assert( command.getName() == 'IDigAPony' );

	}


	// should create and place a command on bottom of the deque for processing
	public void function testEnqueueCommand() {
		structDelete( request, 'voib' );
		context = new voib.src.context();
		var cmd1 = 'IDigAPony' ;
		var cmd2 = { name='FoolOnTheHill' };
		var cmd3 = context.newCommand( { name="LetItBe", args={}, access='public' } );
		var cmd4 = {};
		var cmd5 = new voib.src.command( 'Yesterday' );
		var cmds = [ cmd1, cmd2, cmd3, cmd4, cmd5 ];

		// using a string name
		context.enqueueCommand( cmds[1] );
		var deque = context.getDeque();
		assert( deque.size() == 1 );
		var command = deque.peek();
		// debug( command );
		assert( command.getName() == 'IDigAPony' );

		// using a struct
		context.enqueueCommand( cmds[2] );
		var deque = context.getDeque();
		assert( deque.size() == 2 );
		var command = deque.peek();
		// debug( command );
		assert( command.getName() == 'IDigAPony' );

		// using a command created by the context
		context.enqueueCommand( cmds[3] );
		var deque = context.getDeque();
		assert( deque.size() == 3 );
		var command = deque.peek();
		// debug( command );
		assert( command.getName() == 'IDigAPony' );

		// using the default
		context.enqueueCommand( cmds[4] );
		var deque = context.getDeque();
		assert( deque.size() == 4 );
		var command = deque.peek();
		// debug( command );
		assert( command.getName() == 'IDigAPony' );

		// using a command created by you
		context.enqueueCommand( cmds[5] );
		var deque = context.getDeque();
		assert( deque.size() == 5 );
		var command = deque.peek();
		// debug( command );
		assert( command.getName() == 'IDigAPony' );
		assert( deque.getLast().getName() == 'Yesterday' );

		// using an array of any of the above
		// NOTE: if you enqueue an array, the order is preserved
		structDelete( request, 'voib' );
		context = new voib.src.context();
		context.enstackCommand( cmds );
		var deque = context.getDeque();
		assert( deque.size() == 5 );
		var command = deque.peek();
		// debug( command );
		assert( command.getName() == 'IDigAPony' );
		assert( deque.getLast().getName() == 'Yesterday' );
	}



	// clears the current context of commands
	public void function testClearCommands() {
		structDelete( request, 'voib' );
		context = new voib.src.context();
		var cmd1 = 'IDigAPony' ;
		var cmd2 = { name='FoolOnTheHill' };
		var cmd3 = context.newCommand( { name="LetItBe", args={}, access='public' } );
		var cmd4 = {};
		var cmd5 = new voib.src.command( 'Yesterday' );
		var cmds = [ cmd1, cmd2, cmd3, cmd4, cmd5 ];

		context.enstackCommand( cmds );
		assert( context.getDeque().size() == 5 );

		context.clearCommands();
		assert( context.getDeque().size() == 0 );
	}


	public void function testHasCommands() {
		// returns FALSE when the context is empty
		// returns TRUE when the context is not empty
		structDelete( request, 'voib' );
		context = new voib.src.context();
		var cmd1 = 'IDigAPony' ;
		var cmd2 = { name='FoolOnTheHill' };
		var cmd3 = context.newCommand( { name="LetItBe", args={}, access='public' } );
		var cmd4 = {};
		var cmd5 = new voib.src.command( 'Yesterday' );
		var cmds = [ cmd1, cmd2, cmd3, cmd4, cmd5 ];

		assert ( !context.hasCommands() );

		context.enstackCommand( cmds );
		assert( context.hasCommands() );

		context.clearCommands();
		assert ( !context.hasCommands() );
	}


	// lookahead functionality that nobody will ever use
	// returns the command at the TOP of the deque without removing it
	public void function testPeekCommand() {
		structDelete( request, 'voib' );
		context = new voib.src.context();
		var cmd1 = 'IDigAPony' ;
		var cmd2 = { name='FoolOnTheHill' };
		var cmd3 = context.newCommand( { name="LetItBe", args={}, access='public' } );
		var cmd4 = {};
		var cmd5 = new voib.src.command( 'Yesterday' );
		var cmds = [ cmd1, cmd2, cmd3, cmd4, cmd5 ];
		context.enstackCommand( cmds );
		assert( context.peekCommand().getName() == 'IDigAPony' );
	}


	public void function testSizeCommands() {
		structDelete( request, 'voib' );
		context = new voib.src.context();
		var cmd1 = 'IDigAPony' ;
		var cmd2 = { name='FoolOnTheHill' };
		var cmd3 = context.newCommand( { name="LetItBe", args={}, access='public' } );
		var cmd4 = {};
		var cmd5 = new voib.src.command( 'Yesterday' );
		var cmds = [ cmd1, cmd2, cmd3, cmd4, cmd5 ];
		context.enstackCommand( cmds );
		assert( context.sizeCommands() == 5 );
	}


	// candy data API

	// set a single data element
	public void function testSet() {
		structDelete( request, 'voib' );
		context = new voib.src.context();
		context.set( 'C', 3 );
		var data = request['voib']['data'];
		assert( structKeyExists( data, 'C' ) );
		assert( data['C'] == 3 );
	}


	public void function testIsDefined() {
		structDelete( request, 'voib' );
		context = new voib.src.context();
		assert( !context.isDefined( 'A' ) );
		context.set( 'C', 3 );
		assert( context.isDefined( 'C' ) );
	}


	public void function testGet() {
		// get( required string key, any defaultValue, boolean keepDefaultValue )
		structDelete( request, 'voib' );
		context = new voib.src.context();

		// get a variable
		context.set( 'C', 33 );
		assert( context.get( 'C' ) == 33 );

		// return a default value if the variable does not exist
		assert( context.get( 'D', 44 ) == 44 );
		assert( !context.isDefined( 'D' ) );

		// set and return a default value if the variable does not exist
		assert( context.get( 'E', 555, TRUE ) == 555 );
		assert( context.isDefined( 'E' ) );
		assert( context.get( 'E' ) == 555 );
	}


	public void function testRemove() {
		// remove( required string key )
		structDelete( request, 'voib' );
		context = new voib.src.context();
		context.set( 'C', 33 );
		assert( context.get( 'C' ) == 33 );
		context.remove( 'C' );
		assert( !context.isDefined( 'C' ) );
	}


	// initialize the context's state
	public void function testInitializeData() {
		structDelete( request, 'voib' );
		context = new voib.src.context( data={ 'A'="11", 'B'="22" } );
		assert( structKeyExists( request['voib']['data'], 'A' ) );
		assert( request['voib']['data']['A'] == 11 );
		assert( structKeyExists( request['voib']['data'], 'B' ) );
		assert( request['voib']['data']['B'] == 22 );
	}


	// reset the context's state
	public void function testSetData() {
		structDelete( request, 'voib' );
		context = new voib.src.context();
		context.setData( { 'A'="1", 'B'="2" } );
		var data = request['voib']['data'];
		assert( structKeyExists( data, 'A' ) );
		assert( data['A'] == 1 );
		assert( structKeyExists( data, 'B' ) );
		assert( data['B'] == 2 );
	}


	// get the context's state
	public void function testGetData() {
		// getData()
		structDelete( request, 'voib' );
		context = new voib.src.context( data={ 'A'="1", 'B'="22", 'C'="333" } );
		var data = context.getData();
		assert( data['A'] == 1 );
		assert( data['B'] == 22 );
		assert( data['C'] == 333 );
	}


	public void function testAppendData() {
		structDelete( request, 'voib' );
		context = new voib.src.context( data={ 'A'="1", 'B'="22", 'C'="333" } );

		// appendData( required struct data, boolean overwrite=TRUE )
		context.appendData( { 'A'="42", 'E'="5" } ); // default is TRUE
		var data = context.getData();
		assert( data['A'] == 42 );
		assert( data['E'] ==5 );

		// appendData( required struct data, boolean overwrite=TRUE )
		context.setData( { 'A'="1", 'B'="2" } );
		context.appendData( { 'A'="42", 'E'="5" }, FALSE );
		var data = context.getData();
		assert( data['A'] == 1 );
		assert( data['E'] ==5 );
	}

/*

	// WILL NOT DO - broadcast mapping is an integration test
	public void function testMapHandlers() {
		fail( 'todo, or maybe not' );
		// setHandlers[]
		// then mapping
		// then hasHandlers
	}

*/
}