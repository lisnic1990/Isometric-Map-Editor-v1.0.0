package  isospace
{
	import as3isolib.display.IsoSprite;
	import as3isolib.geom.Pt;
	import as3isolib.graphics.BitmapFill;
	import as3isolib.utils.IsoDrawingUtil;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	/**
	 * Экземпляр тайла
	 * @author lisnic.tk
	 * @version 1.0.0.0
	 */
	public class Tile extends IsoSprite 
	{
		private var _idTile:int;
		// Имя слоя, которому принадлежит тайл
		private var _inLayer:String;
		// счетчик используетя
		public static var CountIdTile:int = 0;


		// тайловые координаты (т.е. где он расположен):
		public var _column:Number; 
		public var _row:Number;
		
		private var _bitmap:Bitmap;
		private var _area:Object;//Сколько занимет ячеек:
		private var _offset:Object;
		private var _type:String;
		
		// Подсветка тайла
		protected var _baseSprite:Sprite;
		//Параметры тайла
		public var paramsArr:Array = [];


		public function Tile(name:String, area:Object, bitmap:Bitmap, offset:Object, h:int=0, type:String="fixed") 
		{
			this.name = name;	
			_area = area;
			_bitmap = bitmap;
			_offset = offset;
			_type = type;
			
			_idTile = ++CountIdTile;
			
			addSkin(_bitmap);	

			// Создание подсветки
			_baseSprite = createBaseSprite(0xFF0000);
			sprites.unshift(_baseSprite);
			
			this.width = _area.c * World.getInstance().grid.cellSize;
			this.length = _area.r * World.getInstance().grid.cellSize;
			this.height = h; 

		}
		
		/**
		 * добавление изображения
		 * @param	skinBitmap
		 */
		public function addSkin(skinBitmap:Bitmap):void
		{			
			if (_offset != null)
			{
				skinBitmap.x = (_offset.x != null) ? Number(_offset.x) : 0;
				skinBitmap.y = (_offset.y != null) ? Number(_offset.y) : 0;				
			}
			sprites.push( skinBitmap ); // add to sprites in IsoSprite
			invalidateSprites();
		}
		/*Добавляем базовый спрайт у основания*/
		public function addBaseSprite():void 
		{
			_baseSprite = createBaseSprite(0xFF0000);
			
			//sprites[0] = _baseSprite;
			/*
			if (sprites.length < 1) 
			{
				sprites[0] = _baseSprite;
			} else {
				sprites.unshift(_baseSprite);
			}
			*/

			switch (sprites.length) 
			{
				case 0:sprites[0] = _baseSprite;
				break;
				case 1:sprites.unshift(_baseSprite);
				break;
				case 2:sprites[0] = _baseSprite;
				break;
			}
			
			//Рендерю все спрайты, в массиве sprites:
			this.invalidateSprites();
			this.render();
		}
		
		/**
		 * Удаляем базовый спрайт, что у основания
		 */
		public function removeBaseSprite():void 
		{ 
			var index:int = sprites.indexOf(_baseSprite);
			if (_baseSprite && index!=-1 ) 
			{
				//trace(index + 'do: ' + sprites);
				
				sprites.splice( index, 1);
				_baseSprite = null;
				
				//trace('res: ' + sprites);
				//Рендерю все спрайты, в массиве sprites:
				this.invalidateSprites();
				this.render();
			}
		}
		
		/**
		 * Рисует прямоугольник у основания
		 * @param	color
		 * @return
		 */
		protected function createBaseSprite(color:uint = 0):Sprite
		{
			var s:Sprite = new Sprite();
			s.graphics.beginFill(color, .5);
			//trace(  'c = '+_area.c +' r= '+_area.r );
			IsoDrawingUtil.drawIsoRectangle(s.graphics, new Pt(0, 0, 0), (_area.c * Main.cellSize), (_area.r * Main.cellSize));
			s.graphics.endFill();
			return s;
		}
		
		/**
		 * Функция Клонирует Тайл
		 * (переопределяю метод и финализирую метод, чтобы нельзя было больше переопределять этот метод)
		 */
		
		public override final function clone():*
		{						
			trace( this.height );

			var newTile:Tile = new Tile(name, _area, new Bitmap(_bitmap.bitmapData), _offset, this.height); 
			newTile._idTile = _idTile; 
			return newTile;
		}
		

		/*Геттеры и сеттеры*/
		public function get idTile():int 
		{
			return _idTile;
		}
		
		public function get offset():Object 
		{
			return _offset;
		}
		
		public function set offset(value:Object):void 
		{
			_offset = value;
			_bitmap.x = _offset.x;
			_bitmap.y = _offset.y;
		}
		
		public function get bitmap():Bitmap 
		{
			return _bitmap;
		}
		
		public function set bitmap(value:Bitmap):void 
		{
			_bitmap = value;
		}
		
		public function get area():Object 
		{
			return _area;
		}
		
		public function set area(value:Object):void 
		{
			_area = value;
			this.width = _area.c * World.getInstance().grid.cellSize;
			this.length = _area.r * World.getInstance().grid.cellSize;
			// trace('area: '+this.width , this.length);
		}
		
		public function get inLayer():String
		{
			return _inLayer;
		}
		
		public function set inLayer(value:String):void 
		{
			_inLayer = value;
		}
		
		public function set idTile(value:int):void 
		{
			_idTile = value;
		}
		
		public function get type():String 
		{
			return _type;
		}
		
		public function set type(value:String):void 
		{
			_type = value;
		}
		
		public function toString():String 
		{
			return ('[' + Tile + '  name= ' + name + ' _idTile= ' +_idTile + ' _column=' + _column + ' _row=' + _row
					+ "_area.c="+_area.c+ " _area.r="+_area.r+ "_offset.x="+_offset.x+ "_offset.y="+_offset.y +']\n'
			);
		}
		
	}

}