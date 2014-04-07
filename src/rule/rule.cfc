component
displayname="voib.src.rule.rule"
accessors="TRUE"
hint="Configured with a conditional clause or a conjuction with children rules, its isValid method determines whether the rule is satisfied, using provided data" {

	property name="key"                    type="string" hint="name used to retrieve a value from the data";
	property name="operator"               type="string" hint="operator used to determine if a Condition is valid, one of eq|neq|gt|gte|lt|lte|exists|doesNotExist|contains|doesNotContain|typeOf|listHas";
	property name="value"                  type="string" hint="value to be used for the operator evaluation, if necessary";
	property name="conjunction"            type="string" hint="strategy to use for node processing, one of and|or|xor or empty";
	property name="nodes"                  type="array"  hint="child rules to be applied using the conjunction property";
	property name="dataExpressionResolver" type="any"    hint="a DataExpressionResolver";
	property name="logger"                 type="any"    hint="a Logger";
	property name="comment"                type="string" hint="a descriptive comment";
	property name="parent"                 type="any"    hint="parent rule, if any";


	public rule function init( string key, string operator, string value, string conjunction, array nodes, any dataExpressionResolver, any logger, string comment ) {
		setKey( structKeyExists( arguments, 'key' ) ? arguments.key : '' );
		setOperator( structKeyExists( arguments, 'operator' ) ? arguments.operator : 'eq' );
		setValue( structKeyExists( arguments, 'value' ) ? arguments.value : '' );
		setConjunction( structKeyExists( arguments, 'conjunction' ) ? arguments.conjunction : '' );
		setNodes( structKeyExists( arguments, 'nodes' ) ? arguments.nodes : [] );
		setDataExpressionResolver( structKeyExists( arguments, 'dataExpressionResolver' ) ? arguments.dataExpressionResolver : FALSE );
		setLogger( structKeyExists( arguments, 'logger' ) ? arguments.logger : new voib.src.logger() );
		setComment( structKeyExists( arguments, 'comment' ) ? arguments.comment : '' );
		variables.parent = FALSE;
		return this;
	}



	public boolean function isValid( required struct data ) {
		var result = TRUE;
		var infoClause = "";

		// have no conjunction? that takes precedence
		// a leaf or lonely top node
		if ( !len( getConjunction() ) ) {
			result = isValidClause( arguments.data );

		} else {

			if ( arrayLen( getNodes() ) == 0 ) {
				throw( type='InvalidConfigurationException', message='No nodes exist for conjunction [#getConjunction()#]' );
			}

			switch( getConjunction() ) {

				case "and":
					result = andStrategy( arguments.data );
					break;

				case "or":
					result = orStrategy( arguments.data );
					break;

				case "xor":
					result = xorStrategy( arguments.data );
					break;
			}
		}

		if ( !hasParent() ) {
			infoClause = result ? "matched" : "did not match";
			getLogger().info( getMetaData( this ).name & ': ' & infoClause & ' rule #text()#' );
		}

		return result;
	}



	public boolean function isValidClause( required struct data ) {
		var k = getKey();
		var v = getValue();
		var isResolvedKey = FALSE;

		// unloaded keys do not throw exceptions
		if ( !len( k ) || !len( getOperator() ) ) {
			getLogger().error( getMetaData( this ).name & ': the key is missing for a condition with operator (#getOperator()#) and value (#getValue()#), cannot execute' );
			return FALSE;
		}

		// do exists
		if ( !compareNoCase( getOperator(), 'exists' ) ) {
			return structKeyExists( arguments.data, k );
		}

		// do doesNotExist
		if ( !compareNoCase( getOperator(), 'doesNotExist' ) ) {
			return !structKeyExists( arguments.data, k );
		}

		// if the key and/or value is a dataExpression (e.g. g?{something} ), resolve it
		if ( isObject( getDataExpressionResolver() ) && getDataExpressionResolver().isValidExpression( k ) ) {
			k = resolveDataExpression( k, arguments.data );
			isResolvedKey = TRUE;
		}

		if ( isObject( getDataExpressionResolver() ) && getDataExpressionResolver().isValidExpression( v ) ) {
			v = resolveDataExpression( v, arguments.data );
		}

		// missing/incorrect keys do not throw exceptions but we will log them if we can
		if ( !isResolvedKey ) {
			if ( structKeyExists( arguments.data, k ) ) {
				k = arguments.data[k];
			} else {
				getLogger().error( getMetaData( this ).name & ': the data element specified (#k#) does not exist, cannot execute #getOperator()#' );
				return FALSE;
			}
		}

		// do typeOf
		if ( !compareNoCase( getOperator(), 'typeOf' ) ) {
			if ( !isObject( k ) ) {
				getLogger().error( getMetaData( this ).name & ': the data element specified (#getKey()#) is not an object, cannot do typeOf condition' );
				return FALSE;
			}
			if ( !isSimpleValue( v ) ) {
				getLogger().error( getMetaData( this ).name & ': the value specified (#getValue()#) is not a simple value, cannot do typeOf condition' );
				return FALSE;
			}
			return isInstanceOf( k, v );
		}

		if ( !isSimpleValue( k ) ) {
			getLogger().debug( getMetaData( this ).name & ': the key (#getKey()#) is not a simple value, cannot execute #getOperator()#' );
			return FALSE;
		}


		if ( !isSimpleValue( v ) ) {
			getLogger().debug( getMetaData( this ).name & ': the value specified (#getValue()#) is not a simple value, cannot execute #getOperator()#' );
			return FALSE;
		}

		// cfset clause = DE(responseValue) & ' ' & operator & ' ' & DE(conditionValue) /
		// doing match() instead of evaluate() gives us the option of future additional operators (LIKE)
		getLogger().debug( getMetaData( this ).name & ': checking if #k# #getOperator()# #v#' );
		return match( k, getOperator(), v );
	}



	public string function text() hint="provides debugging text" {
		var k = isSimpleValue( getKey() ) ? getKey() : "[complex value]" ;
		var v = isSimpleValue( getValue() ) ? getValue() : "[complex value]" ;
		var t = "";
		var i = 0;
		var node = FALSE;
		var nodes = getNodes();
		var sz = arrayLen( nodes );

		// a leaf or lonely top node
		if ( !len( getConjunction() ) ) {

			// a rule with no nodes and no key is "empty" (not configured) but considered TRUE
			if ( !len( k ) ) { return "TRUE!"; }

			t = k & ' ' & getOperator();
			if ( len( v ) ) { t = t & ' ' & v; }
			if ( hasParent() ) { t = '( ' & t & ' )'; }

			return t;
		}

		while ( i < sz ) {
			if ( i != 0 ) { t = t & " " & getConjunction() & " "; }

			node = nodes[++i];
			t = t & node.text();
		}

		return t;
	}



	public void function setConjunction( required string conjunction ) {
		if ( len( arguments.conjunction ) && !listFind( 'and,or,xor', lCase( arguments.conjunction ) ) ) {
			throw( type='InvalidArgumentException', message='Conjunction argument must be empty, or one of: and|or|xor, was: [#arguments.conjunction#]' );
		}

		variables.conjunction = lCase( arguments.conjunction );
	}



	public void function setOperator( required string operator ) hint="" {
		var op = lCase( arguments.operator );
		if ( op == 'doesnotexist' ) { op = 'doesNotExist'; }
		if ( op == 'doesnotcontain' ) { op = 'doesNotContain'; }
		if ( op == 'typeof' ) { op = 'typeOf'; }
		if ( op == 'listhas' ) { op = 'listHas'; }
		if ( !listFind( 'eq,neq,gt,gte,lt,lte,exists,doesNotExist,contains,doesNotContain,typeOf,listHas', op ) ) {
			throw( type='InvalidArgumentException', message='operator argument must be one of: eq|neq|gt|gte|lt|lte|exists|doesNotExist|contains|doesNotContain|typeOf|listHas, was: [#arguments.operator#]' );
		}
		variables.operator = op;
	}



	public void function setNodes( required array nodes ) {
		var i = 0;
		var sz = arrayLen(nodes);
		var node = FALSE;

		variables.nodes = [];

		while ( i < sz ) {
			node = nodes[++i];
			node.setParent( this );
		}
		variables.nodes = arguments.nodes;
	}



	public void function setParent( required rule parent ) {
		variables.parent = arguments.parent;
	}



	public boolean function hasParent() {
		return isObject( getParent() );
	}



	private boolean function andStrategy( required struct data ) hint="all nodes must be TRUE" {
		var i = 0;
		var nodes = getNodes();
		var node = FALSE;
		var result = TRUE;

		while ( i < arrayLen( nodes ) ) {
			node = nodes[++i];
			if ( !node.isValid( arguments.data ) ) {
				result = FALSE;
				break;
			}
		}

		return result;
	}



	private boolean function orStrategy( required struct data ) hint="at least one node must be TRUE" {
		var i = 0;
		var nodes = getNodes();
		var node = FALSE;
		var result = FALSE;

		while ( i < arrayLen( nodes ) ) {
			node = nodes[++i];
			if ( node.isValid( arguments.data ) ) {
				result = TRUE;
				break;
			}
		}

		return result;
	}



	private boolean function xorStrategy( required struct data ) hint="one node must be TRUE, the other FALSE" {
		var i = 0;
		var nodes = getNodes();
		var node = FALSE;
		var v = [];

		if ( getConjunction() == 'xor' && arrayLen( nodes ) != 2 ) {
			throw( type='InvalidConfigurationException', message='Only two nodes are allowed when conjunction is "xor", there were ' & arrayLen( nodes ) );
		}

		while ( i < 2 ) {
			node = nodes[++i];
			v[i] = node.isValid( arguments.data );
		}

		if ( ( !v[1] && v[2] ) || ( v[1] && !v[2] ) ) {
			return TRUE;
		}

		return FALSE;
	}



	private boolean function match ( required any elementValue, required string operator, required any conditionValue ) {
		var temp = FALSE;

		switch( arguments.operator ) {

			case "eq":
				return ( arguments.elementValue eq arguments.conditionValue );
				break;

			case "neq":
				return ( arguments.elementValue neq arguments.conditionValue );
				break;

			case "lt":
				return ( arguments.elementValue lt arguments.conditionValue );
				break;

			case "lte":
				return ( arguments.elementValue lte arguments.conditionValue );
				break;

			case "gt":
				return ( arguments.elementValue gt arguments.conditionValue );
				break;

			case "gte":
				return ( arguments.elementValue gte arguments.conditionValue );
				break;

			case "contains":
				return ( arguments.elementValue contains arguments.conditionValue );
				break;

			case "doesNotContain":
				return ( arguments.elementValue does not contain arguments.conditionValue );
				break;

			case "listHas":
				return yesNoFormat( ( listFindNoCase( arguments.elementValue, arguments.conditionValue ) ) );
				break;
		}
	}



	// extension point for data expression resolution (e.g. g?{something} )
	private any function resolveDataExpression( required any expr, required struct data ) {
		var v = "";

		if ( !isObject( getDataExpressionResolver() ) ) {
			getLogger().debug( getMetaData( this ).name & ': null dataExpressionResolver' );
			return arguments.expr;
		}

		v = getDataExpressionResolver().resolveExpression( arguments.expr, arguments.data );
		if ( isSimpleValue( v ) && v == getDataExpressionResolver().getInvalidExpression() ) {
			getLogger().warn( getMetaData( this ).name & ': could not resolve expression: #arguments.expr#' );
			return arguments.expr;
		}

		return v;
	}

}