component {

	pageencoding "utf-8";

	this['name'] = hash( getCurrentTemplatePath() );
	this['sessionManagement'] = FALSE;
	this['clientManagement'] = FALSE;
	this['applicationTimeout'] = createTimeSpan(1,0,0,0);
	this['sessionTimeout'] = createTimeSpan(0,0,20,0);
	this['setClientCookies'] = FALSE;
	this['scriptProtect'] = FALSE;


	public any function onRequest( targetpage ) {

//		writeOutput( 'Example applications are disabled by default for security reasons. To enable, see the README' );

		dispatch( 'onRequest' );
		return TRUE;
	}



	public any function onMissingMethod( required string missingMethodName, required struct missingMethodArguments ) {
		// any unknown function declaration automatically passed to voib for resolution
		include "/voib/src/voib.cfm";
	}

}