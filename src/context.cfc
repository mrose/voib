component
displayname="voib.src.context"
accessors="TRUE"
hint="an invocation context" {

// provides a facade to logging operations with its logger
// provides api for command creation and processing
// maps handlers to commands with its mapper

	property name="deque"            type="any"     setter="FALSE";
	property name="logger"           type="any"     setter="FALSE" hint="Required. Defaults to a no-op logger";
	property name="mapping"          type="any"     setter="FALSE" hint="Required. Defaults to a default mapping";
	property name="result"           type="any"                    hint="Optional return value. Defaults to TRUE";
	property name="throwOnException" type="boolean" setter="FALSE" hint="Optional. Determines how exceptions are handled. Defaults to FALSE";


	public context function init() {
		var loglevel = structKeyExists( arguments, 'loglevel' )? arguments.loglevel : 'nil';

		variables.deque = createObject( 'java', 'java.util.ArrayDeque' );
		variables.logger = structKeyExists( arguments, 'logger' )? arguments.logger : new voib.src.logger( level=loglevel );
		variables.mapping = structKeyExists( arguments, 'mapping' )? arguments.mapping : new voib.src.mapping.basemapping();
		setResult( structKeyExists( arguments, 'result' )? arguments.result : TRUE );
		variables.throwOnException = structKeyExists( arguments, 'throwOnException' )? arguments.throwOnException : FALSE;

		// GLOBAL PER-REQUEST FRAMEWORK CONTROL ELEMENTS
		// do not mess with these unless you know what you're doing
		if ( !structKeyExists( request, 'voib' ) ) {
			request['voib'] = {
				  'id' = createUUID()
				, 'code' = "200"
				, 'data' = structNew()
				, 'executedCommands' = arrayNew()
				, 'exceptions' = arrayNew()
				, 'invocationControl' = "next" // next|clear|halt
				, 'invocationDepth' = "0"
				, 'maximumCommands' = 1000
				, 'maximumDepth' = 100
				, 'message' = "OK"
				, 'output' = ""
				, 'processingSequence' = "0"
			};

			// ok to place arbitrary arguments into the voib namespace
			// also this will overwrite the default framework control elements
			structAppend( request['voib'], arguments, true );

			// but not the ones this context uses as private properties
			structDelete( request['voib'], 'logger' );
			structDelete( request['voib'], 'mapping' );
			structDelete( request['voib'], 'throwOnException' );
		}

		this.info( 'context created' );
		return this;
	}



	public any function onMissingMethod( missingMethodName, missingMethodArguments ) {
		var cmd = FALSE;
		var result = getResult();

// TODO: this is a bad way to determine if in play
		// if there's a command already in play
		if ( !variables.deque.isEmpty() ) {
			return dispatch( arguments.missingMethodName, arguments.missingMethodArguments );
		}

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

				cmd.setMemento( duplicate( request['voib']['data'] ) );
				processCommand( cmd );

				// place the processed command onto audit stack for possible undo
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

		return getResult();
	}



	// map handlers & execute
	private void function processCommand( required any command ) {
		var h = FALSE;
		var handlers = [ ];
		var i = 0;

		if ( mapHandlers( arguments.command ) ) {
			handlers = arguments.command.getHandlers();

			while ( arrayLen( handlers ) > i ) {

				h = handlers[++i];
				h.setContext( this );
				h.setCommand( arguments.command );
				h.execute();

				if ( !this.shouldContinue() ) {
					break;
				}
			}
		}
	}



	public boolean function shouldContinue() {
		return compareNoCase( request['voib']['invocationControl'], 'halt' );
	}



	private boolean function mapHandlers( required any command ) {
		var cmd = arguments.command;

		if ( cmd.hasHandlers() ) {
			this.debug( 'Handler(s) #cmd.getHandlerNames()# are premapped to command #cmd.getName()#' );
			return TRUE;
		}

		cmd.setHandlers( this.getMapping().getHandlers( cmd ) );
		if ( cmd.hasHandlers() ) {
			this.debug( 'Handler(s) #cmd.getHandlerNames()# are now mapped to command #cmd.getName()#' );
			return TRUE;
		}

		// if you are using the standard 'broadcast' mapping (multicastmapping.cfc) this should not happen
		dispatch( name='noHandlerFound', args={ 'command'=cmd } );
		return FALSE;
	}



	// must be a context method since we must handle MaximumInvocationsExceptions and MaximumCommandExceptions internally
	private void function handleException( required any exception ) hint="extension point for exception handling" {

		// to prevent endless iteration, maximumInvocations/Commands must terminate
		if ( getThrowOnException() || ( listFindNoCase( 'MaximumInvocationsException,MaximumCommandsException', arguments.exception.type ) ) ) {
			structAppend( request['voib'], arguments.exception, TRUE ); // true = overwrite
//			arrayAppend( request['voib']['exceptions'], arguments.exception );
			request['voib']['code'] = 500;
			request['voib']['severity'] = 'fatal';
			request['voib']['invocationControl'] = 'halt';
			fatal( trim( request['voib']['message'] & ' ' & request['voib']['detail'] ) );
			structDelete( request['voib'], 'StackTrace' );

			if ( getThrowOnException() ) {
				throw( arguments.exception );
			}

			return;
		}

		// throwOnException defaults to FALSE
		// so let's be optimistic about exceptions
		// try to carry on in spite of them
		request['voib']['invocationControl'] = 'next';
		arrayAppend( request['voib']['exceptions'], arguments.exception );
		error( trim( arguments.exception['message'] & ' ' & arguments.exception['detail'] ) );
	}



	// ---------------------- API for logging ------------------------ //

	public void function debug( required any message ) { getLogger().debug( arguments.message ); }
	public void function info( required any message )  { getLogger().info( arguments.message ); }
	public void function warn( required any message )  { getLogger().warn( arguments.message ); }
	public void function error( required any message ) { getLogger().error( arguments.message ); }
	public void function fatal( required any message ) { getLogger().fatal( arguments.message ); }

	public boolean function isDebugEnabled() { return getLogger().isDebugEnabled(); }
	public boolean function isInfoEnabled() { return getLogger().isInfoEnabled(); }
	public boolean function isWarnEnabled() { return getLogger().isWarnEnabled(); }
	public boolean function isErrorEnabled() { return getLogger().isErrorEnabled(); }
	public boolean function isFatalEnabled() { return getLogger().isFatalEnabled(); }



	// ---------------------- API for command invocation ------------------------ //

	public any function dispatch() hint="takes multiple duck-typed arguments" {
		var cxt = new context( logger=getLogger(), mapping=getMapping() );
		debug( 'created new context' );
		return cxt.onMissingMethod( argumentCollection = arguments );
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
			debug( 'newCommand argument is a string (#arguments.name#)' );
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
		variables.data = arguments.data;
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