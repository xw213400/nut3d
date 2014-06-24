package nut.core.light
{
	import nut.core.Mesh;
	import nut.core.NutScene;

	public class LightBase
	{
		protected var _colorR:Number 		= 1.0;
		protected var _colorG:Number 		= 1.0;
		protected var _colorB:Number 		= 1.0;
		protected var _castShadow:Boolean	= false;
		protected var _meshes:Vector.<Mesh>	= null;
		
		public function LightBase(castShadow:Boolean)
		{
			_castShadow = castShadow;
			_meshes = new Vector.<Mesh>();
		}

		public function set castShadow(value:Boolean):void
		{
			_castShadow = value;
		}

		public function get castShadow():Boolean
		{
			return _castShadow;
		}

		public function get colorB():Number
		{
			return _colorB;
		}

		public function set colorB(value:Number):void
		{
			_colorB = value;
		}

		public function get colorG():Number
		{
			return _colorG;
		}

		public function set colorG(value:Number):void
		{
			_colorG = value;
		}

		public function get colorR():Number
		{
			return _colorR;
		}

		public function set colorR(value:Number):void
		{
			_colorR = value;
		}
		
		public function addMesh(mesh:Mesh):Boolean
		{
			var i:int = _meshes.indexOf(mesh);
			if (i != -1)
				return false;
			
			if (mesh.geometry.maxBones > 0)
				_meshes.splice(0, 0, mesh);
			else
				_meshes.push(mesh);
			
			return true;
		}
		
		public function removeMesh(mesh:Mesh):Boolean
		{
			var i:int = _meshes.indexOf(mesh);
			if (i == -1)
				return false;
			
			_meshes.splice(i, 1);
			
			return true;
		}
		
		public function renderShadowMap():void
		{
			throw new Error('Abstract method was called!');
		}
	}
}