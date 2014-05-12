component extends="voib.tests.src.baseTest" {

	public void function setUp() {
		dataExpressionResolver = new voib.src.rule.dataexpressionresolver();
	}


	public void function testInit() {
		assert( isInstanceOf( dataExpressionResolver, 'voib.src.rule.dataexpressionresolver' ) );
		debug( dataExpressionResolver );
	}


	public void function testIsValidExpression() {
		var b = dataExpressionResolver.isValidExpression( 'v?{actNaturally}' );
		debug( b );
		assert( b );

		b = dataExpressionResolver.isValidExpression( 'v?{session.actNaturally}' );
		debug( b );
		assert( b );

		b = dataExpressionResolver.isValidExpression( 'v?{bands["beatles"]}' );
		debug( b );
		assert( b );

		// complex values are considered literals and thus valid
		var notAString = { 'beatles' = [ 'John','Paul','Ringo','George' ] };
		b = dataExpressionResolver.isValidExpression( notAString );
		debug( b );
		assert( b );

		// now fail
		b = dataExpressionResolver.isValidExpression( '' );
		debug( b );
		assert( !b );

		b = dataExpressionResolver.isValidExpression( 'v' );
		debug( b );
		assert( !b );

		b = dataExpressionResolver.isValidExpression( 'v{actNaturally}' );
		debug( b );
		assert( !b );

		b = dataExpressionResolver.isValidExpression( '${actNaturally}' );
		debug( b );
		assert( !b );

		b = dataExpressionResolver.isValidExpression( 'v77{actNaturally' );
		debug( b );
		assert( !b );
	}


	/**
	 * @mxunit:expectedException InvalidArgumentException
	**/
	public void function testShouldThrowOnInvalidExprArgument() {
		var data = {};
		dataExpressionResolver.setInvalidExpression( 'v?{__invalidExpression}' );
		dataExpressionResolver.resolveExpression( 'v?{__invalidExpression}', data );
	}



	public void function testGetTokens() {
		makePublic( dataExpressionResolver, 'getTokens' );
		var v = dataExpressionResolver.getTokens( 'application.someStruct[2]["anotherStruct"].someVariable' );
		debug( v );
		assert( isArray(v) );
		assert( arrayLen(v) == 5 );
		assert( v[1] == 'application' );
		assert( v[2] == 'someStruct' );
		assert( v[3] == '2' );
		assert( v[4] == '"anotherStruct"' );
		assert( v[5] == 'someVariable' );

		v = dataExpressionResolver.getTokens( 'myObject.myFunction()' );
		debug( v );
		assert( isArray(v) );
		assert( arrayLen(v) == 2 );
		assert( v[1] == 'myObject' );
		assert( v[2] == 'myFunction()' );

	}



	public void function testResolveToken() {
		makePublic( dataExpressionResolver, 'resolveToken' );
		data = {};
		var result = "";

		// retrieve data from a struct
		data = { 'firstName'="John", 'lastName'="Lennon" };
		result = dataExpressionResolver.resolveToken( 'firstname', data );
		debug( result );
		assert( result == 'John' );

		// retrieve complex data from a struct
		data = { 'bands'= { 'beatles' = [ 'John','Paul','Ringo','George' ], 'rollingStones' = [ 'Mick','Keith','Bill','Brian','Charlie','Ian' ] } };
		result = dataExpressionResolver.resolveToken( 'bands', data );
		debug( result );
		assert( isStruct( result ) );
		assert( result['beatles'][1] == 'John' );

		// retrieve data from an array
		data = [ 'John', 'Paul', 'George', 'Ringo' ];
		result = dataExpressionResolver.resolveToken( '2', data );
		debug( result );
		assert( result == 'Paul' );

		// retrieve complex data from an array
		data = [ { 'beatles' = [ 'John','Paul','Ringo','George' ] }, { 'rollingStones' = [ 'Mick','Keith','Bill','Brian','Charlie','Ian' ] } ];
		result = dataExpressionResolver.resolveToken( '1', data );
		debug( result );
		assert( isStruct( result ) );
		assert( result['beatles'][1] == 'John' );

	}



	public void function testResolveTokens() {
		makePublic( dataExpressionResolver, 'resolveTokens' );
		var tokens = [];
		var data = {};
		var result = "";
		var obj = mock();
		obj.sing().returns( 'Hey,Jude' );
		obj.getBand().returns ( { 'beatles'= [ 'John','Paul','Ringo','George' ] } );

		// retrieve a CF scope
		tokens = [ 'request' ];
		result = dataExpressionResolver.resolveTokens( tokens, data );
		debug( result );
		assert( isStruct( result ) );

		// retrieve a key in a CF scope
		tokens = [ 'request', '__isFound' ];
		request['__isFound'] = "TRUE";
		result = dataExpressionResolver.resolveTokens( tokens, data );
		debug( result );
		assert( result );

		// retrieve a literal
		tokens = [ "'literal'" ];
		result = dataExpressionResolver.resolveTokens( tokens, data );
		debug( result );
		assert( result == 'literal' );

		// retrieve a literal with different quotes
		tokens = [ '"literal"' ];
		result = dataExpressionResolver.resolveTokens( tokens, data );
		debug( result );
		assert( result == 'literal' );

		// retrieve a key in a struct
		tokens = [ 'firstName' ];
		data = { 'firstName'="John", 'lastName'="Lennon" };
		result = dataExpressionResolver.resolveTokens( tokens, data );
		debug( result );
		assert( result == 'John' );

		// retrieve a key in a struct of structs
		tokens = [ 'beatles', 'firstName' ];
		data = { 'beatles' = { 'firstName'="John", 'lastName'="Lennon" } };
		result = dataExpressionResolver.resolveTokens( tokens, data );
		debug( result );
		assert( result == 'John' );

		tokens = [ 'rock', 'bands', 'beatles' ];
		data = { 'rock' = { 'bands' = { 'beatles' = "a_good_band", 'rollingStones' = "another_good_band" } } };
		result = dataExpressionResolver.resolveTokens( tokens, data );
		debug( result );
		assert( result == 'a_good_band' );

		// now arrays
		tokens = [ 'bands', '1' ];
		data = { 'bands' = [ 'beatles', 'rollingStones' ] };
		result = dataExpressionResolver.resolveTokens( tokens, data );
		debug( result );
		assert( result == 'beatles' );

		tokens = [ 'bands', '1', '2' ];
		data = { 'bands' = [ [ 'John', 'Paul', 'Ringo', 'George' ], [ 'Mick','Keith','Bill','Brian','Charlie','Ian' ] ] };
		result = dataExpressionResolver.resolveTokens( tokens, data );
		debug( result );
		assert( result == 'Paul' );

		// how about an object
		tokens = [ 'bands', '1' ];
		data = { 'bands' = [ obj ] };
		result = dataExpressionResolver.resolveTokens( tokens, data );
		debug( result );
		assert( isObject( result ) );

		// how about the method of an object
		tokens = [ 'bands', '1', 'sing()' ];
		data = { 'bands' = [ obj ] };
		result = dataExpressionResolver.resolveTokens( tokens, data );
		debug( result );
		assert( result == 'Hey,Jude' );

	}



	public void function testIsParenExpr() {
		makePublic( dataExpressionResolver, 'isParenExpr' );
		var result = "";

		result = dataExpressionResolver.isParenExpr( '' );
		debug( result );
		assert( !result );

		result = dataExpressionResolver.isParenExpr( 'no' );
		debug( result );
		assert( !result );

		result = dataExpressionResolver.isParenExpr( '()no' );
		debug( result );
		assert( !result );

		result = dataExpressionResolver.isParenExpr( 'n()o' );
		debug( result );
		assert( !result );

		result = dataExpressionResolver.isParenExpr( 'yes()' );
		debug( result );
		assert( result );

	}



	public void function testStripParenExpr() {
		makePublic( dataExpressionResolver, 'stripParenExpr' );
		var result = "";

		result = dataExpressionResolver.stripParenExpr( 'blackbird' );
		debug( result );
		assert( result == 'blackbird' );

		result = dataExpressionResolver.stripParenExpr( 'blackbird()' );
		debug( result );
		assert( result == 'blackbird' );

		result = dataExpressionResolver.stripParenExpr( 'blackbird( foo )' );
		debug( result );
		assert( result == 'blackbird' );
	}



	public void function testIsQuoted() {
		makePublic( dataExpressionResolver, 'isQuoted' );
		var result = "";

		result = dataExpressionResolver.isQuoted( 'the Beatles' );
		debug( result );
		assert( !result );

		// this one is missing a trailing single quote
		result = dataExpressionResolver.isQuoted( "'the Beatles" );
		debug( result );
		assert( !result );

		// this one is missing a trailing double quote
		result = dataExpressionResolver.isQuoted( '"the Beatles' );
		debug( result );
		assert( !result );

		result = dataExpressionResolver.isQuoted( '"the Beatles"' );
		debug( result );
		assert( result );

		result = dataExpressionResolver.isQuoted( "'the Beatles'" );
		debug( result );
		assert( result );

	}



	public void function testStripQuotes() {
		makePublic( dataExpressionResolver, 'stripQuotes' );
		var result = "";

		result = dataExpressionResolver.stripQuotes( 'the Beatles' );
		debug( result );
		assert( result == 'the Beatles' );

		// this one is missing a trailing single quote
		result = dataExpressionResolver.stripQuotes( "'the Beatles" );
		debug( result );
		assert( result == "'the Beatles" );

		// this one is missing a trailing double quote
		result = dataExpressionResolver.stripQuotes( '"the Beatles' );
		debug( result );
		assert( result == '"the Beatles' );

		result = dataExpressionResolver.stripQuotes( '"the Beatles"' );
		debug( result );
		assert( result == 'the Beatles' );

		result = dataExpressionResolver.stripQuotes( "'the Beatles'" );
		debug( result );
		assert( result == 'the Beatles' );

	}

//		data = { 'bands'= { 'beatles' = [ 'John','Paul','Ringo','George' ], 'rollingStones' = [ 'Mick','Keith','Bill','Brian','Charlie','Ian' ] } };
//		data = { 'bands'= [ { 'beatles' = [ 'John','Paul','Ringo','George' ] },{ 'rollingStones' = [ 'Mick','Keith','Bill','Brian','Charlie','Ian' ] } ] };
//		data = { 'beatles' = { 'John'="guitar", 'Paul'="bass", 'Ringo'="drums", 'George'="guitar" } };



	public void function testResolveCFScopeExpression() {
		var data = { 'firstName'="Paul", 'lastName'="McCartney" };
		var result = "";

		cookie.firstName = "John";
		result = dataExpressionResolver.resolveExpression( 'v?{cookie.firstName}', cookie );
		debug( result );
		assert( result == 'John' );

		request.firstName="John";
		result = dataExpressionResolver.resolveExpression( 'v?{request.firstName}', data );
		debug( result );
		assert( result == 'John' );

		request.beatle = { 'firstName'="John", 'lastName'="Lennon" };
		result = dataExpressionResolver.resolveExpression( 'v?{beatle.firstName}', request );
		debug( result );
		assert( result == 'John' );

		request.beatle = { 'firstName'="John", 'lastName'="Lennon" };
		result = dataExpressionResolver.resolveExpression( 'v?{request.beatle.firstName}', data );
		debug( result );
		assert( result == 'John' );

	}



	public void function testResolveComplexExpression() {
		var data = {};
		var result = "";
		var obj = mock();
		obj.sing().returns( 'Hey,Jude' );
		obj.getBand().returns ( { 'beatles'= [ 'John','Paul','Ringo','George' ] } );

		// yes we can get a simple method call's return - note that no args are provided as yet.
		data = { obj = obj };
		result = dataExpressionResolver.resolveExpression( 'v?{obj.sing()}', data );
		debug( result );
		assert( result == 'Hey,Jude' );

		data = { obj = obj };
		result = dataExpressionResolver.resolveExpression( 'v?{obj.getBand()}', data );
		debug( result );
		assert( isStruct( result ) );
		assert ( result['beatles'][1] == 'John' );

		// NOTE: case insensitive
		data = { BANDS = { 'beatles'= [ 'John','Paul','Ringo','George' ] } };
		result = dataExpressionResolver.resolveExpression( 'v?{bands.beatles[1]}', data );
		debug( result );
		assert( result == 'John' );

		data = {};
		result = dataExpressionResolver.resolveExpression( 'v?{obj.getBand()}', data );
		debug( result );
		assert( result == dataExpressionResolver.getInvalidExpression() );

		data = {};
		result = dataExpressionResolver.resolveExpression( 'v?{"ticket to ride"}', data );
		debug( result );
		assert( result == 'ticket to ride' );

		data = {};
		request.bands = { 'beatles'= [ 'John','Paul','Ringo','George' ] };
		result = dataExpressionResolver.resolveExpression( 'v?{request.bands.beatles[1]}', data );
		debug( result );
		assert( result == 'John' );

		data = {};
		request['BANDS'] = { 'beatles'= [ 'John','Paul','Ringo','George' ] };
		result = dataExpressionResolver.resolveExpression( 'v?{request.bands.beatles[1]}', data );
		debug( result );
		assert( result == 'John' );

		data = { bands = { 'beatles'= [ { 'firstname'="John", 'lastname'="Lennon" },{ 'firstname'="Paul", 'lastname'="McCartney" },{ 'firstname'="Ringo", 'lastname'="Starr" },{ 'firstname'="George", 'lastname'="Harrison" } ] } };
		result = dataExpressionResolver.resolveExpression( 'v?{bands.beatles[1].FIRSTNAME}', data );
		debug( result );
		assert( result == 'John' );

		data = { 'bands' = { 'beatles'= [ 'John','Paul','Ringo','George' ] } };
		result = dataExpressionResolver.resolveExpression( 'v?{bands.beatles[1]}', data );
		debug( result );
		assert( result == 'John' );

		data = { 'beatles'= [ { 'firstName'="John", 'lastName'="Lennon" },{ 'firstName'="Paul", 'lastName'="McCartney" },{ 'firstName'="Ringo", 'lastName'="Starr" },{ 'firstName'="George", 'lastName'="Harrison" } ] };
		result = dataExpressionResolver.resolveExpression( 'v?{beatles[1].firstName}', data );
		debug( result );
		assert( result == 'John' );

		// expressions that are complex literals are returned intact
		var bands = { 'beatles'= [ { 'firstName'="John", 'lastName'="Lennon" },{ 'firstName'="Paul", 'lastName'="McCartney" },{ 'firstName'="Ringo", 'lastName'="Starr" },{ 'firstName'="George", 'lastName'="Harrison" } ] };
		result = dataExpressionResolver.resolveExpression( bands );
		debug( result );
		assert( isStruct( result ) );
	}

}