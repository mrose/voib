component
displayname="voib.tests.resources.testHandler"
extends="voib.src.handler.basehandler"
voib_listen="eat,drink,sleep"
hint="A test handler" {

	public void function execute( required any command, required any context ) hint="" {
		var cmd = arguments.command;
		var cxt = arguments.context;
		cxt.trace(  getMetaData( this ).name & ': completed' );
	}

}