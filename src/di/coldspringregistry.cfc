component
extends="coldspring.beans.DefaultXmlBeanFactory"
displayname="voib.src.di.coldspringregistry"
accessors="TRUE"
hint="Coldspring adapter for handler creation and caching" {


	property type="any" name="logger" hint="a logger";


	public coldspringregistry function init( struct defaultAttributes={}, struct defaultPropertiesconfig={}, any logger ) {
		setLogger( structKeyExists( arguments, 'logger' ) ? arguments.logger : new voib.src.logger() );
		super.init( argumentCollection = arguments );
		return this;
	}



	public any function getBean( required string beanName ) {
		var bean = 0;

		try {
			bean = super.getBean( arguments.beanName );
		} catch ( any e ) {
			throw( type='InvalidBeanNameException', message=e.message, detail=e.detail );
		}

		return bean;
	}



	public array function getAll( required array types=[], required boolean checkParent=TRUE ) {
		// <!--- cfproperty name="beanFactoryBeanTypes" type="any" hint="comma delimited list of valid bean types" / --->
		// <!--- cfproperty name="checkParent" type="boolean" hint="flag which determines whether a parent beanFactory should be checked, if one exists" / --->
		var all = [];
		var names = [];
		var i = 0;
		var j = 0;
		var type = "";

		while ( i < arrayLen( types ) ) {
			type = types[++i];
			names = findAllBeanNamesByType( type, checkParent );
			getLogger().debug( getMetaData( this ).name & ': got ' & arrayLen( names) & ' names for type ' & type );

			for ( j = 1; j <= arrayLen( names ); j++ ) {
				arrayAppend( all, getBean( names[j] ) );
			}

		}

		return all;
	}



	public array function findAllBeanNamesByType( required string typeName, boolean checkParent="TRUE" ) hint="Finds the all the names of the bean that match the specified type in the bean factory." {
		// <!--- cfargument name="typeName" type="string" required="true" hint="Type of bean to find in the bean factory."/ --->
		// <!--- cfargument name="checkParent" type="boolean" required="false" default="true" hint="Boolean to indicate whether or not to check parent. Defaults to 'true'." / --->


		var beans = ArrayNew(1);
		var parentBeans = ArrayNew(1);
		var key = "";
		var i = 0;

		// Loop through the local factory
		for ( key in variables.beanDefs ) {
			if ( variables.beanDefs[key].getBeanClass() EQ arguments.typeName AND NOT variables.beanDefs[key].isInnerBean() ) {
				ArrayAppend(beans, key);
			}
		}

		// Check the parent factory if available
		if ( IsObject(variables.parent) AND arguments.checkParent ) {
			// mmr feb. 23, 2012: fixed line below. Original incorrectly calls only the first bean and returns a string
			parentBeans = variables.parent.findAllBeanNamesByType( arguments.typeName, arguments.checkParent );

			// Merg the parent bean names array into the local names 
			while ( i < ArrayLen(parentBeans) ) {
				ArrayAppend(beans, parentBeans[++i]);
			}
		}

		return beans;
	}


}