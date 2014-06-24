package nut.core
{
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.utils.ByteArray;

	public class VertexComponent
	{
		private var _name	:String	= null;
		private var _format	:String = null;
		private var _size	:uint	= 0;
		private var _stride	:uint	= 0;
		
		public function VertexComponent(name:String, format:String)
		{
			_name = name;
			_format = format;
			
			if (_format == Context3DVertexBufferFormat.FLOAT_1)
			{
				_size = 1;
			}
			else if (_format == Context3DVertexBufferFormat.FLOAT_2)
			{
				_size = 2;
			}
			else if (_format == Context3DVertexBufferFormat.FLOAT_3)
			{
				_size = 3;
			}
			else if (_format == Context3DVertexBufferFormat.FLOAT_4)
			{
				_size = 4;
			}
			else if (_format == Context3DVertexBufferFormat.BYTES_4)
			{
				_size = 1;
			}
		}

		public function get size():uint
		{
			return _size;
		}

		public function get stride():uint
		{
			return _stride;
		}

		public function set stride(value:uint):void
		{
			_stride = value;
		}

		public function get format():String
		{
			return _format;
		}

		public function get name():String
		{
			return _name;
		}
		
		public function encode(data:ByteArray):void
		{
			data.writeUTF(_name);
			data.writeUTF(_format);
			data.writeByte(_stride);
		}
		
		static public function decode(data:ByteArray):VertexComponent
		{
			var comp:VertexComponent = new VertexComponent(data.readUTF(), data.readUTF());
			comp.stride = data.readByte();
			
			return comp;
		}
	}
}