package ui 
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import isospace.World;
	
	/**
	 * Popup Новая карта
	 * @author lisnic.tk
	 * @version 1.0.0.0
	 */
	public class popupNewMap extends MovieClip 
	{
		
		public function popupNewMap() 
		{
			yesBtn.addEventListener(MouseEvent.CLICK, onClickYes);
			noBtn.addEventListener(MouseEvent.CLICK, onClickNo);
		}
		
		/**
		 * Скрывает окошко
		 * @param	e
		 */
		private function onClickNo(e:MouseEvent):void 
		{
			this.visible = false;
		}
		
		/**
		 * Создание новой карты
		 * @param	e
		 */
		private function onClickYes(e:MouseEvent):void 
		{
			// Удаление всех тайлов со сцены:
			World.getInstance().removeAllTilesFromMap();
			
			// Удаление всех слоев.
			MovieClip(root).Panel.listLayersMC.removeAllLayers();
			
			// Добавляет один слой
			MovieClip(root).Panel.listLayersMC.onClickAddLayer(null);
			
			this.visible = false;
		}
		

		
	}

}