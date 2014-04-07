component
displayname="voib.src.handler.basehandler"
accessors="TRUE"
hint="Base object that must be used for all framework Handler subclasses implementing functionality based on a command;
intended to allow indefinite extensibility. Implementations can use the Order property to specify a priority
for getting applied." {

	// Because they can invoke the framework to dispatch() commands, handlers don't have interceptors 

	property type="string" name="access" hint="string to help determine if this object should handle Commands based on the Command's access property; typically one of public|private, defaults to private";
	property type="string" name="comment" hint="descriptive comment";
	property type="string" name="name" hint="name for this object, used for logging";
	property type="numeric" name="order" hint="priority for being applied";
	property type="array" name="listen" hint="optional array of command names this handler will listen for";
	property type="any" name="rule" hint="a Rule";


	public voib.src.handler.basehandler function init( string access, string name, string comment, numeric order, array listen, any rule ) {
		setAccess( structKeyExists( arguments, 'access' ) ? arguments.access : 'private' );
		setName( structKeyExists( arguments, 'name' ) ? arguments.name : getMetaData( this ).name );
		setComment( structKeyExists( arguments, 'comment' ) ? arguments.comment : '' );
		setOrder( structKeyExists( arguments, 'order' ) ? arguments.order : 999999999 );
		setListen( structKeyExists( arguments, 'listen' ) ? arguments.listen : [ ] );
		listenMetadata();
		setRule( structKeyExists( arguments, 'rule' ) ? arguments.rule : FALSE );
		return this;
	}



	public void function execute( required any command, required any context ) hint="performs the primary processing task of the framework" {
		throw( type="Method.NotImplemented", message="The basehandler's execute method is abstract and must be overridden" );
		arguments.context.debug(  getMetaData( this ).name & ': completed' );
	}



	public boolean function acceptable( required any command, required any context ) {

		if ( !hasValidCommand( arguments.command.getName() ) ) {
			arguments.context.debug( getName() & ': does not listen for command #arguments.command.getName()#' );
			return FALSE;
		}

		if ( !hasValidAccess( arguments.command.getAccess() ) ) { 
			arguments.context.error( getName() & ': could not assign a #getAccess()# handler to #arguments.command.getAccess()# command #arguments.command.getName()#' );
			return FALSE;
		}

		switch( hasValidRule( arguments.context.getData() ) ) {

			case 0:
				arguments.context.debug( getName() & ': did not match rule ( #getRule().ruleText()# )' );
				return FALSE;

			case 1:
				arguments.context.warn( getName() & ': no rule configured' );
				break;

			case 2:
				arguments.context.debug( getName() & ': matched rule ( #getRule().ruleText()# )' );

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



	// looks for voib_listen="commandName1,commandName2,etc" 
	// or @voib_listen attribute 
	// in function metadata and appends to listen array
	private void function listenMetadata() {
		var cfcMetadata = getMetaData( this );

		if ( structKeyExists( cfcMetadata, 'voib_listen' ) ) {
			arrayAppend( variables.listen, listToArray( cfcMetadata.voib_listen ), TRUE );
		}
	}

}