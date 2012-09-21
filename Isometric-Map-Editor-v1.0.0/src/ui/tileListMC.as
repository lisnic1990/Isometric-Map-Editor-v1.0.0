package  ui {
	import as3isolib.graphics.BitmapFill;
	import flash.display.DisplayObject;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	import isospace.IsoContainer;
	import isospace.World;
	import managers.Tiles;
	import isospace.Tile;
	import managers.ToggleEvent;
	import org.casalib.util.ArrayUtil;
	import utility.Alert;
	import utility.GC;
	import utility.Hint;
	import flash.events.Event;	
	import flash.events.MouseEvent;
	import fl.data.DataProvider; 
	import fl.controls.TileList;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import fl.controls.ScrollBarDirection;
	import fl.events.ListEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.FileReferenceList;
	
	/**
	 * @author lisnic.tk
	 * @version 1.0.0.0
	 */
	
	public class tileListMC extends MovieClip {
		
		private var dp:DataProvider = new DataProvider();
		private var fileRefList:CustomFileReferenceList;
		
		private var _currentTile:Tile;
		
		private static var _cacheTiles:Tiles = new Tiles();
		
		public var paramDict:Dictionary = new Dictionary(true);
		
		public static var LIST_COMPLETE:String = "listComplete";
		
		private var fr:FileReference;
		
		public function tileListMC() {
			// constructor code
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry pointW
			
			Alert.register(stage);
			Hint.register(stage);
			
			/*init tilelist*/
			tilelist.direction = ScrollBarDirection.VERTICAL;
			tilelist.columnWidth = 47, 5;
			
			//Ивент на клик по иконке изображения
			//tilelist.addEventListener(MouseEvent.MOUSE_OVER, itemMouseOverMethod, false, 0, true);
			tilelist.addEventListener(ListEvent.ITEM_ROLL_OVER, onItemRollOver );
			
			//Ивент на клик по иконке изображения
			tilelist.addEventListener(MouseEvent.CLICK, itemClickMethod, false, 0, true);

			//Ивент на добавление тайлов
			addtileBtn.addEventListener(MouseEvent.CLICK, onClickAddTile);	
			//Ивент на удаление тайла
			delTileBtn.addEventListener(MouseEvent.CLICK, onClickDelTile);
			//Ивент на реадктирование тайла
			editTileBtn.addEventListener(MouseEvent.CLICK, onClickEditTile);
			//Ивент на сохранение xml кэш тайлов
			saveTilesLibBtn.addEventListener(MouseEvent.CLICK, onClickSaveTilesLib);
			//Ивент на загрузку xml кэш тайлов
			loadTilesLibBtn.addEventListener(MouseEvent.CLICK, onClickLoadTilesLib);
			//Ивент на загрузку bg
			loadBGBtn.addEventListener(MouseEvent.CLICK, onClickloadBG);
			//Ивент на удаление bg
			delBGBtn.addEventListener(MouseEvent.CLICK, onClickdelBG);
			
			//Ивент на сохранение Карты
			saveMapBtn.addEventListener(MouseEvent.CLICK, onClickSaveMap);
			//Ивент на загрузку Карты
			loadMapBtn.addEventListener(MouseEvent.CLICK, onClickLoadMap);
			
			//Ивент на создание новой карты
			newMapBtn.addEventListener(MouseEvent.CLICK, onClickNewMap);
		}
		
		private function onClickNewMap(e:MouseEvent):void 
		{
			popupNewMap.visible = true;
		}
		
		private function onClickLoadMap(e:MouseEvent):void 
		{
			fr = new FileReference();
			var xmlType:Array = [new FileFilter("Xml Files (*.xml)", "*.xml;")];
			fr.addEventListener(Event.SELECT, onSelectedForXmlMap);
			fr.browse(xmlType);			
		}
		private function onSelectedForXmlMap(e:Event):void 
		{
            fr.addEventListener(Event.COMPLETE, onCompleteMap); 
            fr.load(); 
		}
		private function onCompleteMap(e:Event):void 
		{
			var xmlData:XML = new XML(e.target.data);
			MovieClip(root).Panel.settingsMapMC.sizeMapMC.col.text = xmlData.@col;
			MovieClip(root).Panel.settingsMapMC.sizeMapMC.row.text = xmlData.@row;
			MovieClip(root).Panel.settingsMapMC.sizeTileMC.cellSize.text = xmlData.@cellSize;
			MovieClip(root).onClickHandlerApply(null);
			
			var xmlList:XMLList = xmlData.children();
			/*LoadTilesLib:*/
			if (GC.bg) 
			{
				GC.bg.x = xmlList[0].@bgOffsetX;
				GC.bg.y = xmlList[0].@bgOffsetY;
				World.getInstance().currentX = xmlList[0].@panXTo;
				World.getInstance().currentY = xmlList[0].@panYTo;
			}

			//массив измененых id-шников:
			var arrayModifiedID:Object = {};
			var xmlList0:XMLList = xmlList[0].children();
			for (var c:int = 0; c < xmlList0.length(); c++) 
			{
				var resultID:int = _cacheTiles.setSettingsForTileBitmap(xmlList0[c].@name, { c:xmlList0[c].@areaC, r:xmlList0[c].@areaR }, { x:xmlList0[c].@offsetX, y:xmlList0[c].@offsetY }, xmlList0[c].@heigth, xmlList0[c].@id, xmlList0[c].@type );
				//Если ID был изменен, то новый вернеться в resultID, который заношу в Object измененных id-ников:
				if (resultID != -1) 
				{
					//Object [ старый id ] = новый id
					arrayModifiedID[xmlList0[c].@id] = resultID;
					trace("arrayModifiedID["+ xmlList0[c].@id +"] = "+ resultID);
				}
				
			}
			
			trace("arrayModifiedID:");
			trace(arrayModifiedID + " \n END.");
			
			//Удаление всех тайлов со сцены:
			World.getInstance().removeAllTilesFromMap();
			//Удаление всех слоев.
			MovieClip(root).Panel.listLayersMC.removeAllLayers();
			
			/*---LoadLayer---*/
			var xmlList1:XMLList = xmlList[1].children();
			
			for (var k:int = 0; k < xmlList1.length(); k++) 
			{
				//Добавляю слой:
				MovieClip(root).Panel.listLayersMC.addLayer(xmlList1[k].@name, xmlList1[k].@data);
				
				// loadTilesInMap:
				var a_data:Array = xmlList1[k].@data.split(",");	
				var a_not_included:Array = []; //массив тех id что не нашел в _cacheTiles.
				//trace('loadTilesInMap: '+ a_data.length + '\n Arr:' +a_data);
				for (var i:int = 0; i < Main.col; i++) 
				{
					for (var j:int = 0; j < Main.row; j++) 
					{
						if (a_data[(i * Main.row + j)] != 0) 
						{
							//Получаю (старый) id из слоя:
							var idLoc:int = a_data[(i * Main.row + j)];
							
							//проверяю есть ли такой id в Object измененных:
							if (arrayModifiedID[idLoc]) 
							{
								//т.к. есть, то меняю его на новый и апгрейдю слой:
								//trace('старый: ' + idLoc, '    Новый:' + arrayModifiedID[idLoc]);
								idLoc = arrayModifiedID[idLoc];
								//trace("        idLoc = " + idLoc);
								MovieClip(root).Panel.listLayersMC.setIdToCurrentLevel(i, j, idLoc);
							}
							//Получаю тайл из тайл листа:
							var tile:Tile = _cacheTiles.getTileById( idLoc );
							if (tile) 
							{
								World.getInstance().putTileOnMapByParams(tile, xmlList1[k].@name, i, j);
							} else { 
								if (a_not_included.indexOf(a_data[(i * Main.row + j)]) == -1) 
								{
									a_not_included.push(a_data[(i * Main.row + j)]);
								}
							}
						}
					}
				}


			}
			if (a_not_included.length) 
			{
				Alert.show( a_not_included  + "  - Тайлы с данными индексами не были созданы!\nЗагрузи тайлы в тайл лист и перезагрузи карту\nИли забей!+)");
			}
			//Обнуляю те Id что не содежаться в Тайл листе (т.е. на карте эти ячейки становяться свободными):
			MovieClip(root).Panel.listLayersMC.setToZeroID(a_not_included);
			//trace( MovieClip(root).Panel.listLayersMC.getCurrentLayerData().dump()  );
			
			/*---LoadParams---*/
			var paramsList:XMLList = xmlList[2].children();	
			for (var g:int = 0; g < paramsList.length(); g++) 
			{
				var properties:Array = [];
				var propertiesList:XMLList =  paramsList[g].children();	
				for (i = 0; i < propertiesList.length(); i++) 
				{
					properties[i] = { name:propertiesList[i].@name, value:propertiesList[i].@value };
				}

				var tileWithParams:* = ArrayUtil.getItemByKeys(GC.addedTilesArray, { inLayer:paramsList[g].@layerName, _column: paramsList[g].@posX, _row: paramsList[g].@posY } );
				if (tileWithParams) 
				{
					tileWithParams.paramsArr = properties;
					//trace( 'tile:' + tileWithParams );
				}

			}
			
			
			/*Ставим фокус на stage, для того чтобы могли двигать сетку*/
			stage.focus = null;			
		}

		
		private function onClickSaveMap(e:MouseEvent):void 
		{
			fr = new FileReference();
			var xmlToSave:XML = <map></map>;
			xmlToSave.@col = Main.col;
			xmlToSave.@row = Main.row;
			xmlToSave.@cellSize = Main.cellSize;
			var xmlCacheTiles:XML = getXmlWithCacheTiles();
			if (GC.bg) 
			{
				xmlCacheTiles.@bgName = GC.bg.name;
				xmlCacheTiles.@bgOffsetX = GC.bg.x
				xmlCacheTiles.@bgOffsetY = GC.bg.y;
				xmlCacheTiles.@panXTo = World.getInstance().currentX;
				xmlCacheTiles.@panYTo = World.getInstance().currentY;
			}
			var xmlLayers:XML = MovieClip(root).Panel.listLayersMC.getXmlWithLayers();
			
			//Получаю xml с параметрами:
			var xmlParams:XML = MovieClip(root).Panel.listLayersMC.getXmlWithParams();
			
			xmlToSave.appendChild(xmlCacheTiles);
			xmlToSave.appendChild(xmlLayers);
			xmlToSave.appendChild(xmlParams);

			fr.save(xmlToSave.toString(), "map.xml");
		}
		
		private function onClickdelBG(e:MouseEvent):void 
		{
			if (GC.bg && World.getInstance().contains(GC.bg)) 
			{
				World.getInstance().backgroundContainer.removeChild(GC.bg);
			}
		}
		
		private function onClickloadBG(e:MouseEvent):void 
		{
			fr = new FileReference();
			var bgType:Array = [new FileFilter("Images (*.jpg, *.jpeg, *.gif, *.png)", "*.jpg;*.jpeg;*.gif;*.png")];
			fr.addEventListener(Event.SELECT, onSelectedBG);
			fr.browse(bgType);	
		}
		private function onSelectedBG(e:Event):void 
		{
			fr.removeEventListener(Event.SELECT, onSelectedBG);
			fr.addEventListener(Event.COMPLETE, onCompleteLoadBG); 
            fr.load(); 
		}
		private function onCompleteLoadBG(e:Event):void 
		{
			fr.removeEventListener(Event.COMPLETE, onCompleteLoadBG); 

			var loader:Loader = new Loader();
			//loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loader_complete);
			loader.loadBytes(e.target.data);
			World.getInstance().setBackground(loader, fr.name);
		}
		
		private function onClickDelTile(e:MouseEvent):void 
		{			
			if (tilelist.selectedItem != null && tilelist.dataProvider.length) 
			{
				// World.getInstance().MODE = GC.ARROW_MODE;
				
				//Удаление всех тайлов из карты с id текущего выбраного тайла.
				World.getInstance().removeTilesFromMapById( _cacheTiles.getTile(tilelist.selectedItem.label).idTile );
				
				//trace( 'caID ' + _cacheTiles.getTile(tilelist.selectedItem.label).idTile);
				
				//Обнуление id-шников в матрице слоя:
				MovieClip(root).Panel.listLayersMC.setToZeroBy(  _cacheTiles.getTile(tilelist.selectedItem.label).idTile );
				//Удаление тайла и кэша
				_cacheTiles.removeTile(tilelist.selectedItem.label);
				//Удаление тайла из тайллиста
				tilelist.dataProvider.removeItemAt( tilelist.dataProvider.getItemIndex(tilelist.selectedItem) );
				//Удаление текущего выбраного тайла.
				World.getInstance().removeCurrentTileFromMap();				
			}
		}
		
		private function onClickSaveTilesLib(e:MouseEvent):void 
		{
			fr = new FileReference();
			var xmlToSave:XML = getXmlWithCacheTiles();
			fr.save(xmlToSave.toString(), "cacheTiles.xml");

		}
		
		/*Загрузка TilesLib*/
		private function onClickLoadTilesLib(e:MouseEvent):void 
		{
			fr = new FileReference();
			var xmlType:Array = [new FileFilter("Xml Files (*.xml)", "*.xml;")];
			fr.addEventListener(Event.SELECT, onSelectedForXml);
			fr.browse(xmlType);			
		}
		private function onSelectedForXml(e:Event):void 
		{
            fr.addEventListener(Event.COMPLETE, onComplete); 
            fr.load(); 
		}
		private function onComplete(e:Event):void 
		{
			var xmlData:XML = new XML(e.target.data);
			var xmlList:XMLList = xmlData.children()
			
			if (GC.bg) 
			{
				GC.bg.x = xmlData.@bgOffsetX;
				GC.bg.y = xmlData.@bgOffsetY;
			}
			
			for (var i:int = 0; i < xmlList.length(); i++) 
			{
				//trace( xmlList[i].@name );
				_cacheTiles.setSettingsForTileBitmap(xmlList[i].@name, { c:xmlList[i].@areaC, r:xmlList[i].@areaR }, { x:xmlList[i].@offsetX, y:xmlList[i].@offsetY } , xmlList[i].@heigth)
				
				World.getInstance().setOffsetInAddedTilesArray(xmlList[i].@name, { x:xmlList[i].@offsetX, y:xmlList[i].@offsetY } );
			}
		}	
		/*_конец загрузки TilesLib*/
		
		/*возвращает xml файл для послдующего сохранения _cacheTiles.objects*/
		private function getXmlWithCacheTiles():XML 
		{
			var locXmlToSave:XML = <cacheTiles></cacheTiles>;
			
			if (GC.bg) 
			{
				locXmlToSave.@bgOffsetX = GC.bg.x;
				locXmlToSave.@bgOffsetY = GC.bg.y;
			}
			
			for (var key:String in _cacheTiles.objects) {
				//trace(key); // key (a, b, c)
				//trace(_cacheTiles.objects[key]); // value (1, 2, 3)
				var tile:Tile = _cacheTiles.objects[key];
				var itemXmlTile:XML = <tile/>;
				itemXmlTile.@type = tile.type;
				itemXmlTile.@id = tile.idTile;
				itemXmlTile.@name = tile.name;
				//itemXmlTile.@path = 'путь к файлу';
				itemXmlTile.@areaC = tile.area.c;
				itemXmlTile.@areaR = tile.area.r;
				itemXmlTile.@heigth = tile.height;
				itemXmlTile.@offsetX = tile.offset.x;
				itemXmlTile.@offsetY = tile.offset.y;
				locXmlToSave.appendChild(itemXmlTile);
			}
			
			return locXmlToSave;
		}
		
		private function onClickEditTile(e:MouseEvent):void 
		{
			var popMC:popupEditorMC =  popupEditorMC.getInstance();
			
			if (!popMC.visible) 
			{
				if (tilelist.selectedItem) 
				{
					popMC.openPopupEditorMC(tilelist.selectedItem.label);
				}	
			}
		}
		
		/*Обработка добавления тайла*/
		private function onClickAddTile(e:MouseEvent):void{
            fileRefList = new CustomFileReferenceList();
            fileRefList.addEventListener(tileListMC.LIST_COMPLETE, listCompleteHandler);
            fileRefList.browse(fileRefList.getTypes());
        }
        private function listCompleteHandler(event:Event):void {		
			var locArr:Array = fileRefList.fileList;

			for (var i:int = 0; i < locArr.length; i++) 
			{
				if (locArr[i].data !=null && !_cacheTiles.getTile(locArr[i].name)) 
				{				
					var loader:Loader = new Loader();
					loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loader_complete);
					loader.loadBytes(locArr[i].data);
					dp.addItem( { label:locArr[i].name, source:loader } );	
					paramDict[loader] = i;
				}	
			}
			tilelist.dataProvider = dp;
			
        }
		private function loader_complete(e:Event):void 
		{
			//По завершении загрузки изображения:
			var target_loader:Loader = e.currentTarget.loader as Loader;
			target_loader.removeEventListener(Event.COMPLETE, loader_complete);//удаляю ивент
			
			//Загоняю в кэш тайл:
			_cacheTiles.addTile(fileRefList.fileList[ paramDict[target_loader] ].name, { c:1, r:1 }, cloneBitmap(target_loader), { x:0, y:0 } );
			
			paramDict[target_loader] = null; //освобождаем память
		}
		/*Обработка клика по иконке*/
		private function itemClickMethod(e:MouseEvent):void {
			if (e.currentTarget.selectedItem == null) { return; }
			//Рассылаю событие о клике и передаю имя тайла:
			dispatchEvent(new ToggleEvent(ToggleEvent.TILE, e.currentTarget.selectedItem.label)); 
			
			/*Ставим для того чтобы могли двигать сетку*/
			stage.focus = null;
		}

				
		private function onItemRollOver(e:ListEvent):void
		{
			var _currentTile:Tile = _cacheTiles.getTile(String(e.item.label));
			if (_currentTile) 
			{
				Hint.show(_currentTile.name  +'   ID: '+ _currentTile.idTile); 
			}
		}
		
		/*Клонирует Bitmap*/
		private function cloneBitmap(l:Loader):Bitmap {
			return new Bitmap(Bitmap(l.content).bitmapData);
		}

		/*Геттер Кэша с тайлами*/
		static public function get cacheTiles():Tiles 
		{
			return _cacheTiles;
		}
		
		
			
	}
	
}
