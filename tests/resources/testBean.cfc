component
displayname="voib.tests.resources.testBean"
accessors="TRUE"
hint="a bean used to test bean creation" {

	property type="string" name="firstName" hint="firstName of the bean";
	property type="string" name="lastName" hint="lastName of the bean";


	public testBean function init( string firstName, string lastName ) {
		setFirstName( structKeyExists( arguments, 'firstName' ) ? arguments.firstName : '' );
		setLastName( structKeyExists( arguments, 'lastName' ) ? arguments.lastName : '' );
		return this;
	}

}