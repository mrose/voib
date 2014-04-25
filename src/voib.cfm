<cfscript>
	// use application scope for registry if your design allows and you want to save the initialization overhead
	if ( !structKeyExists( variables, 'registry' ) ) {
		variables.registry = new voib.src.di.di1registry( '/voib/src/lexicon', { } );
	}

	// use application scope for mapping if your design allows and you want to save the initialization overhead
	if ( !structKeyExists( variables, 'mapping' ) ) {
		variables.mapping = new voib.src.mapping.multicastmapping( registry=variables.registry );
	}

	if ( !structKeyExists( request, 'voib' ) ) {
		// a special logger for development which also writes to the request scope
		variables.logger = new voib.src.requestLogger( 'debug' );

		// you can also just pass the loglevel to the context if you don't mind a global logger and loglevel
		variables.voib = new voib.src.context( logger=variables.logger, mapping=variables.mapping );
	}

	request['voib']['data'] = invoke( variables.voib, missingMethodName, missingMethodArguments );
</cfscript>