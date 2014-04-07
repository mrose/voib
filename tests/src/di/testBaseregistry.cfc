component extends="voib.tests.src.baseTest" {


	public void function setUp() {
		registry = new voib.src.di.baseregistry();
	}

	// is the correct type
	public void function testInit() {
		assert( isInstanceOf( registry, 'voib.src.di.baseregistry' ) );
		debug( registry );
	}



	// getAll() returns an array
	public void function testGetAllReturnsAnArray() {
		assert( isArray( registry.getAll() ) );
	}
	


	/**
	* @mxunit:expectedException InvalidBeanNameException
	*/
	public void function testThrowsWhenBeanNotFound() {
		registry.getBean( 'red' );
	}

}