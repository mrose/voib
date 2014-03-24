component
displayname="voib.src.logger"
accessors="TRUE"
hint="a really simple logger" {


	property name="levels" type="string" setter="FALSE";
	property name="level" type="string";


	public logger function init( string level ) {
		variables.out = createObject( 'java', 'java.lang.System' ).out;
		variables.levels = "debug,info,warn,error,fatal"; // must be in this sequence
		setLevel( structKeyExists( arguments, 'level' ) ? arguments.level : 'nil' );
		return this;
	}



	// override generated mutator
	public void function setLevel( required string level ) {
		var lvls = listAppend( getLevels(), 'nil' );
		if ( !listFindNoCase( lvls, arguments.level ) ) {
			throw( type='InvalidArgumentException', message='Level must be one of: #listChangeDelims( lvls, "|" )#' );
		}
		variables.level = lcase( arguments.level );
	}



	public boolean function isDebugEnabled() { return isLevelEnabled( 'debug' ); }
	public boolean function isInfoEnabled() { return isLevelEnabled( 'info' ); }
	public boolean function isWarnEnabled() { return isLevelEnabled( 'warn' ); }
	public boolean function isErrorEnabled() { return isLevelEnabled( 'error' ); }
	public boolean function isFatalEnabled() { return isLevelEnabled( 'fatal' ); }

	public void function debug( string message ) { write( 'debug', message ); }
	public void function info( string message ) { write( 'info', message ); }
	public void function warn( string message ) { write( 'warn', message ); }
	public void function error( string message ) { write( 'error', message ); }
	public void function fatal( string message ) { write( 'fatal', message ); }



/* OMM don't work through context grrr
	private any function onMissingMethod( missingMethodName, missingMethodArguments ) {
		var lvls = listChangeDelims( getLevels(), "|" );
		var re = "^is(" & lvls & ")enabled$";
		var m = { 'len'=[ ], 'pos'=[ ] };

		// starts with 'is', ends in 'Enabled', matches a level
		m = reFind( re, lcase( missingMethodName ), 1, 'TRUE' );
		// we want the second matched expression
		if ( arrayLen( m.pos ) >= 2 ) {
			return isLevelEnabled( mid( lcase( missingMethodName ), m.pos[2], m.len[2] ) ); 
		}

		if ( !listFind( lvls, arguments.missingMethodName, '|' ) ) {
			throw( type='InvalidArgumentException', message='method must be one of: #lvls#' );
		}

		if ( !structKeyExists( arguments, 'missingMethodArguments' ) ) {
			throw( type='InvalidArgumentException', message='this method requires a message argument' );
		}

		return write( arguments.missingMethodName, arguments.missingMethodArguments[1] );
	}
*/


	private void function write( required string level, required any message ) {
		var msg = trim( serialize( arguments.message ) );

		if ( !isLevelEnabled( lcase( arguments.level ) ) || !len( msg ) ) {
			return;
		}

		if ( structKeyExists( request, 'voib' ) ) {
			if ( !structKeyExists( request['voib'], 'log' ) ) {
				request['voib']['log'] = [ ];
			}

			arrayAppend( request['voib']['log'], arguments.message );
		}

//		variables.out.println( lcase( arguments.level ) & ': ' & arguments.message );
	}



	private string function serialize( required any message ) {
		// assure that message is a string. Subclass to actually perform serialization
		var msg = arguments.message;
		return msg;
	}



	private boolean function isLevelEnabled( required string level ) {
		var lvl = getLevel();
		var levels = getLevels();

		while ( listLen( levels ) ) {
			if ( lvl == listFirst(levels) && listFind( levels, arguments.level ) ) {
				return TRUE;
			}
			levels = listRest(levels);
		}

		return FALSE;
	}

}