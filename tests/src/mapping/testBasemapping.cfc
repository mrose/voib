component extends="voib.tests.src.baseTest" {


	public void function setUp() {
		mapping = new voib.src.mapping.basemapping();
	}


	// is the correct type
	public void function testInit() {
		assert( isInstanceOf( mapping, 'voib.src.mapping.basemapping' ) );
		debug( mapping );
	}


	/**
	 * @mxunit:expectedException Method.NotImplemented
	**/
	public void function testGetHandlerThrows() {
		var h = mapping.getHandlers( mock( 'command' ) );
	}


	/**
	* @mxunit:expectedException InvalidArgumentException
	*/
	public void function testSetOrderThrowsWithNegativeNumber() {
		mapping.setOrder(-1);
	}



	/**
	* @mxunit:expectedException InvalidArgumentException
	*/
	public void function testSetOrderThrowsWhenNumberTooHigh() {
		mapping.setOrder( 1000000000 );
	}


	// TODO: ordermap() tests
	public void function testReorderReturnsEmptyArrayOnEmptyInput() {
		makePublic( mapping, 'reorder' );
		assert( arrayIsEmpty( mapping.reorder( [ ] ) ) );
		assert( arrayIsEmpty( mapping.reorder( { } ) ) );
	}

}	