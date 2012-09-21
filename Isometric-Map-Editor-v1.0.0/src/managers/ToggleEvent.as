package  managers
{
	import flash.events.Event;
	
	/**
	 * Событие, для переключения между состояниями мыши
	 * в панели инструметнов
	 * @author lisnic.tk
	 * @version 1.0.0.0
	 */
	public class ToggleEvent extends Event 
	{
		static public const FILL:String = "fill";
		static public const ERASE:String = "erase";
		static public const ARROW:String = "arrow";
		public static const TILE:String = "tile";
		public static const PARAMS:String = "params";

		public var data:*;
		
		public function ToggleEvent(type:String, data:* = null) 
		{ 
			super(type, true);
			this.data = data;
		} 
		
		public override function clone():Event 
		{ 
			return new ToggleEvent(type,data);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("ToggleEvent", "type", "data"); 
		}
		
	}
	
}