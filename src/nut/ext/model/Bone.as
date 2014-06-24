package nut.ext.model
{
	import flash.geom.Matrix3D;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	public class Bone
	{
		private var _name				:String		= "";
		private var _children			:Dictionary = new Dictionary();
		private var _parent				:Bone		= null;
		private var _transform			:Matrix3D	= new Matrix3D();
		private var _invBindMatrix		:Matrix3D	= null;
		private var _localToWrapper		:Matrix3D	= new Matrix3D();
		private var _matrix				:Matrix3D	= new Matrix3D();
		private var _localToWorldDirty	:Boolean	= true;
		
		public function Bone()
		{
		}
		
		public function set invBindMatrix(value:Matrix3D):void
		{
			_invBindMatrix = value;
		}

		public function get invBindMatrix():Matrix3D
		{
			return _invBindMatrix;
		}

		public function set localToWrapper(value:Matrix3D):void
		{
			if (_localToWrapper != value)
			{
				_localToWrapper.copyFrom(value);
				_localToWorldDirty = true;
			}
		}

		public function get matrix():Matrix3D
		{
			return _matrix;
		}

		public function get localToWrapper():Matrix3D
		{
			return _localToWrapper;
		}

		public function get children():Dictionary
		{
			return _children;
		}

		public function get transform():Matrix3D
		{
			return _transform;
		}

		public function set transform(value:Matrix3D):void
		{
			_transform.copyFrom(value);
		}

		public function set parent(value:Bone):void
		{
			_parent = value;
		}

		public function get name():String
		{
			return _name;
		}

		public function set name(value:String):void
		{
			_name = value;
		}

		public function addChild(bone:Bone):void
		{
			_children[bone.name] = bone;
			(bone as Bone).parent = this;
		}
		
		public function update() :void
		{
			if (_parent == null)
			{
				_localToWrapper.copyFrom(_transform);
			}
			else
			{
				_localToWrapper.copyFrom(_transform);
				_localToWrapper.append(_parent.localToWrapper);
			}
			
			if (_invBindMatrix != null)
			{
				_matrix.copyFrom(_invBindMatrix);
				_matrix.append(_localToWrapper);
			}
			
			for each (var bone:Bone in _children)
			{
				bone.update();
			}
			
			_localToWorldDirty = true;
		}
		
		public function encode(data:ByteArray):void
		{
			data.writeUTF(_name);
			
			var rawData:Vector.<Number> = _transform.rawData;
			
			for (var i:int = 0; i != 16; ++i)
				data.writeFloat(rawData[i]);
			
			var n:int = 0;
			var oldPos:uint = data.position;
			data.writeByte(0);
			
			for each (var bone:Bone in _children)
			{
				bone.encode(data);
				++n;
			}
			
			var newPos:uint = data.position;
			data.position = oldPos;
			data.writeByte(n);
			data.position = newPos;
		}
		
		public function decode(data:ByteArray):void
		{
			_name = data.readUTF();
			
			_transform.copyRawDataFrom(Vector.<Number>([
				data.readFloat(),data.readFloat(),data.readFloat(),data.readFloat(),
				data.readFloat(),data.readFloat(),data.readFloat(),data.readFloat(),
				data.readFloat(),data.readFloat(),data.readFloat(),data.readFloat(),
				data.readFloat(),data.readFloat(),data.readFloat(),data.readFloat()
			]));
			
			var n:int = data.readUnsignedByte();
			
			for (var i:int = 0; i != n; ++i)
			{
				var child:Bone = new Bone();
				
				child.decode(data);
				addChild(child);
			}
		}
	}
}