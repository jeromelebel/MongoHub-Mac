## System Requirements

Mac OS X (10.6.x, 10.7.x, 10.8.x), intel(64bit/32bit) based.

## Installation

You can either download the compiled executable file from [here](https://github.com/downloads/fotonauts/MongoHub-Mac/MongoHub.zip) 
or clone the source code and compile it on your own system.

## Build

Just build it, it should work (but let me know if you have an errors or warnings).

## Current Status

This project is very new. Any issues or bug reports are welcome. And I still don't have time to write a **usage guide**.

** Known bugs **
    
    - Simple quote is not supported yet for json

** To do list **
    
    - Should manage a list of database/user/password for each connections
    - Should save the password into the keychain
    - Create a document editor to edit using an outline view (like the plist editor in Xcode)
    - Need a progress bar for file export/import to know when it is done
    
** Current **

    - Problem to modify ssh parameters while editing an existing connection (fields were disabled)

## History

** 2.5.4(98) - november 1, 2012 **

    - Fix to display Undefined values https://github.com/fotonauts/MongoHub-Mac/issues/49
    - Fix to avoid a crasher with disconnecting from a server while using ssh tunneling https://github.com/fotonauts/MongoHub-Mac/issues/48
    - Use ⌘ to avoid the confirmation panel in the remove tab (either while clicking or pressing the return key)

** 2.5.3(97) - september 4, 2012 **

    - No more setting for bind address and bind port (bind address is 127.0.0.1 and bind port will be choosen automatically from 40000 or higher) https://github.com/fotonauts/MongoHub-Mac/issues/19
    - Fix for a crasher when the network goes down https://github.com/fotonauts/MongoHub-Mac/issues/42
    - Changing from red to green (except for remove) https://github.com/fotonauts/MongoHub-Mac/issues/44
    - Adding a confirmation dialog correctly when removing all documents https://github.com/fotonauts/MongoHub-Mac/issues/33
    - Some cleanup for the connection editor, thanks to Alex Shteinikov (idooo)

** 2.5.2(96) - july 15, 2012 **

    - Fix: Some UTF8 characters became invisible while editing a document
    - Fix: Some problems with updating colors while editing
    - Open only one document window for each document
    - Close all document windows when close a collection
    - Fix: Making sure the collection outline selection always match the collection tab selection (to make sure Fred doesn't make any mistake)
    - Fix: a blank query will not remove documents anymore. Please use at least '{}'
    - Fix: problem to import documents with array in it https://github.com/fotonauts/MongoHub-Mac/issues/39
    - Adding multiple document selection
    - Adding document drag

** 2.5.1(95) - june 21, 2012 **

    - Fix for https://github.com/fotonauts/MongoHub-Mac/issues/36 (open a second time the same database tab)
    - Trying to make sure we don't make a mistake between the tab opened and the selection in the database outline view (special for fred)

** 2.5(94) - may 27, 2012 **

    - Fix for the limit and skip field (limited to 9999) https://github.com/fotonauts/MongoHub-Mac/issues/30
    - Adding tabs

** 2.4.19(93) - may 23, 2012 **

    - Trying to keep type (integer and float) the same as much as possible (when editing a document) https://github.com/fotonauts/MongoHub-Mac/issues/35
    - Crash fixed when opening a collection with documents that has no "_id" and "name" https://github.com/fotonauts/MongoHub-Mac/issues/24

** 2.4.18(92) - may 10, 2012 **

    - Fix crasher when error https://github.com/fotonauts/MongoHub-Mac/issues/31
    - Fix to use an authenticated database

** 2.4.17(91) - may 5, 2012 **

    - Fix to parse binary values
    - Fix to parse an hash with $type
    - Changing "upset" to "upsert"
    - Fix from billybobuk to get the database list when having auth
    - Adding header in the data outline view
    - Fix to add a document with structures inside an array (https://github.com/fotonauts/MongoHub-Mac/issues/28)

** 2.4.16(90) - jan 29, 2012 **

    - Adding autosave for the connection list window
    - Adding back the index icon
    - Better error message when not having the authorization to get the server status
    - Crash fixed when not having the authorization to get the server status

** 2.4.15(89) - dec 30, 2011 **

    - Crash fixed when remove all documents : https://github.com/fotonauts/MongoHub-Mac/issues/18
    - Change minimum size of MainMenu window to avoid display bug (thanks ohardy)
    - Bug fixes (thanks ohardy)
    - Double click on database name collapse or expand item (thanks ohardy)

** 2.4.14(88) - dec 23, 2011 **

    - Adding full-screen support (lion only), thanks callumj
    - Fix when you don't have the right to get the database list (you need to set the database you want to use in the connection panel)

** 2.4.13(87) - nov 30, 2011 **

	- Key order is preserved in a document
    - Support for UTF-8
    - Fix for Mysql import/export
    - Support for symbol type
    - fix for the UI selection in the connexion window

** 2.4.12(86) - nov 22, 2011 **

    - Problem to update document with boolean values and regexp values

** 2.4.11(85) - nov 22, 2011 **

    - Toolbar items are enabled/disabled according to the selection
    - Connecting to localhost is not an issue anymore
    - Bug to parse json with arrays

** 2.4.10(84) - nov 19, 2011 **

    - Bug to add a new connection

** 2.4.9(83) - nov 18, 2011 **

    - Changing the NSBundle application id
    - Database stats works again
    - History combo-box for the criteria
    - Fix to use database with an admin user/password

** 2.4.8(82) - nov 1, 2011 **

    - Problem to display and parse date types
    
** 2.4.7(81) - nov 1, 2011 **
    
    - Connections are sorted after being loaded (still not sorted after being updated)
    - Adding short cuts to delete a document or an index (Command+delete)
    - Adding tooltips for the buttons with short cuts
    - Queries are sorted by default
    - Problem to display regex and timestamp values in documents

** 2.4.6(80) - oct 28, 2011 **
    
    - Can insert an array of documents
    - MapReduce feature working
    - Fix for parsing: "$oid":"4E9321AF3768CF514A00000C"}
    - Crash when getting stats for some servers
    - New outline view for the databases and collections

** 2.4.5(79) - oct 22, 2011 **

    - Fix to parse { "empty_array": [], "zob": 1}
    - Fix to parse { "empty_hash": {}, "zob": 1}
    - Implementing reIndex

** 2.4.4(78) - oct 20, 2011 **

    - Can create indexes with the UI
    - Can remove indexes with the UI
    - Fix to parse { "_id": { "$oid" : "4E9807F88157F608B4000002" }, "_type": "Activity" }
    - Fix to edit a document when "_id" is an objectid

** 2.4.3(77) - oct 17, 2011 **

    - Fix to parse { "toto" : [ { "1" : 2 }, { "2" : 3 } ] }
    - Display errors (if any) when inserting a document
    - Display errors (if any) when removing a document
    - Fix to remove a document
    - Search for updates at each launch

** 2.4.2(76) - oct 15, 2011 **

    - Crash fixed when using an authenticated database
    - Show all the databases when using authentication
    - Use "admin" database when there is no database set for the authentication
    - Crash fixed when searching for mongo document with "{ "$oid" : "4E40C5111F85DD1BE9FAF825" }"
    - Adding the error message when the search criteria is invalid
    - Trying to be nice to complete your criteria. To search for an id, you can either type: 
            * 123
            * "abc"
            * "$oid" : "123"
            * {"$oid" : "123"}
    - Adding Command-R in the index view to reload the index list


** [Update 2.4.1(75)] **
    
    - Can do export and import (mysql)

** [Update 2.3.2] **
	
	- Fixed a bug in jsoneditor related to Date() object;
	- Add import/export to JSON/CSV functions;
	- Add support for ssh access use public key;
	- Add a function to remove single record in find query window;
	- Fixed a bug to create collection in a database which doesn't have collection;
	
** [Update 2.3.1] **
	
	- Fixed a bug in jsoneditor related to Date() object;
	- Add execution time in find panel;
	- Add reconnect support;
	- Fixed a bug in remove function.

** [2.3.0] **
	
	- Add mongo stat monitor;
	- Add replica set connection support;
	- Add reconnect support;
	- Add an JSON editor for found results with syntax highlight;
	- More flexible query style in find window;
	- Fixed long long int value overflow;
	- Fixed application crash during open/close connection window.

** [2.2.0] **
	
	- SSH Tunnel connection support;
	- Fixed a bug in display ObjectID type fields;
	- Fixed some UI bugs;
	- Fixed some memory leaks and random crashes;
	- Add confirm panel before drop database or collection;
	- Run queries in a seperate thread so that won't block the UI;
	- Fixed a bug to install on some 10.6.x(64bit) system.

** [2.1.0] **
	
	- Auto expand and collaspe finding results;
	- Display Date_t or Timestamp as GMT time format;
	- Fixed a bug in display ObjectIds in Array element;
	- Import data from mysql database to mongodb;
	- Export data from mongodb to mysql database.

** [2.0.9] **
	
	- Add support for mongohq.com;
	- Changed update behavior;
	- Fixed a bug to detect NumberLong type of BSONElement;
	- Fixed a bug in Array type of BSONElement.

** [2.0.8] **
	
	- Fix several UI bugs in Query Window;
	- Fix bugs in Find Query and Update Query;
	- Fix bugs related to ObjectId;
	- Fix copy&paste bugs.

** [2.0.7] **
	
	- Add sparkle framework to check application updates.

** [2.0.6] **
	
	- fixed some UI bugs;
	- add admin auth support.

## Contribute

I'd love to include your contributions, friend.

Then [send me a pull request](https://github.com/fotonauts/MongoHub-Mac/pull/new/master)!
