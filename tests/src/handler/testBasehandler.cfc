component extends="voib.tests.src.baseTest" {


	public void function setUp() {
		handler = new voib.src.handler.basehandler();
	}



	public void function testInit() {
		// is the correct type
		assert( isInstanceOf( handler, 'voib.src.handler.basehandler' ) );
		debug( handler );

		// has defaults:
		assert( handler.getAccess() == 'private' );
		assert( handler.getName() == 'voib.src.handler.basehandler' );
		assert( handler.getComment() == '' );
		assert( handler.getOrder() == 999999999 );
		assert( isArray( handler.getListen() ) && handler.getListen()[1] == 'nil' );
		assert( handler.getRule() == FALSE );
	}


	public void function testAnnotations() {
		// you can use annotations for the default properties, except for rule and name, which is CF reserved for stupid historical reasons
		handler = new voib.tests.resources.testHandler();
		md = getMetadata( handler );
		debug( md );

		assert( handler.getAccess() == 'public' );
		assert( handler.getComment() == 'testing' );
		assert( handler.getName() == 'voib.tests.resources.testHandler' );
		assert( handler.getOrder() == 42 );
		assert( arrayFind( handler.getListen(), 'eat' ) );
		assert( arrayFind( handler.getListen(), 'drink' ) );
		assert( arrayFind( handler.getListen(), 'sleep' ) );

		// constructor args take precedence over annotations
		handler = new voib.tests.resources.testHandler( access='private', comment='not testing', name='ringo', order=99, listen='act,dance,sing' );
		assert( handler.getAccess() == 'private' );
		assert( handler.getComment() == 'not testing' );
		assert( handler.getName() == 'ringo' );
		assert( handler.getOrder() == 99 );
		assert( arrayFind( handler.getListen(), 'act' ) );
		assert( arrayFind( handler.getListen(), 'dance' ) );
		assert( arrayFind( handler.getListen(), 'sing' ) );
	}


	// the basehandler execute should throw an error of type "Method.NotImplemented"
	/**
	* @mxunit:expectedException Method.NotImplemented
	*/
	public void function testExecute() {
		handler.execute();
	}



	// order cannot be a negative number and will throw exception
	/**
	* @mxunit:expectedException InvalidArgumentException
	*/
	public void function testOrderThrowsExceptionOnOrderNegative() {
		handler.setOrder(-1);
	}



	// order cannot be greater than 999,999,999 and will throw exception
	/**
	* @mxunit:expectedException InvalidArgumentException
	*/
	public void function testOrderThrowsExceptionOnOrderTooHigh() {
		handler.setOrder( 1000000000 );
	}



	// access must be one of public|private
	/**
	* @mxunit:expectedException InvalidArgumentException
	*/
	public void function testAccessThrowsExceptionOnInvalidInput() {
		handler.setAccess( 'hooray' );
	}


	public void function testHasValidAccess() {
		makePublic( handler, 'hasValidAccess' );
		assert( handler.hasValidAccess( 'private' ) );
		assert( !handler.hasValidAccess( 'public' ) );
	}



	// listen must be a string, list, or array
	/**
	* @mxunit:expectedException InvalidArgumentException
	*/
	public void function testListenThrowsExceptionOnInvalidInput() {
		var st = { };
		handler.setListen( st );
	}



	public void function testHasValidRule()	{
		makePublic( handler, 'hasValidRule' );

		// when not configured,returns "1" = truthy
		assert( handler.hasValidRule( {} ) == 1 );

		// on valid rule, returns "2" = truthy
		var rule1 = mock();
		rule1.isValid({}).returns( TRUE );
		handler.setRule( rule1 );
		assert( handler.hasValidRule( {} ) == 2 );

		// invalid rule returns "0" = falsey
		var rule2 = mock();
		rule2.isValid({}).returns( FALSE );
		handler.setRule( rule2 );
		assert( handler.hasValidRule( {} ) == 0 );
		
	}



	public void function testhasValidCommand() {
		var command1 = mock( 'voib.src.command', 'typesafe' );
		command1.getName().returns( 'foo' );
		handler.setCommand( command1 );
		makePublic( handler, 'hasValidCommand' );

		// default is to listen for the 'nil' command
		// we incorrectly assume that nobody will create a command with this name
		assert( !handler.hasValidCommand( 'jump' ) );

		// when an empty array is configured, returns TRUE
		handler.setListen ( [ ] );
		assert( handler.hasValidCommand( 'jump' ) );

		// typical use case
		handler.setListen( 'warble,sing,laugh' );
		assert( handler.hasValidCommand( 'sing' ) );
		assert( !handler.hasValidCommand( 'jump' ) );
	}



	// acceptable encapsulates hasValidAccess, hasValidRule, and hasValidCommand publicly
	public void function testAcceptable() {
		// when an empty array is configured, hasValidCommand() returns TRUE
		handler.setListen ( [ ] );

		var command1 = mock( 'voib.src.command', 'typesafe' );
		command1.getAccess().returns( 'private' );
		command1.getName().returns( 'myCommandName' );
		handler.setCommand( command1 );

		var context1 = mock( 'voib.src.context', 'typesafe' );
		context1.getData().returns( {} );
		handler.setContext( context1 );

		assert( handler.acceptable() );
	}



	public void function testOnMissingMethod() {
		// missing methods and their arguments are provided to the context for fulfillment
		fail( 'code me' );
	}
}