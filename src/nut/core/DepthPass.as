package nut.core
{
	import nut.core.material.ShaderBase;
	import nut.enum.PassType;

	public class DepthPass extends PassBase
	{
		private var _mesh		:Mesh	= null;
		private var _depth		:Number = 0.0;
		private var _priority	:int	= 8;
		
		public function DepthPass(priority:int, shader:ShaderBase, setting:RenderSetting):void
		{
			super(PassType.DEPTHSORT, shader, setting);

			_priority = priority;
		}

		public function get mesh():Mesh
		{
			return _mesh;
		}

		public function get priority():int
		{
			return _priority;
		}

		public function set priority(value:int):void
		{
			_priority = value;
		}

		public function get depth():Number
		{
			return _depth;
		}

		public function set depth(value:Number):void
		{
			_depth = value;
		}
		
		override public function addMesh(mesh:Mesh):Boolean
		{
			_mesh = mesh;
			
			return RenderQueue.instance.addDepthPass(this);
		}
		
		override public function removeMesh(mesh:Mesh):Boolean
		{
			return RenderQueue.instance.removeDepthPass(this); 
		}

		override public function render():void
		{	
			if (_mesh.visible)
			{
				_setting.apply()
				_shader.apply();
				_shader.setupVertexAttribute(_mesh.geometry);
				_shader.render(_mesh);
			}
		}
	}
}