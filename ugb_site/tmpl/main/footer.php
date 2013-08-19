<?php if ( !UGB_INSTALLED ){ die(); } // Deny direct access ?>
	<script>
		function GetPermaBannedHTML(){
			return '<span class="label label-danger">Permanently</span>';
		}

		function GetUnBannedHTML(){
			return '<span class="label label-success">Unbanned</span>';
		}
	</script>
	<script src="<?php echo TMPL_FOLER ?>/js/jquery.js"></script>
	<script src="<?php echo TMPL_FOLER ?>/js/bootstrap.min.js"></script>


<footer>
	<small>
		<p class="pull-right">Generated in <span class="badge"><?php echo GENERATION_TIME ?></span></p>
		<p><?php echo getCopyright(); ?></p>
	</small>
</footer>
</div>