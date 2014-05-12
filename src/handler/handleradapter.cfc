component 
displayname="voib.src.handler.handleradapter"
extends="voib.src.handler.basehandler"
accessors="TRUE"
hint="A concrete decorator based on the Spring framework handleradapter interface allowing infinite extensibility to the framework.
Its handler property can be of any type, to enable handlers from other frameworks to be integrated with this framework without custom coding.
The order property of this object allows implementations to specify a sorting order and thus a priority for getting applied." {

	// parent props
	property type="string" name="access" hint="string to help determine if this object should handle Commands based on the Command's access property; typically one of public|private, defaults to private";
	property type="string" name="comment" hint="descriptive comment";
	property type="string" name="name" hint="name for this object, used for logging";
	property type="numeric" name="order" hint="priority for being applied";
	property type="array" name="listen" hint="optional array of command names this handler will listen for";
	property type="any" name="rule" hint="a Rule";
	property type="voib.src.command" name="command" hint="a voib command";
	property type="voib.src.context" name="context" hint="the voib context";

	property type="any" name="handler" hint="non-framework handler being adapted";
	property type="string" name="handlingMethod" hint="name of the method to be called on the handler";


	public handleradapter function init( string access, string name, string comment, numeric order, array listen, any rule, any handler, string handlingMethod ) {
		setHandler( structKeyExists( arguments, 'handler' ) ? arguments.handler : FALSE );
		setHandlingMethod( structKeyExists( arguments, 'handlingMethod' ) ? arguments.handlingMethod : 'execute' );
		super.init( arguments=argumentCollection );
		return this;
	}



	public void function execute( any command, any context ) {
		var cmd = structKeyExists( arguments, 'command' )? arguments.command : getCommand();
		var cxt = structKeyExists( arguments, 'context' )? arguments.context : getContext();

		if ( !acceptable( cmd, cxt ) ) { 
			return;
		}
		setResult( invoke( getHandler(), getHandlingMethod(), cmd.getArgs() ) );
		cxt.debug(  getMetaData( this ).name & ': completed' );
	}

}