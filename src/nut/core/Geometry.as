package nut.core
{
	import flash.display3D.Context3D;
	import flash.display3D.IndexBuffer3D;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Endian;
	
	public class Geometry
	{
		static private var next_id	:uint				= 0;
		private var _id				:uint				= 0;
		private var _indexbuffer	:IndexBuffer3D		= null;
		protected var _vertexbuffer	:VertexBuffer		= null;
		protected var _indices		:ByteArray			= null;
		private var _vertexFormats	:Dictionary			= new Dictionary();
		private var _maxBones		:uint				= 0;
		
		public function Geometry(indices:ByteArray, numVertices:uint)
		{
			_id = ++next_id;
			_indices = indices;
			_vertexbuffer = new VertexBuffer(numVertices);
		}
		
		public function get indices():ByteArray
		{
			return _indices;
		}

		public function get id():uint
		{
			return _id;
		}

		public function get vertexbuffer():VertexBuffer
		{
			return _vertexbuffer;
		}

		public function get maxBones():uint
		{
			return _maxBones;
		}

		public function set maxBones(value:uint):void
		{
			_maxBones = value;
		}
		
		private function setIndexBuffer(context3D:Context3D):IndexBuffer3D
		{
			if (_indexbuffer == null)
			{
				var len:int = _indices.length >>> 1;
				_indexbuffer = context3D.createIndexBuffer(len);
				_indexbuffer.uploadFromByteArray(_indices, 0, 0, len);
			}
			
			return _indexbuffer;
		}
		
		public function draw(context3D:Context3D):void
		{
			var indexBuffer:IndexBuffer3D = setIndexBuffer(context3D);
			
			context3D.drawTriangles(indexBuffer);
		}
		
		public function dispose():void
		{
			if (_indexbuffer != null)
				_indexbuffer.dispose();
			
			_vertexbuffer.dispose();
			_indices.clear();
		}
		
		public function encode(data:ByteArray):void
		{
			data.writeShort(_vertexbuffer.numVertices);
			data.writeUnsignedInt(_indices.length);
			data.writeBytes(_indices);
			data.writeByte(_maxBones);
			_vertexbuffer.encode(data);
		}
		
		static public function decode(data:ByteArray):Geometry
		{
			var numVertices:uint = data.readUnsignedShort();
			var len:uint = data.readUnsignedInt();
			var indices:ByteArray = new ByteArray();
			indices.endian = Endian.LITTLE_ENDIAN;
			data.readBytes(indices, 0, len);
			
			var geom:Geometry = new Geometry(indices, numVertices);
			geom.maxBones = data.readUnsignedByte();
			geom._vertexbuffer.decode(data);
			
			return geom;
		}
	}
}