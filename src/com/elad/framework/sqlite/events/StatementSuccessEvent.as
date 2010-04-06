package com.elad.framework.sqlite.events
{
	import flash.data.SQLStatement;
	import flash.events.Event;
	
	public class StatementSuccessEvent extends Event 
	{
	    /**
	     *  Holds the event string name
	     */		
	    public static var COMMAND_EXEC_SUCCESSFULLY:String = "command_exec_succesfully";
		
		/**
		 * Holds results object 
		 */			
		public var results:Object;
		/**
		 * Holds sql statement text to allow for event handler parsing 
		 */			
		public var sqlText:String;
				
		/**
		 * Default constructor
		 *  
		 * @param type	event name
		 * @param videoList	video list collection
		 * 
		 */			
		public function StatementSuccessEvent(type:String, results:Object, sqlText:String)
		{
			super(type);
			this.results = results;
			this.sqlText = sqlText;
		}
	}
}