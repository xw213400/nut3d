package nut.core
{
	import nut.core.material.ShaderBase;
	import nut.enum.PassType;

	public class Pass extends PassBase
	{	
		private var _id			:uint			= 0;
		private var _meshes		:Vector.<Mesh>	= new Vector.<Mesh>();
		
		public function Pass(passType:uint, shader:ShaderBase, setting:RenderSetting)
		{
			super(passType, shader, setting);
		
			_id = (passType<<24) | shader.id | setting.id;
		}
		
		public function get id():uint
		{
			return _id;
		}

		public function set id(value:uint):void
		{
			_id = value;
		}

		override public function addMesh(mesh:Mesh):Boolean
		{
			if (_meshes.indexOf(mesh) != -1)
				return false;
			
			var n:int = _meshes.length;
			
			if (n == 0)
			{
				RenderQueue.instance.notifyActive(this);
				_meshes.push(mesh);
			}
			else
			{
				var inserted:Boolean = false;
				var id:uint = mesh.geometry.id;
				
				for (var i:int = 0; i != n; ++i)
				{
					if (id <= _meshes[i].geometry.id)
					{
						_meshes.splice(i, 0, mesh);
						inserted = true;
						break;
					}
				}
				
				if (!inserted)
					_meshes.push(mesh);
			}
			
			return true;
		}
		
		override public function removeMesh(mesh:Mesh):Boolean
		{
			var idx:int = _meshes.indexOf(mesh);
			if (idx == -1)
				return false;
			
			_meshes.splice(idx, 1);
			
			if (_meshes.length == 0)
				RenderQueue.instance.notifyFree(this);
			
			return true;
		}
		
		override public function render():void
		{
			var mesh:Mesh;
			var i:int;
			var n:int;
			
			if (_passType == PassType.PICK)
			{
				_setting.apply()
				_shader.apply();
				
				n = _meshes.length;
				for (i = 0; i != n; ++i)
				{
					mesh = _meshes[i];
					if (mesh.visible && (mesh.pickMask & PickController.instance.pickMask)>0)
					{
						shader.setupVertexAttribute(mesh.geometry);
						shader.render(mesh);
					}
				}
			}
			else
			{
				_setting.apply()
				_shader.apply();
				
				n = _meshes.length;
				for (i = 0; i != n; ++i)
				{
					mesh = _meshes[i];
					if (mesh.visible)
					{
						shader.setupVertexAttribute(mesh.geometry);
						shader.render(mesh);
					}
				}
			}
		}
	}
}