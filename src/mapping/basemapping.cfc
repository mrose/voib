component 
displayname="voib.src.mapping.basemapping"
accessors="TRUE"
hint="A Base class that must be implemented by objects that define a mapping between Commands and Handlers.
Returns an array of Handlers for a Command based on any arbitrary factors the implementing class chooses.
When no matching Handlers are found, returns its defaultHandlers property which defaults to an empty array.
Mappings can behave as interceptors when their defaultHandlers property is another mapping.
The order property of this object allows implementations to specify a sorting order and thus a priority for getting applied." {


	property type="array" name="defaultHandlers" hint="an array of default handlers";
	property type="numeric" name="order" hint="priority for getting applied";


	import voib.src.handler.*;


	// Constructor
	public basemapping function init( array defaultHandlers, numeric order ) {
		setDefaultHandlers( structKeyExists( arguments, 'defaultHandlers' ) ? arguments.defaultHandlers : [ ] );
		setOrder( structKeyExists( arguments, 'order' ) ? arguments.order : 999999999 );
		return this;
	}



	public any function getHandlers( required any command ) {
		var handlers = [ ];
		throw( type="Method.NotImplemented" ); // the mapping strategy is applied here in implementing classes
		return handlers;
	} 



	public void function setOrder( required numeric order ) {

		// cannot be negative
		if ( arguments.order < 0 ) throw( type="InvalidArgumentException", detail="The order property for a mapping cannot be a negative number." ); 

		// cannot be greater than 999,999,999
		if ( arguments.order > 999999999 ) throw( type="InvalidArgumentException", detail="The order property for a mapping cannot be a number higher than 999,999,999." ); 

		variables.order = arguments.order;
	}



	private array function reorder( required any collection ) {
		var temp = [ ];
		var elements = [ ];
		var i = 0;
		var j = 0;

		// collection is array of objects:
		if ( isArray( arguments.collection ) ) {
			for ( i = 1; i <= arrayLen( arguments.collection ); i++ ) {
				j = arguments.collection[i].getOrder();
				arrayAppend( temp, j & ',' & i );
			}
		}

		// collection is struct of objects:
		if ( isStruct( arguments.collection ) ) {
			for ( j in arguments.collection ) {
				arrayAppend( temp, arguments.collection[j].getOrder() & ',' & j );
			}
		}

		arraySort( temp, 'textnocase', 'asc' );

		for( i = 1; i <= arrayLen( temp ); i++ ) {
			j = listGetAt( temp[i], 2 );
			elements[i] = arguments.collection[j];
		}

		return elements;
	}



	// return an array of elements (any object which has the getOrder method) ordered from low to high (e.g. 1 before 10 )
	private array function orderMap( required struct map ) {
		var temp = [ ];
		var elements = [ ];
		var key = "";
		var i = 0;

		for ( key in arguments.map ) {
			arrayAppend( temp, arguments.map[key].getOrder() & ',' & key );
		}

		arraySort( temp, 'textnocase', 'asc' );

		for( i = 1; i <= arrayLen( temp ); i++ ) {
			key = listGetAt( temp[i], 2 );
			elements[i] = arguments.map[key];
		}

		return elements;
	}

}