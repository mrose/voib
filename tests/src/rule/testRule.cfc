component extends="voib.tests.src.baseTest" {


	public void function setUp() {
		rule = new voib.src.rule.rule();
	}



	// is the correct type
	public void function testInit() {
		assert( isInstanceOf( rule, 'voib.src.rule.rule' ) );
		debug( rule );
		// defaults:
		assert( rule.getConjunction() == '' );
		assert( rule.getKey() == '' );
		assert( rule.getOperator() == 'eq' );
		assert( rule.getValue() == '' );
		assert( arrayIsEmpty( rule.getNodes() ) );
		assert( rule.getDataExpressionResolver() == FALSE );
		assert( isObject( rule.getLogger() ) );
		assert( rule.getComment() == '' );
		assert( rule.getParent() == FALSE );
	}



	public void function testValidConjunctions() {
		var a = listToArray('and,or,xor,');
		var i = 0;
		while ( i < arrayLen(a) ) {
			rule.setConjunction( a[++i] );
		}
	}



	/**
	* @mxunit:expectedException InvalidArgumentException
	*/
	public void function testThrowsExceptionOnIllegalConjunctionArg() {
		rule.setConjunction( 'nop' );
	}



	public void function testValidOperators() {
		var a = listToArray('eq,neq,gt,gte,lt,lte,exists,doesNotExist,contains,doesNotContain,typeOf,listHas');
		var i = 0;
		while ( i < arrayLen(a) ) {
			rule.setOperator( a[++i] );
		}
	}



	/**
	* @mxunit:expectedException InvalidArgumentException
	*/
	public void function testThrowsExceptionOnIllegalOperatorArg() {
		rule.setOperator( 'aBeatle', 'anInvalidOperator','' );
	}



	public void function testSetParent() {
		var parent = new voib.src.rule.rule();
		rule.setParent( parent );
	}



	public void function testHasParent() {
		var parent = new voib.src.rule.rule();
		assert( !rule.hasParent() );
		rule.setParent( parent );
		assert( rule.hasParent() );
	}



	public void function testSetNodes() {
		var node1 = new voib.src.rule.rule();
		var node2 = new voib.src.rule.rule();
		var node3 = new voib.src.rule.rule();
		var nodes = [node1,node2,node3];
		rule.setNodes( nodes );
		nodes = rule.getNodes();
		debug( nodes );
		assert( isInstanceOf( nodes[1].getParent(), 'voib.src.rule.rule' ) );
		assert( isInstanceOf( nodes[2].getParent(), 'voib.src.rule.rule' ) );
		assert( isInstanceOf( nodes[3].getParent(), 'voib.src.rule.rule' ) );
	}



	public void function testSimpleText() {
		rule.init( key='name', operator='eq', value='Flipper' );
		var text = rule.text();
		debug( text );
		assert( findNoCase( 'name', text ) );
		assert( findNoCase( 'eq', text ) );
		assert( findNoCase( 'Flipper', text ) );
	}



	public void function testComplexText() {
		var hasBlueDog = new voib.src.rule.rule( 'bluedog', 'exists' );
		var hasRedSquirrel = new voib.src.rule.rule( 'redsquirrel', 'eq', '910' );
		var hasGreenCat = new voib.src.rule.rule( 'greencat', 'eq', 'meow' );
		var nodes = [ hasBlueDog, hasRedSquirrel, hasGreenCat ];
		rule.setConjunction( 'or' );
		rule.setNodes( nodes );
		debug( rule.text() );
		assert( rule.text() == '( bluedog exists ) or ( redsquirrel eq 910 ) or ( greencat eq meow )' );
	}



	public void function testAndStrategy() {
		makePublic( rule, 'andStrategy' );
		var hasBlueDog = new voib.src.rule.rule( 'bluedog', 'exists' );
		var hasRedSquirrel = new voib.src.rule.rule( 'redsquirrel', 'eq', '910' );
		var hasGreenCat = new voib.src.rule.rule( 'greencat', 'eq', 'meow' );
		var nodes = [ hasBlueDog, hasRedSquirrel, hasGreenCat ];
		var data = { 'bluedog'="", 'redsquirrel'="910", 'greencat'="meow"  };
		rule.setConjunction( 'and' );
		rule.setNodes( nodes );
		assert( rule.andStrategy( data ) );	
	}



	public void function testOrStrategy() {
		makePublic( rule, 'orStrategy' );
		var hasBlueDog = new voib.src.rule.rule( 'bluedog', 'exists' );
		var hasRedSquirrel = new voib.src.rule.rule( 'redsquirrel', 'eq', '910' );
		var hasGreenCat = new voib.src.rule.rule( 'greencat', 'eq', 'meow' );
		var nodes = [ hasBlueDog, hasRedSquirrel, hasGreenCat ];
		var data = { 'redsquirrel'="909", 'greencat'="meow"  };
		rule.setConjunction( 'or' );
		rule.setNodes( nodes );
		assert( rule.orStrategy( data ) );	
	}


	/**
	* @mxunit:expectedException InvalidConfigurationException
	*/
	public void function testXorStrategyThrowsOnIllegalConfiguration() {
		makePublic( rule, 'xorStrategy' );
		var node1 = new voib.src.rule.rule();
		var node2 = new voib.src.rule.rule();
		var node3 = new voib.src.rule.rule();
		var nodes = [node1,node2,node3];
		rule.setNodes( nodes );
		rule.setConjunction( 'xor' );
		var result = rule.isValid( {} );
	}



	public void function testXorStrategy() {
		makePublic( rule, 'xorStrategy' );
		var hasBlueDog = new voib.src.rule.rule( 'bluedog', 'exists' );
		var hasGreenCat = new voib.src.rule.rule( 'greencat', 'eq', 'meow' );
		var nodes = [ hasBlueDog, hasGreenCat ];
		var data = { 'redsquirrel'="909", 'greencat'="meow"  };
		rule.setConjunction( 'xor' );
		rule.setNodes( nodes );
		assert( rule.xorStrategy( data ) );	
	}



	public void function testMatch() {
		makePublic( rule, 'match' );
		assert( rule.match( '1', 'eq', '1' ) );
		assert( !rule.match( '1', 'eq', '2' ) );
		assert( rule.match( '1', 'neq', '2' ) );
		assert( !rule.match( '1', 'neq', '1' ) );
		assert( rule.match( '1', 'lt', '2' ) );
		assert( !rule.match( '1', 'lt', '1' ) );
		assert( rule.match( '1', 'lte', '1' ) );
		assert( !rule.match( '1', 'lte', '0' ) );
		assert( rule.match( '2', 'gt', '1' ) );
		assert( !rule.match( '2', 'gt', '2' ) );
		assert( rule.match( '2', 'gte', '2' ) );
		assert( !rule.match( '2', 'gte', '3' ) );
		assert( rule.match( 'abc', 'contains', 'a' ) );
		assert( !rule.match( 'abc', 'contains', 'z' ) );
		assert( rule.match( 'abc', 'doesNotContain', 'z' ) );
		assert( !rule.match( 'abc', 'doesNotContain', 'a' ) );
		assert( rule.match( 'a,b,c', 'listHas', 'a' ) );
		assert( !rule.match( 'a,b,c', 'listHas', 'x' ) );
	}



	public void function testIsValidClause() {

		emptyRule = new voib.src.rule.rule();
		assert( isInstanceOf( emptyRule, 'voib.src.rule.rule' ) );
		data = { 'emptyRule'=emptyRule, 'aBeatle'='John', 'aNumber'=10, aList='aaa,bbb,ccc,ddd' };

		// unloaded keys do not throw exceptions
		assert( !emptyRule.isValid( data ) );

		// missing/incorrect keys do not throw exceptions
		missingKeyRule = new voib.src.rule.rule( key='name', operator='eq', value='Flipper' );
		assert( !missingKeyRule.isValid( data ) );

		// happy paths
		rule.init( key='aBeatle', operator='eq', value='John' );
		assert( rule.isValid( data ) );

		rule.init( key='aBeatle', operator='neq', value='Paul' ); // luaP deirub I
		assert( rule.isValid( data ) );

		rule.init( key='aNumber', operator='gt', value='5' );
		assert( rule.isValid( data ) );

		rule.init( key='aNumber', operator='gte', value='10' );
		assert( rule.isValid( data ) );

		rule.init( key='aNumber', operator='lt', value='20' );
		assert( rule.isValid( data ) );

		rule.init( key='aNumber', operator='lte', value='10' );
		assert( rule.isValid( data ) );

		rule.init( 'aBeatle', 'exists' );
		assert( rule.isValid( data ) );

		rule.init( 'aTurtle', 'doesNotExist' );
		assert( rule.isValid( data ) );

		rule.init( 'aBeatle', 'contains', 'J' );
		assert( rule.isValid( data ) );

		rule.init( 'aBeatle', 'doesNotContain', 'Z' );
		assert( rule.isValid( data ) );

		rule.init( 'emptyRule', 'typeOf', 'voib.src.rule.rule' );
//		debug( getMetaData( rule ) );
		assert( rule.isValid( data ) );

		rule.init( 'aList', 'listHas', 'aaa' );
//debug( getMetaData( rule ) );
		assert( rule.isValid( data ) );
		rule.init( 'aList', 'listHas', 'Q' );
		assert( !rule.isValid( data ) );
	}



	public void function testIsValid() {
		var hasBlueDog = new voib.src.rule.rule( 'bluedog', 'exists' );
		var hasRedSquirrel = new voib.src.rule.rule( 'redsquirrel', 'eq', '910' );
		var hasGreenCat = new voib.src.rule.rule( 'greencat', 'eq', 'meow' );
		var nodes = [ hasBlueDog, hasRedSquirrel, hasGreenCat ];
		var data = { 'bluedog'="", 'redsquirrel'="910", 'greencat'="meow"  };
		rule.setConjunction( 'and' );
		rule.setNodes( nodes );
		assert( rule.isValid( data ) );
	}

}