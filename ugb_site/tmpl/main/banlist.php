	<h3><?php echo CLUSTER_NAME.'&nbsp;'.getClusterIcon( CLUSTER_ID, 16 ); ?></h3>
	<h4><?php echo mysql_num_rows(BAN_LIST); ?> Bans and Counting</h5>
	<section id="bans">
	<table class="table table-bordered table-striped table-hover table-small">
		<thead>
			<tr>
				<th width="15">#</th>
				<th>Steam ID</th>
				<th>Name</th>
				<th>Reason</th>
				<th>Date Ban</th>
				<th>Expires on</th>
				<th>Banned by</th>
			</tr>
		</thead>
		<tbody>

<?php

$ban_id = 1;
while($row = mysql_fetch_assoc(BAN_LIST)){ ?>
			<tr>
				<td><?php echo getClusterIcon( $row['_Cluster'], 16 ); ?></td>
				<td><a href="<?php echo getUserLink( $row['_SteamID'] ) ?>" target="_blank"><?php echo $row['_SteamID']; ?></a></td>
				<td><?php echo $row['_SteamName'] ? $row['_SteamName'] : $default_name; ?></td>
				<td><?php echo $row['_Reason'] ?></td>
				<td><?php echo date("H:i - d.m.Y", $row['_Time']) ?></td>
				<td id="b_len_<?php echo $ban_id ?>" length="<?php echo $row['_Length']; ?>"></td>
				<td><?php echo getAdminInfo( $row ); ?></td>
			</tr>
<?php $ban_id++; } ?>
		</tbody>
	</table>
</section>