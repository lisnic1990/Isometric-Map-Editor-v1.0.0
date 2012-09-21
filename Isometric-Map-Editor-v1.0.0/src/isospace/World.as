package isospace
{
	import as3isolib.display.IsoView;
	import as3isolib.display.primitive.IsoBox;
	import as3isolib.display.scene.IsoGrid;
	import as3isolib.display.scene.IsoScene;
	import as3isolib.geom.IsoMath;
	import as3isolib.geom.Pt;
	import de.polygonal.ds.Array2;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import managers.ToggleEvent;
	import org.casalib.util.ArrayUtil;
	import ui.keys;
	import ui.listLayersMC;
	import ui.tileListMC;
	import utility.GC;
	

	/**
	 * Изометрический мир
	 * @author lisnic.tk
	 * @version 1.0.0.0
	 */
	
	public class World extends IsoView
	{
		// Сцена
		private var _groundScene:IsoScene;
		// Сцена для сетки
		private var _gridScene:IsoScene;
		// Сетка
		private var _grid:IsoGrid;
		
		// состояние редактора
		private var _debugMode:Boolean = false;
		
		// Управление картой (panBy)
		private var _keyEventClass:keys;
		// Смещение карты за раз
		private var valueOffset:int = 10; 
		private var panPt:Point;
		
		// Тайл курсор
		private var _boxPol:IsoBox;
		
		// Текущий тайл
		public var _currentTile:Tile;
		
		// Режим инструмета мыши
		private var _MODE:String = GC.ARROW_MODE;

		
		public function World(w:Number = 800, h:Number = 600, gridCols:Number = 20, gridRows:Number = 20, gridCellsize:Number = 20)
		{
			_instance = this;
			this.autoUpdate = true;
			setSize(w, h);
			createGrid(gridCols, gridRows, gridCellsize);
			createGroundScene();
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			/*Управление картой*/
			_keyEventClass = new keys(this);
			addEventListener(Event.ENTER_FRAME, handleEnterFrame);
			
			/*Тайл курсор*/
			_boxPol = new IsoBox();
            _boxPol.setSize( _grid.cellSize, _grid.cellSize, 1 );
			
			_gridScene.addChild( _boxPol );
			
			this.addEventListener( MouseEvent.MOUSE_MOVE, onMoveObject, false, 0, true );
			this.addEventListener( MouseEvent.CLICK, onClickObject, false, 0, true );
			this.addEventListener( MouseEvent.MOUSE_WHEEL, viewZoom, false, 0, true );
			
			stage.addEventListener( ToggleEvent.TILE, onTileObject );
			stage.addEventListener( ToggleEvent.ERASE, onTileEraseBtn);
			stage.addEventListener( ToggleEvent.FILL, onTileFillBtn);
			stage.addEventListener( ToggleEvent.ARROW, onArrowBtn);
		}
		
		/**
		 * Panning Map
		 * @param	e
		 */
		private function onArrowBtn(e:ToggleEvent):void 
		{
			this.addEventListener(MouseEvent.MOUSE_DOWN, viewMouseDown, false, 0, true);
		}
		private function viewMouseDown(e:Event)
		{
			panPt = new Point(stage.mouseX, stage.mouseY);	
			
			this.addEventListener(MouseEvent.MOUSE_MOVE, viewPan, false, 0, true);
			this.addEventListener(MouseEvent.MOUSE_UP, viewMouseUp, false, 0, true);
		}
		private function viewPan(e:Event)
		{
			this.panBy(panPt.x - stage.mouseX, panPt.y - stage.mouseY);
			panPt.x = stage.mouseX;
			panPt.y = stage.mouseY;
		}
		private function viewMouseUp(e:Event)
		{
			this.removeEventListener(MouseEvent.MOUSE_MOVE, viewPan);
			this.removeEventListener(MouseEvent.MOUSE_UP, viewMouseUp); 
		}
		public function removeEventListener_ViewMouseDown():void 
		{
			//удаляю слушатель
			this.removeEventListener(MouseEvent.MOUSE_DOWN, viewMouseDown);
		}/*Panning Map  end*/
		
		
		/**
		 * Обработка клика по кнопке Fill
		 * Заполнение ограниченой области текущим образцом тайлов
		 * @param	e
		 */
		private function onTileFillBtn(e:ToggleEvent):void 
		{
			if (_currentTile==null && MovieClip(root).Panel.tileListPanel.tilelist.selectedItem!=null) 
			{
				_currentTile = tileListMC.cacheTiles.getTile( MovieClip(root).Panel.tileListPanel.tilelist.selectedItem.label );
				if (_currentTile) 
				{
					_currentTile.setSize( _grid.cellSize, _grid.cellSize, 100 );
					_groundScene.addChild( _currentTile );
					onMoveObject( null );  
				}
			}
		}

		/**
		 * Включаю инструмен "Стирание"
		 * @param	e
		 */
		private function onTileEraseBtn(e:ToggleEvent):void 
		{
			removeCurrentTileFromMap();
		}
		
		/**
		 * Удаление текущего тайла из карты
		 */
		public function removeCurrentTileFromMap():void 
		{
			if (_currentTile && _groundScene.contains(_currentTile))  //Если он не нулл и содержиться на сцене,то
			{
				_groundScene.removeChild(_currentTile);
				_currentTile = null;
			}
		}
		
		/**
		 * Удаление тайлов по ID
		 * @param	idtile
		 */
		public function removeTilesFromMapById(idtile:int=0):void 
		{		
			var idTileLoc:int = idtile;
			if (_currentTile) 
			{
				idTileLoc = (idtile == 0)?_currentTile.idTile:idtile;  
			}
			
			var locArrForRemove:Array = [];
			
			/*Поиск нужных элементов для удаления и запись их в locArrForRemove*/
			for (var i:int = 0; i < GC.addedTilesArray.length; i++) 
			{
				if (idTileLoc == GC.addedTilesArray[i].idTile) 
				{
					locArrForRemove.push(GC.addedTilesArray[i]);
				}
			}
			/*удаление элементов из locArrForRemove*/
			for (var j:int = 0; j < locArrForRemove.length; j++) 
			{
				this.removeTile(locArrForRemove[j]);
			}
		}

		/**
		 * Удаление тайлов содержащихся в слое labelLayer
		 * @param	labelLayer			Имя слоя
		 */
		public function removeTilesFromMapByLayer(labelLayer:String):void 
		{			
			var locArrForRemove:Array = [];
			
			// Поиск нужных элементов для удаления и запись их в locArrForRemove
			for (var i:int = 0; i < GC.addedTilesArray.length; i++) 
			{
				if (labelLayer == GC.addedTilesArray[i].inLayer) 
				{
					locArrForRemove.push(GC.addedTilesArray[i]);
				}
			}
			// Удаление элементов из locArrForRemove
			for (var j:int = 0; j < locArrForRemove.length; j++) 
			{
				this.removeTile(locArrForRemove[j]);
			}
		}
		
		/**
		 * Удаление всех тайлов из карты
		 */
		public function removeAllTilesFromMap():void 
		{			
			if(GC.addedTilesArray.length!=0){
				var k:int = GC.addedTilesArray.length;
				while( k -- )
				{
					this.removeTile(GC.addedTilesArray[k]);
				}
			}			
		}
		
		/**
		 * Обработка клика по карте
		 * @param	e
		 */
		private function onClickObject(e:MouseEvent):void 
		{
			trace('Click on the map');
			switch (_MODE) 
			{
				case GC.ARROW_MODE: onArrowBtn(null); break;
				case GC.TILE_MODE: PutTileOnMap(); break;
				case GC.ERASE_MODE: EraseTileFromMap(); break;
				case GC.FILL_MODE: FillTileMap(); break;
				case GC.PARAMS_MODE: setParamsTileOnMap(); break;
				default:trace('.....But never done');
			}
		}
		
		/**
		 * Добавляю свойства тайлу на карте
		 */
		private function setParamsTileOnMap():void 
		{
			// Получаю координаты:
			var colum:int = int( _boxPol.x / _grid.cellSize );
			var row:int = int( _boxPol.y / _grid.cellSize );
			
			var targetTilesArr:Array = ArrayUtil.getItemsByKeys(GC.addedTilesArray, { _column: colum, _row: row } );
			
			for (var i:int = 0; i < targetTilesArr.length; i++) 
			{
				var targetTile:Tile = targetTilesArr[i];

				if (targetTile && targetTile.inLayer==MovieClip(root).Panel.listLayersMC.getCurrentLayer()) 
				{
					//Открывается окно для редактирования своиств тайла:
					MovieClip(root).params_popupMC.openParamsEditor(targetTile);
					break;
				}
			}			
		}
		
		/**
		 * Заливаю слой тайлами
		 */
		private function FillTileMap():void 
		{
			//Получаю координаты:
			var colum:int = int( _boxPol.x / _grid.cellSize );
			var row:int = int( _boxPol.y / _grid.cellSize );	
			
			var currLayer:String = MovieClip(root).Panel.listLayersMC.getCurrentLayer();
			
			// trace('Уже выбранный: '+ MovieClip(root).Panel.tileListPanel.tilelist.selectedItem.label );

			if (_currentTile) 
			{
				var putTile:Tile = _currentTile.clone();
				
				putTileOnMapByParams(putTile, currLayer, colum, row);

				MovieClip(root).Panel.listLayersMC.fillCurrentLayer(colum, row, putTile.idTile);

				var arr2:Array2 = MovieClip(root).Panel.listLayersMC.getCurrentLayerData();

				for (var i:int = 0; i < Main.col; i++) 
				{
					for (var j:int = 0; j < Main.row; j++) 
					{
						var id:int = arr2.get( i, j );

						if (id==putTile.idTile)
						{
							trace(putTile, currLayer, i, j);
							putTileOnMapByParams(putTile, currLayer, i, j);
						}
					}
				}
			} 
			
		}

		/**
		 * "Стирание"
		 * Удаление тайла из карты
		 */
		private function EraseTileFromMap():void 
		{
			// Получаю координаты:
			var colum:int = int( _boxPol.x / _grid.cellSize );
			var row:int = int( _boxPol.y / _grid.cellSize );
			
			var targetTilesArr:Array = ArrayUtil.getItemsByKeys(GC.addedTilesArray, { _column: colum, _row: row } );
			
			for (var i:int = 0; i < targetTilesArr.length; i++) 
			{
				var targetTile:* = targetTilesArr[i];

				if (targetTile && targetTile.inLayer==MovieClip(root).Panel.listLayersMC.getCurrentLayer()) 
				{
					//запись в текущий слой:
					MovieClip(root).Panel.listLayersMC.setIdToCurrentLevel(colum, row, 0);
					this.removeTile(targetTile)
				}
			}
		}
		
		/**
		 * Ставим тайл на карту
		 */
		private function PutTileOnMap():void 
		{				
			if (_currentTile) 
			{
				//Получаю координаты:
				var colum:int = int( _boxPol.x / _grid.cellSize );
				var row:int = int( _boxPol.y / _grid.cellSize );
			
				trace("Creating a clone of tile");
				var putTile:Tile = _currentTile.clone();
				putTile.bitmap.alpha = 1;
				
				//Удаляю базовый тайл(подсветка):
				if (! MovieClip(root).Panel.settingsMapMC.backlightBtn.selected) 
				{
					putTile.removeBaseSprite();
				}
				
				// trace("_boxPol.x= " + _boxPol.x, '_boxPol.y= ', _boxPol.y);

				if (MovieClip(root).Panel.listLayersMC.isCellBusy(colum, row)) 
				{
					//Если ячейка занята то удаляю Tile:
					EraseTileFromMap();
				}
				
				this.addTile( putTile , colum, row);
				
				/*//запись в текущий слой:*/
				MovieClip(root).Panel.listLayersMC.setIdToCurrentLevel(putTile._column, putTile._row, putTile.idTile);
				
				this.invalidatePosition();
				this.render();
			} 

		}

		/**
		 * Ставит тайл на сцену по параметрам
		 * @param	tile
		 * @param	layer
		 * @param	colum
		 * @param	row
		 */
		public function putTileOnMapByParams(tile:Tile, layer:String, colum:int=0, row:int=0):void
		{		
			var putTile:Tile = tile.clone();

			this.addTile( putTile, colum, row);

			putTile.inLayer = layer;
			
			//Удаляю базовый тайл(подсветка):
			if (! MovieClip(root).Panel.settingsMapMC.backlightBtn.selected) 
			{
				putTile.removeBaseSprite();
			}
		}
		
		/**
		 * Вызывается когда происходит клик по оконке в tileList
		 * @param	e
		 */
		private function onTileObject(e:ToggleEvent):void 
		{
			MovieClip(root).Panel.mouseChangeMC.updateBtns(ToggleEvent.TILE);
			trace( 'Click on the tile in tileList. ' +"  onTileObject: " + e.data);
			removeCurrentTileFromMap();
			_currentTile = tileListMC.cacheTiles.getTile(String(e.data));
			
			if (_currentTile) 
			{
				_currentTile.bitmap.alpha = 0.5;
				// _currentTile.setSize( _grid.cellSize, _grid.cellSize);
				_groundScene.addChild( _currentTile );
				
				_currentTile.addBaseSprite();
				
				onMoveObject( null );  
			}
		}
		/**
		 * Движение мыши по сетке
		 * @param	e
		 */
		private function onMoveObject( e:MouseEvent ):void
        {
				var pt:Pt = this.localToIso( new Point( (stage.mouseX-this.parent.x), stage.mouseY ) );
				var colum:int = int( pt.x / _grid.cellSize );
				var row:int = int( pt.y / _grid.cellSize );

				colum = (colum < 0)?0: ((colum > (_grid.gridSize[0]-1))?(_grid.gridSize[0]-1):colum);
				row = (row < 0)?0:((row > (_grid.gridSize[1]-1))?(_grid.gridSize[1]-1):row);
				
				_boxPol.x = colum * _grid.cellSize; 
				_boxPol.y = row * _grid.cellSize;

				if (_currentTile && _groundScene.contains(_currentTile)) 
				{
					_currentTile.x = _boxPol.x; // colum * _grid.cellSize; 
					_currentTile.y = _boxPol.y; //row * _grid.cellSize;
				}
		}

		/*
		 * Выполняется каждый кадр
		 */
		private function handleEnterFrame(e:Event):void
		{		
			/*Перемещение мира если нажаты клавиши стрелки*/
			if (_keyEventClass.theyArePressed[Keyboard.LEFT]) 
			{
				valueOffset = (_keyEventClass.theyArePressed[Keyboard.SHIFT]) ?10:5;
				panBy( -valueOffset, 0);
			}
			if (_keyEventClass.theyArePressed[Keyboard.UP]) 
			{
				valueOffset = (_keyEventClass.theyArePressed[Keyboard.SHIFT]) ?10:5;
				panBy(0, -valueOffset);
			}
			if (_keyEventClass.theyArePressed[Keyboard.RIGHT]) 
			{
				valueOffset = (_keyEventClass.theyArePressed[Keyboard.SHIFT]) ?10:5;
				panBy( valueOffset, 0);
			}
			if (_keyEventClass.theyArePressed[Keyboard.DOWN]) 
			{
				valueOffset = (_keyEventClass.theyArePressed[Keyboard.SHIFT]) ?10:5;
				panBy(0, valueOffset);
			}
			/*Zoom*/
			if (_keyEventClass.theyArePressed[Keyboard.NUMPAD_SUBTRACT] && _keyEventClass.theyArePressed[Keyboard.CONTROL])  
			{
				zoom (currentZoom - 0.1);
			}
			if (_keyEventClass.theyArePressed[Keyboard.NUMPAD_ADD] && _keyEventClass.theyArePressed[Keyboard.CONTROL]) 
			{
				zoom (currentZoom + 0.1);
			}
			if (_keyEventClass.theyArePressed[Keyboard.END]) 
			{
				reset();
			}
			/*Shift GC.bg*/
			if (GC.bg && contains(GC.bg)) 
			{
				if (_keyEventClass.theyArePressed[Keyboard.NUMPAD_4] && _keyEventClass.theyArePressed[Keyboard.CONTROL])  
				{
					GC.bg.x -= 5;
				}
				if (_keyEventClass.theyArePressed[Keyboard.NUMPAD_6] && _keyEventClass.theyArePressed[Keyboard.CONTROL])  
				{
					GC.bg.x += 5;
				}
				if (_keyEventClass.theyArePressed[Keyboard.NUMPAD_8] && _keyEventClass.theyArePressed[Keyboard.CONTROL])  
				{
					GC.bg.y -= 5;
				}
				if (_keyEventClass.theyArePressed[Keyboard.NUMPAD_2] && _keyEventClass.theyArePressed[Keyboard.CONTROL])  
				{
					GC.bg.y += 5;
				}
			}
			// рендер сцены
			
			_groundScene.invalidateScene();
			_gridScene.render();
			_groundScene.render();
			render();
		}
		
		private function viewZoom(e:MouseEvent)
		{
			if(e.delta > 0)
			{
				zoom (currentZoom - 0.1);
			}
			if(e.delta < 0)
			{
				zoom (currentZoom + 0.1);
			}
		}

		/**
		 * Добавление Тайла
		 * @param	tile
		 * @param	col
		 * @param	row
		 */
		public function addTile(tile:Tile, col:Number=1, row:Number=1):void
		{		
			//ДОбавляем на сцену
			_groundScene.addChild(tile);
			//Присваиваю ему позицию на карте
			tile._column = col;
			tile._row = row;
			//двигаю по x и по y:
			tile.x = col * _grid.cellSize; 
			tile.y = row * _grid.cellSize;
			//Устанавливаю текущий слой			
			tile.inLayer = MovieClip(root).Panel.listLayersMC.getCurrentLayer();
			//Загоняю в масив добавленных элементов
			GC.addedTilesArray.push(tile);
			
			// trace(tile + '  был добавлен!!');
			// trace("GC.addedTilesArray: " + GC.addedTilesArray);	
			//Render:
			_groundScene.invalidateScene();
			_groundScene.render();
			tile.invalidatePosition();
			tile.render();
			
		}
		
		/**
		 * Удаляет Тайл
		 * @param	tile
		 */
		public function removeTile(tile:Tile):void
		{
			if (_groundScene.contains(tile))
			{
				_groundScene.removeChild(tile);	
				ArrayUtil.removeItem(GC.addedTilesArray, tile);
			}
		}
		/**
		 * Изменяю offset добавленных тайлов
		 * @param	nameTile
		 * @param	offsetObject
		 */
		public function setOffsetInAddedTilesArray( nameTile:String, offsetObject:Object):void 
		{
			var locAddedTilesArr:Array = GC.addedTilesArray;
			for (var i:int = 0; i < locAddedTilesArr.length; i++) 
			{
				if (nameTile==locAddedTilesArr[i].name) 
				{
					locAddedTilesArr[i].offset = offsetObject;
					//trace('i='+i+'  ' + locAddedTilesArr[i] , offsetObject);
				}
			}
		}
		
		/**
		 * Изменяю Visible добавленных тайлов
		 * @param	layerName
		 * @param	flagVisible
		 */
		public function setVisibleTilesInAddedTilesArray( layerName:String, flagVisible:Boolean):void 
		{
			// trace('Имя слоя:'+layerName+'   Флаг: '+flagVisible);
			var locAddedTilesArr:Array = GC.addedTilesArray;
			var indexAlpha:int = (flagVisible)?1:0;
			for (var i:int = 0; i < locAddedTilesArr.length; i++) 
			{
				if (layerName==locAddedTilesArr[i].inLayer) 
				{
					locAddedTilesArr[i].bitmap.alpha = indexAlpha;
				}
			}
			
			this.invalidatePosition();
			this.render();
		}

		/**
		 * Изменяет подсветку
		 * @param	flagBacklight
		 */
		public function setBacklightTilesInAddedTilesArray(flagBacklight:Boolean):void 
		{
			var locAddedTilesArr:Array = GC.addedTilesArray;
			var layerName:String = MovieClip(root).Panel.listLayersMC.getCurrentLayer();
			
			for (var i:int = 0; i < locAddedTilesArr.length; i++) 
			{
				if (layerName==locAddedTilesArr[i].inLayer) 
				{
					if (flagBacklight) 
					{
						locAddedTilesArr[i].addBaseSprite();
					} else {
						locAddedTilesArr[i].removeBaseSprite();
					}
				} else {
					locAddedTilesArr[i].removeBaseSprite();
				}
			}
			
			this.invalidatePosition();
			this.render();
		}
		
		/**
		 * Ставит бэкгроунд
		 * @param	bg
		 * @param	nameBG
		 * @param	x
		 * @param	y
		 */
		public function setBackground(bg:DisplayObject, nameBG:String = 'defaultBG', x:Number = 0, y:Number = 0):void
		{
			if (GC.bg && contains(GC.bg)) 
			{
				backgroundContainer.removeChild(GC.bg);
			}
			GC.bg = bg;
			GC.bg.name = nameBG;
			GC.bg.x = x;
			GC.bg.y = y;
			backgroundContainer.addChild(GC.bg);
		}
		
		//-----------------------------------------------------------------------------------
		/**
		 * Создание IsoScene
		 */
		private function createGroundScene():void
		{
			_groundScene = new IsoScene();
			addScene(_groundScene);
		}
		/**
		 * Создание сетки
		 * @param	cols
		 * @param	rows
		 * @param	cellsize
		 */
		private function createGrid(cols:Number, rows:Number, cellsize:Number = 20):void
		{
			_gridScene = new IsoScene();
			addScene(_gridScene);
			
			_grid = new IsoGrid();
			_grid.cellSize = cellsize;
			_grid.setGridSize(cols, rows);
			_gridScene.addChild(_grid);
		}


		/*Геттеры и Сеттеры*/
		public function get grid():IsoGrid
		{
			return _grid;
		}
		
		public function get debugMode():Boolean
		{
			return _debugMode;
		}
		
		public function set debugMode(value:Boolean):void
		{
			_debugMode = value;
			if (_debugMode)
			{
				if (!containsScene(_gridScene))
				{
					addSceneAt(_gridScene, 0);
				}
			}
			else
			{
				if (containsScene(_gridScene))
				{
					removeScene(_gridScene);
				}
			}
		}
		
		public function get groundScene():IsoScene 
		{
			return _groundScene;
		}
		
		public function set MODE(value:String):void 
		{
			_MODE = value;
		}

		public function boxPolSetSize():void 
		{
			_boxPol.setSize(_grid.cellSize, _grid.cellSize, _boxPol.height);
			onMoveObject(null);
		}
		
		// SINGLETON
		private static var _instance:World;
		
		public static function getInstance():World
		{
			return _instance;
		}
	}

}



		/*
		private function panningZoom(e:MouseEvent):void 
		{
			panPt = new Point(stage.mouseX, stage.mouseY);
			viewPan = true;
			stage.addEventListener(MouseEvent.MIDDLE_MOUSE_UP, viewMiddle_Mouse_Up, false, 0, true );
		}
		private function viewMiddle_Mouse_Up(e:MouseEvent):void 
		{
			viewPan = false;
			stage.removeEventListener(MouseEvent.MIDDLE_MOUSE_UP, viewMiddle_Mouse_Up);
		}
		*/			
			//this.addEventListener( MouseEvent.MIDDLE_MOUSE_DOWN, panningZoom);

			/*if (viewPan) 
			{
				this.panBy(panPt.x - stage.mouseX, panPt.y - stage.mouseY);
				panPt.x = stage.mouseX;
				panPt.y = stage.mouseY;
			} 
			else {}*/

		/*Удаляет все потомки мувика
		private function removeChildrenOf(mc:MovieClip):void{
			if(mc_mc.numChildren!=0){
				var k:int = mc.numChildren;
				while( k -- )
				{
					mc.removeChildAt( k );
				}
			}
		}*/