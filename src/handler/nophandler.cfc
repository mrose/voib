component
displayname="voib.src.handler.nophandler"
extends="voib.src.handler.basehandler"
hint="A no-op handler" {


	public void function execute( any command, any context ) hint="" {
		var cxt = structKeyExists( arguments, 'context' )? arguments.context : getContext();
		cxt.debug( getName() & ': completed' );
	}

}