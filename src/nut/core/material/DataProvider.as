package nut.core.material
{
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import nut.core.Float4;
	import nut.core.NutTexture;

	public class DataProvider
	{
		protected var _properties :Dictionary = new Dictionary();
		
		public function DataProvider()
		{
		}
		
		public function get properties():Dictionary
		{
			return _properties;
		}

		/**
		 * 设置Shader属性 
		 * @param name		属性名称
		 * @param value		属性值
		 */		
		public function addProperty(name:String, value:Object):Boolean
		{
			var prop:Property = _properties[name];
			
			if (prop == null)
			{
				prop = new Property(name, value);
				_properties[name] = prop;
				
				return true;
			}
			
			return false;
		}
		
		public function getProperty(name:String):Property
		{
			return _properties[name];
		}
		
		public function removeProperty(name:String):Boolean
		{
			var prop:Property = _properties[name];
			
			if (prop != null)
			{
				delete _properties[name];
				
				return true;
			}
			
			return false;
		}
		
		public function getFloat4(name:String):Float4
		{
			return getProperty(name).value as Float4;
		}
		
		public function getNumber(name:String):Number
		{
			return getProperty(name).value as Number;
		}
		
		public function getTexture(name:String):NutTexture
		{
			return getProperty(name).value as NutTexture;
		}
		
		public function getInt(name:String):int
		{
			return getProperty(name).value as int;
		}
		
		public function clear():void
		{
			_properties = new Dictionary();
		}
		
		public function clone():DataProvider
		{
			var dp:DataProvider = new DataProvider();
			
			for (var key:String in _properties)
			{
				dp.properties[key] = _properties[key].clone();
			}
			
			return dp;
		}
		
		public function encode(data:ByteArray):void
		{
			var n:int = 0;
			for each(var property:Property in _properties)
			{
				++n;
			}
			data.writeShort(n);
			
			for each(property in _properties)
			{
				property.encode(data);
			}
		}
		
		public function decode(data:ByteArray):void
		{
			var n:int = data.readShort();
			
			for (var i:int = 0; i != n; ++i)
			{
				var prop:Property = Property.decode(data);
				_properties[prop.name] = prop;
			}
		}
		
		public function matchItemFrom(data:DataProvider):void
		{
			var key:String;
			
			for (key in _properties)
			{
				if (data.properties[key] == null)
				{
					delete _properties[key];
				}
			}
			
			for (key in data.properties)
			{
				if (_properties[key] == null)
				{
					_properties[key] = data.properties[key].clone();
				}
			}
		}
	}
}