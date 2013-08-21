--[[ Global ban configs. ]]

UGB_TABLE       = "globalbans";			-- Name of the table that will store bans. 
UGB_CLUSTER     = "*";					-- The name of the cluster to filter bans ( '*' - do not use a cluster ).
UGB_DEBUG       = true; 				-- Show debug message.
UGB_INTERVAL    = 90;					-- The interval between update ban list.
UGB_ADMIN_NAME  = "(Console)"			-- This admin name by default.
UGB_BAN_MESSAGE = "You've been banned from the server!\nLifted In: %s\nReason: %s";		-- This message is shown when a player join the server.
UGB_PERMA_MSG   = "Permanently!"; 		--Message of permanently ban.