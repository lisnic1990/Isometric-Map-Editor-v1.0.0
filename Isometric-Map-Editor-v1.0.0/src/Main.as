package 
{
	import com.adobe.images.JPGEncoder;
	import com.adobe.images.PNGEncoder;
	import flash.display.BitmapData;
	import flash.display.StageScaleMode;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import isospace.World;
	import ui.keys;
	import utility.Alert;
	import utility.GC;
	
	import as3isolib.core.ClassFactory;
	import as3isolib.display.IsoSprite;
	import as3isolib.display.primitive.IsoBox;
	import as3isolib.display.renderers.DefaultShadowRenderer;
	import as3isolib.enum.RenderStyleType;
	import as3isolib.geom.IsoMath;
	import as3isolib.geom.Pt;
	import as3isolib.graphics.SolidColorFill;
	import flash.display.Bitmap;
	import fl.controls.ScrollBarDirection;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import as3isolib.display.IsoView;
	import as3isolib.display.scene.IsoGrid;
	import as3isolib.display.scene.IsoScene;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;
	
	/**
	 * @author lisnic.tk
	 * @version 1.0.0.0
	 */
	

	public class Main extends MovieClip 
	{			
		public static var col:int=1;
		public static var row:int=1;
		public static var cellSize:int;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
		}
		
		/**
		 * Инициализация
		 * @param	e
		 */
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			_instance = this;
			
			//Читаю поля col,row,cellSize:
			readParamFields();
			
			// Установить сетку
			SetGrig();

			// Применить введеные параметры
			Panel.settingsMapMC.applyBtn.addEventListener(MouseEvent.CLICK, onClickHandlerApply);	
			// Вкл/Выкл Подсветка тайлов
			Panel.settingsMapMC.backlightBtn.addEventListener(MouseEvent.CLICK, onClickBacklightBtn);
			// Вкл/Выкл Сетки
			Panel.settingsMapMC.showGridBtn.addEventListener(MouseEvent.CLICK, onClickShowGridBtn);
			// Сохранить скриншот карты
			Panel.settingsMapMC.captureBtn.addEventListener(MouseEvent.CLICK, onClickHandlerCapture);
			// Показать справку:
			Panel.helpBtn.addEventListener(MouseEvent.CLICK, onClickHandlerHelp);
		}
		
		/**
		 * Создание скриншота
		 * @param	e
		 */
		private function onClickHandlerCapture(e:MouseEvent):void 
		{
			var bitmapData:BitmapData=new BitmapData(World.getInstance().width, World.getInstance().height);
			bitmapData.draw(World.getInstance());  
			//
			var jpgEncoder:JPGEncoder = new JPGEncoder(1);
			var byteArray:ByteArray = jpgEncoder.encode(bitmapData);

			byteArray = PNGEncoder.encode(bitmapData);
			
			var fileReference:FileReference=new FileReference();
			fileReference.save(byteArray, "capture.jpg"); 				
		}
		
		/**
		 * Показывает/скрывает сетку
		 * @param	e
		 */
		private function onClickShowGridBtn(e:MouseEvent):void 
		{
			World.getInstance().debugMode = e.target.selected;
		}
		/**
		 * Подсветка элементов текущего слоя
		 * @param	e
		 */
		private function onClickBacklightBtn(e:MouseEvent):void 
		{
			World.getInstance().setBacklightTilesInAddedTilesArray(e.target.selected);
		}
		/**
		 * Считывает параметры полей:
		 * Columns
		 * Rows
		 * Cell Size
		 */
		private function readParamFields():void {
			try {
				col = int(Panel.settingsMapMC.sizeMapMC.col.text);
			} catch (e:ErrorEvent) { col = 1; }

			
			try {
				row = int(Panel.settingsMapMC.sizeMapMC.row.text);
			} catch (e:ErrorEvent) { row = 1; }

			
			try {
				cellSize = int(Panel.settingsMapMC.sizeTileMC.cellSize.text);
			} catch (e:ErrorEvent) { cellSize = 32; }
		}

		/**
		 * Считывает введеные даные
		 * Меняет соответственно сетку
		 * @param	e
		 */
		public function onClickHandlerApply(e:MouseEvent):void 
		{
			readParamFields();
			SetGrig();
		}

		/**
		 * Устанавливает новый размер сетки:
		 */
		private function SetGrig():void 
		{		
			// Считывает введеные параметры:
			col = (col == 0)?1:col;
			row = (row == 0)?1:row;
			cellSize = (cellSize == 0)?4:cellSize;
			
			// Изменяет сетку:
			World.getInstance().grid.cellSize =  cellSize;
			World.getInstance().grid.setGridSize(col, row, 1);
			
			//Изменяет размер boxPol:
			World.getInstance().boxPolSetSize();
			
			// Ресайз всех слоев:
			MovieClip(root).Panel.listLayersMC.resizeLayers(col, row);

			// Рендерит сцену
			World.getInstance().render();
		}

		//SINGLETON
		private static var _instance:Main;
		
		public static function getInstance():Main
		{
			if (_instance == null)
			{
				_instance = new Main();
			}
			return _instance;
		}
		
		

		// Показывает Справку:
		private function onClickHandlerHelp(e:MouseEvent):void 
		{
			var helpString:String = "Двигать Backgroung: Ctrl+NUMPAD[4,8,6,2]" + "\n" +
									"Двигать сцену: Стрелки  \n Zoom: колесо  ИЛИ Ctrl+'+', Ctrl+'-' " +"\n"+
									"Вернуть по дефолту: Ctrl+End" +"\n"+
									"--------------------------------------" +"\n" +
									"Использование:" +"\n" +

									"Ставим необходимый параметры в Size map: col,row, cellSize." +"\n" +
									"Загружаем тайлы: Click on  Add Tile/s" +"\n" +
									"Если необходимо, редактируем тайл. Для этого выбираем его из тайллиста и кликаем кнопку Edit Tile." +"\n" +
									"Открывается окошко, где можно настроить количество занимаемых клеток и смещение относительно верхнего угла прямоугольника основания." +"\n" +
									"Чтобы сохранить текущие настроики тайлов, жми на saveTilesLib." +"\n" +
									"А для загрузки их жми на LoadTilesLib." +"\n" +
									"Фон загрузить можно используя кнопку LoadBG, А также легко удалить нажав Del BG." +"\n" +
									"Создание, Сохранение и загрузка  Карты. - три кнопки подряд [NewMap, SaveMap, LoadMap]" +"\n" +
									"все в форате xml." +"\n" +
									"Слои:" +"\n" +
									"Кнопка S - Сохранение текущих слоев в отдельном файле." +"\n" +
									"CheckBox's:" +"\n" +
									"Backlight - подсвечивает текущий слой" +"\n" +
									"Show Grid -показывает/Скрывает сетку" 
									"----------------------" +"\n" +
									"Четыре кноки сверху:" +"\n" +

									"Стрелка - когда активна на карту ничего поствить/удалить нельзя." +"\n" +
									"Т - Режам тайлов, можно ставить на карту по одному тайлу" +"\n" +
									"Красная херня - Резинка" +"\n" +
									"Флакон - Заливка, лучше этим инструментом не пользоваться.) напрягает комп" ;

				Alert.show(helpString);
				
		}
		
		
		
	}
	
}