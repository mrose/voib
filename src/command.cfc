component
displayname="voib.src.command"
accessors="TRUE"
hint="A transient which enables the queueing, binding (mapping) and invocation of registered handlers against it's properties and the context" {

	property type="string" name="name" hint="unique name for this Command";
	property type="struct" name="args" hint="struct of arbitrary 'modifiers' whose values will be used during processing";
	property type="string" name="access" hint="string denoting an arbitrary security domain (typically either 'public' or 'private') used to assist matched handler processing";
	property type="array"  name="handlers" hint="Handlers mapped to this Command prior to its execution";

	// context processing relationship
//	property type="numeric" name="invocationDepth" hint="";
//	property type="numeric" name="processingSequence" hint="";
	property type="struct"  name="memento" setter="FALSE" hint="state data provided prior to processing";


	public command function init( required string name, struct args='#{}#', access="private" ) {
		setName( arguments.name );
		setArgs( arguments.args );
		setAccess( arguments.access );

//		setInvocationDepth( 0 );
//		setProcessingSequence( 0 );
		variables.memento = {} ;

		// the invoker instances the execute method should delegate to.
		// The method called will always be execute().
		// if necessary, use the handleradapter to facade the actual invoker, and/or it's method, or use onMissingMethod
		// yes, facade is a verb. no, really, it is.
		setHandlers( [ ] );

		return this;
	}



	public void function execute( required any context ) {
		var i = 0;
		var h = FALSE;
		var handlers = [ ];

		arguments.context.debug( 'command #getName()# execution starts' );

//		setInvocationDepth( arguments.context.invocationDepth );
//		setProcessingSequence( arguments.context.processingSequence );

// TODO: fix this cheat
		variables.memento = duplicate( request['voib']['data'] ) ;

		mapHandlers( arguments.context );
		handlers = getHandlers();

		while ( arrayLen( handlers ) > i ) {

			h = handlers[++i];

//			if ( isInstanceOf( h, 'voib.src.handler.transienthandler' ) ) {
//				h.setContext( arguments.context );
//			}

			h.execute( this, arguments.context );

			if ( !arguments.context.shouldContinue() ) {
				break;
			}
		}

		arguments.context.debug( 'command #getName()# execution ends' );
	}



	private boolean function mapHandlers( required any context ) {
		var h = [ ];

		if ( hasHandlers() ) {
			arguments.context.debug( 'Handler(s) #getHandlerNames()# are already mapped to command #getName()#' );
			return TRUE;
		}

		h = arguments.context.getMapping().getHandlers( this );
		setHandlers( isArray( h ) ? h : [ h ] );
		if ( hasHandlers() ) {
			arguments.context.debug( 'Handler(s) #getHandlerNames()# are now mapped to command #getName()#' );
			return TRUE;
		}

		return arguments.context.noHandlerFound( this );
	}



	public any function undo() {
		return duplicate( getMemento() );
	}



// arguments api

	public boolean function isArgDefined( required string key ) {
		return structKeyExists( variables.args, arguments.key );
	}



	public boolean function hasArg( required string key ) {
		return isArgDefined( arguments.key );
	}



	public any function getArg( required string key, any tempDefaultValue ) {
		if ( !isArgDefined( arguments.key ) ) {
			if ( structKeyExists( arguments, 'tempDefaultValue' ) ) {
				return arguments.tempDefaultValue;
			} else {
				throw( type='UndefinedElementException', message='Element #arguments.key# is undefined in the args property of command #getName()# and no default was provided' );
			}
		}
		return variables['args'][arguments.key];
	}



	public Command function setArg( required string key, required any value ) {
		variables['args'][arguments.key] = arguments.value;
		return this;
	}



	public boolean function hasHandlers() {
		return yesNoFormat( arrayLen( getHandlers() ) );
	}



	public string function getHandlerNames() {
		var names = "";
		var i = 0;
		var handlers = getHandlers();

		while ( arrayLen( handlers ) > i ) {
			names = listAppend( names, handlers[++i].getName() );
		}

		return names;
	}



	// override generated method so we can return a self reference
	public any function setHandlers( required array handlers) {
		variables.handlers = arguments.handlers;
		return this;
	}

}