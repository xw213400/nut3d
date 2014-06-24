package nut.core.material
{
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	
	import nut.core.Float4;
	import nut.core.Nut;
	import nut.core.NutTexture;
	
	public class Property
	{
		static public const VT_TEXTURE	:int = 1;
		static public const VT_FLOAT4	:int = 2;
		static public const VT_INT		:int = 3;
		static public const VT_NUMBER	:int = 4;
		
		private var _name		:String		= null;
		private var _value		:Object		= null;
		
		public function Property(name:String, val:Object)
		{
			_name = name;
			value = val;
		}
		
		public function get name():String
		{
			return _name;
		}

		public function get value():Object
		{
			return _value;
		}

		public function set value(value:Object):void
		{
			_value = value;
		}
		
		public function clone():Property
		{
			var prop:Property;
			
			if (_value is Float4)
			{
				prop = new Property(_name, _value.clone());
			}
			else
			{
				prop = new Property(_name, _value);
			}
			
			return prop;
		}
		
		public function toString():String
		{
			return _value.toString();
		}
		
		public function encode(data:ByteArray):void
		{
			data.writeUTF(_name);
			
			if (_value is NutTexture)
			{
				data.writeByte(VT_TEXTURE);
				data.writeUTF((_value as NutTexture).name);
			}
			else if (value is Number)
			{
				data.writeByte(VT_NUMBER);
				data.writeFloat(_value as Number);
			}
			else if (value is int)
			{
				data.writeByte(VT_INT);
				data.writeInt(_value as int);
			}
			else if (value is Float4)
			{
				data.writeByte(VT_FLOAT4);
				(_value as Float4).encode(data);
			}
		}
		
		static public function decode(data:ByteArray):Property
		{
			var name:String = data.readUTF();
			var value:Object = null;
			
			var vt:int = data.readByte();
			
			if (vt == VT_TEXTURE)
			{
				value = Nut.resMgr.loadTexture(data.readUTF());
			}
			else if (vt == VT_NUMBER)
			{
				value = data.readFloat();
			}
			else if (vt == VT_INT)
			{
				value = data.readInt();
			}
			else if (vt == VT_FLOAT4)
			{
				value = Float4.decode(data);
			}
			
			return new Property(name, value);
		}
	}
}