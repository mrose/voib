component
displayname="voib.tests.resources.testHandler"
extends="voib.src.handler.basehandler"
access="public"
comment="testing"
order="42"
listen="eat,drink,sleep"
hint="A test handler" {

	public void function execute() hint="" {
		var cmd = getCommand();
		var cxt = getContext();
		cxt.trace(  getMetaData( this ).name & ': completed' );
	}

}