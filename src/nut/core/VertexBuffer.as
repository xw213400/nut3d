package nut.core
{
	import flash.display3D.VertexBuffer3D;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Endian;

	public class VertexBuffer
	{
		private var _numVertices	:uint			= 0;
		private var _buffer3D		:VertexBuffer3D	= null;
		private var _dataDirty		:Boolean		= false;
		private var _vertices		:ByteArray		= null;
		private var _components		:Dictionary		= null;
		private var _size			:uint			= 0;
		
		public function VertexBuffer(numVertices:uint)
		{
			_numVertices = numVertices;
			_components = new Dictionary();
		}
		
		public function get numVertices():uint
		{
			return _numVertices;
		}

		public function get size():uint
		{
			return _size;
		}

		public function set dataDirty(value:Boolean):void
		{
			_dataDirty = value;
		}

		public function get vertices():ByteArray
		{
			return _vertices;
		}
		
		public function init(verts:ByteArray, comps:Array):void
		{
			var n:int = comps.length;
			for (var i:int = 0; i != n; ++i)
			{
				var comp:VertexComponent = comps[i];
				
				_components[comp.name] = comp;
				comp.stride = _size;
				_size += comp.size;
			}
			
			_vertices = verts;
		}

		public function addComponent(name:String, format:String, verts:ByteArray):Boolean
		{
			if (_components[name] != null)
				return false;
			
			var component:VertexComponent = new VertexComponent(name, format);
			
			_components[component.name] = component;
			component.stride = _size;
			_size += component.size;
			
			var oldData:ByteArray = _vertices;
			
			_vertices = new ByteArray();
			_vertices.endian = Endian.LITTLE_ENDIAN;
			
			if (oldData == null)
			{
				for (var i:int = 0; i != _numVertices; ++i)
				{
					_vertices.writeBytes(verts, i*component.size*4, component.size*4);
				}
			}
			else
			{
				for (i = 0; i != _numVertices; ++i)
				{
					_vertices.writeBytes(oldData, i*component.stride*4, component.stride*4);
					_vertices.writeBytes(verts, i*component.size*4, component.size*4);
				}
				
				oldData.clear();
			}
			
			return true;
		}
		
		public function addComponentFromFloats(name:String, format:String, verts:Vector.<Number>):Boolean
		{
			if (_components[name] != null)
				return false;
			
			var component:VertexComponent = new VertexComponent(name, format);
			
			_components[component.name] = component;
			component.stride = _size;
			_size += component.size;
			
			var oldData:ByteArray = _vertices;
			_vertices = new ByteArray();
			_vertices.endian = Endian.LITTLE_ENDIAN;
			
			if (oldData == null)
			{
				for (var i:int = 0; i != _numVertices; ++i)
				{
					var idx:int = i*component.size;
					for (var j:int = 0; j != component.size; ++j)
					{
						_vertices.writeFloat(verts[idx+j]);
					}
				}
			}
			else
			{
				for (i = 0; i != _numVertices; ++i)
				{
					_vertices.writeBytes(oldData, i*component.stride*4, component.stride*4);
					
					idx = i*component.size;
					for (j = 0; j != component.size; ++j)
					{
						_vertices.writeFloat(verts[idx+j]);
					}
				}
				
				oldData.clear();
			}
			
			return true;
		}
		
		public function getComponent(name:String):VertexComponent
		{
			return _components[name];
		}
		
		private function setup():VertexBuffer3D
		{
			if (_buffer3D == null)
			{
				_buffer3D = Nut.scene.context3D.createVertexBuffer(_numVertices, _size);
				_buffer3D.uploadFromByteArray(_vertices, 0, 0, _numVertices);
			}
			else if (_dataDirty)
			{
				_dataDirty = false;
				_buffer3D.uploadFromByteArray(_vertices, 0, 0, _numVertices);
			}
			
			return _buffer3D;
		}
		
		public function setupVertexBuffer(name:String, regId:int):Boolean
		{
			var component:VertexComponent = _components[name];
			if (component == null)
				return false;
			
			setup();
			Nut.scene.context3D.setVertexBufferAt(regId, _buffer3D, component.stride, component.format);
			
			return true;
		}
		
		public function dispose():void
		{
			if (_buffer3D != null)
				_buffer3D.dispose();
			
			_vertices.clear();
		}
		
		public function encode(data:ByteArray):void
		{
			var n:int = 0;
			for each (var comp:VertexComponent in _components)
			{
				n++;
			}
			data.writeByte(n);
			
			for each (comp in _components)
			{
				comp.encode(data);
			}
			
			data.writeUnsignedInt(_vertices.length);
			data.writeBytes(_vertices);
		}
		
		public function decode(data:ByteArray):void
		{
			var n:int = data.readUnsignedByte();
			
			for (var i:int = 0; i != n; ++i)
			{
				var comp:VertexComponent = VertexComponent.decode(data);
				
				_components[comp.name] = comp;
				_size += comp.size;
			}
			
			var len:uint = data.readUnsignedInt();
			_vertices = new ByteArray();
			_vertices.endian = Endian.LITTLE_ENDIAN;
			data.readBytes(_vertices, 0, len);
		}
	}
}