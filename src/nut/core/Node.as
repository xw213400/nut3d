package nut.core
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;

	public class Node
	{
		protected var _transform		:Matrix3D		= new Matrix3D();
		private var _localToWorld	:Matrix3D		= new Matrix3D();
		private var _parent			:Node			= null;
		private var _children		:Vector.<Node>	= new Vector.<Node>();
		protected var _localToWorldDirty	:Boolean	= false;
		private var _visible		:Boolean 		= true;
		private var _pickMask		:uint			= 0;
		
		public function Node()
		{
		}

		public function get pickMask():uint
		{
			return _pickMask;
		}

		public function set pickMask(value:uint):void
		{
			_pickMask = value;
			
			var len:int = _children.length;
			for (var i :int = 0; i != len; ++i)
			{
				_children[i].pickMask = value;
			}
		}

		public function get visible():Boolean
		{
			return _visible;
		}

		public function set visible(value:Boolean):void
		{
			_visible = value;
			
			var len:int = _children.length;
			for (var i :int = 0; i != len; ++i)
			{
				_children[i].visible = value;
			}
		}

		public function set transform(value:Matrix3D):void
		{
			_transform.copyFrom(value);
			localToWorldDirty();
		}

		public function get localToWorld():Matrix3D
		{
			if (_localToWorldDirty)
			{
				rebuildLocalToWorld();
			}
			
			return _localToWorld;
		}

		public function get parent():Node
		{
			return _parent;
		}

		public function set parent(value:Node):void
		{
			if (_parent != value)
				localToWorldDirty();
			
			_parent = value;
		}

		public function get position():Vector3D
		{
			return _transform.position;
		}
		
		public function get x():Number
		{
			return _transform.position.x;
		}
		
		public function get y():Number
		{
			return _transform.position.y;
		}
		
		public function get z():Number
		{
			return _transform.position.z;
		}
		
		public function getRotation(orientationStyle:String="eulerAngles"):Vector3D
		{
			return _transform.decompose(orientationStyle)[1];
		}
		
		public function get scale():Vector3D
		{
			return _transform.decompose()[2];
		}
		
		public function get derivedPosition():Vector3D
		{
			if (_localToWorldDirty)
			{
				rebuildLocalToWorld();
			}
			
			return _localToWorld.position;
		}
		
		public function getDerivedRotation(orientationStyle:String="eulerAngles"):Vector3D
		{
			if (_localToWorldDirty)
			{
				rebuildLocalToWorld();
			}
			
			return _localToWorld.decompose(orientationStyle)[1];
		}
		
		public function get derivedScale():Vector3D
		{
			if (_localToWorldDirty)
			{
				rebuildLocalToWorld();
			}
			
			return _localToWorld.decompose()[2];
		}
		
		public function set position(value:Vector3D):void
		{
			_transform.position = value;
			
			localToWorldDirty();
		}
		
		public function setRotation(value:Vector3D, orientationStyle:String="eulerAngles"):void
		{
			var component :Vector.<Vector3D> = _transform.decompose(orientationStyle);
			component[1] = value;
			_transform.recompose(component, orientationStyle);
			
			localToWorldDirty();
		}
		
		public function set scale(value:Vector3D):void
		{
			var component :Vector.<Vector3D> = _transform.decompose();
			component[2] = value;
			_transform.recompose(component);
			
			localToWorldDirty();
		}
		
		public function set derivedPosition(value:Vector3D):void
		{
			_localToWorld.position = value;
			
			_transform.copyFrom(_parent.localToWorld);
			_transform.invert();
			_transform.prepend(_localToWorld);
			
			notifyChildLoacalToWorldDirty();
		}
		
		public function setDerivedRotation(value:Vector3D, orientationStyle:String="eulerAngles"):void
		{
			var component :Vector.<Vector3D> = _localToWorld.decompose(orientationStyle);
			component[1] = value;
			_localToWorld.recompose(component, orientationStyle);
			
			_transform.copyFrom(_parent.localToWorld);
			_transform.invert();
			_transform.prepend(_localToWorld);
			
			notifyChildLoacalToWorldDirty();
		}
		
		public function set derivedScale(value:Vector3D):void
		{
			var component :Vector.<Vector3D> = _localToWorld.decompose();
			component[2] = value;
			_localToWorld.recompose(component);
			
			_transform.copyFrom(_parent.localToWorld);
			_transform.invert();
			_transform.prepend(_localToWorld);
			
			notifyChildLoacalToWorldDirty();
		}

		public function get children():Vector.<Node>
		{
			return _children;
		}
		
		private function rebuildLocalToWorld():void
		{
			_localToWorld.copyFrom(_transform);
			if (_parent != null)
				_localToWorld.append(_parent.localToWorld);
			
			_localToWorldDirty = false;
		}

		public function addChild(node:Node):void
		{
			if (_children.indexOf(node) == -1)
			{
				_children.push(node);
				node.parent = this;
			}
		}
		
		public function removeChild(node:Node):void
		{
			var idx:int = _children.indexOf(node);
			if (idx != -1)
			{
				_children.splice(idx, 1);
				node.parent = null;
			}
		}
		
		protected function localToWorldDirty():void
		{
			_localToWorldDirty = true;
			
			var len:int = _children.length;
			for (var i :int = 0; i != len; ++i)
			{
				_children[i].localToWorldDirty();
			}
		}
		
		private function notifyChildLoacalToWorldDirty():void
		{
			var len:int = _children.length;
			for (var i :int = 0; i != len; ++i)
			{
				_children[i].localToWorldDirty();
			}
		}
		
		public function appendLocalToWorldTo(matrix:Matrix3D):void
		{
			matrix.append(_localToWorld);
		}
	}
}