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

}