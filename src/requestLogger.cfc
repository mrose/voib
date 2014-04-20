component
extends="logger"
displayname="voib.src.requestlogger"
accessors="TRUE"
hint="a really simple logger that logs to the request scope" {


	private void function write( required string level, required any message ) {
		var msg = trim( serialize( arguments.message ) );
		var typ = lcase( arguments.level );

		if ( !isLevelEnabled( lcase( arguments.level ) ) || !len( msg ) ) {
			return;
		}

		if ( structKeyExists( request, 'voib' ) ) {
			if ( !structKeyExists( request['voib'], 'log' ) ) {
				request['voib']['log'] = [ ];
			}

			if ( structKeyExists( request['voib'], 'id' ) ) {
				msg = "[id:" & request['voib']['id'] & "] " & msg;
			}

			arrayAppend( request['voib']['log'], msg );
		}

	}


}