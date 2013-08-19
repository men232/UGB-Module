<?php

/**
 * Copyright (c) 2013 gmodlive team.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 *   * Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *
 *   * Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in
 *     the documentation and/or other materials provided with the
 *     distribution.
 *
 *   * Neither the names of the copyright holders nor the names of the
 *     contributors may be used to endorse or promote products derived
 *     from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
 * ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 *
 * @package     ULX Global Ban
 * @author      Andrew Mensky - men232@bigmir.net
 * @copyright   2013 gmodlive team.
 * @license     http://www.opensource.org/licenses/bsd-license.php  BSD License
 * @link        http://gmodlive.com
 */

// Global info.
define('NAME', "UGB Module");
define('VERSION', "0.1 beta");
define('URL', "");

// Include 
require_once('SourceQuery/SourceQuery.class.php');
require_once('functions.php');
require_once('config.php');

// Page generation time.
gen_timer_start();

// TMPL checking.
define('TMPL_FOLER', './tmpl/'.$tmpl_name);
$TMPL_ELEMENTS = array(
	'header',
	'body',
	'footer',
);

for ($i=0; $i < count($TMPL_ELEMENTS); $i++) {
	if ( !file_exists( TMPL_FOLER . '/' . $TMPL_ELEMENTS[ $i ] . '.php' ) ){
		die('Template element "'.$TMPL_ELEMENTS[ $i ].'.php" not found.');
	};
};

// Page array generator.
if ( strcmp($_GET['p'], 'srv') == 0 ){
	define( 'HIDE_BAN_LIST', true );
}elseif ( $_GET['p'] && $CLUSTERS_DATA[ $_GET['p'] ] ){
	define( 'CLUSTER_ID', $_GET['p'] );
	define( 'CLUSTER_NAME', $CLUSTERS_DATA[ $_GET['p'] ][ 'title' ] );
	define( 'HIDE_SERVER_LIST', true );
}else{
	define( 'CLUSTER_ID', "*" );
	define( 'CLUSTER_NAME', $CLUSTERS_DATA[ '*' ][ 'title' ] );
};

$_P = $_GET['p'] ? $_GET['p'] : 'home';

foreach ($CLUSTERS_DATA as $key => $value) {
	$PAGES[ $key ] = $value['title'];
};

// MySQL Connection.
$connection = mysql_connect( $dbhost, $dbuser, $dbpass );
if ( $connection ){
	mysql_select_db($dbname);
}else{
	die('MySQL Error: '.mysql_error());
};

// MySQL Server list.
if ( !defined('HIDE_SERVER_LIST') ){
	define('SERVER_LIST', getServerList() );
};

// MySQL Ban list.
if ( !defined('HIDE_BAN_LIST') ){
	define('BAN_LIST', getBanList() );
};

mysql_close($connection);

?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<meta HTTP-EQUIV="refresh" CONTENT="70" 
		<meta name="keywords" content="ulx, global, ban, banning, bans, gmod, garrys, mod, addon, ulib">
		<title><?php echo $site_name ?> - Global Bans</title>
		<script type="text/javascript">
			var currenttime = '<? print date("h:i:s a j M Y", time())?>';
			var serverdate = new Date(currenttime);
			var ban_count = <?php echo !defined('HIDE_BAN_LIST') ? mysql_num_rows(BAN_LIST) : 0; ?>;
			var ban_lents = new Array();
			var time_add = <? echo $time_add ?>;
		</script>
		<!-- Header begin -->
		<?php require_once( TMPL_FOLER . '/header.php' ); ?>
		<!-- Header end -->
	</head>
	<body>
		<!-- Body begin -->
		<?php require_once( TMPL_FOLER . '/body.php' ); ?>
		
		<!-- Footer begin -->
		<?php
		define('GENERATION_TIME', gen_timer_stop());
		require_once( TMPL_FOLER . '/footer.php' );
		?>
		<script src="./js/main.js"></script>
		<!-- Footer end -->

		<!-- Body end -->
	</body>
</html>