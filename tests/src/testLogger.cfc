component extends="voib.tests.src.baseTest" {


	public void function setUp() {
		logger = new voib.src.logger();
	}


	// is the correct type
	public void function testInit() {
		assert( isInstanceOf( logger, 'voib.src.logger' ) );
		debug( logger );
	}


	// can set a valid level : nil,debug,info,warn,error,fatal
	public void function testCanSetValidLevels() {
		logger.setLevel( 'nil' );
		logger.setLevel( 'debug' );
		logger.setLevel( 'info' );
		logger.setLevel( 'warn' );
		logger.setLevel( 'error' );
		logger.setLevel( 'fatal' );
	}


	// cannot set an invalid level
	/**
	* @mxunit:expectedException InvalidArgumentException
	*/
	public void function testThrowsOnInvalidLevel() {
		logger.setLevel( 'foobar' );
	}


	public void function testIsDebugEnabled() {
		logger.setLevel( 'debug' );
		assert( logger.isDebugEnabled() );
		assert( logger.isInfoEnabled() );
		assert( logger.isWarnEnabled() );
		assert( logger.isErrorEnabled() );
		assert( logger.isFatalEnabled() );
	}


	public void function testIsInfoEnabled() {
		logger.setLevel( 'info' );
		assert( !logger.isDebugEnabled() );
		assert( logger.isInfoEnabled() );
		assert( logger.isWarnEnabled() );
		assert( logger.isErrorEnabled() );
		assert( logger.isFatalEnabled() );
	}


	public void function testIsWarnEnabled() {
		logger.setLevel( 'warn' );
		assert( !logger.isDebugEnabled() );
		assert( !logger.isInfoEnabled() );
		assert( logger.isWarnEnabled() );
		assert( logger.isErrorEnabled() );
		assert( logger.isFatalEnabled() );
	}


	public void function testIsErrorEnabled() {
		logger.setLevel( 'error' );
		assert( !logger.isDebugEnabled() );
		assert( !logger.isInfoEnabled() );
		assert( !logger.isWarnEnabled() );
		assert( logger.isErrorEnabled() );
		assert( logger.isFatalEnabled() );
	}


	public void function testIsFatalEnabled() {
		logger.setLevel( 'fatal' );
		assert( !logger.isDebugEnabled() );
		assert( !logger.isInfoEnabled() );
		assert( !logger.isWarnEnabled() );
		assert( !logger.isErrorEnabled() );
		assert( logger.isFatalEnabled() );
	}


	public void function testIsNilEnabled() {
		logger.setLevel( 'nil' );
		assert( !logger.isDebugEnabled() );
		assert( !logger.isInfoEnabled() );
		assert( !logger.isWarnEnabled() );
		assert( !logger.isErrorEnabled() );
		assert( !logger.isFatalEnabled() );
	}


}