## System Requirements

Mac OS X (10.8.x, 10.9.x, 10.10.x), intel 64bit based.

## Download

[HERE](https://github.com/downloads/bububa/MongoHub-Mac/MongoHub.zip)
Or you can compile it yourself using Xcode

## Build

Just build it, it should work (but let me know if you have an errors or warnings).

## Contributors

List of all [contributions](https://github.com/jeromelebel/MongoHub-Mac/graphs/contributors).

- [Alex Shteinikov](https://github.com/idooo), list of [commits](https://github.com/jeromelebel/MongoHub-Mac/commits?author=idooo)
- [Anthony Williams](https://github.com/abitgone), list of [commits](https://github.com/jeromelebel/MongoHub-Mac/commits?author=abitgone)
- [Chris Faulkner](https://github.com/faulkner), list of [commits](https://github.com/jeromelebel/MongoHub-Mac/commits?author=faulkner)
- [Joseph Price](https://github.com/joprice), list of [commits](https://github.com/jeromelebel/MongoHub-Mac/commits?author=joprice)
- [Lukas Benes](https://github.com/falsecz), list of [commits](https://github.com/jeromelebel/MongoHub-Mac/commits?author=falsecz)
- [Olivier Hardy](https://github.com/ohardy), list of [commits](https://github.com/jeromelebel/MongoHub-Mac/commits?author=ohardy)
- [Philipp Krenn](https://github.com/xeraa), list of [commits](https://github.com/jeromelebel/MongoHub-Mac/commits?author=xeraa)
- [Prof Syd Xu](https://github.com/bububa), list of [commits](https://github.com/jeromelebel/MongoHub-Mac/commits?author=bububa)
- [Steve Steiner](https://github.com/ssteinerx), list of [commits](https://github.com/jeromelebel/MongoHub-Mac/commits?author=ssteinerx)
- [Tom Bocklisch](https://github.com/tmbo), list of [commits](https://github.com/jeromelebel/MongoHub-Mac/commits?author=tmbo)
- [Travis Choma](https://github.com/travischoma), list of [commits](https://github.com/jeromelebel/MongoHub-Mac/commits?author=travis@emphatic.co)
- [魏涛](https://github.com/undancer), list of [commits](https://github.com/jeromelebel/MongoHub-Mac/commits?author=undancer)

Please send me a [pull request](https://github.com/jeromelebel/MongoHub-Mac/pull/new/master)!

## Current Status

**To do list**
    
- Create a document editor to edit using an outline view (like the plist editor in Xcode)

**Current**

- mongo-c-driver 1.1.4
- Adding a menu "Add Connection With URL…" [issue #108](https://github.com/jeromelebel/MongoHub-Mac/issues/108)
- Making sure all menu items are disabled when they should not be used
- Issue to get the document count in the aggregation result
- Can copy documents with OS X 10.8 and 10.9 thanks to [Sergey Basmanov](https://github.com/sbasmanov)

**Beta**

## History

**3.1.5b1 - april 13, 2015**

- mongo-c-driver 1.1.4
- Adding a menu "Add Connection With URL…" [issue #108](https://github.com/jeromelebel/MongoHub-Mac/issues/108)
- Making sure all menu items are disabled when they should not be used
- Issue to get the document count in the aggregation result
- Can copy documents with OS X 10.8 and 10.9 thanks to [Sergey Basmanov](https://github.com/sbasmanov)

**3.1.4 - march 28, 2015**

- Fixing issue to get indexes with Mongodb 3.0 [issue #199](https://github.com/jeromelebel/MongoHub-Mac/issues/199)

**3.1.3 - march 28, 2015**

- Issue with 10.9 to double click on a document, thanks to [Sergey Basmanov](https://github.com/sbasmanov)

**3.1.2 - march 28, 2015**

- Fix issue to edit only selected documents in the Find tab

**3.1.1 - march 28, 2015**

- Make aggregation tab be the default

**3.1 - march 28, 2015**

- Can copy documents in the Find tab
- Adding support for full screen in a connection window [issue #175](https://github.com/jeromelebel/MongoHub-Mac/issues/175)
- Adding a preference for the default sort order in the Find tab [issue #129](https://github.com/jeromelebel/MongoHub-Mac/issues/129)
- Adding a preference to present keys sorted in the Find tab [issue #77](https://github.com/jeromelebel/MongoHub-Mac/issues/77)
- Display errors from import/export
- Can import more than 200 documents [issue #172](https://github.com/jeromelebel/MongoHub-Mac/issues/172)
- Fix for a crash when the ssh drops [issue #171](https://github.com/jeromelebel/MongoHub-Mac/issues/171)
- New UI to create/drop indexes [issue #178](https://github.com/jeromelebel/MongoHub-Mac/issues/178)
- Removed duplicate collection name when generating displayed query in the find tab [pul #184](https://github.com/jeromelebel/MongoHub-Mac/pull/184), thanks to [Steve Steiner](https://github.com/ssteinerx)
- Showing dates in the outline view in local time zone [issue #174](https://github.com/jeromelebel/MongoHub-Mac/issues/174)
- Fix to export to mysql
- Can insert multiple documents in the insert tab with [ { document1 }, { document2 }, ... ]
- Dropping support for 10.7
- Dropping support for 32bits
- Don't open a contextual menu if a sheet is opened [issue #183](https://github.com/jeromelebel/MongoHub-Mac/issues/183)
- Crash fixed to parse wrong regexp in a json [issue #191](https://github.com/jeromelebel/MongoHub-Mac/issues/191)
- Documents are copied inside an array (using the pasteboard) [issue #195](https://github.com/jeromelebel/MongoHub-Mac/issues/195)
- Fix for a crash when the server is not valid [issue #196](https://github.com/jeromelebel/MongoHub-Mac/issues/196)
- Fix for a crash when changingn the collection name [issue #193](https://github.com/jeromelebel/MongoHub-Mac/issues/193)
- Fix for a crash when editing a document [issue #198](https://github.com/jeromelebel/MongoHub-Mac/issues/198)
- Crash fix for [issue #200](https://github.com/jeromelebel/MongoHub-Mac/issues/200)
- Fix to create a new database with mongodb 3.0 [issue #203](https://github.com/jeromelebel/MongoHub-Mac/issues/203)
- Better json editor feedback, when saving a document [issue #201](https://github.com/jeromelebel/MongoHub-Mac/issues/201)
- Copying documents are now in a json array (using the pasteboard) [issue #195](https://github.com/jeromelebel/MongoHub-Mac/issues/195)
- Support for Number.POSITIVE_INFINITY, Number.NEGATIVE_INFINITY, Number.NaN [issue #206](https://github.com/jeromelebel/MongoHub-Mac/issues/206)
- Parse correctly keys in a document (now, accepts numbers without quotes)
- Mongo C Driver 1.1.2
- Fix to make MongoHub usable again for services like Compose.io/MongoHQ, thanks to [Travis Choma](https://github.com/travischoma)

**3.1 beta 4 - march 6, 2015**

- Crash fix for [issue #200](https://github.com/jeromelebel/MongoHub-Mac/issues/200)
- Fix to create a new database with mongodb 3.0 [issue #203](https://github.com/jeromelebel/MongoHub-Mac/issues/203)
- Better json editor feedback, when saving a document [issue #201](https://github.com/jeromelebel/MongoHub-Mac/issues/201)
- Support for Number.POSITIVE_INFINITY, Number.NEGATIVE_INFINITY, Number.NaN [issue #206](https://github.com/jeromelebel/MongoHub-Mac/issues/206)
- Parse correctly keys in a document (now, accepts numbers without quotes)
- Fix for SCRAM authentification in Mongo 3.0 [issue #200](https://github.com/jeromelebel/MongoHub-Mac/issues/200)

**3.1 beta 3 - february 19, 2015**

- Copying documents are now in a json array (using the pasteboard) [issue #195](https://github.com/jeromelebel/MongoHub-Mac/issues/195)
- Fix for a crash when the server is not valid [issue #196](https://github.com/jeromelebel/MongoHub-Mac/issues/196)
- Fix for a crash when changingn the collection name [issue #193](https://github.com/jeromelebel/MongoHub-Mac/issues/193)
- Fix for a crash when editing a document [issue #198](https://github.com/jeromelebel/MongoHub-Mac/issues/198)

**3.1 beta 2 - february 4, 2015**

- Better parsing errors in the aggregation tab
- Avoiding some crashes in the aggregation tab

**3.1 beta 1 - january 19, 2015**

- Can copy documents in the Find tab
- Adding support for full screen in a connection window [issue #175](https://github.com/jeromelebel/MongoHub-Mac/issues/175)
- Adding a preference for the default sort order in the Find tab [issue #129](https://github.com/jeromelebel/MongoHub-Mac/issues/129)
- Adding a preference to present keys sorted in the Find tab [issue #77](https://github.com/jeromelebel/MongoHub-Mac/issues/77)
- Display errors from import/export
- Can import more than 200 documents [issue #172](https://github.com/jeromelebel/MongoHub-Mac/issues/172)
- Fix for a crash when the ssh drops [issue #171](https://github.com/jeromelebel/MongoHub-Mac/issues/171)
- New UI to create/drop indexes [issue #178](https://github.com/jeromelebel/MongoHub-Mac/issues/178)
- Removed duplicate collection name when generating displayed query in the find tab [pul #184](https://github.com/jeromelebel/MongoHub-Mac/pull/184), thanks to [Steve Steiner](https://github.com/ssteinerx)
- Showing dates in the outline view in local time zone [issue #174](https://github.com/jeromelebel/MongoHub-Mac/issues/174)
- Fix to export to mysql
- Can insert multiple documents in the insert tab with [ { document1 }, { document2 }, ... ]
- Dropping support for 10.7
- Dropping support for 32bits
- Don't open a contextual menu if a sheet is opened [issue #183](https://github.com/jeromelebel/MongoHub-Mac/issues/183)
- Crash fixed to parse wrong regexp in a json [issue #191](https://github.com/jeromelebel/MongoHub-Mac/issues/191)

**3.0.8 - november 5, 2014**

- Fixing bugs related to DBRef and $ref [issue #148](https://github.com/jeromelebel/MongoHub-Mac/issues/148)

**3.0.7 - november 5, 2014**

- Better support for DBRef(), the collection should be an absolute collection [issue #148](https://github.com/jeromelebel/MongoHub-Mac/issues/148)
- Better display of name connections in the main window [issue #72](https://github.com/jeromelebel/MongoHub-Mac/issues/72)
- Reopen the main window when coming back to the application (if closed) [issue #76](https://github.com/jeromelebel/MongoHub-Mac/issues/76)
- Add a dock menu (with all the connections)
- Can use return key to start a search in the find tab [issue #100](https://github.com/jeromelebel/MongoHub-Mac/issues/100)

**3.0.6 - october 30, 2014**

- Autoreconnect the ssh tunnel when it is down
- Changing the shortcut from ⌘→ and ⌘← to ⌥⌘→ and ⌥⌘← to get next and previous results in the find tab [issue #162](https://github.com/jeromelebel/MongoHub-Mac/issues/162)
- Issue to upgrade from old version (2.3.2) [issue #166](https://github.com/jeromelebel/MongoHub-Mac/issues/166)

**3.0.5 - october 23, 2014**

- Issue to edit 2 connections, one after the other
- Problem to migrate data store from 2.6.x to 3.0.x [issue #153](https://github.com/jeromelebel/MongoHub-Mac/issues/153)

**3.0.4 - october 22, 2014**

- Crash in the Monitor Activity [issue #155](https://github.com/jeromelebel/MongoHub-Mac/issues/155)
- Adding Next and Previous buttons [issue #149](https://github.com/jeromelebel/MongoHub-Mac/issues/149)
- Adding auto expand popup button to view results
- Crash closing the connection editor window while it is not a sheet
- Field filter now uses json (example : { field_to_see: 1, field_to_filter_out: 0 }) [issue #116](https://github.com/jeromelebel/MongoHub-Mac/issues/116)
- Don't show twice the collection name in the query (in the update tab) [issue #158](https://github.com/jeromelebel/MongoHub-Mac/issues/158)
- Avoiding a crash on 10.7 [issue #157](https://github.com/jeromelebel/MongoHub-Mac/issues/157) (I will drop the support of 10.7 soon)

**3.0.2 - october 21, 2014**

- Adding back the activity monitor (in the toolbar) [issue #152](https://github.com/jeromelebel/MongoHub-Mac/issues/152)
- Display correctly errors (if any) while saving a document
- Fixing few issues while editing the criteria in the remove tab [issue #151](https://github.com/jeromelebel/MongoHub-Mac/issues/151)
- Better support for DBRef
- Problem to autosave the toolbar in the connection window
- Maybe a fix for ssh problems [issue #146](https://github.com/jeromelebel/MongoHub-Mac/issues/146)
- Issue with default filename when doing file export

**3.0.1 - october 17, 2014**

- Fixing issue with passwords that contain some specific characters [issue #147](https://github.com/jeromelebel/MongoHub-Mac/issues/147)

**3.0 - october 17, 2014**

- SSL Working
- Fix for a crash when having problem to parse a json [issue #125](https://github.com/jeromelebel/MongoHub-Mac/issues/125)
- Support for functions and scope functions [issue #120](https://github.com/jeromelebel/MongoHub-Mac/issues/120)
- Fix to connect to mongoHQ [issue #124](https://github.com/jeromelebel/MongoHub-Mac/issues/124)
- Better support for primary and secondary in replica set
- Migrate SSH password into the keychain [issue #106](https://github.com/jeromelebel/MongoHub-Mac/issues/106)
- Migrate database password into the keychain [issue #106](https://github.com/jeromelebel/MongoHub-Mac/issues/106)
- Fix for adding a database with more than one server connected (the database was created on all servers)
- Fix for adding a collection with more than one server connected (the collection was created on all servers)
- Adding contextual menu in the main window
- Display glitch fixed in the connection window
- Adding a log window
- Accept connecting to secondary server [issue #113](https://github.com/jeromelebel/MongoHub-Mac/issues/113)
- Can change font and colors in the json editor and font [issue #135](https://github.com/jeromelebel/MongoHub-Mac/issues/135)
- cmd-w should close the current tab [issue #119](https://github.com/jeromelebel/MongoHub-Mac/issues/119)
- Better support for tunneling with replica set/sharding
- Can copy/paste mongodb URI [issue #108](https://github.com/jeromelebel/MongoHub-Mac/issues/108)
- Adding support for timeout parameter in URL
- Update some images to be high resolution [issue #54](https://github.com/jeromelebel/MongoHub-Mac/issues/54)
- Adding contextual menu in the database/collection list
- Can renaming a collection
- Closing tabs when dropping a collection/database
- Nicer update panel [issue #142](https://github.com/jeromelebel/MongoHub-Mac/issues/142)
- Workaround for corrupted bson
- Always check for debug updates on a debug version
- Fixing memory leaks
- A little faster to display a thousand collections in a database

**2.7 beta 21 - october 15, 2014**

- Workaround for corrupted bson

**2.7 beta 20 - october 15, 2014**

- Disable the remove operator button when needed

**2.7 beta 19 - october 15, 2014**

- Adding more update operator in the update tab
- Workaround for corrupted bson
- Always check for debug updates on a debug version

**2.7 beta 18 - october 14, 2014**

- Fixing memory leaks
- Better UI for dropping collections/databases
- Moving the timeout in the application preference
- Nicer update panel

**2.7 beta 17 - october 8, 2014**

- Display (in the log window) the correct error number if the connection failed
- Can renaming a collection
- Closing tabs when dropping a collection/database
- Connection issues fixed [issue #126](https://github.com/jeromelebel/MongoHub-Mac/issues/126)

**2.7 beta 16 - october 5, 2014**

- Adding back the edit icon in the main window
- Adding contextual menu in the database/collection list
- Workaround for connection problem

**2.7 beta 15 - october 4, 2014**

- Fix for ssl [issue #140](https://github.com/jeromelebel/MongoHub-Mac/issues/140)
- Update some images to be high resolution [issue #54](https://github.com/jeromelebel/MongoHub-Mac/issues/54)

**2.7 beta 14 - october 4, 2014**

- Fix to display a lot of collections [issue #139](https://github.com/jeromelebel/MongoHub-Mac/issues/139)

**2.7 beta 13 - september 29, 2014**

- Support for URI pasted in the main window
- Adding support for timeout parameter in URL

**2.7 beta 12 - september 2, 2014**

- Fix in the close button of a connection window

**2.7 beta 11 - september 2, 2014**

- Adding a log window
- Accept connecting to secondary server [issue #113](https://github.com/jeromelebel/MongoHub-Mac/issues/113)
- Can change font and colors in the json editor and font [issue #135](https://github.com/jeromelebel/MongoHub-Mac/issues/135)
- cmd-w should close the current tab [issue #119](https://github.com/jeromelebel/MongoHub-Mac/issues/119)
- Better support for tunneling with replica set/sharding

**2.7 beta 10 - august 27, 2014**

- Display glitch fixed in the connection window

**2.7 beta 9 - august 26, 2014**

- SSL fix

**2.7 beta 8 - august 25, 2014**

- Migrate SSH password into the keychain [issue #106](https://github.com/jeromelebel/MongoHub-Mac/issues/106)
- Migrate database password into the keychain [issue #106](https://github.com/jeromelebel/MongoHub-Mac/issues/106)
- Fix for adding a database with more than one server connected (the database was created on all servers)
- Fix for adding a collection with more than one server connected (the collection was created on all servers)
- Adding contextual menu in the main window
- Can copy mongodb URI
- Adding the option for weak SSL certificate

**2.7 beta 7 - july 23, 2014**

- Fix for a problem to parse json (bug introduced in 2.7)

**2.7 beta 6 - july 21, 2014**

- SSL was activated for all connections

**2.7 beta 5 - july 19, 2014**

- Fix for ports higher than 32767 (bug introduced in 2.7)

**2.7 beta 4 - july 18, 2014**

- SSL Working

**2.7 beta 3 - june 13, 2014**

- Support for functions and scope functions [issue #120](https://github.com/jeromelebel/MongoHub-Mac/issues/120)
- Fix to connect to mongoHQ [issue #124](https://github.com/jeromelebel/MongoHub-Mac/issues/124)

**2.6.2 - june 12, 2014**

- Be able to downgrade from 2.7 beta
- Avoid automatic correction from Mac OS X while typing a new document [issue #121](https://github.com/jeromelebel/MongoHub-Mac/issues/121) (Thanks to Anthony Williams with [pull request #122](https://github.com/jeromelebel/MongoHub-Mac/pull/122))
- Avoid automatic correction from Mac OS X while typing map/reduce functions

**2.7 beta 1 and 2 - june 11, 2014**

- Avoid automatic correction from Mac OS X while typing a new document [issue #121](https://github.com/jeromelebel/MongoHub-Mac/issues/121) (Thanks to Anthony Williams with [pull request #122](https://github.com/jeromelebel/MongoHub-Mac/pull/122))
- Avoid automatic correction from Mac OS X while typing map/reduce functions
- Better support for primary and secondary

**2.6 - april 17, 2014**

- Support for tengen json
- Progress bar while importing/exporting to/from file
- A lot of fix to convert dates with milliseconds into json and parse dates with milliseconds
- Using more sheets instead of modal panels
- Few crashes fixed
- More checks to make sure a document is parsed correctly (and therefore there is no modification while converting a document into json and parsing again the json)
- Better support for long integer vs integer

**2.6 beta 6 - january 16, 2014**

- Using a sheet to remove a connection
- Removing a crash when trying to remove some documents (with the tab)
- Better way to make sure we don't modify a document, and better way to notify it to the user
- Using sheet to add a database or a collection

**2.6 beta 5 - december 15, 2013**

- Fixing connection icon display at launch
- Json export/import working
- A better test to make sure no data are corrupted while editing a document

**2.6 beta 4 - november 21, 2013**

- Make sure we don't mixup double and integer type (while editing a document)
- Trying to explain to the user if a document might be changed while editing it

**2.6 beta 3 - november 21, 2013**

- Correct support for integer and long integer type (no more mix up)

**2.5.15 - november 17, 2013**

- Removing an assert (while editing a document) with too much false positive
- Connection editor window is displayed as a sheet
- Can duplication a connection [issue #75](https://github.com/jeromelebel/MongoHub-Mac/issues/75)
- Short cut to delete a connection (command-backspace) [issue #69](https://github.com/jeromelebel/MongoHub-Mac/issues/69)

**2.5.14 - november 16, 2013**

- Using the ssh-agent when having passphrase [issue #93](https://github.com/jeromelebel/MongoHub-Mac/issues/93) (thanks for Nick Brook's help)
- Fix from a bug introduced in 2.5.13(107), problem to tab away the document outline view to the delete button [issue #97](https://github.com/jeromelebel/MongoHub-Mac/issues/97)
- Better error reporting for find, update or delete (thanks to Johannes Schriewer)
- Fix for database with no name [issue #101](https://github.com/jeromelebel/MongoHub-Mac/issues/101)
- Fix for generating/parsing json with a date with milliseconds [issue #102](https://github.com/jeromelebel/MongoHub-Mac/issues/102)
- Adding a preference panel to choose to get beta version (this will support tengen json)
- Dropping support for Mac OS X 10.6.x

**2.5.13(107) - october 19, 2013**

- Can type any value without double quote in the search field, it will be replaced by { "_id": "<value>" }
- Adding support for retina display (thanks to Patryk Kasperski)
- Following the strict json for undefined value according to [extended json](http://docs.mongodb.org/manual/reference/mongodb-extended-json/) (now, exporting and parsing undefined as { "$undefined": true }
- Fixing a crash when trying to save an invalid json document

**2.5.12(106) - september 8, 2013**
    
- New build to fix the font problem in the query window [issue #91](https://github.com/jeromelebel/MongoHub-Mac/issues/91)

**2.5.11(105) - september 7, 2013**

- Default port was not set (thanks to undancer) [issue #89](https://github.com/jeromelebel/MongoHub-Mac/issues/89)

**2.5.10(104) - june 11, 2013**

- Problem to convert a double from bson to json and back to bson (bis)
- Adding support to minKey and maxKey (thanks for castiel's help)

**2.5.9(103) - june 11, 2013**

- Problem to convert a double from bson to json and back to bson

**2.5.8(102) - june 11, 2013**

- Crash while opening a collection that contains a data (introduced in 2.5.6)

**2.5.7(101) - june 6, 2013**

- Drop database/collection default action must be "No" [issue #65](https://github.com/jeromelebel/MongoHub-Mac/issues/65)
- New Connection window doesn't use 127.0.0.1:27017 by default [issue #60](https://github.com/jeromelebel/MongoHub-Mac/issues/60)
- Double values are truncated while being edited

**2.5.6(100) - may 19, 2013**

- Unable to reopen connection window after it is closed [issue #63](https://github.com/jeromelebel/MongoHub-Mac/issues/63)
- Horizontal and vertical paddings between "New connection" button and window border must be equal [issue #68](https://github.com/jeromelebel/MongoHub-Mac/issues/68)
- Binary should be imported and exported as base64 (instead of hexa)
- Accept queries with objectid between double quotes
- Bug fix when the mongo host port was left with the default value (while using ssh tunneling) [issue #78](https://github.com/jeromelebel/MongoHub-Mac/issues/78)
- ssh tunnel is a lot faster to open the connection now

**2.5.5(99) - march 3, 2013**

- Problem to modify ssh parameters while editing an existing connection (fields were disabled)
- Multi update checkbox added for updates (thanks to Tom Bocklisch)
- Bug fix to export mongo to sql: crash while exporting [issue #58](https://github.com/jeromelebel/MongoHub-Mac/issues/58)
- ObjectId should be in lower case [issue #55](https://github.com/jeromelebel/MongoHub-Mac/issues/55)
- Confirm dialog before connection delete (thanks to falsecz) https://github.com/jeromelebel/MongoHub-Mac/pull/57

**2.5.4(98) - november 1, 2012**

- Fix to display Undefined values [issue #49](https://github.com/jeromelebel/MongoHub-Mac/issues/49)
- Fix to avoid a crasher with disconnecting from a server while using ssh tunneling [issue #48](https://github.com/jeromelebel/MongoHub-Mac/issues/48)
- Use ⌘ to avoid the confirmation panel in the remove tab (either while clicking or pressing the return key)

**2.5.3(97) - september 4, 2012**

- No more setting for bind address and bind port (bind address is 127.0.0.1 and bind port will be choosen automatically from 40000 or higher) [issue #19](https://github.com/jeromelebel/MongoHub-Mac/issues/19)
- Fix for a crasher when the network goes down [issue #42](https://github.com/jeromelebel/MongoHub-Mac/issues/42)
- Changing from red to green (except for remove) [issue #44](https://github.com/jeromelebel/MongoHub-Mac/issues/44)
- Adding a confirmation dialog correctly when removing all documents [issue #33](https://github.com/jeromelebel/MongoHub-Mac/issues/33)
- Some cleanup for the connection editor, thanks to Alex Shteinikov (idooo)

**2.5.2(96) - july 15, 2012**

- Fix: Some UTF8 characters became invisible while editing a document
- Fix: Some problems with updating colors while editing
- Open only one document window for each document
- Close all document windows when close a collection
- Fix: Making sure the collection outline selection always match the collection tab selection (to make sure Fred doesn't make any mistake)
- Fix: a blank query will not remove documents anymore. Please use at least '{}'
- Fix: problem to import documents with array in it [issue #39](https://github.com/jeromelebel/MongoHub-Mac/issues/39)
- Adding multiple document selection
- Adding document drag

**2.5.1(95) - june 21, 2012**

- Fix for [issue #36](https://github.com/jeromelebel/MongoHub-Mac/issues/36) (open a second time the same database tab)
- Trying to make sure we don't make a mistake between the tab opened and the selection in the database outline view (special for fred)

**2.5(94) - may 27, 2012**

- Fix for the limit and skip field (limited to 9999) [issue #30](https://github.com/jeromelebel/MongoHub-Mac/issues/30)
- Adding tabs

**2.4.19(93) - may 23, 2012**

- Trying to keep type (integer and float) the same as much as possible (when editing a document) [issue #35](https://github.com/jeromelebel/MongoHub-Mac/issues/35)
- Crash fixed when opening a collection with documents that has no "_id" and "name" [issue #24](https://github.com/jeromelebel/MongoHub-Mac/issues/24)

**2.4.18(92) - may 10, 2012**

- Fix crasher when error [issue #31](https://github.com/jeromelebel/MongoHub-Mac/issues/31)
- Fix to use an authenticated database

**2.4.17(91) - may 5, 2012**

- Fix to parse binary values
- Fix to parse an hash with $type
- Changing "upset" to "upsert"
- Fix from billybobuk to get the database list when having auth
- Adding header in the data outline view
- Fix to add a document with structures inside an array [issue #28](https://github.com/jeromelebel/MongoHub-Mac/issues/28)

**2.4.16(90) - jan 29, 2012**

- Adding autosave for the connection list window
- Adding back the index icon
- Better error message when not having the authorization to get the server status
- Crash fixed when not having the authorization to get the server status

**2.4.15(89) - dec 30, 2011**

- Crash fixed when remove all documents : [issue #18](https://github.com/jeromelebel/MongoHub-Mac/issues/18)
- Change minimum size of MainMenu window to avoid display bug (thanks ohardy)
- Bug fixes (thanks ohardy)
- Double click on database name collapse or expand item (thanks ohardy)

**2.4.14(88) - dec 23, 2011**

- Adding full-screen support (lion only), thanks callumj
- Fix when you don't have the right to get the database list (you need to set the database you want to use in the connection panel)

**2.4.13(87) - nov 30, 2011**

	- Key order is preserved in a document
- Support for UTF-8
- Fix for Mysql import/export
- Support for symbol type
- fix for the UI selection in the connection window

**2.4.12(86) - nov 22, 2011**

- Problem to update document with boolean values and regexp values

**2.4.11(85) - nov 22, 2011**

- Toolbar items are enabled/disabled according to the selection
- Connecting to localhost is not an issue anymore
- Bug to parse json with arrays

**2.4.10(84) - nov 19, 2011**

- Bug to add a new connection

**2.4.9(83) - nov 18, 2011**

- Changing the NSBundle application id
- Database stats works again
- History combo-box for the criteria
- Fix to use database with an admin user/password

**2.4.8(82) - nov 1, 2011**

- Problem to display and parse date types
    
**2.4.7(81) - nov 1, 2011**
    
- Connections are sorted after being loaded (still not sorted after being updated)
- Adding short cuts to delete a document or an index (Command+delete)
- Adding tooltips for the buttons with short cuts
- Queries are sorted by default
- Problem to display regex and timestamp values in documents

**2.4.6(80) - oct 28, 2011**
    
- Can insert an array of documents
- MapReduce feature working
- Fix for parsing: "$oid":"4E9321AF3768CF514A00000C"}
- Crash when getting stats for some servers
- New outline view for the databases and collections

**2.4.5(79) - oct 22, 2011**

- Fix to parse { "empty_array": [], "zob": 1}
- Fix to parse { "empty_hash": {}, "zob": 1}
- Implementing reIndex

**2.4.4(78) - oct 20, 2011**

- Can create indexes with the UI
- Can remove indexes with the UI
- Fix to parse { "_id": { "$oid" : "4E9807F88157F608B4000002" }, "_type": "Activity" }
- Fix to edit a document when "_id" is an objectid

**2.4.3(77) - oct 17, 2011**

- Fix to parse { "toto" : [ { "1" : 2 }, { "2" : 3 } ] }
- Display errors (if any) when inserting a document
- Display errors (if any) when removing a document
- Fix to remove a document
- Search for updates at each launch

**2.4.2(76) - oct 15, 2011**

- Crash fixed when using an authenticated database
- Show all the databases when using authentication
- Use "admin" database when there is no database set for the authentication
- Crash fixed when searching for mongo document with "{ "$oid" : "4E40C5111F85DD1BE9FAF825" }"
- Adding the error message when the search criteria is invalid
- Trying to be nice to complete your criteria. To search for an id, you can either type: 
 - 123
 - "abc"
 - "$oid" : "123"
 - {"$oid" : "123"}
- Adding Command-R in the index view to reload the index list


**[Update 2.4.1(75)]**
    
- Can do export and import (mysql)

**[Update 2.3.2]**
	
- Fixed a bug in jsoneditor related to Date() object;
- Add import/export to JSON/CSV functions;
- Add support for ssh access use public key;
- Add a function to remove single record in find query window;
- Fixed a bug to create collection in a database which doesn't have collection;
	
**[Update 2.3.1]**

- Fixed a bug in jsoneditor related to Date() object;
- Add execution time in find panel;
- Add reconnect support;
- Fixed a bug in remove function.

**[2.3.0]**

- Add mongo stat monitor;
- Add replica set connection support;
- Add reconnect support;
- Add an JSON editor for found results with syntax highlight;
- More flexible query style in find window;
- Fixed long long int value overflow;
- Fixed application crash during open/close connection window.

**[2.2.0]**

- SSH Tunnel connection support;
- Fixed a bug in display ObjectID type fields;
- Fixed some UI bugs;
- Fixed some memory leaks and random crashes;
- Add confirm panel before drop database or collection;
- Run queries in a seperate thread so that won't block the UI;
- Fixed a bug to install on some 10.6.x(64bit) system.

**[2.1.0]**

- Auto expand and collaspe finding results;
- Display Date_t or Timestamp as GMT time format;
- Fixed a bug in display ObjectIds in Array element;
- Import data from mysql database to mongodb;
- Export data from mongodb to mysql database.

**[2.0.9]**

- Add support for mongohq.com;
- Changed update behavior;
- Fixed a bug to detect NumberLong type of BSONElement;
- Fixed a bug in Array type of BSONElement.

**[2.0.8]**

- Fix several UI bugs in Query Window;
- Fix bugs in Find Query and Update Query;
- Fix bugs related to ObjectId;
- Fix copy&paste bugs.

**[2.0.7]**

- Add sparkle framework to check application updates.

**[2.0.6]**

- fixed some UI bugs;
- add admin auth support.
