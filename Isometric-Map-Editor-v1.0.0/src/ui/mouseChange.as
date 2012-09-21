package  ui {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import isospace.World;
	import managers.ToggleEvent;
	import utility.GC;
	
	/**
	 * Класс работы с верхней панелью инструментов
	 * @author lisnic.tk
	 * @version 1.0.0.0
	 */
	public class mouseChange extends MovieClip {
		
		public function mouseChange() {
			// constructor code
			arrowBtn.addEventListener(MouseEvent.CLICK, onArrowBtn);
			tileBtn.addEventListener(MouseEvent.CLICK, onTileBtn);
			eraseBtn.addEventListener(MouseEvent.CLICK, onEraseBtn);
			fillBtn.addEventListener(MouseEvent.CLICK, onFillBtn);
			paramsBtn.addEventListener(MouseEvent.CLICK, onParamsBtnBtn);
		}
		
		private function onParamsBtnBtn(e:MouseEvent):void 
		{
			//Рассылаю событие о клике:
			dispatchEvent(new ToggleEvent(ToggleEvent.PARAMS));
			updateBtns(ToggleEvent.PARAMS);
		}
		
		private function onArrowBtn(e:MouseEvent):void 
		{
			//Рассылаю событие о клике:
			dispatchEvent(new ToggleEvent(ToggleEvent.ARROW));
			updateBtns(ToggleEvent.ARROW);
		}
		private function onTileBtn(e:MouseEvent):void 
		{
			//Рассылаю событие о клике:
			//dispatchEvent(new ToggleEvent(ToggleEvent.TILE));
			updateBtns(ToggleEvent.TILE);
		}
		private function onEraseBtn(e:MouseEvent):void 
		{
			//Рассылаю событие о клике:
			dispatchEvent(new ToggleEvent(ToggleEvent.ERASE));
			updateBtns(ToggleEvent.ERASE);
		}
		private function onFillBtn(e:MouseEvent):void 
		{
			//Рассылаю событие о клике:
			dispatchEvent(new ToggleEvent(ToggleEvent.FILL));
			updateBtns(ToggleEvent.FILL);
		}
		public function updateBtns(typeBtn:String):void 
		{
			switch (typeBtn) 
			{
				case ToggleEvent.ARROW: { 
					arrowBtn.scaleX = arrowBtn.scaleY = 1.3;
					tileBtn.scaleX = tileBtn.scaleY = 1;
					eraseBtn.scaleX = eraseBtn.scaleY = 1;
					fillBtn.scaleX = fillBtn.scaleY = 1;
					paramsBtn.scaleX = paramsBtn.scaleY = 1;
					World.getInstance().MODE = GC.ARROW_MODE;
					if (World.getInstance()._currentTile) World.getInstance()._currentTile.bitmap.alpha = 0;
				}break;
				case ToggleEvent.TILE: { 
					arrowBtn.scaleX = arrowBtn.scaleY = 1;
					tileBtn.scaleX = tileBtn.scaleY = 1.3;
					eraseBtn.scaleX = eraseBtn.scaleY = 1;
					fillBtn.scaleX = fillBtn.scaleY = 1;	
					paramsBtn.scaleX = paramsBtn.scaleY = 1;
					World.getInstance().MODE = GC.TILE_MODE;
					World.getInstance().removeEventListener_ViewMouseDown();
					if (World.getInstance()._currentTile) World.getInstance()._currentTile.bitmap.alpha = 0.5;
				}break;
				case ToggleEvent.ERASE: { 
					arrowBtn.scaleX = arrowBtn.scaleY = 1;
					tileBtn.scaleX = tileBtn.scaleY = 1;
					eraseBtn.scaleX = eraseBtn.scaleY = 1.3;
					fillBtn.scaleX = fillBtn.scaleY = 1;
					paramsBtn.scaleX = paramsBtn.scaleY = 1;
					World.getInstance().MODE = GC.ERASE_MODE;
					World.getInstance().removeEventListener_ViewMouseDown();
				}break;
				case ToggleEvent.FILL: { 
					arrowBtn.scaleX = arrowBtn.scaleY = 1;
					tileBtn.scaleX = tileBtn.scaleY = 1;
					eraseBtn.scaleX = eraseBtn.scaleY = 1;
					fillBtn.scaleX = fillBtn.scaleY = 1.3;	
					paramsBtn.scaleX = paramsBtn.scaleY = 1;
					World.getInstance().MODE = GC.FILL_MODE;
					World.getInstance().removeEventListener_ViewMouseDown();
					if (World.getInstance()._currentTile) World.getInstance()._currentTile.bitmap.alpha = 0.5;
				}break;
				case ToggleEvent.PARAMS: { 
					arrowBtn.scaleX = arrowBtn.scaleY = 1;
					tileBtn.scaleX = tileBtn.scaleY = 1;
					eraseBtn.scaleX = eraseBtn.scaleY = 1;
					fillBtn.scaleX = fillBtn.scaleY = 1;	
					paramsBtn.scaleX = paramsBtn.scaleY = 1.3;	
					World.getInstance().MODE = GC.PARAMS_MODE;
					World.getInstance().removeEventListener_ViewMouseDown();
					if (World.getInstance()._currentTile) World.getInstance()._currentTile.bitmap.alpha = 0;
				}break;
			}
		}
		
	}
	
}
