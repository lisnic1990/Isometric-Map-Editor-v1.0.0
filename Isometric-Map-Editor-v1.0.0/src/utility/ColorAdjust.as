
/*
 
  The MIT License, 
 
  Copyright (c) 2011. silin (http://silin.su#AS3)
 
*/
package  utility
{

	import flash.filters.ColorMatrixFilter;
	import flash.geom.Matrix;
	/**
	 * ColorMatrixFilter с методами установоки расхожих параметров цветности <br>
	 * 
	 * @author silin
	 */
	public class ColorAdjust
	{
		
		// RGB to Luminance conversion constants 
		private static const R_LUM:Number = 0.212671;
		private static const G_LUM:Number = 0.715160;
		private static const B_LUM:Number = 0.072169;
		//че-то они разные в разных источниках.., надо бы разобраться
		/*
		private static var R_LUM:Number = 0.3086;
		private static var G_LUM:Number = 0.6094;
		private static var B_LUM:Number = 0.0820;
		*/
		
		/*
		private static var R_LUM:Number = 0.3;
		private static var G_LUM:Number = 0.59;
		private static var B_LUM:Number = 0.11;
		*/
		//режимы модификации _filter.matrix concat или создание нового							
		public static const ADD:String = "add";
		public static const CLEAR:String = "clear";
									
									
		private var _mode:String = ADD;
		private var _filter:ColorMatrixFilter;
		
		
		/**
		 * constructor
		 * @param	mode	режим изменения параметров ADD | CLEAR (добавление или обновление)
		 */
		function ColorAdjust ( mode:String = ADD )
		{
			
			_filter = new ColorMatrixFilter();
			_mode = mode;
			reset();
		}
		
		/**
		 *  ColorMatrixFilter с текущими установками
		 */
		public function get filter():flash.filters.ColorMatrixFilter { return _filter; }
		
		/**
		 * режим изменения матрицы при установке новых значений: CLEAR | ADD <br>
		 * абсолютные величины или конкатенция с текущием состоянием
		 */
		public function get mode():String { return _mode; }
		
		public function set mode(value:String):void 
		{
			_mode = value;
		}
		
		/**
		 * сброс параметров
		 */
		public function reset():ColorAdjust
		{
			_filter.matrix=[	1, 0, 0, 0, 0,
								0, 1, 0, 0, 0,
								0, 0, 1, 0, 0,
								0, 0, 0, 1, 0];
			return this;
		}
		/**
		 * 
		 * @param	rgb		24-битный цвет подкраски
		 * @param	amount	величина подкраски, 0..1
		 */
		public function colorize ( rgb:Number, amount:Number=1):ColorAdjust
		{
			
			
			var r:Number = ( ( rgb >> 16 ) & 0xff ) / 255;
			var g:Number = ( ( rgb >> 8  ) & 0xff ) / 255;
			var b:Number = (   rgb         & 0xff ) / 255;
			
			var inv_amount:Number = 1 - amount;
			
			var mtrx:Array =  [ inv_amount + amount*r*R_LUM, amount*r*G_LUM,  amount*r*B_LUM, 0, 0,
								amount*g*R_LUM, inv_amount + amount*g*G_LUM, amount*g*B_LUM, 0, 0,
								amount*b*R_LUM,amount*b*G_LUM, inv_amount + amount*b*B_LUM, 0, 0,
								0, 0, 0, 1, 0 ];
		
			setMatrix(mtrx);
			return this;
		}
		/**
		 * 
		 * @param	rgb		24-битный цвет оттенка
		 * @param	amount	величина,  0..1
		 */
		public function tint ( rgb:Number, amount:Number=0.35):ColorAdjust
		{
			
			
			var r:Number =  ( rgb >> 16 ) & 0xff;
			var g:Number =  ( rgb >> 8  ) & 0xff;
			var b:Number =    rgb         & 0xff;
			
			var inv_amount:Number = 1 - amount;
			
			var mtrx:Array =  [ inv_amount, 0, 0, 0, r * amount,
								0, inv_amount, 0, 0, g * amount,
								0, 0, inv_amount, 0, b * amount,
								0, 0, 0, 1, 0 ];
								
			setMatrix(mtrx);
			return this;
		}
		/**
		 * инвертирует цвета
		 */
		public function invert():ColorAdjust
		{
			var mtrx:Array =  [ -1, 0, 0, 0, 255,
								0, -1, 0, 0, 255,
								0,  0, -1, 0, 255,
								0, 0, 0, 1, 0];
			
			setMatrix(mtrx);
			return this;
		}
		/**
		 * установка оттенков сепии
		 */
		public function sepia():ColorAdjust
		{
			var mtrx:Array = [	0.3930000066757202, 0.7689999938011169, 0.1889999955892563, 0, 0, 
								0.3490000069141388, 0.6859999895095825, 0.1679999977350235, 0, 0, 
								0.2720000147819519, 0.5339999794960022, 0.1309999972581863, 0, 0, 
								0, 0, 0, 1,	0];
			setMatrix(mtrx);
			return this;
		}
		
		
		private function concat(mtrx:Array):ColorAdjust
		{
			
			var temp:Array = [];
			var i:int = 0;
			var matrix:Array = _filter.matrix;
			for (var y:int = 0; y < 4; y++ )
			{
				
				for (var x:int = 0; x < 5; x++ )
				{
					temp[i + x] = 	mtrx[i    ] * matrix[x] + 
									mtrx[i+1] * matrix[x +  5] + 
									mtrx[i+2] * matrix[x + 10] + 
									mtrx[i+3] * matrix[x + 15] +
									(x == 4 ? mtrx[i+4] : 0);
				}
				i+=5;
			}
			_filter.matrix = temp;
			return this;
			
		}
		
		/**
		 * brightness, -1..1
		 */
		public function brightness(value:Number):ColorAdjust 
		{
			
			var mtrx:Array = [	1, 0, 0, 0, 255*value,
								0, 1, 0, 0, 255*value,
								0, 0, 1, 0, 255*value,
								0, 0, 0, 1, 0 ];
							
			setMatrix(mtrx);
			return this;
			
		}
		
		/**
		 * contrast, -1..1
		 */
		public function contrast(value:Number):ColorAdjust 
		{
			value += 1;
			var mtrx:Array = [	value, 0, 0, 0, 128 * (1 - value),
								0, value, 0, 0, 128 * (1 - value),
								0, 0, value, 0, 128 * (1 - value),
								0, 0, 0, 1, 0];
			
			setMatrix(mtrx);
			return this;
		}
		/**
		 * hue, 0..360
		 */
		public function hue(value:Number):ColorAdjust 
		{
			
			var angle:Number = value * Math.PI / 180;
				
			var c:Number = Math.cos( angle );
			var s:Number = Math.sin( angle );
			
			var f1:Number = 0.213;
			var f2:Number = 0.715;
			var f3:Number = 0.072;
			
			var mtrx:Array = [	(f1 + (c * (1 - f1))) + (s * ( -f1)), (f2 + (c * ( -f2))) + (s * ( -f2)), (f3 + (c * ( -f3))) + (s * (1 - f3)), 0, 0, (f1 + (c * ( -f1))) + (s * 0.143), (f2 + (c * (1 - f2))) + (s * 0.14), (f3 + (c * ( -f3))) + (s * -0.283), 0, 0, (f1 + (c * ( -f1))) + (s * ( -(1 - f1))), (f2 + (c * ( -f2))) + (s * f2), (f3 + (c * (1 - f3))) + (s * f3), 
								0, 0, 0, 0, 
								0, 1, 0, 0, 
								0, 0, 0, 1];
							
			setMatrix(mtrx);
			return this;
		}
		/**
		 * saturation, 0..1
		 */
		public function saturation(value:Number):ColorAdjust 
		{
			
			var amount:Number = 1 - value;
			
			var irlum:Number = amount * R_LUM;
			var iglum:Number = amount * G_LUM;
			var iblum:Number = amount * B_LUM;
			
			var mtrx:Array = [	irlum + value, iglum, iblum, 0, 0,
								irlum, iglum + value, iblum, 0, 0,
								irlum, iglum, iblum + value, 0, 0,
								0, 0, 0, 1, 0 ];
									
			setMatrix(mtrx);
			return this;
		}
		/**
		 * threshold, 0..1
		 */
		public function threshold( value:Number ):ColorAdjust
		{
			var mtrx:Array =  [	R_LUM * 256, G_LUM * 256, B_LUM * 256, 0,  -256 * value, 
			
								R_LUM * 256, G_LUM * 256,B_LUM * 256, 0,  -256 * value, 
										
								R_LUM * 256, G_LUM * 256, B_LUM * 256, 0,  -256 * value, 
									
								0, 0, 0, 1, 0]; 
										
			setMatrix(mtrx);
			return this;
		}
		
		
		
		/**
		 * alpha, 0..1
		 */
		public function  alpha(value:Number):ColorAdjust 
		{
			var mtrx:Array =  [ 1, 0, 0, 0, 0,
							 0, 1, 0, 0, 0,
							 0, 0, 1, 0, 0,
							 0, 0, 0, value, 0 ];
			setMatrix(mtrx);
			return this;
		}
		/**
		 * микширование по каналам 
		 * параметры: R|G|B|A (1|2|4|8)
		 * @param	r, 1..15
		 * @param	g, 1..15
		 * @param	b, 1..15
		 * @param	a, 1..15
		 */
		public function setChannels (r:int, g:int=0, b:int=0, a:int=0 ):ColorAdjust
		{
			var rf:Number =((r & 1) == 1 ? 1:0) + ((r & 2) == 2 ? 1:0) + ((r & 4) == 4 ? 1:0) + ((r & 8) == 8 ? 1:0); 
			if (rf > 0) rf = 1 / rf;
			var gf:Number =((g & 1) == 1 ? 1:0) + ((g & 2) == 2 ? 1:0) + ((g & 4) == 4 ? 1:0) + ((g & 8) == 8 ? 1:0); 
			if (gf > 0) gf = 1 / gf;
			var bf:Number =((b & 1) == 1 ? 1:0) + ((b & 2) == 2 ? 1:0) + ((b & 4) == 4 ? 1:0) + ((b & 8) == 8 ? 1:0); 
			if (bf > 0) bf = 1 / bf;
			var af:Number =((a & 1) == 1 ? 1:0) + ((a & 2) == 2 ? 1:0) + ((a & 4) == 4 ? 1:0) + ((a & 8) == 8 ? 1:0); 
			if (af > 0) af = 1 / af;
			
			var mtrx:Array =  [
				(r & 1) == 1 ? rf:0, (r & 2) == 2 ? rf:0, (r & 4) == 4 ? rf:0, (r & 8) == 8 ? rf:0, 0,
				(g & 1) == 1 ? gf:0, (g & 2) == 2 ? gf:0, (g & 4) == 4 ? gf:0, (g & 8) == 8 ? gf:0, 0,
				(b & 1) == 1 ? bf:0, (b & 2) == 2 ? bf:0, (b & 4) == 4 ? bf:0, (b & 8) == 8 ? bf:0, 0,
				(a & 1) == 1 ? af:0, (a & 2) == 2 ? af:0, (a & 4) == 4 ? af:0, (a & 8) == 8 ? af:0, 0
			];
			
			setMatrix(mtrx);
			return this;
		}
		/////////////////////////////////////////
		/////////////////////////////////////////
		/////////////////////////////////////////
		
		private function setMatrix(mtrx:Array):void
		{
			switch(_mode)
			{
				case ADD:
					concat(mtrx);
					break;
				case CLEAR:
					_filter.matrix = mtrx;
					break;
			}
			
		}

	}
}