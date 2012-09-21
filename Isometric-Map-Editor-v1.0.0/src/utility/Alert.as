/*
 
  The MIT License, 
 
  Copyright (c) 2011. silin (http://silin.su#AS3)
 
*/
package utility
{
	
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.Point;
	import flash.text.*;
	import flash.utils.*;
	/**
	 * вывод алерта и/или блокировки интерактивонсти заблуренным скриншотом; <br/>
	 * перед использованием обязателен вызов Alert.register(); <br/>
	 * все параметры должны быть установлены до вызова Alert.register();
	 * 
	 * @author silin 
	 */
	public class Alert {
		
		public static var GAP:int = 10;
		public static var BG_COLOR:int = 0x000000;
		public static var BG_ALPHA:Number = 0.35;
		public static var BG_ROUND_CORNER:Number = 8;
		
		public static var FRAME_COLOR:uint = 0xFFFFFF;
		public static var FRAME_THICKNESS:uint = 2;
		
		
		public static var BUTTON_WIDTH:int = 60;
		public static var BUTTON_HEIGHT:int = 20;
		public static var BUTTON_FACE_COLOR:int = 0xEEEEEE;
		public static var BUTTON_BORDER_COLOR:int = -1;
		public static var BUTTON_TEXT_COLOR:int = 0x404040;
		public static var BUTTON_TEXT_SIZE:int = 11;
		
		public static var MESSAGE_COLOR:int = 0xFFFFFF;
		public static var MESSAGE_TEXT_SIZE:int = 12;
		//public static var SHADOW:BitmapFilter = new DropShadowFilter(2, 45, 0x000000, 0.25);
		public static var BUTTON_OVER_FILTER:BitmapFilter = new GlowFilter(0xFFFFFF, 0.25);
		
		
		
		private static var _messageTF:TextField = new TextField();
		private static var _body:Sprite = new Sprite();
		private static var _skin:Shape = new Shape();
		private static var _screenBitmap:Bitmap = new Bitmap();
		
		private static var _stage:DisplayObjectContainer;
		private static var _okBut:TextField = new TextField();
		private static var _cancelBut:TextField = new TextField();
		private static var _clrMtrx:ColorAdjust = new ColorAdjust(ColorAdjust.ADD);
		private static var _format:TextFormat;
		
		private static var _okCallback:Function=null;
		private static var _cancelCallback:Function=null;
		
		
		/**
		 * не конструктор, экземпляры не создаем
		 */
		public function Alert():void 
		{
			throw(new Error ("Alert is a static class and should not be instantiated. "));
		}

		/**
		 * привязка к контейнеру, обязательный метод
		 * @param	stage	
		 */ 
		public static function register(stage:Stage)	:void
		{
			if (_stage) 
			{
				trace("Alert: double Alert.register() call");
				return;
			}
			
			_stage = stage;
			
			_clrMtrx.saturation(0);
			_clrMtrx.colorize(0xFFFF80, 0.1);
			
			if (BUTTON_BORDER_COLOR >= 0)
			{
				_okBut.border = true;
				_okBut.borderColor = BUTTON_BORDER_COLOR;
				_cancelBut.border = true;
				_cancelBut.borderColor = BUTTON_BORDER_COLOR;
			}
			
			_body.addChild(_screenBitmap);
			_body.addChild(_skin);
			_body.addChild(_messageTF);
			_body.addChild(_okBut);
			_body.addChild(_cancelBut);
			
			
			_okBut.addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
			_cancelBut.addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
			_okBut.addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
			_cancelBut.addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
			_okBut.addEventListener(MouseEvent.MOUSE_DOWN, mouseOutHandler);
			_cancelBut.addEventListener(MouseEvent.MOUSE_DOWN, mouseOutHandler);
			
			
			config();
			
		}
		
		static private function mouseOutHandler(evnt:MouseEvent):void 
		{
			
			var but:TextField=evnt.target as TextField
			but.filters = [];
			
		}
		
		static private function mouseOverHandler(evnt:MouseEvent):void 
		{
			var but:TextField=evnt.target as TextField
			but.filters = [BUTTON_OVER_FILTER];
			
		}
		
		
		private static function config():void
		{
			
			_format = new TextFormat("_sans", MESSAGE_TEXT_SIZE, MESSAGE_COLOR, true);
			_format.align = TextFormatAlign.CENTER;
			_messageTF.defaultTextFormat = _format;
			_messageTF.autoSize = TextFieldAutoSize.CENTER;
			_messageTF.mouseEnabled = false;
			
			
			_format.size = BUTTON_TEXT_SIZE;
			_format.color = BUTTON_TEXT_COLOR;
			
			_okBut.width = BUTTON_WIDTH;
			_okBut.height = BUTTON_HEIGHT;
			_okBut.background = true;
			_okBut.selectable = false;
			_okBut.defaultTextFormat = _format;
			_okBut.backgroundColor = BUTTON_FACE_COLOR;
			
			
			
			_cancelBut.width = BUTTON_WIDTH;
			_cancelBut.height = BUTTON_HEIGHT;
			_cancelBut.background = true;
			_cancelBut.selectable = false;
			_cancelBut.defaultTextFormat = _format;
			_cancelBut.backgroundColor = BUTTON_FACE_COLOR;
			
			
			//_skin.filters = [SHADOW];
		}
		
		
		private static function drawSkin(w:int, h:int):void
		{
			_skin.graphics.clear();
			_skin.graphics.beginFill(BG_COLOR, BG_ALPHA);
			_skin.graphics.lineStyle(FRAME_THICKNESS, FRAME_COLOR);
			//_skin.graphics.drawRect(0, 0, 100, 100);
			_skin.graphics.drawRoundRect(0, 0, w, h, BG_ROUND_CORNER, BG_ROUND_CORNER);
			
		}
		/**
		 * сносит все
		 */
		public static function clear(evnt:MouseEvent=null):void	
		{
			if (!_stage ) return;
			
			if (_body.parent) 	_stage.removeChild(_body);
			_messageTF.text = "";
			_okBut.visible = false;
			_cancelBut.visible = false;
			_skin.visible = false;
			
			if(evnt) switch(evnt.target)
			{
				case _okBut:
					try
					{
						_okCallback();
					}catch(err:Error){}
					
				break;
				case _cancelBut:
					try
					{
						_cancelCallback();
					}catch(err:Error){}
				break;
			}
		}
		
		/**
		 * алерт с двумя кнопками 
		 * @param	message				message
		 * @param	okCallback			callback function
		 * @param	cancelCallBack		callback function
		 * @param	okLabel				button label
		 * @param	cancelLabel			button label
		 */
		public static function ask(message:String, 	okCallback:Function = null, cancelCallBack:Function = null, 
													okLabel:String = "OK", cancelLabel:String = "Cancel"):void
		
		{
			if (!_stage) return;
			
			block();
			
			_okCallback = okCallback;
			_cancelCallback = cancelCallBack;
			
			//var cX:int = (_stage.stage.stageWidth - _okBut.width) / 2;
			var cX:int = _stage.stage.stageWidth / 2;
			var cY:int = (_stage.stage.stageHeight - _okBut.height) / 2;
			
			_okBut.text = okLabel;
			
			_okBut.x = cX - BUTTON_WIDTH - GAP;
			_okBut.y = cY;
			
			_okBut.addEventListener(MouseEvent.CLICK, clear);
			_okBut.visible = true;

			_cancelBut.text = cancelLabel;
			_cancelBut.x = cX + GAP;
			_cancelBut.y = cY;
			_cancelBut.addEventListener(MouseEvent.CLICK, clear);
			_cancelBut.visible = true;
			
			_messageTF.text = message;
			_messageTF.x = cX - _messageTF.textWidth / 2;
			_messageTF.y = cY - _messageTF.textHeight - GAP;
			
			//_skin.width = Math.max(200, _messageTF.width + 2 * GAP);
			//_skin.height = _messageTF.height + _okBut.height + 3 * GAP;
			drawSkin(Math.max(200, _messageTF.width + 2 * GAP), _messageTF.height + _okBut.height + 3 * GAP);
			_skin.x = cX - _skin.width / 2;
			_skin.y = _messageTF.y - GAP;
			_skin.visible = true;
			

		}
		/**
		 * только сообщение
		 * @param	message
		 */
		public static function message(message:String):void
		{
			if (!_stage) return;
			block();
			
			
			
			var cX:int = (_stage.stage.stageWidth - _okBut.width) / 2;
			var cY:int = (_stage.stage.stageHeight - _okBut.height) / 2;
			
			
			
			_messageTF.text = message;
			_messageTF.x = cX - _messageTF.textWidth / 2;
			_messageTF.y = cY - _messageTF.textHeight - GAP;
				
			//_skin.width = Math.max(200, _messageTF.width + 2 * GAP);
			//_skin.height = _messageTF.height + _okBut.height + 3 * GAP;
			drawSkin(Math.max(200, _messageTF.width + 2 * GAP), _messageTF.height + 2 * GAP);
			_skin.x = cX - _skin.width / 2;
			_skin.y = _messageTF.y - GAP;
			_skin.visible = true;

		}
		
		/**
		 * алерт с одной кнопкой
		 * @param	message			messaqqe
		 * @param	okCallback		callback function
		 * @param	okLabel			button label
		 */
		public static function show(message:String, okCallback:Function=null, okLabel:String = "OK"):void
		{
			if (!_stage) return;
			block();
			
			_okCallback = okCallback;
			
			var cX:int = (_stage.stage.stageWidth - _okBut.width) / 2;
			var cY:int = (_stage.stage.stageHeight - _okBut.height) / 2;
			
			_okBut.text = okLabel;
			
			_okBut.x = cX - BUTTON_WIDTH / 2;
			_okBut.y = cY;
			_okBut.addEventListener(MouseEvent.CLICK, clear);
			_okBut.visible = true;
			
			_messageTF.text = message;
			_messageTF.x = cX - _messageTF.textWidth / 2;
			_messageTF.y = cY - _messageTF.textHeight - GAP;
				
			//_skin.width = Math.max(200, _messageTF.width + 2 * GAP);
			//_skin.height = _messageTF.height + _okBut.height + 3 * GAP;
			drawSkin(Math.max(200, _messageTF.width + 2 * GAP), _messageTF.height + _okBut.height + 3 * GAP);
			_skin.x = cX - _skin.width / 2;
			_skin.y = _messageTF.y - GAP;
			_skin.visible = true;

		}
		
	
		/**
		 * блокировка интерактивонсти заблуренным скриншотом
		 */
		public static function block():void
		{
			if (!_stage) return;
			
			_okBut.visible = false;
			_cancelBut.visible = false;
			if (_skin) _skin.visible = false;
			_messageTF.text = "";
			_okCallback = null;
			_cancelCallback = null;
			
			var bmd:BitmapData = new BitmapData(_stage.stage.stageWidth, _stage.stage.stageHeight, true, 0);
			bmd.draw(_stage);
			
			bmd.applyFilter(bmd, bmd.rect, new Point(), _clrMtrx.filter);
			bmd.applyFilter(bmd, bmd.rect, new Point(), new BlurFilter(4, 4));
			_screenBitmap.bitmapData = bmd;
			_stage.addChild(_body);
			
		}
		
	}
}



