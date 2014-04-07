component extends="voib.tests.src.baseTest" {


	public void function setUp() {
		mapping = new voib.src.mapping.multicastmapping();
	}


	// is the correct type
	public void function testInit() {
		assert( isInstanceOf( mapping, 'voib.src.mapping.basemapping' ) );
		assert( isInstanceOf( mapping, 'voib.src.mapping.multicastmapping' ) );
		debug( mapping );
	}


	public void function testGetHandlersReturnsArray() {
		var cmd = mock( 'command' );
		cmd.getName().returns( 'mock' );
		var h = mapping.getHandlers( cmd );
		debug( h );
		assert( isArray( h ) );
	}

}	