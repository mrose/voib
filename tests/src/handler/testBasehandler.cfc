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
		assert( isArray( handler.getListen() ) && arrayIsEmpty( handler.getListen() ) );
		assert( handler.getRule() == FALSE );
	}


	public void function testAnnotations() {
		// you can use annotations for the default properties, except for rule
//		handler = new voib.tests.resources.testHandler();
//		makePublic( handler, 'listenMetadata' );
//		handler.listenMetadata();
//		assert( arrayFind( handler.getListen(), 'eat' ) );
//		assert( arrayFind( handler.getListen(), 'drink' ) );
//		assert( arrayFind( handler.getListen(), 'sleep' ) );


		// annotations take precedence over constructor arguments
		// TODO: probably should be the other way round

		fail('code me');
	}


	// the basehandler execute should throw an error of type "Method.NotImplemented"
	/**
	* @mxunit:expectedException Method.NotImplemented
	*/
	public void function testExecute() {
		handler.execute( 'command', 'context' );
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
		makePublic( handler, 'hasValidCommand' );
		// when not configured returns TRUE
		assert( handler.hasValidCommand( 'myCommandName' ) );
		handler.setListen( [ 'myCommandName','someOtherCommandName'] );
		assert( handler.hasValidCommand( 'myCommandName' ) );
		assert( !handler.hasValidCommand( 'missingCommandName' ) );
	}



	// acceptable encapsulates hasValidAccess, hasValidRule, and hasValidCommand publicly
	public void function testAcceptable() {

		var command1 = mock();
		command1.getAccess().returns( 'private' );
		command1.getName().returns( 'myCommandName' );

		var context1 = mock();
		context1.getData().returns( {} );

		assert( handler.acceptable( command1, context1 ) );
	}



	public void function testOnMissingMethod() {
		// missing methods and their arguments are provided to the context for fulfillment
		fail( 'code me' );
	}
}