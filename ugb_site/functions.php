<?php
// Page generation time.
function gen_timer_start(){
	global $pageMakingStart;
	$pageMakingStart = microtime();
	$pageMakingStart = explode(' ', $pageMakingStart);
	$pageMakingStart = $pageMakingStart[1] + $pageMakingStart[0];
	return $pageMakingStart;
};

function gen_timer_stop(){
	global $pageMakingStart;
	global $pageMakingEnd;
	$pageMakingEnd = microtime();
	$pageMakingEnd = explode(' ', $pageMakingEnd);
	$pageMakingEnd = $pageMakingEnd[1] + $pageMakingEnd[0];
	$pageMakingEnd = round($pageMakingEnd - $pageMakingStart, 4);
	return $pageMakingEnd == "" ? 0 : $pageMakingEnd;
};

function getServerList(){
	global $table_prefix;
	
	$query = 'SELECT * FROM '.$table_prefix.'servers';
	return mysql_query($query);
};

function getBanList(){
	global $table_prefix;
	global $table_name;

	if ( CLUSTER_ID != '*' ){
		$query = ' SELECT * FROM `'.$table_prefix.$table_name.'` WHERE _Cluster = "'.mysql_escape_string(CLUSTER_ID).'"';
	}else{
		$query = 'SELECT * FROM `'.$table_prefix.$table_name.'`';
	}
	return mysql_query($query);
};

function printMsg( $d, $s ){
	echo "[".$d."] ".$s."\n";
};

function getCopyright(){
	return '"'.TMPL_NAME.' v.'.TMPL_VERSION.'"'.' Template by <a href="'.TMPL_AUTHOR_URL.'" title="'.TMPL_AUTHOR_NAME.'" target="_blank">Andrew Mensky</a>. Powered by <a href="'.URL.'" target="_blank">'.NAME.'</a> v.'.VERSION;
}

function getClusterIcon( $id, $size ){
	global $CLUSTERS_DATA;

	if ( $CLUSTERS_DATA[ $id ] && $CLUSTERS_DATA[ $id ][ 'icon' ] ){
		return '<img align="baseline" title="'.$CLUSTERS_DATA[ $id ][ 'title' ].'" height="'.$size.'" alt="'.$id.'" src="./icon/'.$CLUSTERS_DATA[ $id ][ 'icon' ].'"/>';
	};

	return '#'.$id;
};

function getUserLink( $steam_id ){
	return "http://steamcommunity.com/profiles/".convert32to64($steam_id);
}

function getAdminInfo( $row ){
	if ( $row['_ASteamID'] ){
		return '<a href="'.getUserLink( $row['_ASteamID'] ).'" target="_blank">'.$row['_ASteamName'].'</a>';
	}

	return '(Console)';
}

function convert32to64($steam_id){
	list( , $m1, $m2) = explode(':', $steam_id, 3);
	list($steam_cid, ) = explode('.', bcadd((((int) $m2 * 2) + $m1), '76561197960265728'), 2);
	return $steam_cid;
};

function getServerInfo( $ip, $port ){	
	$Timer = MicroTime( true );
	$Query = new SourceQuery( );

	$Info = Array( );

	try
	{
		$Query->Connect( $ip, $port, SQ_TIMEOUT, SQ_ENGINE );

		$Info    = $Query->GetInfo( );
	}
	catch( Exception $e )
	{
		$Exception = $e;
	}

	$Query->Disconnect( );

	return $Info;
}
?>