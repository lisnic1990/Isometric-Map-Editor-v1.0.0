package ui
{
	import flash.events.KeyboardEvent;
	
	/**
	 * Класс для работы с клавиатурой
	 * 
	 * @author lisnic.tk
	 * @version 1.0.0.0
	 */
	public class keys
	{		
		private var _theyArePressed:Object = { };
		
		public function keys(movieclip)
		{
			movieclip.stage.addEventListener(KeyboardEvent.KEY_DOWN, key_down);
			movieclip.stage.addEventListener(KeyboardEvent.KEY_UP, key_up);
		}

		private function key_down(event:KeyboardEvent):void
		{
			_theyArePressed[event.keyCode] = true;
		}
		private function key_up(event:KeyboardEvent):void
		{
			_theyArePressed[event.keyCode] = false;
		}
		
		public function get theyArePressed():Object 
		{
			return _theyArePressed;
		}
	}
}