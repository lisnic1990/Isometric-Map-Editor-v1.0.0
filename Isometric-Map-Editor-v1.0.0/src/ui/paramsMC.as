package  ui {
	
	import flash.display.MovieClip;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import isospace.Tile;
	import isospace.World;
	import managers.ToggleEvent;
	import utility.GC;
	
	/**
	 * Класс окна изменнеия параметров объектов на карте
	 * @author lisnic.tk
	 * @version 1.0.0.0
	 */
	public class paramsMC extends MovieClip {
		
		private var tempParamsArr:Array = [];
		private var tile:Tile;
		
		public function paramsMC() {
			// constructor code
			addBtn.addEventListener(MouseEvent.CLICK, onAddBtn);
			okBtn.addEventListener(MouseEvent.CLICK, onOkBtn);
			cancelBtn.addEventListener(MouseEvent.CLICK, onCancelBtn);
			
			//Обработка нажания Enter:
			nameField.addEventListener(KeyboardEvent.KEY_UP, key_down);
			valueField.addEventListener(KeyboardEvent.KEY_UP, key_down);
		}
		/**
		 * Нажата клавиша Enter
		 * @param	event
		 */
		private function key_down(event:KeyboardEvent):void
		{
			if (event.keyCode == 13) 
			{
				onAddBtn(null);
			}
		}
		/**
		 * Отмена
		 * @param	e
		 */
		private function onCancelBtn(e:MouseEvent):void 
		{
			clearAllItemsContainerMC();
			this.visible = false;
		}
		/**
		 * Ок, сохранение введеных параметров
		 * @param	e
		 */
		private function onOkBtn(e:MouseEvent):void 
		{
			if (tile) 
			{
				//Очищение массива с параметрами у тайла:
				tile.paramsArr.length = 0;
				//Запись tempParamsArr в массив тайла tile.paramsArr:
				for (var i:int = 0; i < tempParamsArr.length; i++) 
				{
					tile.paramsArr[i] = { name:tempParamsArr[i].nameField.text, value:tempParamsArr[i].valueField.text };
					// trace('есть тайл '+tile + tempParamsArr[i].nameField.text, tempParamsArr[i].valueField.text );
				}
				clearAllItemsContainerMC();
			}
			this.visible = false;
		}
		
		/**
		 * Удаление Item-ов из бласти видимости
		 */
		private function clearAllItemsContainerMC():void 
		{
			//Удаляю из массива и из this.itemsContainerMC:
			if(this.itemsContainerMC.numChildren!=0){
				var k:int = this.itemsContainerMC.numChildren;
				while( k -- )
				{
					this.itemsContainerMC.removeChildAt( k );
				}
			}
			//Очищение временного массива:
			tempParamsArr.length = 0;
		}
		/**
		 * Открывает окно с параметрами
		 * @param	targetTile
		 */
		public function openParamsEditor(targetTile:Tile):void 
		{
			//Удаление Item-ов из бласти видимости:
			clearAllItemsContainerMC();
			
			if (targetTile) 
			{
				this.visible = true;
				tile = targetTile;
				this.nameTile.text = tile.name;
				this.LayerNameTile.text = tile.inLayer;
				this.positionTile.text = 'x = ' + tile._column + '  y = ' + tile._row;
				for (var i:int = 0; i < tile.paramsArr.length; i++) 
				{
					var item:itemParamsMC = new itemParamsMC();
					item.removeBtn.addEventListener(MouseEvent.CLICK, onRemoveBtn);
					item.y += this.itemsContainerMC.numChildren * 25;
					item.nameField.text = tile.paramsArr[i].name;
					item.valueField.text = tile.paramsArr[i].value;
					this.itemsContainerMC.addChild(item);
					tempParamsArr.push(item);
				}
			
			}
		}
		/**
		 * удаление параметр
		 * @param	e
		 */
		private function onRemoveBtn(e:MouseEvent):void 
		{
			// Удаляю из массива и из this.itemsContainerMC:
			for (var i:int = 0; i < tempParamsArr.length; i++) 
			{
				if (tempParamsArr[i] == e.target.parent) {
					this.itemsContainerMC.removeChild(tempParamsArr[i]);
					tempParamsArr.splice(i, 1);
					break;
				}
			}
			// Сортирую визуально:
			for (i = 0; i < tempParamsArr.length; i++) 
			{
				tempParamsArr[i].y = i * 25;
			}
		}
		/**
		 * Добавляет параметр
		 * @param	e
		 */
		private function onAddBtn(e:MouseEvent):void 
		{
			if (this.nameField.text!='' && this.valueField.text!='') 
			{
				var item:itemParamsMC = new itemParamsMC();
				item.removeBtn.addEventListener(MouseEvent.CLICK, onRemoveBtn);
				item.y += this.itemsContainerMC.numChildren * 25;
				item.nameField.text = this.nameField.text;
				item.valueField.text = this.valueField.text;
				this.itemsContainerMC.addChild(item);
				tempParamsArr.push(item);
			}
		}
		
		
	}
	
}
