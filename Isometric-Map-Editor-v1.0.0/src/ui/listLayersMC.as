package  ui {
	import de.polygonal.ds.Array2;
	import flash.display.MovieClip;
	import flash.events.Event;
	import fl.events.SliderEvent;
	import flash.events.MouseEvent;
	import fl.data.DataProvider;
	import fl.controls.List;
	import isospace.Tile;
	import isospace.World;
	import org.casalib.util.ArrayUtil;
	import utility.GC;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.FileReferenceList;
	
	
	/**
	 * Класс работы со слоями
	 * 
	 * @author lisnic.tk
	 * @version 1.0.0.0
	 */
	public class listLayersMC extends MovieClip {

		private var fr_For_Xml:FileReference;
		
		public function listLayersMC() {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			addBtn.addEventListener(MouseEvent.CLICK, onClickAddLayer);	
			delBtn.addEventListener(MouseEvent.CLICK, onClickDelLayer);	
			saveBtn.addEventListener(MouseEvent.CLICK, onClickSaveLayer);	
			
			upBtn.addEventListener(MouseEvent.CLICK, onClickUpLayer);	
			downBtn.addEventListener(MouseEvent.CLICK, onClickDownLayer);
			
			visibleBtn.addEventListener(MouseEvent.CLICK, onClickVisibleBtn);
			
			nameLayer.text = 'Layer' + listLayers.dataProvider.length;
			onClickAddLayer(null);
			
			// Клик по item
			listLayers.addEventListener(Event.CHANGE, onChangeHandler);
		}
		/*Подсвечивает baseSprite's у тайлов*/
		private function onChangeHandler(e:Event):void 
		{
			try 
			{
				//Подсветка:
				World.getInstance().setBacklightTilesInAddedTilesArray(MovieClip(root).Panel.settingsMapMC.backlightBtn.selected);
				//Visible Тайлов:
				var item:Object = listLayers.dataProvider.getItemAt(listLayers.selectedIndex);
				visibleBtn.selected = item.visible;
				World.getInstance().setVisibleTilesInAddedTilesArray(listLayers.selectedItem.label, item.visible);
				
				trace(listLayers.selectedItem.label, item.visible ,   'index== '+listLayers.selectedIndex);
			} catch (e:Error) { trace(e + '   onChangeHandler: Ошибка, в данном случее из за того что при создании делаю один слой, до того как созданы другие элементы сцены, к которым пока что нет доступа'); }
			
			/*Ставим для того чтобы могли двигать сетку*/
			stage.focus = null;	
		}
		
		/**
		 * Скрывает/показыват все тайлы, соответствено checkbox состоянию
		 * @param	e
		 */
		private function onClickVisibleBtn(e:MouseEvent):void 
		{
			trace('onClickVisibleBtn' + e.target.selected );
			
			var item:Object = listLayers.dataProvider.getItemAt(listLayers.selectedIndex);
			item.visible = e.target.selected;
			listLayers.dataProvider.replaceItemAt(item, listLayers.selectedIndex)
			
			World.getInstance().setVisibleTilesInAddedTilesArray(listLayers.selectedItem.label, e.target.selected);
			
		}
		/**
		 * Перемещение слоя на уровень ниже
		 * @param	e
		 */
		private function onClickDownLayer(e:MouseEvent):void 
		{		
			var index:int = listLayers.dataProvider.getItemIndex(listLayers.selectedItem);
			//trace(index +'   '+ listLayers.dataProvider.length);

			if ((index+1) != listLayers.dataProvider.length ) 
			{
				var curItem:Object = listLayers.dataProvider.getItemAt( index );
				var curItemDown:Object = listLayers.dataProvider.getItemAt( (index+1) );
				listLayers.dataProvider.replaceItemAt(curItem, (index + 1));
				listLayers.dataProvider.replaceItemAt(curItemDown, index);
				listLayers.selectedItem = curItem;
				listLayers.scrollToIndex((index + 1));
			}			
		}
		/**
		 * Перемещение слоя на уровень выше
		 * @param	e
		 */
		private function onClickUpLayer(e:MouseEvent):void 
		{
			var index:int = listLayers.dataProvider.getItemIndex(listLayers.selectedItem);
			//trace(index +'   '+ listLayers.dataProvider.length);

			if ((index-1) != -1 ) 
			{
				var curItem:Object = listLayers.dataProvider.getItemAt( index );
				var curItemDown:Object = listLayers.dataProvider.getItemAt( (index-1) );
				listLayers.dataProvider.replaceItemAt(curItem, (index - 1));
				listLayers.dataProvider.replaceItemAt(curItemDown, index);
				listLayers.selectedItem = curItem;
				listLayers.scrollToIndex((index - 1));
			}
		}
		
		/**
		 * Сохранение слоев
		 * @param	e
		 */
		private function onClickSaveLayer(e:MouseEvent):void 
		{
			fr_For_Xml = new FileReference();
			var xmlToSave:XML = getXmlWithLayers();
			fr_For_Xml.save(xmlToSave.toString(), "layers.xml");
		}
		
		/**
		 * Возвращает xml файл для послeдующего СОХРАНЕНИЯ слоев
		 * @return
		 */
		public function getXmlWithLayers():XML 
		{
			var locXmlToSave:XML = <layers></layers>;
			
			var item0:Object = listLayers.dataProvider.getItemAt(0);

			for (var i:int = 0; i < listLayers.dataProvider.length; i++) 
			{
				var item:Object = listLayers.dataProvider.getItemAt(i);

				var itemXmlLayer:XML = <layer></layer>; 	
				itemXmlLayer.@name = item.label;
				
				if (item.data.size==1) 
				{
					item.data.resize(Main.col, Main.row);
				}
				
				trace('getXmlWithLayers: \n' + item.data.dump() );
				
				for (var k:int = 0; k < Main.col; k++) 
				{
					for (var l:int = 0; l < Main.row; l++) 
					{
						if (k==0 && l==0) 
						{
							itemXmlLayer.@data += item.data.get(k, l).toString(); 
						} else {
							itemXmlLayer.@data += ',' + item.data.get(k, l).toString(); 
						}
					}
				}
				
				locXmlToSave.appendChild(itemXmlLayer);
			}	
			
			locXmlToSave.@width = item0.data.width;
			locXmlToSave.@height = item0.data.height;
			
			return locXmlToSave;
		}
		
		/**
		 * Возвращает xml файл для послeдующего СОХРАНЕНИЯ параметров
		 * @return
		 */
		public function getXmlWithParams():XML
		{
			var locXmlToSave:XML = <params></params>;
			for (var i:int = 0; i < GC.addedTilesArray.length; i++) 
			{
				if (GC.addedTilesArray[i].paramsArr.length) 
				{
					var itemXmlProperties:XML = <properties></properties>; 	
					itemXmlProperties.@layerName = GC.addedTilesArray[i].inLayer;
					itemXmlProperties.@posX = GC.addedTilesArray[i]._column;
					itemXmlProperties.@posY = GC.addedTilesArray[i]._row;

					for (var j:int = 0; j < GC.addedTilesArray[i].paramsArr.length; j++) 
					{
						var itemXmlProperty:XML = <property></property>; 	
						itemXmlProperty.@name = GC.addedTilesArray[i].paramsArr[j].name;
						itemXmlProperty.@value = GC.addedTilesArray[i].paramsArr[j].value;
						
						itemXmlProperties.appendChild(itemXmlProperty);
					}
				
					locXmlToSave.appendChild(itemXmlProperties);
				}
			}
			
			return locXmlToSave;
		}
		
		/**
		 * Удаление слоя
		 * @param	e
		 */
		private function onClickDelLayer(e:MouseEvent):void 
		{
			if (listLayers.length>1) //один остается
			{				
				World.getInstance().removeTilesFromMapByLayer(listLayers.selectedItem.label);
				listLayers.removeItem(listLayers.selectedItem);
				listLayers.selectedIndex = 0;
			}		
		}
		/**
		 * Добавление слоя
		 * @param	e
		 */
		public function onClickAddLayer(e:MouseEvent):void 
		{
			var arr2:Array2 = new Array2(Main.col, Main.row);
			var label:String = getUnicNameForLayer(nameLayer.text);
			listLayers.dataProvider.addItem( { label:label , data:arr2, visible:true } ); 
			nameLayer.text = getUnicNameForLayer(label);
			// выделяю его:
			listLayers.selectedItem = listLayers.dataProvider.getItemAt(listLayers.dataProvider.length - 1);
			
			// Удаляем undefined значения:
			setUndefinedToZero(listLayers.selectedItem.data);
		}
		/**
		 * Возвращает уникальное имя слоя
		 * @param	checkThisName
		 * @return
		 */
		private function getUnicNameForLayer(checkThisName:String=''):String 
		{
			var arrNames:Array = [];
			// Получаю массив имен существующих слоев:
			for (var i:int = 0; i < listLayers.dataProvider.length; i++) 
			{
				arrNames.push((listLayers.dataProvider.getItemAt(i).label).toString())
			}
			var inArr:Boolean = false;
			
			//Если checkThisName уникален, то его же и возвращаем
			if(arrNames.indexOf(checkThisName)>-1)
			{
				inArr = true;
			}
			// Если его нет в масиве, его и возвращаю:
			if (inArr==false) 
			{
				return checkThisName;
			} 
			
			// Иначе возвращаю новое имя:
			var index:int = listLayers.dataProvider.length;
			var newName:String = 'Layer' + index;

			while (arrNames.indexOf(newName)!=-1 )
			{
				newName = 'Layer' + (++index);
			}
			return newName;
		}
		/**
		 * Добавление слоя при загрузке
		 * @param	name	Имя слоя
		 * @param	data	Данные
		 */
		public function addLayer(name:String, data:String):void 
		{
			var a_data:Array = data.split(",");	
			//Создаю arr2 и записываю в него a_data:
			var arr2:Array2 = new Array2(Main.col, Main.row);

			for (var i:int = 0; i < Main.col; i++) 
			{
				for (var j:int = 0; j < Main.row; j++) 
				{
					arr2.set( i, j, a_data[(i * Main.row + j)]);
				}
			}
			//	trace( arr2.dump() );
			listLayers.dataProvider.addItem( { label:name , data:arr2, visible:true } ); 
			nameLayer.text = 'Layer' + listLayers.dataProvider.length;
			//выделяю его:
			listLayers.selectedItem = listLayers.dataProvider.getItemAt(listLayers.dataProvider.length-1);
		}
		
		//Ставит в 0 все id в слоях которые совпадают с элементами из a_not_included:
		public function setToZeroID(a_not_included:Array):void {
			for (var i:int = 0; i < a_not_included.length; i++) 
			{					
				setToZeroBy(a_not_included[i]);
			}		
		}
		/**
		 * Изменяет заданый id в позициях:
		 * @param	posx
		 * @param	posy
		 * @param	id
		 */
		public function setIdToCurrentLevel(posx:int, posy:int, id:int):void 
		{
			var curItem:Object = listLayers.dataProvider.getItemAt( listLayers.dataProvider.getItemIndex(listLayers.selectedItem) );
			if (curItem.data.size==1)  //new Array2(1,1)- поэтому:==1 
			{
				var arr2:Array2 = new Array2(Main.col, Main.row);
				arr2.fill(0);
				arr2.set(posx, posy, id);
				curItem.data = arr2; 
				trace('Im create curItem.data!!!!!!!!!!!!!!');
			} 
			
			curItem.data.set(posx, posy, id);
			trace(posx, posy, id + "  <- was saved");
		}
		
		/**
		 * Проверка: занята ли ячейка
		 * @param	posx
		 * @param	posy
		 * @return
		 */
		public function isCellBusy(posx:int=0, posy:int=0):Boolean 
		{
			var curItem:Object = listLayers.dataProvider.getItemAt( listLayers.dataProvider.getItemIndex(listLayers.selectedItem) );
			
			if (curItem.data.size==1) 
			{
				return false; 
			} else {
				if (curItem.data.get(posx, posy)) 
				{
					//trace(curItem.data.get(posx, posy))
					return true;
				}
			}
			return false;
		}
		
		/**
		 * Обнуляет все id-шники всех слоев (т.е. записывает 0)
		 * @param	id
		 */
		public function setToZeroBy(id:int):void 
		{
			for (var i:int = 0; i < listLayers.dataProvider.length; i++) 
			{
				var item:Object = listLayers.dataProvider.getItemAt(i);
				for (var j:int = 0; j < item.data.width; j++) 
				{
					for (var k:int = 0; k < item.data.height; k++) 
					{
						if (item.data.get(j,k) == id) { item.data.set(j,k,0); }
					}
				}
			}	
		}
		
		public function getCurrentLayer():String {
			return listLayers.selectedItem.label;
		}
		
		public function getCurrentLayerData():Array2 {
			return listLayers.selectedItem.data;
		}
		
		public function removeAllLayers():void {
			 listLayers.dataProvider.removeAll();
		}
		
		
		/**
		 * Ресайз слоев
		 * @param	w		Ширина
		 * @param	h		Высота
		 */
		public function resizeLayers(w:int, h:int):void 
		{
			for (var i:int = 0; i < listLayers.dataProvider.length; i++) 
			{
				var item:Object = listLayers.dataProvider.getItemAt(i);
				
				if (item.data.size==1) 
				{
					listLayers.selectedItem.data.resize(w, h);
					listLayers.selectedItem.data.fill(0);
					return; 
				} else {
					//минимальный размер массива:
					var minx:int = w < item.data.width ? w : item.data.width;
					var miny:int = h < item.data.height ? h : item.data.height;

					//Массив для удаляемых элементов:
					var arrTilesForRemove:Array = [];
					
					trace( item.label  + 'mins:  '+ minx +' '+ miny);
					
					//пробегаю весь массив, и элементы которые выходят за предел массива, удаляются:
					for (var j:int = 0; j < item.data.width; j++) 
					{
						for (var k:int = 0; k < item.data.height; k++) 
						{
							if ((j >= minx)||(k >= miny))
							{ 	
								//Поиск тайла по координатам:
								var targetTile = ArrayUtil.getItemByKeys(GC.addedTilesArray, { _column: j, _row: k } );
								//Проверка, в данном ли слое тайл находиться.
								if (targetTile) {
									arrTilesForRemove.push( targetTile );
								}
							}
							//trace(j, k, targetTile);	
						}
					}
					
					// trace( 'arr 1= ' + arrTilesForRemove );
					
					/*удаление элементов из locArrForRemove*/
					for (var c:int = 0; c < arrTilesForRemove.length; c++) 
					{
						World.getInstance().removeTile(arrTilesForRemove[c]);
					}
					//Рендер сцены:
					World.getInstance().invalidatePosition();
					World.getInstance().render();

					// Ресайз массива:
					item.data.resize(w, h);
					
					// Удаляем undefined:
					setUndefinedToZero(item.data);
					
					/*
					trace( 'arr 2= ' + arrTilesForRemove );
					trace( item.data.dump() );
					*/
				}
				
			}	
		}
		
		
		/**
		 * Удаляем undefined значения из  массива
		 * @param	arr2		Двумерный массив
		 */
		public function setUndefinedToZero(arr2:Array2):void {
			for (var i:int = 0; i < Main.col; i++) 
			{
				for (var j:int = 0; j < Main.row; j++) 
				{
					if (arr2.get(i,j) == undefined) {
						arr2.set( i, j, 0);
					}
				}
			}
		}
		
		
		/**
		 * Заливаю маств заданным id, из позиции ti, tj
		 * (Инструмент Fill)
		 * @param	ti
		 * @param	tj
		 * @param	id
		 */
		public function fillCurrentLayer(ti, tj, id):void {
			var curItem:Object = listLayers.dataProvider.getItemAt( listLayers.dataProvider.getItemIndex(listLayers.selectedItem) );
			
			if (curItem.data.size==1) 
			{
				curItem.data = new Array2(Main.col, Main.row);
				curItem.data.fill(0);
			} 
			
			curItem.data.set(ti, tj, id);
			fillByThis(curItem.data , ti, tj, id);

			//trace('FILL '+curItem.data.dump());
		}
		/**
		 * Утилитка для заливки
		 * @param	arr2	Двумерный массив
		 * @param	ti		Позиция из которой заливается по i
		 * @param	tj		Позиция из которой заливается по j
		 * @param	id		Id которым заливается
		 */
		private function fillByThis(arr2:Array2 ,ti:Number, tj:Number, id:int):void 
		{
			if(tj!=0){
				var leftID:int = arr2.get(ti, (tj - 1));
				if (leftID == 0) { 
					arr2.set(ti, (tj - 1), id);
					fillByThis(arr2, ti, (tj - 1), id);
				}
			}

			if(tj!=(arr2.height-1)){						
				var rightID:int = arr2.get(ti, (tj + 1));
				if (rightID == 0) { 
					arr2.set(ti, (tj + 1), id)
					fillByThis(arr2, ti, (tj + 1), id);
				}
			}
			
			if(ti!=0){
				var upID:int = arr2.get((ti-1), tj);
				if (upID == 0) { 
					arr2.set((ti - 1), tj, id);
					fillByThis(arr2, (ti - 1), tj, id);
				}
			}
			
			if(ti!=(arr2.width-1)){
				var downID:int = arr2.get((ti+1), tj);
				if (downID == 0) { 
					arr2.set((ti + 1), tj, id);
					fillByThis(arr2, (ti + 1), tj, id);
				}
			}
		}
		
	}
	
}
