package com.toddrothe.model.vo
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	public class ReadingVO extends EventDispatcher
	{
		private var _id:int;
		public function get id():int
		{
			return _id;
		}
		public function set id(v:int):void
		{
			_id = v;
		}
		
		private var _date:Date;
		public function get date():Date
		{
			return _date;
		}
		public function set date(v:Date):void
		{
			_date = new Date( v );
		}
		
		private var _moisture:int;
		public function get moisture():int
		{
			return _moisture;
		}
		public function set moisture(v:int):void
		{
			_moisture = v;
		}
		
		private var _temprature:int;
		public function get temprature():int
		{
			return _temprature;
		}
		public function set temprature(v:int):void
		{
			_temprature = v;
		}
		
		private var _light:int;
		public function get light():int
		{
			return _light;
		}
		public function set light(v:int):void
		{
			_light = v;
		}
		
		
// TR: CONSTRUCTOR		
		public function ReadingVO(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function createReadingObj( id:int, date:Date, moisture:int, temprature:int, light:int ):void
		{
			this.id = id;
			this.date = date;
			this.moisture = moisture;
			this.temprature = temprature;
			this.light = light;
		}
		
	}
}