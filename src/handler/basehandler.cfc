component
displayname="voib.src.handler.basehandler"
accessors="TRUE"
hint="Transient base object that must be used for all framework Handler subclasses implementing functionality based on a command;
intended to allow indefinite extensibility. Implementations can use the Order property to specify a priority
for getting applied." {

	// Because they can invoke the framework to dispatch() commands, handlers don't have interceptors 

	property type="string" name="access" hint="string to help determine if this object should handle Commands based on the Command's access property; typically one of public|private, defaults to private";
	property type="string" name="comment" hint="descriptive comment";
	property type="string" name="name" hint="name for this object, used for logging";
	property type="numeric" name="order" hint="priority for being applied";
	property type="array" name="listen" hint="optional array of command names this handler will listen for";
	property type="any" name="rule" hint="a Rule";
	property type="voib.src.command" name="command" hint="a voib command";
	property type="voib.src.context" name="context" hint="the voib context";


	public voib.src.handler.basehandler function init( string access, string name, string comment, numeric order, array listen, any rule ) {
		setProperties( argumentCollection=arguments );
		return this;
	}



	public void function execute() hint="performs the primary processing task of the framework" {
		throw( type="Method.NotImplemented", message="The basehandler's execute method is abstract and must be overridden" );
		getContext.debug(  getMetaData( this ).name & ': completed' );
	}



	public boolean function acceptable() {

		var cmd = getCommand();
		var cxt = getContext();

		if ( !hasValidCommand( cmd.getName() ) ) {
			cxt.debug( getName() & ': does not listen for command #cmd.getName()#' );
			return FALSE;
		}

		if ( !hasValidAccess( cmd.getAccess() ) ) { 
			cxt.error( getName() & ': could not assign a #getAccess()# handler to #cmd.getAccess()# command #cmd.getName()#' );
			return FALSE;
		}

		switch( hasValidRule( cxt.getData() ) ) {

			case 0:
				cxt.debug( getName() & ': did not match rule ( #getRule().ruleText()# )' );
				return FALSE;

			case 1:
				cxt.info( getName() & ': no rule configured' );
				break;

			case 2:
				cxt.debug( getName() & ': matched rule ( #getRule().ruleText()# )' );

		}

		return TRUE;
	}



	public void function setOrder( required numeric order ) {
		// cannot be negative
		if ( arguments.order < 0 ) throw( type="InvalidArgumentException", detail="The order property for a handler cannot be a negative number." ); 

		// cannot be greater than 999,999,999
		if ( arguments.order > 999999999 ) throw( type="InvalidArgumentException", detail="The order property for a handler cannot be a number higher than 999,999,999." ); 

		variables.order = arguments.order;
	}



	public void function setAccess( required string access ) {
		if ( !listFind( 'public,private', lCase( arguments.access ) ) ) {
			throw( type='InvalidArgumentException', message='Access must be one of: public|private' );
		}
		variables.access = lCase( arguments.access );
	}



	public boolean function hasValidAccess( required string commandAccess ) hint="assure that a handler whose access property is private will not process a command whose access property is public" {
		/**
		 * NOT OKAY when command is public, but handler is private
		 * command = private, handler= private OK
		 * command = private, handler = public OK
		 * command = public, handler = public OK
		**/
		if ( lCase( arguments.commandAccess ) == 'public'  && getAccess() != 'public' ) {
			return FALSE;
		}
		return TRUE;
	}



	public boolean function hasValidCommand( required string commandName ) hint="boolean " {
		if ( arrayIsEmpty( getListen( ) ) || arrayFindNoCase( getListen(), arguments.commandName ) ) {
			return TRUE;
		}
		return FALSE;
	}



	public any function hasValidRule( required any data ) {

		// Handlers without rules should be invoked, so VALID if no rule is configured
		if ( !isObject( getRule() ) ) {
			return 1;
		}

		if ( getRule().isValid( arguments.data ) ) {
			return 2;
		}

		return 0;
	}



	public any function onMissingMethod( required string missingMethodName, required struct missingMethodArguments ) {
		var result = invoke( getContext(), missingMethodName, missingMethodArguments );
	}



	// constructor takes precedence over annotations/metadata, so dependency injection works as expected 
	private void function setProperties( string access, string name, string comment, numeric order, array listen, any rule ) {
		var cfcMetadata = getMetaData( this );
		var defaults = { 'access'="private", 'name' = getMetaData( this ).name, 'comment' = "", 'order' = 999999999, 'listen' = arrayNew(), 'rule'=FALSE };

		if ( structKeyExists( cfcMetadata, 'listen' ) ) {
			cfcMetadata.listen = listToArray( cfcMetadata.listen );
		}

		setAccess( structKeyExists( arguments, 'access' ) ? arguments.access : structKeyExists( cfcMetadata, 'access' ) ? cfcMetadata.access : defaults.access );
		setName( structKeyExists( arguments, 'name' ) ? arguments.name : structKeyExists( cfcMetadata, 'name' ) ? cfcMetadata.name : defaults.name );
		setComment( structKeyExists( arguments, 'comment' ) ? arguments.comment : structKeyExists( cfcMetadata, 'comment' ) ? cfcMetadata.comment : defaults.comment );
		setOrder( structKeyExists( arguments, 'order' ) ? arguments.order : structKeyExists( cfcMetadata, 'order' ) ? cfcMetadata.order : defaults.order );
		setListen( structKeyExists( arguments, 'listen' ) ? arguments.listen : structKeyExists( cfcMetadata, 'listen' ) ? cfcMetadata.listen : defaults.listen );
		setRule( structKeyExists( arguments, 'rule' ) ? arguments.rule : structKeyExists( cfcMetatdata, 'rule' ) ? cfcMetadata.rule : defaults.rule );

	}

}