component
displayname="voib.src.mapping.multicastmapping"
extends="basemapping"
accessors="TRUE"
hint="Retrieves an array of handlers by delegating to it's configured registry; when an empty array is returned, returns it's defaultHandlers property, an array." {


	// inherited property array defaultHandlers;
	// inherited property numeric order;
	property type="any" name="registry" hint="Registry used to retrieve handlers";


	// Constructor
	public multicastmapping function init( array defaultHandlers, numeric order, any registry ) {
		super.init( argumentCollection = arguments );
		setRegistry( structKeyExists( arguments, 'registry' ) ? arguments.registry : new voib.src.di.baseregistry() );
		return this;
	}



	public array function getHandlers( required any command ) {

		var handlers = [ ];

		lock name='multicastmappingGetHandlersLock' type='exclusive' timeout='500' throwOnTimeout='TRUE' {
			handlers = reorder( getRegistry().getAll() ); 
			// debug( getMetaData( this ).name & ': assigned #arrayLen( handlers )# handlers to command #arguments.command.getName()#' );
		}

		if ( arrayIsEmpty( handlers ) ) {
			handlers = getDefaultHandlers();
		}

		return handlers;
	}

}