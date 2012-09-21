package  managers
{
	import flash.display.Bitmap;
	import flash.errors.IllegalOperationError;
	import isospace.Tile;
	
	/**
	 * Менеджер тайлов
	 * @author lisnic.tk
	 * @version 1.0.0.0
	 */
	public class Tiles 
	{
		private var _сountTiles:uint;
		private var _objects:Object = { };
		
		public function Tiles() 
		{
			_сountTiles = 0;
		}
		
		/**
		 * Добавления тайла
		 * @param	name
		 * @param	area
		 * @param	bitmap
		 * @param	offset
		 */
		public function addTile(name:String, area:Object, bitmap:Bitmap, offset:Object):void 
		{			
			// Проверка уникальности
			if (!_objects[name]) 
			{
				_objects[name] = new Tile(name, area, bitmap, offset);
				_сountTiles++;
			}
			else
			{ 
				trace("addTile: Объект уже находится в этом пуле!");
			}

			trace(Tiles+'   Добавлен тайл в кэш!    _сountTiles= '+_сountTiles);
		}
		/**
		 * Возвращает тайл по имени
		 * @param	name		Имя тайла
		 * @return
		 */
		public function getTile(name:String):Tile 
		{			
			if (_objects[name]) 
			{
				return _objects[name];
			} else
			{ 
				// trace("getTile: С таким именем тайл отсутствует!");
				return null;
			}
		}

		/**
		 * Возвращает образец тайла по id
		 * @param	id			id тайла
		 * @return
		 */
		public function getTileById(id:int):Tile 
		{					
			for (var name:String in _objects)
			{
				if (_objects[name] && _objects[name].idTile == id) 
				{
					return _objects[name];
				}
			}
			
			return null;
		}
		/**
		 * Удаляет тайл
		 * @param	name		Имя тайла
		 */
		public function removeTile(name:String):void 
		{			
			if (_objects[name]) 
			{
				_objects[name] = null;
				delete _objects[name];
				_сountTiles--;
			} else
			{ 
				trace("removeTile: С таким именем тайл отсутствует!");
			}
			
			for (var s:String in _objects)
			{
				trace(s + " = " + _objects[s]);
			}
		}
		/**
		 * Изменяет тайл 
		 * @param	name		Имя тайла
		 * @param	area		Площадь тайла
		 * @param	bitmap		изображение
		 * @param	offset		смещение тайла
		 */
		public function setTile(name:String, area:Object, bitmap:Bitmap, offset:Object):void 
		{			
			if (_objects[name]) 
			{
				_objects[name] = null;
				delete _objects[name];
				addTile(name, area, bitmap, offset);
			} else
			{ 
				throw new ArgumentError("setTile: С таким именем тайл отсутствует!");
			}
		}

		/**
		 * Изменяет параметры тайла
		 * @param	name
		 * @param	area
		 * @param	offset
		 * @param	h
		 * @param	idTile
		 * @param	type
		 * @return				Возвращает id тайла, или -1 - если тайл не найден
		 */
		public function setSettingsForTileBitmap(name:String, area:Object, offset:Object, h:int, idTile:int=-1, type:String="fixed"):int 
		{			
			if (_objects[name]) 
			{
				_objects[name].area = area;
				_objects[name].offset = offset;
				
				_objects[name].height = h;
				
				_objects[name].type = type;

				// trace('Изменяю заданый тайл:  '+ name +'   setSettingsForTileBitmap: (c,r)'+ _objects[name].area.c , _objects[name].area.r);
				//_objects[name].addBaseSprite();
				
				if (idTile!=-1) 
				{
					trace( "1 _objects[" + name + "].idTile = " + _objects[name].idTile);
					
					//Изменяем id если таковой уже есть в нашем кэше тайлов:
					var flagChange:Boolean = changeIDifNecessary(name, idTile);
					if (flagChange) 
					{
						return _objects[name].idTile;
					}
					
					trace( "2 _objects[" + name + "].idTile = " + _objects[name].idTile);
				}
			} else
			{ 
				trace("setSettingsForTileBitmap: С таким именем тайл отсутствует!");
			}
			
			return -1;
			
		}
		
		/**
		 * Изменяем id если таковой уже есть в нашем кэше тайлов
		 * @param	name		Имя тайла
		 * @param	idTile		id Тайла
		 * @return	Возвращает true - если был зменен,
					false - если не был изменен
		 */
		private function changeIDifNecessary(name:String, idTile:int):Boolean 
		{
			//Если это тот же объект с таким же ID, то ничего не делаем:
			if ((_objects[name].idTile == idTile)&&(_objects[name] == getTileById(idTile))) 
			{
				trace("ТОТ ЖЕ")
				return false;
			}			
			
			//Если объект из кэша с данным id отсутствует либо отличается:
			if (_objects[name] != getTileById(idTile)) 
			{
				//Создаю новый ID для данного тайла:
				var newID:int = ++Tile.CountIdTile;
				/*
				while (getCountTilesWithThisID(newID)!=0) 
				{
					newID = ++Tile.CountIdTile;
				}*/
				trace("newID= " + newID);
				_objects[name].idTile = newID;
				return true;
			}else {
				//Присваиваю полученый ID для данного тайла:
				_objects[name].idTile = idTile;
				return false;
			}
		}
		
		/**
		 * Возвращает число тайлов с таким ID
		 * @param	newID
		 * @return
		 */
		private function getCountTilesWithThisID(newID:int):int 
		{
			var count:int = 0;
			for (var name:String in _objects)
			{
				if (_objects[name] && _objects[name].idTile == newID) 
				{
					count++;
				}
			}
			return count;
		}
		/**
		 * Возвращат массив тайлов с таким ID
		 * @param	idTile			ID тайла
		 */
		private function getArrTilesWithThisID(idTile:int):Array 
		{
			var tilesWithThisID:Array = [];
			for (var name:String in _objects)
			{
				if (_objects[name] && _objects[name].idTile == idTile) 
				{
					tilesWithThisID.push(_objects[name]);
				}
			}
			return tilesWithThisID;
		}

		/**
		 * GETTERS AND SETTERS:
		 */
		public function get сountTiles():uint 
		{
			return _сountTiles;
		}
		
		public function get objects():Object 
		{
			return _objects;
		}
		
	}

}