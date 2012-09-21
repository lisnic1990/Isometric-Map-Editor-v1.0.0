package isospace {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	/**
	 * Контейнер для изображения
	 * @author lisnic.tk
	 * @version 1.0.0.0
	 */
	public class IsoContainer extends MovieClip {
		
		private var _world:World;
		
		public function IsoContainer() {

			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			// Создание изометрического мира
			_world = new World(800, 600, 10, 10, 32);
			addChild(_world);
		}
		/**
		 * Возвращает мир
		 */
		public function get world():World 
		{
			return _world;
		}


	}
}
