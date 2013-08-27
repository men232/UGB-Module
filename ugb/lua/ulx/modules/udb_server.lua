-- DataBase modul for ULX -- modify by Andrew Mensky and create by kurozael!

require("mysqloo");

UDB = UDB or {};
UDB.version = "0.1b";

local mysqloo = mysqloo;
local ErrorNoHalt = ErrorNoHalt;
local tostring = tostring;
local error = error;
local pairs = pairs;
local pcall = pcall;
local type = type;
local string = string;
local table = table;

mysql_basic_class = { __index = mysql_basic_class };
local mysql_connection = mysql_connection or nil;
local mysql_queue = mysql_queue or {};

-- basic class --
function mysql_basic_class:SetTable( s )
	self.tableName = UDB:Prefixer( s );
	return self;
end;

function mysql_basic_class:SetValue( key, value, disallow_empty )
	value = tostring(value);
	
	if ( disallow_empty and value == "nil" ) then
		return self;
	end;
	
	self.vars[key] = UDB:Escape(value);
	return self;
end;

function mysql_basic_class:SetCallback( callback )
	self.Callback = callback;
	return self;
end;

function mysql_basic_class:AddWhere( key, value )
	value = UDB:Escape(tostring(value));
		self.where[#self.where + 1] = string.gsub(key, '?', "\""..value.."\"");
	return self;
end;

function mysql_basic_class:New()
	local object = {data = {}};
	setmetatable( object, self );
	self.__index = self;
	return object;
end;

-- update class --
mysql_update_class = mysql_basic_class:New();

function mysql_update_class:Replace( key, search, replace )
	search = "\""..UDB:Escape(tostring(search)).."\"";
	replace = "\""..UDB:Escape(tostring(replace)).."\"";
	self.vars[key] = "REPLACE("..key..", \""..search.."\", \""..replace.."\")";
	return self;
end;

function mysql_update_class:Push()
	if (!self.tableName) then return; end;
	
	local updateQuery = "";
	
	for k, v in pairs(self.vars) do
		if (updateQuery == "") then
			updateQuery = "UPDATE "..self.tableName.." SET "..k.." = \""..v.."\"";
		else
			updateQuery = updateQuery..", "..k.." = \""..v.."\"";
		end;
	end;
	
	if (updateQuery == "") then return; end;
	
	local whereTable = {};
	
	for k, v in pairs(self.where) do
		whereTable[#whereTable + 1] = v;
	end;
	
	local whereString = table.concat(whereTable, " AND ");
	
	if (whereString != "") then
		UDB:Query(updateQuery.." WHERE "..whereString, self.Callback );
	else
		UDB:Query(updateQuery, self.Callback );
	end;
end;

-- insert class --
mysql_insert_class = mysql_basic_class:New();

function mysql_insert_class:Push()
	if (!self.tableName) then return; end;
	
	local keyList = {};
	local valueList = {};
	
	for k, v in pairs(self.vars) do
		keyList[#keyList + 1] = k;
		valueList[#valueList + 1] = "\""..UDB:Escape(tostring(v)).."\"";
	end;
	
	if (#keyList == 0) then return; end;
	
	local insertQuery = "INSERT INTO "..self.tableName.." ("..table.concat(keyList, ", ")..")";
		insertQuery = insertQuery.." VALUES("..table.concat(valueList, ", ")..")";
	UDB:Query(insertQuery, self.Callback );
end;

-- select class --
mysql_select_class = mysql_basic_class:New();

function mysql_select_class:AddColumn( key )
	self.selectColumns[#self.selectColumns + 1] = key;
	return self;
end;

function mysql_select_class:SetOrder( key, value )
	self.Order = key.." "..value;
	return self;
end;

function mysql_select_class:Pull()
	if (!self.tableName) then return; end;
	
	if (#self.selectColumns == 0) then
		self.selectColumns[#self.selectColumns + 1] = "*";
	end;
	
	local selectQuery = "SELECT "..table.concat(self.selectColumns, ", ").." FROM "..self.tableName;
	local whereTable = {};
	
	for k, v in pairs(self.where) do
		whereTable[#whereTable + 1] = v;
	end;
	
	local whereString = table.concat(whereTable, " AND ");
	
	if (whereString != "") then
		selectQuery = selectQuery.." WHERE "..whereString;
	end;
	
	if (self.selectOrder != "") then
		selectQuery = selectQuery.." ORDER BY "..self.selectOrder;
	end;
	
	UDB:Query( selectQuery, self.Callback );
end;

-- delete class --
mysql_delete_class = mysql_basic_class:New();

function mysql_delete_class:Push()
	if (!self.tableName) then return; end;
	
	local deleteQuery = "DELETE FROM "..self.tableName;
	local whereTable = {};
	
	for k, v in pairs(self.where) do
		whereTable[#whereTable + 1] = v;
	end;
	
	local whereString = table.concat(whereTable, " AND ");
	
	if (whereString != "") then
		UDB:Query(deleteQuery.." WHERE "..whereString, self.Callback);
	else
		UDB:Query(deleteQuery, self.Callback);
	end;
end;

function UDB:NewMetaTable(baseTable)
	local object = {};
		setmetatable(object, baseTable);
		baseTable.__index = baseTable;
	return object;
end;

-- A function to begin a database update.
function UDB:Update(tableName)
	local object = self:NewMetaTable(mysql_update_class);
		object.vars = {};
		object.where = {};
		object.tableName = tableName;
	return object;
end;

-- A function to begin a database insert.
function UDB:Insert(tableName)
	local object = self:NewMetaTable(mysql_insert_class);
		object.vars = {};
		object.tableName = tableName;
	return object;
end;

-- A function to begin a database select.
function UDB:Select(tableName)
	local object = self:NewMetaTable(mysql_select_class);
		object.selectColumns = {};
		object.where = {};
		object.selectOrder = "";
		object.tableName = tableName;
	return object;
end;

-- A function to begin a database delete.
function UDB:Delete(tableName)
	local object = self:NewMetaTable(mysql_delete_class);
		object.where = {};
		object.tableName = tableName;
	return object;
end;

function UDB:Error( s )
	MsgC( Color(255,0,0), "[UDB MySQL Error] " .. s .. "\n" )
end;

function UDB:Success( s )
	MsgC( Color(0,255,0), "[UDB MySQL] " .. s .. "\n" );
end;

function UDB:Debug( s )
	if ( UDB_DEBUG ) then
		print("[UDB Debug] "..s);
	end;
end;

-- A function to query the database.
function UDB:Query( sql, Callback )
	if ( !UDB_ENABLE ) then
		return;
	end;

	sql = string.gsub(sql, " +", " "); -- Clean space.
	local query = mysql_connection:query( sql );

	UDB:Debug( sql.."\n" );

	query.onError = function( q, err, sql )
		if mysql_connection:status() == mysqloo.DATABASE_NOT_CONNECTED then
			table.insert( mysql_queue, { sql, Callback or function() end } );
			mysql_connection:connect();
		end;

		self:Error( err );
	end;

	query.onSuccess = function( q, data )
		if ( Callback ) then
			Callback(data);
		end;
	end;

	query:start();
end;

-- A function to get whether a result is valid.
function UDB:IsResult(result)
	return (result and type(result) == "table" and #result > 0);
end;

-- A function to make a string safe for SQL.
function UDB:Escape(text)
	return mysql_connection:escape(text);
end;

-- A function to register server in database.
function UDB:RegisterServer()
	local tableName = UDB:Prefixer( "servers" );
	local IPAddress, HostPort = UDB:GetIP();
	local HostName = GetHostName();

	local queryObj = UDB:Select( tableName )
		if ( UDB_SERVERID == "" ) then
			queryObj:AddWhere( "_IP = ?", IPAddress );
			queryObj:AddWhere( "_Port = ?", HostPort );
		else 
			queryObj:AddWhere( "_ID = ?", UDB_SERVERID );
		end;
		
		queryObj:SetCallback( function( result )
			local bExists = UDB:IsResult( result );

			if ( bExists ) then
				UDB_SERVERID = result[1]["_ID"];
				UDB:Success( "ServerID set To: " .. result[1]["_ID"] );
			elseif( !bExists and UDB_SERVERID == "" ) then
				UDB_SERVERID = tostring( math.ceil(util.CRC( "udb_"..IPAddress.."_"..HostPort.."_udb" ) / 100000) );
				UDB:Success( "Generate ServerID: " .. UDB_SERVERID );
			end;

			-- Insert or update server info.
			local queryObj = bExists and UDB:Update( tableName ) or UDB:Insert( tableName );
				if ( bExists ) then
					queryObj:AddWhere( "_ID = ?", UDB_SERVERID );
				else
					queryObj:SetValue( "_ID", UDB_SERVERID );
				end;
				queryObj:SetValue( "_IP", IPAddress );
				queryObj:SetValue( "_Port", HostPort );
				queryObj:SetValue( "_HostName", HostName );
			queryObj:Push();
		end);
	queryObj:Pull();
end;

-- Called when the database is connected.
function UDB:OnConnected()
	UDB:Success( "connected!" );

	local first_time = UDB.NoMySQL == nil;
	local query = {};
	
	if ( first_time ) then
		query = {
		[[CREATE TABLE IF NOT EXISTS `]]..UDB:Prefixer( "servers" )..[[` (
				`_ID` varchar(60) NOT NULL UNIQUE,
				`_IP` varchar(60) NOT NULL,
				`_Port` varchar(60) NOT NULL,
				`_HostName` varchar(150) NOT NULL,
				PRIMARY KEY (`_ID`) );
		]]};
	end;
	
	hook.Call( "UDBConnectedQuery", nil, query, first_time );

	local callback = function()
		hook.Call( "UDBConnected", nil );
	end;
		
	if ( #query > 0 ) then
		for i=1,#query do
			UDB:Query( string.gsub( query[i], "%s", " "), i == #query and callback );
		end;
	end;

	UDB:RegisterServer();
	UDB.NoMySQL = false;
end;

-- Called when the database connection fails.
function UDB:OnConnectionFailed(errText)
	self:Error( errText );
	self.NoMySQL = errText;
end;

-- A function to connect to the database.
function UDB:Connect(host, username, password, database, port)
	if ( !UDB_ENABLE ) then
		MsgC( Color(255,0,0), "[UDB] Disabled!\n");
		return;
	end;

	if (host == "localhost") then
		host = "127.0.0.1";
	end;
	
	local bSuccess, databaseConnection, errText = pcall(mysqloo.connect, host, username, password, database, port);

	if ( databaseConnection ) then
		databaseConnection.onConnected = function( db )
			self:OnConnected();

			for k, v in pairs( mysql_queue ) do
				self:Query( v[ 1 ], v[ 2 ] );
			end;

			mysql_queue = {};
		end;

		databaseConnection.onConnectionFailed = function( db, err )
			self:OnConnectionFailed(err);
		end;

	else
		self:OnConnectionFailed( errText or "Somtinh wrong" );
	end;

	databaseConnection:connect();
	mysql_connection = databaseConnection;
end;

-- A function to clear some '_'
function UDB:Prefixer( s )
	local prefix = UDB_PREFIX;
	return (prefix.."_"..s):gsub( "_+", "_" );
end;

function UDB:GetIP()
	/*if ( not UDB.public_ip or UDB.public_ip == "" ) then
		http.Fetch("http://whatismyip.akamai.com/", function( ip )
			UDB.public_ip = ip;
		end);
	end;*/

	local IPAddress = UDB_SERVERIP;
	local HostPort = GetConVarString("hostport");
	
	if ( IPAddress == "" ) then
		IPAddress = GetConVarString("ip");
	end;

	return IPAddress, HostPort;
end;

function UDB:IsConnected()
	return mysql_connection and mysql_connection:status() == mysqloo.DATABASE_CONNECTED;
end;

-- Called when the gamemode loads and starts.
function UDB:Initialize()	
	UDB:Connect( UDB_HOST, UDB_USERNAME, UDB_PASSWORD, UDB_DATABASE, UDB_PORT );
end;
//hook.Add( "Initialize", "UDB.Initialize", UDB.Initialize );

-- Update and reconnect.
timer.Create( 'UDB.Update', 3, 0, function()
	if ( UDB.NoMySQL != nil and UDB_ENABLE ) then
		local curTime = CurTime();

		if ( !UDB.LastUpdate ) then
			UDB.LastUpdate = 0;
		end;

		if ( UDB.LastUpdate < curTime and !UDB:IsConnected() ) then
			UDB:Initialize();
			UDB.LastUpdate = curTime + math.min( UDB_INTERVAL, 1);
		end;
	end;
end);

UDB:Initialize();