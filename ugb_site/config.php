<?php
// MySQL Configs.
$dbhost       = 'localhost';	// IP Address to your database.
$dbname       = '';				// Database on the MySQL server.
$dbuser       = 'root';			// Username to log in on the MySQL server.
$dbpass       = '';				// Password to log in on the MySQL server.
$table_prefix = 'u_';			// Prefix for table name's.

// Site Configs.
$site_name    = 'MySite';		// Site name.
$site_url     = '#';			// Site url.
$tmpl_name    = 'main';			// Name of the template folder.
$default_name = 'Unknown';		// It will be displayed if the player has no name.
$time_add     = 0;  			// If you have a time zone difference between the site and the server. Use this value to add or to learn the time. (In sec.)

// Cluster configs.
$CLUSTERS_DATA = array(
	// Global claster, don't remove!
	'*' => array(
		'title' => 'Every bans',
		'icon' => 'world.png',
	),

	// RP Example.
	/*'rp' => array(
		'title' => 'RP Bans',
		'icon' => 'drp.png',
	),

	// TTT Example.
	'ttt' => array(
		'title' => 'TTT Bans',
		'icon' => 'ttt.png',
	),*/
);

// Pages list.
$PAGES = array(
	'home' => "Home",		// Don't remove!
	'srv' => "Server list", // Don't remove!
);

// Source Query configs.
define( 'SQ_TIMEOUT', 1 );
define( 'SQ_ENGINE', SourceQuery :: SOURCE );

define( 'UGB_INSTALLED', true ); // Ignore this line.
?>