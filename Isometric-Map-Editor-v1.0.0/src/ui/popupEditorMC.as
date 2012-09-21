package ui {
	
	import flash.display.Bitmap;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import isospace.Tile;
	import isospace.World;
	
	/**
	 * Класс попап окна для редактирования тайла
	 * @author lisnic.tk
	 * @version 1.0.0.0
	 */
	public class popupEditorMC extends MovieClip {
		
		// Текущий редактируемый тайл
		private var _currentEditableTile:Tile;
		
		public function popupEditorMC() {
			_instance = this;
			
			okBtn.addEventListener(MouseEvent.CLICK, onOkBtn);
			okCancel.addEventListener(MouseEvent.CLICK, onCancel);
			
			//Обработка изменения типа:
			addListenersForTypeChange();
		}
		/**
		 * Отмена редактирования
		 * @param	e
		 */
		private function onCancel(e:MouseEvent):void 
		{
			visible = false;
		}
		
		/**
		 * Обработчик кнопки Ок
		 * Сохранение данных
		 * @param	e
		 */
		private function onOkBtn(e:MouseEvent):void 
		{	
			World.getInstance().setOffsetInAddedTilesArray( nameTile.text, { x:offsetX.value, y:offsetY.value } );

			tileListMC.cacheTiles.setSettingsForTileBitmap(nameTile.text, { c:int(colums.text), r:int(rows.text) }, { x:offsetX.value, y:offsetY.value }, Heigth.value, -1, getStringType() )

			visible = false;
		}
		
		/**
		 * Возвращает тип тайла для записи:
		 * @return
		 */
		private function getStringType():String
		{
			var locType:String;
				//Записываю тип:
				switch (true) 
				{
					case this.fixedType.selected:
						locType = "fixed";
					break;
					case this.animatedType.selected:
						locType = "animated";
					break;
					case this.graphicType.selected:
						locType = "graphic";
					break;
					case this.otherType.selected:
						if (this.typeField.text != '') { 
							locType = this.typeField.text; 
						} else {
							locType = "fixed"; 
						}
					break;
				}
				//Востанавливаю по умолчанию:
				this.fixedType.selected = false;
				this.animatedType.selected = false;
				this.graphicType.selected = false;
				this.otherType.selected = false;
				this.typeField.text = "typeName";
				
				return locType;
		}
		/**
		 * Открытия окна, вывод данных данного выбраного тайла
		 * @param	label		Имя выбраного тайла
		 */
		public function openPopupEditorMC(label:String):void 
		{	
			_currentEditableTile = tileListMC.cacheTiles.getTile(label);

			visible = true;
			nameTile.text = _currentEditableTile.name;
			
			//Вставляю Bitmap в previewMC:
			var _currentBitmap:Bitmap = new Bitmap(Bitmap(_currentEditableTile.bitmap).bitmapData);
			if (previewMC.numChildren==1) 
			{			
				resizeThisBy(_currentBitmap, previewMC);
				previewMC.addChild(_currentBitmap);
			} else {
				previewMC.removeChildAt(1);
				resizeThisBy(_currentBitmap, previewMC);
				previewMC.addChild(_currentBitmap);
			}
			
			tileID.text = "Tile ID:  " + _currentEditableTile.idTile;

			offsetX.value = _currentEditableTile.offset.x;
			offsetY.value = _currentEditableTile.offset.y;
			
			colums.text = String(_currentEditableTile.area.c)+'';
			rows.text = String(_currentEditableTile.area.r) + '';
			
			Heigth.value = _currentEditableTile.height;

			//устанавливаю тип:
			if (_currentEditableTile.type == "fixed") 
			{
				this.fixedType.selected = true;
				this.animatedType.selected = false;
				this.graphicType.selected = false;
				this.otherType.selected = false;
				this.typeField.enabled = false;
				this.typeField.text = "typeName";
			} else
				if (_currentEditableTile.type == "animated") 
				{
					this.fixedType.selected = false;
					this.animatedType.selected = true;
					this.graphicType.selected = false;
					this.otherType.selected = false;
					this.typeField.enabled = false;
					this.typeField.text = "typeName";
				} else
					if (_currentEditableTile.type == "graphic") 
					{
						this.fixedType.selected = false;
						this.animatedType.selected = false;
						this.graphicType.selected = true;
						this.otherType.selected = false;
						this.typeField.enabled = false;
						this.typeField.text = "typeName";
					} else
						{
							this.fixedType.selected = false;
							this.animatedType.selected = false;
							this.graphicType.selected = false;
							this.otherType.selected = true;
							
							this.typeField.enabled = true;
							this.typeField.text = _currentEditableTile.type;
						}
			
			
			
		}
		
		/**
		 * Изменяет размер изображения по  контейнеру
		 * @param	currentBitmap			Маштабируемое изображение
		 * @param	byObject				Контейнер
		 */
		private function resizeThisBy(currentBitmap:Bitmap, byObject:DisplayObjectContainer):void 
		{
			if (currentBitmap.width > byObject.width) 
			{
				currentBitmap.height = (byObject.width * currentBitmap.height) / currentBitmap.width;
				currentBitmap.width = byObject.width;
			}
			
			if (currentBitmap.height > byObject.height) 
			{
				currentBitmap.width = (currentBitmap.width * byObject.height) / currentBitmap.height;
				currentBitmap.height = byObject.height;
			}
		}
		
		//SINGLETON
		private static var _instance:popupEditorMC;
		
		public static function getInstance():popupEditorMC
		{
			if (_instance == null)
			{
				_instance = new popupEditorMC();
			}
			return _instance;
		}
		
		public function get currentEditableTile():Tile 
		{
			return _currentEditableTile;
		}
		
		public function set currentEditableTile(value:Tile):void 
		{
			_currentEditableTile = value;
		}
		
		
		
		
		
		/**
		 * Обработка изменения типа
		 */
		private function addListenersForTypeChange():void 
		{
			fixedType.addEventListener(MouseEvent.CLICK, onFixedTypeBtn);
			animatedType.addEventListener(MouseEvent.CLICK, onAnimatedypeBtn);
			graphicType.addEventListener(MouseEvent.CLICK, onGraphicTypeBtn);
			otherType.addEventListener(MouseEvent.CLICK, onOtherTypeBtn);
		}

		private function onFixedTypeBtn(e:MouseEvent):void 
		{		
			if (e.target.selected) 
			{
				animatedType.selected = graphicType.selected = otherType.selected = false;
				typeField.enabled = false;
			} else {
				otherType.selected = true;
				typeField.enabled = true;
			}
		}

		private function onGraphicTypeBtn(e:MouseEvent):void 
		{
			if (e.target.selected) 
			{
				fixedType.selected = animatedType.selected = otherType.selected = false;
				typeField.enabled = false;
			} else {
				otherType.selected = true;
				typeField.enabled = true;
			}
		}
		
		private function onAnimatedypeBtn(e:MouseEvent):void 
		{
			if (e.target.selected) 
			{
				fixedType.selected = graphicType.selected = otherType.selected = false;
				typeField.enabled = false;
			} else {
				otherType.selected = true;
				typeField.enabled = true;
			}
		}
		
		private function onOtherTypeBtn(e:MouseEvent):void 
		{
			if (e.target.selected) 
			{
				fixedType.selected  = animatedType.selected = graphicType.selected = false;
				typeField.enabled = true;
			} else {
				otherType.selected = true;
				typeField.enabled = true;
			}
		}
		//Обработка изменения типа END.
		
		
		

	}
	
}
