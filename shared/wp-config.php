<?php

	// The name of the database for WordPress
	define( 'DB_NAME', 			'' );

	// MySQL database username
	define( 'DB_USER', 			'' );

	// MySQL database password
	define( 'DB_PASSWORD', 		'' );

	// MySQL hostname
	define( 'DB_HOST', 			'localhost' );

	// Database Charset to use in creating database tables.
	define( 'DB_CHARSET', 		'utf8' );

	// The Database Collate type. Don't change this if in doubt.
	define( 'DB_COLLATE', 		'' );

	define( 'AUTH_KEY',         '' );
	define( 'SECURE_AUTH_KEY',  '' );
	define( 'LOGGED_IN_KEY',    '' );
	define( 'NONCE_KEY',        '' );
	define( 'AUTH_SALT',        '' );
	define( 'SECURE_AUTH_SALT', '' );
	define( 'LOGGED_IN_SALT',   '' );
	define( 'NONCE_SALT',       '' );


	$table_prefix = 'wp_';

	define( 'WPLANG', '' );

	define( 'WP_DEBUG', false );
	define( 'CONCATENATE_SCRIPTS', true );
	define( 'SCRIPT_DEBUG', false );

	define( 'WP_ALLOW_MULTISITE', true );
	define( 'MULTISITE', true );
	define( 'SUBDOMAIN_INSTALL', true );
	define( 'DOMAIN_CURRENT_SITE', 'richardtape.com' );
	define( 'PATH_CURRENT_SITE', '/' );
	define( 'SITE_ID_CURRENT_SITE', 1 );
	define( 'BLOG_ID_CURRENT_SITE', 1 );

	define( 'WP_AUTO_UPDATE_CORE', false );

	// The content directory is symlinked, so let's work out the path
	$WPContentDir = readlink( dirname( dirname( __FILE__ )  ) . '/current'  ) . '/content';

	define( 'WP_CONTENT_DIR', $WPContentDir );

	// This is forced http, as I don't need SSL, but may need to work out how to get HTTPS working
	define( 'WP_CONTENT_URL', 'http://' . $_SERVER['HTTP_HOST'] . '/content' );


	// Absolute path to the WordPress directory.
	if ( !defined( 'ABSPATH' ) )
		define( 'ABSPATH', dirname( __FILE__ ) . '/wp/' );

	// Sets up WordPress vars and included files.
	require_once( ABSPATH . 'wp-settings.php' );
