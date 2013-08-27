-- Global ban modul for ULX --by Andrew Mensky!
-- If this file is opened again, xgui bans will be broken.

-- UGB DATA
UGB = UGB or {};
UGB.version = 0.2;
UGB.ulib_reserv = UGB.ulib_reserv or {};

-- UGB ENUM
UGB_VERSION_OUT_DATE = -1;
UGB_VERSION_NORMAL = 0;
UGB_VERSION_NEWEST = 1;

-- A function to get ugb version.
function UGB:GetVersion() return self.version; end;

-- A function to check version status.
function UGB:VersionStatus( version_check )
	local cur_version = tonumber( self:GetVersion() );
	
	if ( cur_version == version_check ) then
		return UGB_VERSION_NORMAL;
	elseif ( cur_version > version_check ) then
		return UGB_VERSION_NEWEST;
	else
		return UGB_VERSION_OUT_DATE;
	end;
end;

function UGB:CheckVersion()
	http.Fetch( "https://raw.github.com/men232/UGB-Module/master/VERSION", function( html )
		local version = tonumber( html );

		if ( version ) then
			local status = self:VersionStatus( version );

			if ( status == UGB_VERSION_OUT_DATE ) then
				MsgC( Color(255,0,0), "Your version UGB is outdated. Please update this module.\nhttps://github.com/men232/UGB-Module \n");
			elseif ( status == UGB_VERSION_NEWEST ) then
				UGB:Success( "Where did you get the version is newer than mine? :D" );
			else
				UGB:Success( "Your version ugb relevant :)" );
			end;
		else
			UGB:Error( "Failed checking version." );
		end;
	end);
end;

-- A function to print error message by UGB.
function UGB:Error( s )
	MsgC( Color(255,0,0), "[UGB Error] " .. s .. "\n" );
end;

-- A function to print a success message by UGB.
function UGB:Success( s )
	MsgC( Color(0,255,0), "[UGB] " .. s .. "\n" );
end;

-- A function to print a debug message by UGB.
function UGB:Debug( s )
	if ( UGB_DEBUG ) then
		print("[UGB Debug] "..s);
	end;
end;

-- A function to reserver ulib func.
function UGB:ULibReserver( s )
	if ( !self.ulib_reserv[ s ] ) then
		self.ulib_reserv[ s ] = ULib[s] or function() end;
	end;
end;

-- A function to call reserver ulib func.
function UGB:ULibCall( s, ... )
	local callback = self.ulib_reserv[ s ];

	if ( callback ) then
		return callback( ... );
	end;
end;

-- A function to split name and steamid
function UGB:NameIDSplit( s )
	if ( s ) then
		local Name = string.gsub( s, "%(STEAM_%w:%w:%w*%)", "" );
		local SteamID = string.match( s, "(STEAM_%w:%w:%w*)" );

		return Name, SteamID;
	end;
end;

-- Stolen from xgui :) 
local function ConvertTime( seconds )
	--Convert number of seconds remaining to something more legible (Thanks JamminR!)
	local years = math.floor( seconds / 31536000 )
	seconds = seconds - ( years * 31536000 )
	local days = math.floor( seconds / 86400 )
	seconds = seconds - ( days * 86400 )
	local hours = math.floor( seconds/3600 )
	seconds = seconds - ( hours * 3600 )
	local minutes = math.floor( seconds/60 )
	seconds = seconds - ( minutes * 60 )
	local curtime = ""
	if years ~= 0 then curtime = curtime .. years .. " year" .. ( ( years > 1 ) and "s, " or ", " ) end
	if days ~= 0 then curtime = curtime .. days .. " day" .. ( ( days > 1 ) and "s, " or ", " ) end
	curtime = curtime .. ( ( hours < 10 ) and "0" or "" ) .. hours .. ":"
	curtime = curtime .. ( ( minutes < 10 ) and "0" or "" ) .. minutes .. ":"
	return curtime .. ( ( seconds < 10 and "0" or "" ) .. seconds )
end

-- Attempts to get the public ip :(
/*function UGB:GetIP( port )
    local hostip = GetConVar( "hostip" ):GetInt();

    local ip = {};
    ip[ 1 ] = bit.rshift( bit.band( hostip, 0xFF000000 ), 24 );
    ip[ 2 ] = bit.rshift( bit.band( hostip, 0x00FF0000 ), 16 );
    ip[ 3 ] = bit.rshift( bit.band( hostip, 0x0000FF00 ), 8 );
    ip[ 4 ] = bit.band( hostip, 0x000000FF );
 
    return table.concat( ip, "." )..(port and ":"..GetConVarString( "hostport" ) or "");
end;*/

-- ULib.addBan - Save the original function to fit your needs.
UGB:ULibReserver( "addBan" );

-- ULib.addBan - Replaces the function.
function ULib.addBan( steamid, time, reason, name, admin )
	local strTime = time ~= 0 and string.format( "for %s minute(s)", time ) or "permanently";
	local showReason = string.format( "Banned %s: %s", strTime, reason );

	local players = player.GetAll();
	for i=1, #players do
		if players[ i ]:SteamID() == steamid then
			ULib.kick( players[ i ], showReason, admin );
			break; -- Stop the loop.
		end;
	end;

	-- This redundant kick code.
	game.ConsoleCommand( string.format( "kickid %s %s\n", steamid, showReason or "" ) )

	local admin_name;
	if admin then
		admin_name = UGB_ADMIN_NAME;
		if admin:IsValid() then
			admin_name = string.format( "%s(%s)", admin:Name(), admin:SteamID() );
		end;
	end;

	local t = {};
	if ULib.bans[ steamid ] then
		t = ULib.bans[ steamid ];
		t.modified_admin = admin_name;
		t.modified_time = os.time();
	else
		t.admin = admin_name;
	end
	t.time = t.time or os.time();
	t.unban = time > 0 and ( ( time * 60 ) + os.time() ) or 0;
	t.reason = reason;
	t.name = name;
	ULib.bans[ steamid ] = t;

	local cluster   = UGB_CLUSTER;
	local tableName = UDB:Prefixer( UGB_TABLE );

	if ( not cluster or cluster == "" ) then
		cluster = "*";
	end;

	-- Find ban in db.
	local queryObj = UDB:Select( tableName );
		queryObj:AddWhere( "_SteamID = ?", steamid );
		queryObj:AddWhere( "_Cluster = ?", cluster );
		queryObj:SetCallback( function( result )
			local bExists = UDB:IsResult( result );
			local admin_name, admin_sid = UGB:NameIDSplit( t.admin );
			
			-- REMEMBER MY NAME :)
			if ( bExists and (!t.name or t.name == "") ) then
				t.name = result[1]["_SteamName"];
			end;
			
			-- Insert or update ban.
			local queryObj = bExists and UDB:Update( tableName ) or UDB:Insert( tableName );
				if ( bExists ) then
					queryObj:AddWhere( "_SteamID = ?", steamid );
					queryObj:AddWhere( "_Cluster = ?", cluster );
				else
					queryObj:SetValue( "_SteamID", steamid );
					queryObj:SetValue( "_Cluster", cluster );
				end;
				
				queryObj:SetValue( "_SteamName", t.name, true );
				queryObj:SetValue( "_Length", t.unban, true );
				queryObj:SetValue( "_Time", t.time, true );
				queryObj:SetValue( "_ASteamName", admin_name, true );
				queryObj:SetValue( "_ASteamID", admin_sid, true );
				queryObj:SetValue( "_Reason", t.reason );
				queryObj:SetValue( "_ServerID", UDB_SERVERID );
				queryObj:SetValue( "_MSteamName", t.modified_admin, true );
				queryObj:SetValue( "_MTime", t.modified_time, true );
				
				queryObj:SetCallback( function( result )
					UGB:Success( ( bExists and "Update" or "Insert").." ban ["..UDB_SERVERID.."]["..cluster.."]: " .. steamid );
					ULib.refreshBans();
				end);
				
			queryObj:Push();
		end);
	queryObj:Pull();
end;

-- ULib.unban - Save the original function to fit your needs.
UGB:ULibReserver( "unban" );

-- ULib.unban - Replaces the function.
function ULib.unban( steamid )
	//UGB:ULibCall( "unban", steamid ); -- No more need

	ULib.queueFunctionCall( game.ConsoleCommand, "removeid " .. steamid );

	--ULib banlist
	ULib.bans[ steamid ] = nil;

	local tableName = UDB:Prefixer( UGB_TABLE );
	local cluster   = UGB_CLUSTER;

	if ( not cluster or cluster == "" ) then
		cluster = "*";
	end;
	
	-- Remove ban from database.
	local queryObj = UDB:Delete( tableName );
		queryObj:AddWhere( "_SteamID = ?", steamid );
		queryObj:AddWhere( "_Cluster = ?", cluster );
		queryObj:SetCallback( function( result )
			UGB:Success( "Remove ban ["..UDB_SERVERID.."]["..cluster.."]: " .. steamid );
			ULib.refreshBans();
		end);
	queryObj:Push();
end;

-- ULib.refreshBans - Save the original function to fit your needs.
UGB:ULibReserver( "refreshBans" );

-- ULib.refreshBans - Replaces the function.
function ULib.refreshBans()
	UGB:Debug( "Refresh ban list." );

	local cluster   = UGB_CLUSTER;
	local tableName = UDB:Prefixer( UGB_TABLE );

	if ( not cluster or cluster == "" ) then
		cluster = "*";
	end;
	
	-- Cleaning previous bans.
	local xgui_data = {};
	for steamid, _ in pairs( ULib.bans ) do
		table.insert( xgui_data, steamid );
	end;
	xgui.removeData( {}, "bans", xgui_data );
	
	ULib.bans = {};
	local os_time = os.time();

	-- Find ban in db.
	local queryObj = UDB:Select( tableName );
		queryObj:AddWhere( "_Cluster = ?", cluster );
		queryObj:AddWhere( "( _Length > "..os_time.." OR _Length = 0 )", os_time );
		queryObj:SetCallback( function( result )
			if ( UDB:IsResult( result ) ) then
				-- Generate a list of online players.
				local plys = player.GetAll();
				local players = {};
				for i=1, #plys do
					players[ plys[ i ]:SteamID() ] = plys[ i ];
				end;
				
				local xgui_data = {};

				-- Refresh bans ob server.
				for i, data in pairs( result ) do
					local steamid = data["_SteamID"];
					ULib.bans[ steamid ] = {};
					local t = ULib.bans[ steamid ];

					for k, v in pairs( data ) do
						if ( v == "" ) then
							continue;
						end;

						if ( k == "_SteamName" ) then
							t.name = v;
						elseif ( k == "_Length" ) then
							t.unban = tonumber(v);
						elseif ( k == "_Time" ) then
							t.time = tonumber(v);
						elseif ( k == "_ASteamName" ) then
							t.admin = v..( data["_ASteamID"] and "("..data["_ASteamID"]..")" or "" );
						elseif ( k == "_Reason" ) then
							t.reason = v;
						elseif ( k == "_MSteamName" ) then
							t.modified_admin = v;
						elseif ( k == "_MTime" ) then
							t.modified_time = tonumber(v);
						end;
					end;

					-- Send ban data to xgui.
					xgui_data[ data["_SteamID"] ] = t;
					xgui.updateData( {}, "bans", xgui_data );

					-- Kick if the ban was on a different server.
					local ply = players[ steamid ];
					if ( ply and ply:IsValid() and (t.unban == 0 or t.unban >= os_time) ) then
						local strTime = time ~= 0 and string.format( "for %s minute(s)", math.ceil( (t.unban - os_time)/60 ) ) or "permanently";
						local showReason = string.format( "Banned %s: %s", strTime, t.reason );
						
						ULib.kick( ply, showReason );
						
						-- This redundant kick code.
						game.ConsoleCommand( string.format( "kickid %s %s\n", steamid, showReason or "" ) );
					end;

					-- Debug.
					UGB:Debug( "Get ban: ["..cluster.."]["..data["_SteamID"].."]" );
				end;

				-- XGUI Refresh.
				xgui.updateData( {}, "bans", xgui_data );
				xgui.svmodules[1].postinit();
				
				-- This global xgui bans update! This needed because xgui can update only 1 ban in vgui.
				ULib.queueFunctionCall( function()
					local plys = player.GetAll();
					local players = {};
					
					for i=1, #plys do						
						if ( ULib.ucl.query( plys[ i ], xgui.dataTypes["bans"].access ) ) then
							table.insert( players, plys[ i ] );
						end;
					end;
					
					if #players == 0 then return end;
					xgui.sendDataTable( players, { "bans" } );
				end);
			end;
		end);
	queryObj:Pull();
end;

-- Create ban table on database server.
hook.Add( "UDBConnectedQuery", "UGB.DBConnectedQuery", function( query, first_time )
	if ( first_time ) then
		table.insert( query, [[
			CREATE TABLE IF NOT EXISTS `]]..UDB:Prefixer( UGB_TABLE )..[[` (
				`_SteamID` varchar(60) NOT NULL,
				`_SteamName` varchar(150),
				`_Length` varchar(50) NOT NULL,
				`_Time` varchar(50) NOT NULL,
				`_ASteamName` varchar(150),
				`_ASteamID` varchar(60),
				`_Reason` varchar(255) NOT NULL,
				`_ServerID` varchar(50) NOT NULL,
				`_Cluster` varchar(50) NOT NULL,
				`_MSteamName` varchar(50),
				`_MTime` varchar(60),
				PRIMARY KEY (`_SteamID`,`_Cluster`) );
		]]);
	end;
end);

-- Refresh ban list when when connecting to the db server.
hook.Add( "UDBConnected", "UGB.DBConnected", function()
	UGB:CheckVersion();
	ULib.refreshBans();
end);

-- Alternative functional banid.
function UDB.CheckPassword( SteamID, IP, sv_password, ClientPassword, PlayerName )
	local SteamID = util.SteamIDFrom64(SteamID);
	local t = ULib.bans[ SteamID ];
	
	if t then
		MsgC( Color( 255, 0, 0 ), PlayerName.." ["..SteamID.."] Banned! \n" );
		local bantime = t.unban;

		if ( bantime >= os.time() ) then
			return false, string.format( UGB_BAN_MESSAGE, ConvertTime( bantime - os.time() ), t.reason or "None" );
		elseif bantime == 0 then
			return false, string.format( UGB_PERMA_MSG, t.reason or "None" );
		elseif ( UGB_REMOVE_EXPIRED ) then
			UGB:Debug("Removing expired bans!");
			ULib.unban(SteamID);
		end;
	end;
end;
hook.Add( "CheckPassword", "UGB.CheckPassword", UDB.CheckPassword);

-- Refresh ban list timer.
timer.Create( "UGB.RefreshTimer", UGB_INTERVAL, 0, function() ULib.refreshBans() end)