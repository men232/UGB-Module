UGB-Module
==========
A Custom Global Ban System designed to be used only with ULX & ULib Garry's Mod servers.
This is my first public release. The code should be well documented!

FEATURES
==========
UDB Module: A powerful tool to work with your database.

Server ID: When your server starts, it checks for configurations to your IP:PORT. If it's not it'll create it and assign the server an ID. If it is it'll assign the server an existing ID.

Bans: This addon Hijack the ULib function to add a ban, and inserts it into the MySQL Database.

Information: When a user has been banned, all the available information saved in the MySQL Database.
Each time your server is started, the hostname is automatically updated in the MySQL database.

Template Support!

Clusters: The ability to combine your ban lists in clusters.

PLANED/TODO
==============
* To learn English.
* Reverse conversion.
* Drink vodka and play balalaika.

INSTALLATION
==============
*Requires MySQLOO.

Game Server:
Place the addon 'ugb', in your servers addons folder.
Inside the 'ugb' folder, under lua\autorun edit the file *_config.lua to your needs.

WebSite:
Place the 'ugb_site', in your website folder.
Inside the 'ugb_site' folder, edit the file config.php to your needs.