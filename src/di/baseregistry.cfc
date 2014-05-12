component
accessors="TRUE"
hint="A default registry. Doesn't do much" {


	public baseregistry function init() {
		return this;
	}



	public array function getAll() {
		return [ ];
	}



	public boolean function containsBean( string beanName ) {
		return FALSE;
	}



	public any function getBean( string beanName ) {
		throw( type='InvalidBeanNameException', detail='bean not found dammit' );
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


}