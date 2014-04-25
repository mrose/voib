component extends="voib.tests.src.baseTest" {


	public void function setUp() {
		// signature: ( required string name, struct args=structNew(), string access="private" )
		command = new voib.src.command( 'default' );
		h1 = mock();
		h1.getName().returns( 'handler1' );
		h2 = mock();
		h2.getName().returns( 'handler2' );
	}



	public void function testInit() {
		debug( command );
		assert( isInstanceOf( command, 'voib.src.command' ) );
	}



	// handlers must be a component or array of them
	/**
	* @mxunit:expectedException InvalidArgumentException
	*/
	public void function testSetHandlersThrowsExceptionOnInvalidInput() {
		var st = { };
		command.setHandlers( st );
	}



	public void function testSetHandlers() {
		command.setHandlers( [ h1, h2 ] );
		command.setHandlers( h1 );
	}



	public void function testHasHandlers() {
		var b = command.hasHandlers();
		debug( b );
		assert( !b );

		command.setHandlers( [ h1, h2 ] );
		b = command.hasHandlers();
		debug( b );
		assert ( b );
	}



	public void function testGetHandlerNames() {
		var nm = command.getHandlerNames();
		assert( len( nm ) == 0 );

		command.setHandlers( [ h1, h2 ] );
		nm = command.getHandlerNames();
		debug( nm );
		assert( nm == 'handler1,handler2' );
	}



	// returns a temporary default value for a missing argument
	public void function testReturnsTemporaryDefaultForMissingArg() {
		assert( 'providedDefault' == command.getArg( 'someMissingKey', 'providedDefault' ) );
	}
	
}