package nut.core
{
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	
	import nut.util.NutMath;

	public class Float4
	{
		public static const IDENTITY:Float4 = new Float4(0, 0, 0, 1);
		
		public static const X_AXIS	:Float4	= new Float4(1, 0, 0, 1);
		public static const Y_AXIS	:Float4	= new Float4(0, 1, 0, 1);
		public static const Z_AXIS	:Float4	= new Float4(0, 0, 1, 1);
		public static const ONE		:Float4	= new Float4(1, 1, 1, 1);
		public static const ZERO	:Float4	= new Float4(0, 0, 0, 0);
		
		public static const WHITE	:Float4	= ONE;
		public static const BLACK	:Float4	= IDENTITY;
		public static const RED		:Float4	= X_AXIS;
		public static const GREEN	:Float4	= Y_AXIS;
		public static const BLUE	:Float4	= Z_AXIS;
		
		private static var TEMP1	:Float4	= new Float4();
		private static var TEMP2	:Float4	= new Float4();
		private static var TEMP3	:Float4	= new Float4();
		
		public var data:Vector.<Number> = new Vector.<Number>(4);
		
		public function Float4(x:Number=0, y:Number=0, z:Number=0, w:Number=1)
		{
			data[0] = x;
			data[1] = y;
			data[2] = z;
			data[3] = w;
		}
		
		public function set x(value:Number):void
		{
			data[0] = value;
		}
		
		public function get x():Number
		{
			return data[0];
		}
		
		public function set y(value:Number):void
		{
			data[1] = value;
		}
		
		public function get y():Number
		{
			return data[1];
		}
		
		public function set z(value:Number):void
		{
			data[2] = value;
		}
		
		public function get z():Number
		{
			return data[2];
		}
		
		public function set w(value:Number):void
		{
			data[3] = value;
		}
		
		public function get w():Number
		{
			return data[3];
		}
		
		public function set r(value:Number):void
		{
			data[0] = value;
		}
		
		public function get r():Number
		{
			return data[0];
		}
		
		public function set g(value:Number):void
		{
			data[1] = value;
		}
		
		public function get g():Number
		{
			return data[1];
		}
		
		public function set b(value:Number):void
		{
			data[2] = value;
		}
		
		public function get b():Number
		{
			return data[2];
		}
		
		public function set a(value:Number):void
		{
			data[3] = value;
		}
		
		public function get a():Number
		{
			return data[3];
		}
		
		public function clone():Float4
		{
			return new Float4(data[0], data[1], data[2], data[3]);
		}
		
		public function toString():String
		{
			return x.toPrecision(5)+" ,"+y.toPrecision(5)+" ,"+z.toPrecision(5)+" ,"+w.toPrecision(5);
		}
		
		public function toVector3D():Vector3D
		{
			return new Vector3D(x, y, z, w);
		}
		
		public function copyV3D(v:Vector3D):void
		{
			x = v.x;
			y = v.y;
			z = v.z;
			w = v.w;
		}
		
		public function negate():void
		{
			x = -x;
			y = -y;
			z = -z;
		}
		
		public function copy(v:Float4):void
		{
			x = v.x;
			y = v.y;
			z = v.z;
			w = v.w;
		}
		
		public function addBy(v:Float4):void
		{
			x += v.x;
			y += v.y;
			z += v.z;
		}
		
		public function scaleBy(s:Number):void
		{
			x *= s;
			y *= s;
			z *= s;
		}
		
		public function mutiplyBy(v:Float4):void
		{
			x *= v.x;
			y *= v.y;
			z *= v.z;
		}
		
		public function crossProduct(v:Float4):Float4
		{
			TEMP1.x = y*v.z - z*v.y;
			TEMP1.y = z*v.x - x*v.z;
			TEMP1.z = x*v.y - y*v.x;
			
			return TEMP1.clone();
		}
		
		public function rotBy(q:Float4):void
		{
			// nVidia SDK implementation
			TEMP2.copy(q);						//TEMP2 qvec
			TEMP3.copy(q.crossProduct(this));	//TEMP3 uv
			TEMP2.crossProduct(TEMP3);			//TEMP1 uuv
			TEMP3.scaleBy(2.0*q.w);
			TEMP1.scaleBy(2.0);
			
			addBy(TEMP3);
			addBy(TEMP1);
		}
		
		public function perpendicular():Float4
		{
			var fSquareZero:Number = 1e-12;
			
			crossProduct(X_AXIS);

			// Check length
			var lensq:Number = TEMP1.squareLength();
			if (TEMP1.isZeroLength())
			{
				crossProduct(Y_AXIS);
			}
			
			TEMP1.normalize();
			
			return TEMP1.clone();
		}
		
		public function squareLength():Number
		{
			return x*x + y*y + z*z;
		}
		
		public function length():Number
		{
			return Math.sqrt(squareLength());
		}
		
		public function normalize():Number
		{
			var len:Number = length();
			
			if(len > 0.0)
			{
				var invLen:Number = 1.0/len;
				x *= invLen;
				y *= invLen;
				z *= invLen;
			}
			
			return len;
		}
		
		public function dotProduct(v:Float4) :Number
		{
			return x*v.x + y*v.y +z*v.z;
		}
		
		public function isZeroLength():Boolean
		{
			var sqlen:Number = squareLength();
			return sqlen < 1e-12;
		}
		
		public function getRotation(v:Float4):Float4
		{
			// Copy, since cannot modify local
			TEMP1.copy(this);
			TEMP2.copy(v);
			TEMP1.normalize();
			TEMP2.normalize();
			
			var d : Number = TEMP1.dotProduct(TEMP2);
			
			if (d >= 1.0)
			{
				return IDENTITY.clone();
			}
			
			if (d < ((1e-6)-1.0))
			{
				var axis:Float4 = X_AXIS.crossProduct(TEMP1);
				if (axis.isZeroLength()) // pick another if colinear
					axis = Y_AXIS.crossProduct(TEMP1);
				
				return NutMath.getQFromAngleAxis(Math.PI, axis);
			}
			else
			{
				var s : Number = Math.sqrt( (1+d)*2 );
				var invs : Number = 1 / s;
				
				var c:Float4 = TEMP1.crossProduct(TEMP2);
				
				TEMP1.x = c.x*invs;
				TEMP1.y = c.y*invs;
				TEMP1.z = c.z*invs;
				TEMP1.w = s*0.5;
				
				return TEMP1.clone();
			}
		}
		
		public function saturate() :void
		{
			if (r < 0)
				r = 0;
			else if (r > 1)
				r = 1;
			
			if (g < 0)
				g = 0;
			else if (g > 1)
				g = 1;
			
			if (b < 0)
				b = 0;
			else if (b > 1)
				b = 1;
			
			if (a < 0)
				a = 0;
			else if (a > 1)
				a = 1;
		}
		
		public function add4By(c:Float4) :void
		{
			r += c.r;
			g += c.g;
			b += c.b;
			a += c.a;
		}
		
		public function sub4By(c:Float4) :void
		{
			r -= c.r;
			g -= c.g;
			b -= c.b;
			a -= c.a;
		}
		
		public function getAsARGB():uint
		{
			var val8	:uint = 0;
			var val32	:uint = 0;
			
			// Alpha
			val8 = a * 255;
			val8 &= 0xFF;
			val32 |= (val8 << 24);
			
			// Red
			val8 = r * 255;
			val8 &= 0xFF;
			val32 |= (val8 << 16);
			
			// Green
			val8 = g * 255;
			val8 &= 0xFF;
			val32 |= (val8 << 8);
			
			// Blue
			val8 = b * 255;
			val8 &= 0xFF;
			val32 |= val8;
			
			return val32;
		}
		
		public function encode(data:ByteArray):void
		{
			data.writeFloat(x);
			data.writeFloat(y);
			data.writeFloat(z);
			data.writeFloat(w);
		}
		
		static public function decode(data:ByteArray):Float4
		{
			return new Float4(data.readFloat(),data.readFloat(),data.readFloat(),data.readFloat());
		}
	}
}