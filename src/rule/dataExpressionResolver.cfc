component
displayname="voib.src.rule.dataexpressionresolver"
accessors="TRUE"
hint="Returns the result of an expression against provided data using the special syntax v?{myVariable}.
The expression can contain bracket syntax (i.e. v?{myArray[2]} or v?{myStruct['myVariable']}), dotted syntax (i.e. v?{myStruct.myVariable}), or a mixture.
There is no limit to the depth of the expression.
Expressions which begin with a literal (i.e. 'v?{myLiteral}' ) will return the literal value, ignoring any provided data.
Expressions which begin with the ColdFusion scopes: Server, Application, Session, Request, and Cookie will use that scope as the
starting point for expression resolution, ignoring any provided data.
Returns its invalidExpression property when an expression cannot be resolved." {


	property type="any" name="logger" hint="any logger";
	property type="string" name="invalidExpression" hint="string to use to determine if an expression is not resolved correctly";


	public dataexpressionresolver function init( any logger, string invalidExpression ) {
		setLogger( structKeyExists( arguments, 'logger' ) ? arguments.logger : new voib.src.logger() );
		setInvalidExpression( structKeyExists( arguments, 'invalidExpression' ) ? arguments.invalidExpression : 'v?{__invalidExpression}' );
		return this;
	}



	public any function isValidExpression( required any expr ) {
		// if the expression is not a string, it is a literal and thus considerered valid
		if ( !isSimpleValue( arguments.expr ) ) {
			return TRUE;
		}
		return REFindNoCase( '^v\?\{(.)+}', arguments.expr );
	}



	public any function resolveExpression( required any expr, struct data='#{}#' ) {
		var v = getInvalidExpression();

		if ( isSimpleValue( arguments.expr ) && arguments.expr == getInvalidExpression() ) {
			throw ( type='InvalidArgumentException', message='The expr argument to the resolveExpression function cannot be #getInvalidExpression()# which is the invalidExpression property of the component' );
		}

		if ( !isValidExpression( arguments.expr ) ) {
			getLogger().warn( 'invalid expression syntax: #arguments.expr#' );
			return v;
		}

		// if the expression is not a string, it is a literal and thus returned intact
		if ( !isSimpleValue( arguments.expr ) ) {
			return arguments.expr;
		}

		v = resolveTokens( getTokens( getStrippedExpression( arguments.expr ) ), arguments.data );

		if ( isSimpleValue( v ) && v == getInvalidExpression() ) {
			getLogger().warn( 'could not resolve expression to data for #arguments.expr#' );
		}

		return v;
	}



	private any function resolveTokens( required array tokens, required any data ) {
		var t = arguments.tokens;
		var d = arguments.data;
		var sz = arrayLen( t );
		var i = 0;

		try {

			for ( i=1; i <= sz; i++ ) {
				getLogger().debug( 't[#i#] is #t[i]#' );

				if ( i == 1 ) {
					// when the first token is the name of a CF scope, working data set becomes that scope
					if ( listFindNoCase( 'server,application,session,request,cookie', t[i] ) ) {
						getLogger().debug( '#t[i]# is a CF scope' );
						d = getScope( t[i] );
						continue;
					}
	
					// when the first token is a string literal, we'll return the literal without quotes as the resolved expression
					if ( isQuoted( t[i] ) ) {
						d = stripQuotes( t[i] );
						break;
					}

				}

				d = resolveToken( stripQuotes( t[i] ), d );
				if ( isSimpleValue(d) && d == getInvalidExpression() ) {
					break;
				}

			} // end loop

		}
		catch ( any e ) {
			d = getInvalidExpression();
//d = e;
			getLogger().error( e['message'] & ' ' & e['detail'] );
		}

		if ( isSimpleValue( d ) ) {
			getLogger().debug( 'expression resolved to #d#' );
		} else {
			getLogger().debug( 'expression resolved to a complex value' );
		}

		return d;
	}



	private any function resolveToken( required string key, required any data ) {
		var m = "";

		if ( isObject( arguments.data ) ) {
			getLogger().debug( 'data is an object instance, executing method #arguments.key#' );
			return invoke( cfcinstance='#arguments.data#', methodname='#stripParenExpr( arguments.key )#' );
		}

		if ( isStruct( arguments.data ) && structKeyExists( arguments.data, arguments.key ) ) {
			getLogger().debug( 'data is a struct, finding key #arguments.key#' );
			return arguments.data[arguments.key];
		}

		if ( isArray( arguments.data ) && isNumeric( arguments.key ) && arrayLen( arguments.data ) >= arguments.key ) {
			getLogger().debug( 'data is an array, finding element #arguments.key#' );
			return arguments.data[arguments.key];
		}

		getLogger().debug( 'uh oh, cannot find key #arguments.key#' );
		return getInvalidExpression();
	}



	private string function stripParenExpr( required string expr ) {
		var s = arguments.expr;
		var c = isParenExpr( arguments.expr );

		if ( c ) {
			return left( s, --c );
		}
		return s;
	}


	private numeric function isParenExpr( required string expr ) {
		return REFind( '[\(](.)*[\)]$', arguments.expr );
//		return REFind( '[\(](.)*[\)]$', arguments.expr, 1, 'TRUE' );
	}



	private string function stripQuotes( required string expr ) {
		var s = arguments.expr;
		if ( isQuoted(s) ) {
			return mid( s, 2, len(s)-2 );
		}
		return s;
	}



	private boolean function isQuoted( required string expr ) {
		// a single quote escapes another single quote
		return reFind( '^["|''](.)*["|'']$', arguments.expr );
	}



	private string function getStrippedExpression( required string expr ) {
		var value = mid( arguments.expr, 4, len( arguments.expr )-4 );
		return value;
	}



	private array function getTokens( required string expr ) {
		return listToArray( listChangeDelims( arguments.expr, '|', '[.]' ), '|' );
	}



	private any function getScope( required string scopeName ) {
		switch( lCase( arguments.scopeName ) ) {
			case "server":
				return server;
				break;
			case "application":
				return application;
				break;
			case "session":
				return session;
				break;
			case "request":
				return request;
				break;
			case "cookie":
				return cookie;
				break;
		}
	}

}