package nut.util
{
	import flash.geom.Vector3D;
	
	import nut.core.Float4;

	public class NutMath
	{	
		static public const RAD_2_DEG	:Number		= 180./Math.PI;
		static public const DEG_2_RAD	:Number		= Math.PI/180.;
		static public const HALF_PI		:Number		= Math.PI*0.5;
		static public const TWO_PI		:Number		= Math.PI*2.0;
		
		static public var randTable	:Vector.<Number> = null;
		static public var sinTable 	:Vector.<Number> = null;
		
		static private var _trigTableFactor:Number = 0.0;

		public static function init(randTableSize:uint=1024, trigTableSize:uint=4096) :void
		{
			randTable = new Vector.<Number>(randTableSize);

			for (var i:int = 0; i != randTableSize; ++i)
			{
				randTable[i] = Math.random();
			}

			sinTable = new Vector.<Number>(trigTableSize);
			_trigTableFactor = trigTableSize / TWO_PI;
			
			var angle:Number;
			var angleUnit:Number = 1.0 / _trigTableFactor;
			for (i = 0; i < trigTableSize; ++i)
			{
				angle =  i * angleUnit;
				sinTable.push(Math.sin(angle));
			}
		}
		
		static public function parseARGB(argb:uint):Float4
		{
			var color:Float4 = new Float4();
			
			color.a = ((argb & 0xFF000000) >>> 24) / 0xFF;
			color.r = ((argb & 0x00FF0000) >>> 16) / 0xFF;
			color.g = ((argb & 0x0000FF00) >>> 8) / 0xFF;
			color.b = (argb & 0x000000FF) / 0xFF;
			
			return color;
		}
		
		static public function random(idx:int):Number
		{			
			return randTable[idx];
		}
		
		public static function sin(fValue:Number) :Number
		{
			var idx :int;
			
			if (fValue >= 0.0)
			{
				idx = fValue * _trigTableFactor;
				idx %=  sinTable.length;
			}
			else
			{
				idx = -fValue * _trigTableFactor;
				idx %= sinTable.length;
				idx = sinTable.length - idx - 1;
			}
			
			return sinTable[idx];
		}
		
		public static function cos(fValue:Number) :Number
		{
			// Convert range to index values, wrap if required
			var val:Number = fValue + HALF_PI;
			var idx :int;
			if (val >= 0.0)
			{
				idx = val * _trigTableFactor;
				idx %=  sinTable.length;
			}
			else
			{
				idx = -val * _trigTableFactor;
				idx %= sinTable.length;
				idx = sinTable.length - idx - 1;
			}
			
			return sinTable[idx];
		}

		public static function getQFromAngleAxis(rfAngle:Number, rkAxis:Float4):Float4
		{
			var rot	:Float4 = new Float4();
			var fHalfAngle : Number = 0.5*rfAngle;
			var fSin : Number = NutMath.sin(fHalfAngle);
			
			rot.w = NutMath.cos(fHalfAngle);
			rot.x = fSin*rkAxis.x;
			rot.y = fSin*rkAxis.y;
			rot.z = fSin*rkAxis.z;
			
			return rot;
		}
	}
}