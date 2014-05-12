component extends="voib.tests.src.di.testBaseregistry" {


	public void function setUp() {
		registry = new voib.src.di.di1registry( '/voib/tests/resources/' );
	}



	// is the correct type
	public void function testInit() {
		assert( isInstanceOf( registry, 'voib.src.di.di1registry' ) );
		// assert( isInstanceOf( registry, 'voib.src.di.baseregistry' ) ); extends di1.ioc instead. grrr. 
		debug( registry );
	}


	// can load beans
	public void function testCanLoadBeans() {
		assert( !structIsEmpty( registry.getBeanInfo().beanInfo ) );
	}


	// getAll
	public void function testGetAll() {
		assert( !arrayIsEmpty( registry.getAll() ) );
	}


	// containsBean
	public void function testContainsBean() {
//		debug( registry.getBeanInfo().beanInfo );
		assert( registry.containsBean('testHandler') );
	}


	// getBean
	public void function testGetBean() {
		assert( isInstanceOf( registry.getBean('testHandler'), 'voib.tests.resources.testHandler' ) );
	}


}