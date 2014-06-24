package nut.core
{
	import flash.display3D.Context3D;
	
	import nut.core.light.LightBase;

	public class NutScene extends Node
	{
		private var _camera			:NutCamera			= null;
		private var _viewport		:Viewport			= null;
		private var _lights			:Vector.<LightBase>	= new Vector.<LightBase>();
		
		public function NutScene()
		{
			super();
		}

		public function set viewport(value:Viewport):void
		{
			_viewport = value;
		}

		public function set camera(value:NutCamera):void
		{
			_camera = value;
		}

		public function get viewport():Viewport
		{
			return _viewport;
		}

		public function get context3D():Context3D
		{
			return _viewport.context3D;
		}

		public function get camera():NutCamera
		{
			return _camera;
		}
		
		public function addLight(light:LightBase):Boolean
		{
			var i:int = _lights.indexOf(light);
			if (i != -1)
				return false;
			
			_lights.push(light);
			
			return true;
		}
		
		public function removeLight(light:LightBase):Boolean
		{
			var i:int = _lights.indexOf(light);
			if (i == -1)
				return false;
			
			_lights.splice(i, 1);
			
			return true;
		}
		
		public function render():Boolean
		{
			if (_camera == null)
				return false;
			
			RegState.reset();
			
			for each (var light:LightBase in _lights)
			{
				if (light.castShadow)
				{
					light.renderShadowMap();
				}
			}
			
			prepareVisibleMeshes(_camera.frustum);

			RenderQueue.instance.render();
			
			return true;
		}

		/**
		 * @brief 视锥裁剪。
		 * @param[in] camera
		 * 
		 */		
		private function prepareVisibleMeshes(frustum:Frustum):void
		{
			findVisibleMesh(this, frustum);
		}
		
		public function findVisibleMesh(node:Node, frustum:Frustum):void
		{
			var nodes :Vector.<Node> = node.children;
			
			for each (var n :Node in nodes)
			{
				if (n.visible)
				{
					if (n is Mesh)
					{}
					else
						findVisibleMesh(n, frustum);
				}
			}
		}
	}
}