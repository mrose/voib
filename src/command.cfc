component
displayname="voib.src.command"
accessors="TRUE"
hint="A transient which enables the queueing, binding (mapping) and invocation of registered handlers against it's properties and the context" {

	property type="string"  name="name"     hint="unique name for this Command";
	property type="struct"  name="args"     hint="struct of arbitrary 'modifiers' whose values will be used during processing";
	property type="string"  name="access"   hint="string denoting an arbitrary security domain (typically either 'public' or 'private') used to assist mapped handler processing";
	property type="any"     name="handlers" hint="Handlers mapped to this Command prior to its execution";
	property type="struct"  name="memento"  hint="state data provided prior to processing";


	public command function init( required string name, struct args='#{}#', access='private', handlers='#[ ]#' ) {
		setName( arguments.name );
		setArgs( arguments.args );
		setAccess( arguments.access );
		setHandlers( arguments.handlers );
		setMemento( { } );
		return this;
	}



	public any function undo() {
		return duplicate( getMemento() );
	}



	public void function setHandlers( required any handlers ) {
		var h = arguments.handlers;

		if ( !isArray( h ) && !isValid( 'component', h ) ) {
			throw( type='InvalidArgumentException', message='Handlers must be a component or array' );
		}

		variables.handlers = isArray(h) ? h : [h];
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
				throw( type='UndefinedElementException', message='Element #arguments.key# is undefined in the args property of command #getName()#, no tempDefaultValue was provided' );
			}
		}
		return variables['args'][arguments.key];
	}



	public Command function setArg( required string key, required any value ) {
		variables['args'][arguments.key] = arguments.value;
		return this;
	}

}