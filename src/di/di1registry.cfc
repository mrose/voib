component
extends="di1.ioc"
displayname="voib.src.di.di1registry"
accessors="TRUE"
hint="Adapter for handler creation and caching using di1" {


	property type="string" name="excludePattern" hint="a regex to exclude matching handlers";



	public voib.src.di.di1registry function init( string folders, struct config = { }, string excludePattern='lexicon$' ) {
		setExcludePattern( structKeyExists( arguments, 'excludePattern' ) ? arguments.excludePattern : calcExcludePattern( folders ) );
		super.init( argumentCollection = arguments );
		return this;
	}



	public array function getAll() {
		var names = listToArray( structKeyList( getBeanInfo().beanInfo ) ); // listToArray needed for acf9
		var name = "";
		var all = [ ];
		var b = FALSE;

		for ( name in names ) {
			if ( !compareNoCase( name, 'beanfactory' ) ) { continue; } //exclude self
			if ( reFindNoCase( getExcludePattern(), name ) ) { continue; }
			// warn if not a handler
			b = getBean( name );
			if ( !isInstanceOf( b, 'voib.src.handler.basehandler' ) ) {
// TODO: uncomment				warn( getMetaData( this ).name & ': ' & name & ' is not a subclass of voib.src.handler.basehandler' );
				continue;
			}
			// getLogger().debug( getMetaData( this ).name & ': ' & name & ' added to handlers returned for getAll::' );
			arrayAppend( all, b );
		}

		return reorder( all );
	}



	public any function getBean( required string beanName ) {
		var bean = 0;

		try {
			bean = super.getBean( arguments.beanName );
		} catch ( any e ) {
			throw( type='InvalidBeanNameException', message='for Bean #arguments.beanName#, ' & e.message, detail=e.detail, tagContext=e.tagcontext );
		}

		return bean;
	}



	private string function calcExcludePattern( string folders ) {
// TODO will be something like (aaa|bbb|lexicon)$
		return "lexicon$";
	}



	// use unembroidered names only
	private void function discoverBeansInFolder( string mapping ) {
		var folder = replace( expandPath( mapping ), chr(92), '/', 'all' );
		var webroot = replace( expandPath( '/' ), chr(92), '/', 'all' );
		if ( mapping.startsWith( webroot ) ) {
			// must be an already expanded path!
			folder = mapping;
		}
		// treat absolute file paths as not (web)root-relative:
		var rootRelative = left( mapping, 1 ) == '/' && folder != mapping;
		while ( left( mapping, 1 ) == '.' || left( mapping, 1 ) == '/' ) {
			if ( len( mapping ) > 1 ) {
				mapping = right( mapping, len( mapping ) - 1 );
			} else {
				mapping = '';
			}
		}
		mapping = replace( mapping, '/', '.', 'all' );
		// find all the CFCs here:
        var cfcs = [ ];
        try {
		    cfcs = directoryList( folder, variables.config.recurse, 'path', '*.cfc' );
        } catch ( any e ) {
            // assume bad path - ignore it, cfcs is empty list
        }
		for ( var cfcOSPath in cfcs ) {
			var cfcPath = replace( cfcOSPath, chr(92), '/', 'all' );
			// watch out for excluded paths:
			var excludePath = false;
			for ( var pattern in variables.config.exclude ) {
				if ( findNoCase( pattern, cfcPath ) ) {
					excludePath = true;
					continue;
				}
			}
			if ( excludePath ) continue;
			var dirPath = getDirectoryFromPath( cfcPath );
			var dir = listLast( dirPath, '/' );
			var singleDir = singular( dir );
			var file = listLast( cfcPath, '/' );
			var beanName = left( file, len( file ) - 4 );
			var dottedPath = deduceDottedPath( cfcPath, folder, mapping, rootRelative );
			var metadata = { 
				name = beanName, qualifier = singleDir, isSingleton = !beanIsTransient( singleDir, dir, beanName ), 
				path = cfcPath, cfc = dottedPath, metadata = cleanMetadata( dottedPath )
			};
			if ( structKeyExists( variables.beanInfo, beanName ) ) {
				structDelete( variables.beanInfo, beanName );
				variables.beanInfo[ beanName ] = metadata;
			} else {
				variables.beanInfo[ beanName ] = metadata;
			}
		}
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