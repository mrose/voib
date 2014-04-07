component extends="voib.tests.src.di.testBaseregistry" {


	public void function setUp() {
		registry = new voib.src.di.coldspringregistry();
	}



	// is the correct type
	public void function testInit() {
		assert( isInstanceOf( registry, 'voib.src.di.coldspringregistry' ) );
		// assert( isInstanceOf( registry, 'voib.src.di.baseregistry' ) ); extends the Coldspring BF instead. grrr. 
		debug( registry );
	}



	// can load beans
	public void function testLoadBeans() {
		registry.loadBeans( "/voib/tests/resources/di/testColdspringregistry.xml" );
		var result = registry.getBeanDefinitionList();
		assert( structKeyExists( result, 'testBean' ) );
		assert( structKeyExists( result, 'testHandlerA' ) );
		assert( structKeyExists( result, 'testHandlerB' ) );
		assert( structKeyExists( result, 'testHandlerC' ) );
		assert( structKeyExists( result, 'testHandlerD' ) );
	}



	public void function testFindAllBeanNamesByType() {
		registry.loadBeans( "/voib/tests/resources/di/testColdspringregistry.xml" );
		var result = registry.findAllBeanNamesByType( 'voib.tests.resources.testHandler' );
		debug( result );
		assert( arrayLen( result ) == 4 );
		assert( listFindNoCase( arrayToList(result), 'testHandlerA' ) );
		assert( listFindNoCase( arrayToList(result), 'testHandlerB' ) );
		assert( listFindNoCase( arrayToList(result), 'testHandlerC' ) );
		assert( listFindNoCase( arrayToList(result), 'testHandlerD' ) );
	}



	public void function testGetAll() {
		registry.loadBeans( "/voib/tests/resources/di/testColdspringregistry.xml" );
		var result = registry.getAll( ['voib.tests.resources.testHandler'], FALSE );
		debug( result );
		assert( arrayLen( result ) == 4 );
	}



}