package utility
{
	import flash.display.DisplayObject;

	/**
	 * @author lisnic.tk
	 * @version 1.0.0.0
	 */
	public class GC
	{	
		// Константы Событий:
		public static const TILE_MODE:String = "TILE_MODE";
		public static const ERASE_MODE:String = "ERASE_MODE";
		public static const FILL_MODE:String = "FILL_MODE";
		public static const ARROW_MODE:String = "ARROW_MODE";
		public static const PARAMS_MODE:String = "PARAMS_MODE";
		
		// Массив тайлов
		public static var addedTilesArray:Array = [];
		// Фон
		public static var bg:DisplayObject;

		public function GC() { }
	
		//Утелиты:
			
		/*
		public static function traceAddedTilesArray():void
		{			
			for (var i:int = 0; i < addedTilesArray.length; i++) 
			{
				trace( addedTilesArray[i].width +'  ' + addedTilesArray[i].length );
			}
		}
		
		/*
		 * Возвращает массив из строки ( Трейса массива ) т.е. из [[12,3],[2,0],[5,3]]
		/*
		public static function getArrayN2FromString(wArr:int, hArr:int, introArrString:String):Array
		{
			var res:Array = [[]];
			var temp:String = '';
			var i:int = 0;
			var j:int = 0;

			for (var l:int = 0; l < introArrString.length; l++)
			{
				if (introArrString.charAt(l)in['0','1','2','3','4','5','6','7','8','9','-'])
				{
					temp +=  introArrString.charAt(l);
				}
				else
				{
					if (parseInt(temp))
					{
						res[i][j] = parseInt(temp);
						// trace('res['+i+']['+j+'] = '+res[i][j])
						temp = '';
						if (j!=(wArr-1))
						{
							j++;
						}
						else
						{
							j = 0;
							i++;
							res[i] = new Array();
						}
					}
				}
			}
			return res;
		}
		*/
		

	}

}
