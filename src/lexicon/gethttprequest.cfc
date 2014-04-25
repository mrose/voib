component
displayname="voib.src.lexicon.gethttprequest"
extends="voib.src.handler.basehandler"
accessors="TRUE"
hint="Marshalls url, form, cgi, and http header data to be used as input for processing using configuration." {

	property type="string" name="scopeSequence" hint="order of ColdFusion scopes to be inspected for input variables";
	property type="string" name="defaultUrlVariables" hint="comma delimited list of variable names allowed for input from ColdFusion's URL scope, defaults to '*', meaning all";
	property type="string" name="defaultFormVariables" hint="comma delimited list of variable names allowed for input from ColdFusion's Form scope, defaults to '*', meaning all";
	property type="string" name="defaultCgiVariables" hint="comma delimited list of variable names allowed for input from ColdFusion's CGI scope";
	property type="string" name="defaultHttpRequestDataVariables" hint="comma delimited list of variable names allowed for input returned from ColdFusion's getHttpRequestData() function";

	// parent property string access;
	// parent property string comment;
	// parent property string name;
	// parent property numeric order;
	// parent property array listen;
	// parent property any rule;


	public voib.src.lexicon.gethttprequest function init( string access, string name, string comment, numeric order, array listen, any rule ) {
		arguments.access = "public"; // this one is public!
		super.init( argumentCollection=arguments );
		setScopeSequence( 'url,form,cgi,httpRequestData' );
		setDefaultUrlVariables( '*' );
		setDefaultFormVariables( '*' );
		setDefaultCgiVariables( 'REMOTE_ADDR,SERVER_PORT,SERVER_PORT_SECURE,SERVER_NAME,PATH_INFO,SCRIPT_NAME' );
		setDefaultHttpRequestDataVariables( 'headers,method,protocol' );
		return this;
	}


	public void function execute() {
		var cmd = getCommand();
		var cxt = getContext();
		var key = "" ;
		var requestData = {};
		var i = 0;

		if ( !acceptable() ) {
			return;
		}

		for ( i=1; i <= listLen( getScopeSequence() ); i++ ) {
			key = listGetAt( getScopeSequence(), i );
			st = getScopedVariables( key, resolveVarNames( key, arguments.command.getArgs() ) );
			structAppend( requestData, st, TRUE ) ; // thus scopeSequence matters
		}

//		cxt.appendData( requestData, TRUE );
		requestData['time'] = dateFormat( now(), 'yyyy-mm-dd' ) & ' ' & timeFormat( now(), 'HH:mm:ss:l' );
		// preserve original, unrevised request data for later
		// by convention, a prefix of an underscore means "do not modify"
		cxt.setDataElement( '_request', requestData );
		cxt.debug(  getMetaData( this ).name & ': completed' );
	}



	// if you don't like the names, extend/subclass this component/method 
	private string function resolveVarNames( scopeName, required struct commandArgs ) {
		if  ( structKeyExists( arguments.commandArgs, arguments.scopeName & 'AllowedVariablesList' ) ) {
			return arguments.commandArgs[arguments.scopeName & 'AllowedVariablesList'];
		}
		return evaluate( 'getDefault' & arguments.scopeName & 'Variables()' );
	}



	private struct function getScopedVariables( required string scopeName, required string varNames ) {
		var d = getScopeStruct( arguments.scopeName );
		var key = "" ;
		var st = {};

		for ( key in d ) {

			// asterisk is a magic word, means 'all', so blank can mean 'none'
			if ( arguments.varNames == '*' || listFindNoCase( arguments.varNames, key ) > 0 ) {

				// cgi.path_info fixes
				if ( ( lCase( arguments.scopeName ) == 'cgi' ) && ( lCase( key ) == 'path_info' ) ) {
					if ( !structKeyExists( d, lCase( key ) ) ) { d[key] = ""; } // it was missing, we'll make it blank
					if ( d[key] == cgi.script_name ) { d[key] = ""; } // IIS Fix/Quirk. thanks, Elliott
				}

				st[lcase(key)] = d[key];
			}
		}

		return st;
	}



	// using duplicate() to remove the hard reference
	private any function getScopeStruct( required string scopeName ) {
		switch( lCase( arguments.scopeName ) ) {
			case "httpRequestData":
				return duplicate( getHttpRequestData() );
				break;
			case "url":
				return duplicate( url );
				break;
			case "form":
				return duplicate( form );
				break;
			case "cgi":
				return duplicate( cgi );
				break;
		}
	}



	// scopeSequence argument is expected to be a list
	public void function setScopeSequence( required string scopeSequence ) {
		var i = 0;

		// cannot be blank
		if ( len( arguments.scopeSequence ) == 0 ) {
			throw( type='gethttprequest.InvalidScopeSequence', message='The Scope Sequence list cannot be empty' );
		}

		// must contain only valid words, comma delimited
		for ( i=1; i <= listLen( arguments.scopeSequence ); i++ ) {
			if ( listFindNoCase( 'url,form,cgi,httpRequestData', listGetAt( arguments.scopeSequence, i ) ) == 0 ) {
				throw( type='gethttprequest.InvalidScopeSequence', message='The Scope Sequence list must only contain "url", "form", "cgi", and "httpRequestData" and must be comma-delimited' );
			}
		}
		variables.scopeSequence = arguments.scopeSequence;
	}
}