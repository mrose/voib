component
displayname="voib.src.logger"
accessors="TRUE"
hint="a really simple logger" {


	property name="levels" type="string" setter="FALSE";
	property name="level" type="string";


	public logger function init( required string level='nil' ) {
		setLevel( arguments.level );
		return this;
	}



	// override generated mutator
	public void function setLevel( required string level ) {
		var found = FALSE;
		var i = 0;
		var lvls = "debug,info,warn,error,fatal,nil";

		if ( !listFindNoCase( lvls, arguments.level ) ) {
			throw( type='InvalidArgumentException', message='Level must be one of: #listChangeDelims( lvls, "|" )#' );
		}
		variables.level = lcase( arguments.level );

		lvls = "debug,info,warn,error,fatal";
		variables.levels = "";
		while ( listLen( lvls ) ) {
			if ( listFirst(lvls) == variables.level ) {
				found = TRUE;
			}

			if ( found ) {
				variables.levels = listAppend( variables.levels, listFirst(lvls) );
			}

			lvls = listRest(lvls);
		}

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

		writelog( lcase( arguments.level ) & ': ' & arguments.message, 'console' );
	}



	private string function serialize( required any message ) {
		// assure that message is a string. Subclass to actually perform serialization
		var msg = arguments.message;
		return msg;
	}



	private numeric function isLevelEnabled( required string level ) {
		return listFind( variables.levels, lcase(arguments.level) );
	}

}