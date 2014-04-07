component extends="voib.tests.src.di.testBaseregistry" {


	public void function setUp() {
		registry = new voib.src.di.di1registry( '/voib/tests/resources/di' );
	}



	// is the correct type
	public void function testInit() {
		assert( isInstanceOf( registry, 'voib.src.di.di1registry' ) );
		// assert( isInstanceOf( registry, 'voib.src.di.baseregistry' ) ); extends di1.ioc instead. grrr. 
		debug( registry );
	}


	// can load beans
	public void function testCanLoadBeans() {
		fail( 'todo' );
	}

	// getAll
	public void function testGetAll() {
		fail( 'todo' );
	}


	// containsBean
	public void function testContainsBean() {
		fail( 'todo' );
	}


	// getBean
	public void function testGetBean() {
		fail( 'todo' );
	}


}