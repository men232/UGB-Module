-- Global ban modul for ULX --by Andrew Mensky!

local CATEGORY_NAME = "Utility";

-- Simple convert from ulx to ugb bans.
local function Convert( calling_ply )
	if not ULib.fileExists( ULib.BANS_FILE ) then
		return ulx.fancyLogAdmin( calling_ply, "Nothing to convert" );
	end;
	
	local bans, err = ULib.parseKeyValues( ULib.fileRead( ULib.BANS_FILE ) );
	
	if ( err ) then
		return ulx.fancyLogAdmin( calling_ply, err );
	end;
	
	local os_time = os.time();
	local c_fine = 0;
	local c_err = 0;
	
	for k, v in pairs( bans ) do
		if type( v ) == "table" and type( k ) == "string" then
			local time = ( v.unban - os_time ) / 60;
			if ( time > 0 or math.floor( v.unban ) == 0 ) then -- We floor it because GM10 has floating point errors that might make it be 0.1e-20 or something dumb.
				-- Create fake admin :)
				local admin = {};
				local name, sid = UGB:NameIDSplit( v.admin );
				
				function admin:IsValid() return name and sid and name != "(Console)"; end;
				function admin:Name() return name; end;
				function admin:Nick() return name; end;
				function admin:SteamID() return sid; end;
				
				-- Convert ban
				ULib.addBan( k, time, v.reason, v.name, admin );
				
				c_fine = c_fine + 1;
			end;
		else
			ulx.fancyLogAdmin( calling_ply, "Warning: Bad ban data is being ignored, key = " .. tostring( k ) .. "\n" );
			c_err = c_err + 1;
		end;
	end;
	
	ulx.fancyLogAdmin( calling_ply, "Converted bans: #s, Errors: #s.", tostring(c_fine), tostring(c_err) );
end;

local cmd = ulx.command( CATEGORY_NAME, "ugb convert_ulx", Convert );
cmd:defaultAccess( ULib.ACCESS_SUPERADMIN );
cmd:help( "Convert from ulx bans to ugb" );


-- Convert from bcool1 global bans to ugb.
local forewarned = false;

local function Convert2( calling_ply )
	local tableName = UDB:Prefixer( UGB_TABLE );
		
	local queryObj = UDB:Select( "bans" );
		queryObj:SetCallback( function( result )
			if not UDB:IsResult( result ) then
				return ULib.tsayError( calling_ply, "There is nothing to convert." );
			end;
			
			local count = #result;
			
			for i=1, count do
				local queryObj = UDB:Select( tableName );
					queryObj:AddWhere( "_SteamID = ?", result[i]["OSteamID"] );
					queryObj:AddWhere( "_Cluster = ?", UGB_CLUSTER );
					queryObj:SetCallback( function( result2 )
						local bExists = UDB:IsResult( result2 );
						
						local queryObj = bExists and UDB:Update( tableName ) or UDB:Insert( tableName );
							if ( bExists ) then
								queryObj:AddWhere( "_SteamID = ?", result[i]["OSteamID"] );
								queryObj:AddWhere( "_Cluster = ?", UGB_CLUSTER );
							else
								queryObj:SetValue( "_SteamID", result[i]["OSteamID"] );
								queryObj:SetValue( "_Cluster", UGB_CLUSTER );
							end;
						
							queryObj:SetValue( "_SteamID", result[i]["OSteamID"] );
							queryObj:SetValue( "_Cluster", UGB_CLUSTER );
							queryObj:SetValue( "_SteamName", result[i]["OName"], true );
							queryObj:SetValue( "_Length", result[i]["Length"], true );
							queryObj:SetValue( "_Time", result[i]["Time"], true );
							queryObj:SetValue( "_ASteamName", result[i]["AName"], true );
							queryObj:SetValue( "_ASteamID", result[i]["ASteamID"], true );
							queryObj:SetValue( "_Reason", result[i]["Reason"] );
							queryObj:SetValue( "_ServerID", UDB_SERVERID );
							queryObj:SetValue( "_MSteamName", result[i]["MAdmin"], true );
							queryObj:SetValue( "_MTime", result[i]["MTime"], true );
							if ( i ==  count ) then
								queryObj:SetCallback( function()
									ULib.queueFunctionCall( function()
										ULib.refreshBans();
										ulx.fancyLogAdmin( calling_ply, "Imported "..count.." bcool bans.\n" );
									end);
								end);
							end;
						queryObj:Push();
					end);
				queryObj:Pull();
			end;
		end);
	queryObj:Pull();
end;

local cmd = ulx.command( CATEGORY_NAME, "ugb convert_bcool", Convert2 );
cmd:defaultAccess( ULib.ACCESS_SUPERADMIN );
cmd:help( "Convert bcool bans to ugb." );

-- Forced refresh.
local function Refresh( calling_ply )
	ULib.refreshBans()
end;

local cmd = ulx.command( CATEGORY_NAME, "ugb refresh", Refresh );
cmd:defaultAccess( ULib.ACCESS_SUPERADMIN );
cmd:help( "Convert ulx bans to global bans." );