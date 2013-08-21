-- Global ban modul for ULX --by Andrew Mensky!

local CATEGORY_NAME = "Utility";

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
				//print(admin:Name(), admin:SteamID());
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

local cmd = ulx.command( CATEGORY_NAME, "ugb convert", Convert );
cmd:defaultAccess( ULib.ACCESS_SUPERADMIN );
cmd:help( "Convert ulx bans to global bans." );

local function Refresh( calling_ply )
	ULib.refreshBans()
end;

local cmd = ulx.command( CATEGORY_NAME, "ugb refresh", Refresh );
cmd:defaultAccess( ULib.ACCESS_SUPERADMIN );
cmd:help( "Convert ulx bans to global bans." );