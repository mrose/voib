component
displayname="voib.src.lexicon.noHandlerFound"
extends="voib.src.handler.basehandler"
accessors="TRUE"
listen="noHandlerFound"
hint="Extension point for handler mapping" {

	public void function execute() {
		if ( !acceptable() ) {
			return;
		}

		var access = getCommand().getArg( 'command' ).getAccess();
		var name = getCommand().getArg( 'command' ).getName();
		warn( 'No handlers were mapped to #access# command #name#' );
		getContext().setResult( 'FALSE' );
	}

}