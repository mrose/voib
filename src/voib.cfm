<cfscript>
	// use application scope for registry if your design allows and you want to save the initialization overhead
	if ( !structKeyExists( variables, 'registry' ) ) {
		variables.registry = new voib.src.di.di1registry( '/voib/src/lexicon', { } );
	}

	if ( !structKeyExists( request, 'voib' ) ) {
		variables.voib = new voib.src.context( { 'loglevel':'debug', 'registry':variables.registry } );
	}

	invoke( variables.voib, missingMethodName, missingMethodArguments );
writedump( request );
writedump( variables );

</cfscript>