<cfscript>
	// use application scope for registry if your design allows and you want to save the initialization overhead
	if ( !structKeyExists( variables, 'registry' ) ) {
		variables.registry = new voib.src.di.di1registry( '/voib/src/lexicon', { } );
	}

	if ( !structKeyExists( variables, 'logger' ) ) {
		variables.logger = new voib.src.requestLogger( 'debug' );
	}

	if ( !structKeyExists( variables, 'mapping' ) ) {
		variables.mapping = new voib.src.mapping.multicastmapping( registry=variables.registry );
	}

	if ( !structKeyExists( request, 'voib' ) ) {
		variables.voib = new voib.src.context( { 'logger':variables.logger, 'mapping':variables.mapping } );
	}

	request['voib']['data'] = invoke( variables.voib, missingMethodName, missingMethodArguments );
</cfscript>