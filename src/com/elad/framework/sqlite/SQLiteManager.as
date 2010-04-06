/*
 
     Copyright (c) 2009 Elad Elrom.  Elrom LLC. All rights reserved. 
    
    Permission is hereby granted, free of charge, to any person
    obtaining a copy of this software and associated documentation
    files (the "Software"), to deal in the Software without
    restriction, including without limitation the rights to use,
    copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the
    Software is furnished to do so, subject to the following
    conditions:
    
    The above copyright notice and this permission notice shall be
    included in all copies or substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
    OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
    NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
    HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
    WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
    FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
    OTHER DEALINGS IN THE SOFTWARE.

     @author  Elad Elrom
     @contact elad.ny at gmail.com

 */
package com.elad.framework.sqlite
{
	import com.elad.framework.sqlite.events.StatementSuccessEvent;
	
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	import flash.errors.SQLError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	import flash.filesystem.File;

	/**
	 * <code>SQLiteManager</code> help handling the database connections and calls. You pass a start properties to the singleton and you
	 * can execute common commands or custom commands.
	 * 
	 * @author elad
	 * 
	 * @example The following code sets the volume level for your sound:  
	 * <listing version="3.0">
	 * 		var database:SQLiteManager = SQLiteManager.getInstance();
	 * 		database.start("Users.sql3", "Users", "CREATE TABLE Users(userId VARCHAR(150) PRIMARY KEY, UserName VARCHAR(150))");
	 * 		
	 * 		database.addEventListener(SQLiteManager.COMMAND_EXEC_SUCCESSFULLY, onSelectResult);
	 * 		database.addEventListener(SQLiteManager.COMMAND_EXEC_FAILED, onFail);
	 * 		
	 * 		database.executeSelectAllCommand();
	 *		
	 *		private function onSelectResult(event:StatementSuccessEvent):void
	 *		{
	 *		     var result:Array = event.results.data;
	 *		}
	 *		
	 *		private function onFail(event:Event):void
	 *		{
	 *		     // handle fail
	 *		}
	 * </listing>
	 * 
	 */
	public class SQLiteManager extends EventDispatcher implements ISQLiteManager
	{
		/**
		 * Database file name and extension
		 */		
		public var dbFullFileName:String;
		
		/**
		 * Database Name
		 */		
		public var tableName:String;
		
		/**
		 * SQL command to create the database
		 */		
		public var createDbStatement:String;
		
		// datsbase apis instances
		protected var connection:SQLConnection;
		protected var statement:SQLStatement;
		protected var sqlFile:File;
		
		// repeated sql command
		protected var repeateFailCallBack:Function;
		protected var repeateCallBack:Function;
		protected var repeateSqlCommand:String = "";
		
		// events strings
		public static var COMMAND_EXEC_SUCCESSFULLY:String = "commandExecSuccesfully";
		public static var DATABASE_CONNECTED_SUCCESSFULLY:String = "databaseConnectedSuccessfully";
		public static var COMMAND_EXEC_FAILED:String = "commandExecFailed";
		public static var DATABASE_READY:String = "databaseReady";
		
		// Singleton instance.
		protected static var instance:SQLiteManager;
		
		/**
		 * Enforce singleton design pattern.
		 *  
		 * @param enforcer
		 * 
		 */		
		public function SQLiteManager(enforcer:AccessRestriction)
		{
			if (enforcer == null)
				throw new Error("Error enforcer input param is undefined" );
		}
		
		/**
		 * Opens a database connection.
		 *  
		 * @param dbFullFileName the database file name for instance: Users.sql
		 * @param tableName holds the database name, for instance: Users
		 * @param createTableStatement holds the create database statment for instance: CREATE TABLE Users(userId VARCHAR(150) PRIMARY KEY, UserName VARCHAR(150))
		 * 
		 */	
		public function start(dbFullFileName:String, tableName:String, createTableStatement:String):void
		{    
			this.dbFullFileName = dbFullFileName;
			this.tableName = tableName;
			this.createDbStatement = createTableStatement;
						   		
			connection = new SQLConnection();
			sqlFile = File.applicationStorageDirectory.resolvePath(dbFullFileName);
			
			try
			{
			    connection.open(sqlFile);
			    this.dispatchEvent(new Event(DATABASE_CONNECTED_SUCCESSFULLY));
			}
			catch (error:SQLError)
			{
			    trace("Error message:", error.message);
			    trace("Details:", error.details);
			    fail();
			}
		}
		
		
		/**
		 * Close connection 
		 * 
		 */		
		public function close():void
		{
			connection.close();
		}		
		
		/**
		 * Test the table to ensure it exists. Sends a fail call back function to create the table if 
		 * it doesn't exists.
		 * 
		 */		
		public function testTableExists():void
		{
			var sql:String = "SELECT * FROM "+tableName+" LIMIT 1;";
			executeCustomCommand(sql, this.onDatabaseReady, this.createTable );	 			
		}
	
		/**
		 * Method to create the database table.
		 * 
		 */		
		private function createTable():void
		{
		    statement = new SQLStatement();
		    statement.sqlConnection = connection;
		    statement.text = createDbStatement;
		    statement.execute();
		    
		    statement.addEventListener(SQLEvent.RESULT, onDatabaseReady);			
		}
		
		/**
		 * Common sql command: select all entries in database
		 *  
		 * @param callback
		 * @param failCallback
		 * 
		 */		
		public function executeSelectAllCommand(callback:Function=null, failCallback:Function=null):void
		{
			var sql:String = "SELECT * FROM "+tableName+";";
			executeCustomCommand(sql, callback, failCallback);
		}
		
		/**
		 * Common sql command: delete all entries in database
		 * 
		 * @param callback
		 * 
		 */		
		public function executeDeleteAllCommand(callback:Function=null):void
		{
			var sql:String = "DELETE * FROM "+tableName+";";
			executeCustomCommand(sql, callback);
		}		
				
		/**
		 * Method to execute a SQL command
		 * 
		 * @param sql SQL command string
		 * @param callback success call back function to impliment if necessery
		 * @param failCallBack fail call back function to impliment if necessery
		 * 
		 */	
		public function executeCustomCommand(sql:String, callBack:Function=null, failCallBack:Function=null):void
		{
		    statement = new SQLStatement();
		    statement.sqlConnection = connection;
		    
		    statement.text = sql;
		    
		    if (callBack!=null)
		    {
		    	statement.addEventListener(SQLEvent.RESULT, callBack);
		    }
		    else
		    {
		    	statement.addEventListener(SQLEvent.RESULT, onStatementSuccess);
		    }
		    
		    statement.addEventListener(SQLErrorEvent.ERROR, function():void {
		    		fail();
		    	});
		    
			try
			{
			    statement.execute();
			}
			catch (error:SQLError)
			{
				this.handleErrors(error, sql, callBack, failCallBack);			    
			}			
		}
		
		/**
		 * Utility method to clean bad characters that can break SQL commands 
		 * 
		 * @param str
		 * @return 
		 * 
		 */		
		public static function removeBadCharacters(str:String):String
		{
			var retVal:String = str.split("'").join("&#8217;&rsquo;");
			return retVal;
		}

		// ------------------------------HANDLERS----------------------------		

		/**
		 * Method to handle SQL command that create the dataabase.  
		 * If the method was created due to a fail SQL command method checks if need to repeate any SQL command.
		 *  
		 * @param event
		 * 
		 */		
		private function onDatabaseReady(event:Event=null):void
		{
			var evt:Event = new Event(DATABASE_READY);
			this.dispatchEvent(evt);
			
			if (repeateSqlCommand != "")
			{
				this.executeCustomCommand(repeateSqlCommand, repeateCallBack, repeateFailCallBack);
				
				repeateSqlCommand = "";
				repeateFailCallBack = null;
				repeateCallBack = null;
			}
		}
				
		/**
		 * Handle successful calls 
		 * @param event
		 * 
		 */		
		private function onStatementSuccess(event:SQLEvent):void 
		{
			var results:Object = statement.getResult();
			var sqlText:String = statement.text;
			var evt:StatementSuccessEvent = new StatementSuccessEvent(COMMAND_EXEC_SUCCESSFULLY, results, sqlText);
			this.dispatchEvent(evt);
		}
		
		/**
		 * Error handler
		 *  
		 * @param error
		 * @param sql
		 * @param callBack
		 * @param failCallBack
		 * 
		 */		
		private function handleErrors(error:SQLError, sql:String, callBack:Function, failCallBack:Function):void
		{
			trace("Error message:", error.message);
			trace("Details:", error.details);
			    			
		    if (error.details == "no such table: '"+tableName+"'")
		    {
		    	repeateSqlCommand = sql;
		    	repeateFailCallBack = failCallBack;
		    	repeateCallBack = callBack; 
		    	createTable();
		    }
		    else
		    {
			    if (failCallBack != null)
			    {
			    	failCallBack();
			    }
			    else
			    {
			    	fail();
			    }			    	
		    }			
		}
		
		/**
		 * Handler for fail calls
		 *  
		 * @param event
		 * 
		 */		
		private function fail(event:Event=null):void
		{
	        var evt:Event = new Event(COMMAND_EXEC_FAILED);
	        this.dispatchEvent(evt);
	        
	        close();
		}

		/**
		 * Method function to retrieve instance of the class
		 *  
		 * @return The same instance of the class
		 * 
		 */
		public static function getInstance():SQLiteManager
		{
			if( instance == null )
				instance = new  SQLiteManager(new AccessRestriction());
			
			return instance;
		}
				
	}
}

class AccessRestriction {}