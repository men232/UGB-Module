	<h3>Server list</h3>
	<section id="servers">
	<table class="table table-bordered table-striped table-hover table-small">
		<thead>
			<tr>
				<th width="50">ID</th>
				<th>IP Address</th>
				<th>Server Name</th>
				<th>Gamemode</th>
				<th>Map</th>
				<th>Players</th>
			</tr>
		</thead>
		<tbody>
	<?php while($row = mysql_fetch_assoc(SERVER_LIST)){
		$ip = $row['_IP'];
		$port = $row['_Port'];
		$Info = getServerInfo( $ip, $port );?>
		<tr>
			<td><?php echo $row['_ID']; ?></td>
			<td><a href="steam://connect/<?php echo $ip; ?>:<?php echo $port; ?>"><?php echo $ip; ?>:<?php echo $port; ?></td>
			<td><?php echo $Info[ 'HostName' ] ? $Info[ 'HostName' ] : $row['_HostName']; ?></td>
			<td><?php echo $Info[ 'ModDesc' ]; ?></td>
			<td><?php echo $Info[ 'Map' ]; ?></td>
			<td><?php echo $Info[ 'Players' ].'/'.$Info[ 'MaxPlayers' ]; ?></td>
		</tr>
	<?php } ?>
			</tbody>
		</table>
	</section>