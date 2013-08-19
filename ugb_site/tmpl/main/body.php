<?php if ( !UGB_INSTALLED ){ die(); } // Deny direct access ?>
	<div class="container">
	<header>
		<nav class="navbar" role="navigation">
		  <!-- Brand and toggle get grouped for better mobile display -->
		  <div class="navbar-header">
		    <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-ex1-collapse">
		      <span class="sr-only">Toggle navigation</span>
		      <span class="icon-bar"></span>
		      <span class="icon-bar"></span>
		      <span class="icon-bar"></span>
		    </button>
		    <a class="navbar-brand" href="<?php echo $site_url ?>"><?php echo $site_name ?></a>
		  </div>

		  <!-- Collect the nav links, forms, and other content for toggling -->
		  <div class="collapse navbar-collapse navbar-ex1-collapse">
		    <ul class="nav navbar-nav">
			    <?php foreach ($PAGES as $key => $value) { ?>
			    	<li class="<?php echo strcmp( $_P, $key ) == 0 ? 'active' : '' ?>">
			    		<a href="<?php echo './index.php?p='.$key ?>">
			    		<?php
			    			if ( $CLUSTERS_DATA[ $key ] ){
			    				echo $CLUSTERS_DATA[ $key ][ 'title' ].'&nbsp;&nbsp;'.getClusterIcon( $key, 16 );
			    			}else{
			    				echo $value;
			    			};
			    		?>
			    		</a>
			    	</li>
			    <?php }; ?>
		    </ul>
          <ul class="nav navbar-nav navbar-right">
          		<li><a><span id="servertime"></span></a></li>
          </ul>
		  </div><!-- /.navbar-collapse -->
		</nav>
	</header>

	<!-- Server list begin -->
	<?php if ( !defined('HIDE_SERVER_LIST') ){ require_once( TMPL_FOLER . '/serverlist.php' ); }; ?>
	<!-- Server list end -->

	<!-- Ban list begin -->
	<?php if ( !defined('HIDE_BAN_LIST') ){ require_once( TMPL_FOLER . '/banlist.php' ); }; ?>
	<!-- Ban list end -->