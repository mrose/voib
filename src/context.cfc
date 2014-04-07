component
displayname="voib.src.context"
accessors="TRUE"
hint="an invocation context" {


	property name="deque" setter="FALSE";
	property name="logger" setter="FALSE";
	property name="mapping" setter="FALSE";


	public context function init( struct args ) {

		variables.deque = createObject( 'java', 'java.util.ArrayDeque' );

		if ( !structKeyExists( request, 'voib' ) ) {
			request['voib'] = structKeyExists( arguments, 'args' )? arguments.args: { } ;
			request['voib']['id'] = createUUID();

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
			param name="request['voib']['maximumCommands']" default="1000";
			param name="request['voib']['maximumDepth']" default="100";
			param name="request['voib']['throwOnException']" default="FALSE";
			param name="request['voib']['output']" default="";
			param name="request['voib']['logger']" default="#new voib.src.logger()#";
			param name="request['voib']['mapping']" default="#new voib.src.mapping.basemapping()#";
		}

		variables.logger = request['voib']['logger'];
		variables.mapping = request['voib']['mapping'];
		this.info( 'context created' );
		return this;
	}



	public any function onMissingMethod( missingMethodName, missingMethodArguments ) {
		var cmd = FALSE;
		var cxt = FALSE;

		try {

			if ( ++request['voib']['invocationDepth'] > request['voib']['maximumDepth'] ) {
				throw( type='MaximumInvocationsException', message='The maximum number of invocations (#request['voib']['maximumDepth']#) that can be processed has been exceeded' );
			}
			debug( 'invocation #request['voib']['invocationDepth']# starts' );

			enstackCommand( name=arguments.missingMethodName, args=arguments.missingMethodArguments );

			while ( !variables.deque.isEmpty() ) {

				cmd = variables.deque.pop() ; // no peek()ing here as we will get fablunged

				if ( ++request['voib']['processingSequence'] > request['voib']['maximumCommands'] ) {
					throw( type='MaximumCommandsException', message='The maximum number of Commands (#request['voib']['maximumCommands']#) that can be processed has been exceeded' );
				}

				info( 'Process of command #cmd.getName()# starts, invocation #request['voib']['invocationDepth']#, processingSequence #request['voib']['processingSequence']#, #variables.deque.size()# commands remaining' );

				// map handlers & execute
				cmd.execute( this );

				// place the processed command onto a stack for possible undo
				arrayAppend( request['voib']['executedCommands'], cmd ); 
				info( 'Process of command #cmd.getName()# ends with #request['voib']['invocationControl']#' );

				if ( !shouldContinue() ) {
					break;
				}

			} // end while

		} catch ( any e ) {
			handleException( e );
		} finally {
			debug( 'invocation #request['voib']['invocationDepth']--# ends' );

		}

		return request['voib'];
	}



	public boolean function shouldContinue() {
		return compareNoCase( request['voib']['invocationControl'], 'halt' );
	}



	// public because command calls it when mapping - prolly means we should refactor
	public boolean function noHandlerFound( required any command ) hint="extension point for when handler mapping is not found" {
		warn( 'No handlers were mapped to #arguments.command.getAccess()# command #arguments.command.getName()#' );
		return FALSE;
	}



	private void function handleException( required any exception ) hint="extension point for exception handling" {

		if ( request['voib']['throwOnException'] ) {
			structAppend( request['voib'], arguments.exception, TRUE ); // true = overwrite
			request['voib']['code'] = 500;
			request['voib']['severity'] = 'error';
			throw( arguments.exception );
		}

		// prevent endless iteration
		if ( listFindNoCase( 'MaximumInvocationsException,MaximumCommandsException', arguments.exception.type ) ) {
			structAppend( request['voib'], arguments.exception, TRUE ); // true = overwrite
			request['voib']['code'] = 500;
			request['voib']['severity'] = 'error';
			request['voib']['invocationControl'] = 'halt';
			request['voib']['severity'] = 'fatal';
			request['voib']['type'] = arguments.exception.type;
			error( trim( request['voib']['message'] & ' ' & request['voib']['detail'] ) );
			return;
		}

		// let's be optimistic about exceptions, trying to carry on in spite of them
		request['voib']['invocationControl'] = 'next';

//			structDelete( request['voib'], 'ErrorCode' );
//			structDelete( request['voib'], 'ErrNumber' );
			structDelete( request['voib'], 'StackTrace' );
//			structDelete( request['voib'], 'TagContext' );

		error( trim( request['voib']['message'] & ' ' & request['voib']['detail'] ) );
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



	// ---------------------- API for command invocation ------------------------ //

	public any function dispatch()  hint="takes multiple duck-typed arguments" {
		var cxt = new context();
		cxt.onMissingMethod( argumentCollection = arguments );
	}


	public any function newCommand( any name, struct args, string access ) hint="Commands can be created in a number of ways.<ol><li>If the 'name' argument is not provided, the default Command is returned.</li><li>If the name argument is a struct, the struct arguments are used to create the Command.</li><li>If the name argument is a string, the default properties are used for Command creation.</li></ol>" {

		// default - nothing passed in.
		if ( isNull( arguments[1] ) ) {
			debug( 'newCommand was passed no arguments, returning default Command' );
			return createCommand();
		}

		// it's already an object, either a command or a subclass
		if ( isObject( arguments[1] ) and isInstanceOf( arguments[1], 'voib.src.command' ) ) {
			debug( 'newCommand argument (#arguments[1].getName()#) is already a Command' );
			return arguments[1];
		}

		// now we'll overload the first argument to allow commands to be created in multiple ways
		// if the first argument is a struct, we'll pass it's arguments along to be created into a Command
		if ( isStruct( arguments[1] ) ) {
			debug( 'newCommand argument is a struct' );
			return createCommand( argumentCollection = arguments[1] );
		}

		// if the first argument is an array, we'll pass it's arguments along to newCommands() and take our chances
		if ( isArray( arguments[1] ) ) {
			debug( 'newCommand argument is an array' );
			return newCommands( arguments[1] );
		}

		// if the first argument is a string, we'll pass the rest of the arguments along, too
		if ( structKeyExists( arguments, 'name' ) && isValid( 'string', arguments.name ) ) {
			debug( 'newCommand argument (#arguments.name#) is a string' );
			return createCommand( argumentCollection = arguments );
		}

		// last resort: the default
		debug( 'newCommand returning default Command' );
		return createCommand();

	}



	private any function createCommand( string name, struct args, string access ) {
		structAppend( arguments, { 'name'="default", 'args'={ }, 'access'="private" }, FALSE );
		var cmd = new command( argumentCollection = arguments );
		debug( 'created command for ' & arguments.name );
		return cmd;
	}



	private array function newCommands( required array config ) {
		var commands = [ ];
		var c = FALSE;
		var i = 0;
		var sz = arrayLen( arguments.config );

		while( i < sz ) {
			c = arguments.config[++i];
			if ( isObject( c ) && isInstanceOf( c, 'command' ) ) {
				arrayAppend( commands, c );
				continue;
			}

			// we'll let it throw if the config is incorrect
			if ( isSimpleValue( c ) ) {
				arrayAppend( commands, newCommand( c ) );
				continue;
			}

			arrayAppend( commands, newCommand( argumentCollection=c ) );
		}

		return commands;
	}



	public void function enstackCommand() {
		var cmd = FALSE;
		var i = 0;

		// if the first arg is an array, it must be an array of commands
		// iterate from bottom to top to preserve order
		if ( !isNull( arguments[1] ) && isArray( arguments[1] ) ) {
			i = arrayLen( arguments[1] );
			while ( i > 0 ) {
				enstackCommand( arguments[1][i--] );
			}
			return;
		}

		cmd = newCommand( argumentCollection = arguments );

		if ( variables.deque.size() > request['voib']['maximumCommands'] ) {
			throw( type='MaximumCommandsException', message='The maximum number of Commands (#request['voib']['maximumCommands']#) that can be processed has been exceeded' );
		}
		variables.deque.addFirst( cmd );
		debug( 'enstacked command #cmd.getName()#' );
	}



	public void function enqueueCommand() {
		var cmd = FALSE;
		var i = 0;

		if ( !isNull( arguments[1] ) && isArray( arguments[1] ) ) {
			while ( i < arrayLen( arguments[1] ) ) {
				enqueueCommand( arguments[1][++i] );
			}
			return;
		}

		cmd = newCommand( argumentCollection = arguments );

		if ( variables.deque.size() >= request['voib']['maximumCommands'] ) {
			throw( type='MaximumCommandsException', message='The maximum number of Commands (#request['voib']['maximumCommands']#) that can be processed has been exceeded' );
		}
		variables.deque.addLast( cmd );
		debug( 'enqueued command #cmd.getName()#' );
	}



	public void function clearCommands() {
		var sz = sizeCommands();
		variables.deque.clear();
		debug( 'cleared #sz# commands in the current invocation' );
	}



	public any function dequeueCommand() {
		return variables.deque.pop();
	}



	public boolean function hasCommands() {
		return !variables.deque.isEmpty();
	}



	public any function destackCommand() {
		return variables.deque.pop();
	}



	public any function peekCommand() {
		return variables.deque.peek();
	}



	public numeric function sizeCommands() {
		return variables.deque.size();
	}



	// ---------------------- candy API for data ------------------------ //

	public voib.src.context function setData( required struct data ) {
		request['voib']['data'] = arguments.data;
		return this; // allow method chaining
	}



	public struct function getData() {
		return request['voib']['data'];
	}



	public void function appendData( required struct data , boolean overwrite=TRUE ) {
		structAppend( request['voib']['data'], arguments.data, arguments.overwrite );
	}



	public void function setDataElement( required string key, required any value ) {
		request['voib']['data'][arguments.key] = arguments.value;
	}



	public any function getDataElement( required string key, any defaultValue, boolean keepDefaultValue ) {
		if ( ( !structKeyExists( request['voib']['data'], arguments.key ) && ( structKeyExists( arguments, 'defaultValue' ) ) ) ) {
			if ( structKeyExists( arguments, 'keepDefaultValue') && ( arguments.keepDefaultValue ) ) {
				setDataElement( arguments.key, arguments.defaultValue );
			}
			return arguments.defaultValue;
		}
		return request['voib']['data'][arguments.key];
	}



	public boolean function isDataElementDefined( required string key ) {
		return structKeyExists( request['voib']['data'], arguments.key );
	}



	public void function removeDataElement( required string key ) {
		structDelete( request['voib']['data'], arguments.key );
	}

}