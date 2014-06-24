package nut.core
{
	import flash.utils.Dictionary;
	
	import nut.core.material.ShaderBase;
	import nut.enum.PassType;

	public class PassBase
	{
		static private var passes:Dictionary = new Dictionary();
		
		protected var _shader	:ShaderBase		= null;
		protected var _setting	:RenderSetting	= null;
		protected var _passType	:uint			= PassType.INVALID;

		static public function getPass(passType:uint, meshId:uint, shader:ShaderBase, setting:RenderSetting=null):PassBase
		{
			var id:uint = 0;
			var pass:PassBase = null;
			
			if (passType == PassType.DEPTHSORT)
			{
				id = (passType<<24) | meshId;
				pass = passes[id];
				
				if (pass == null)
				{
					if (setting == null)
						setting = shader.defaultSetting;
					
					pass = new DepthPass(0, shader, setting.clone());
					passes[id] = pass; 
				}
				else
				{
					pass.shader = shader;
					if (setting != null && pass.setting != setting)
						pass.setting = setting;
				}
			}
			else
			{
				if (setting == null)
					setting = shader.defaultSetting;
				
				id = (passType<<24) | shader.id | setting.id;
				
				pass = passes[id];
				
				if (pass == null)
				{
					pass = new Pass(passType, shader, setting);
					passes[id] = pass; 
				}
			}
			
			return pass;
		}
		
		public function PassBase(passType:uint, shader:ShaderBase, setting:RenderSetting)
		{
			_passType = passType;
			_shader = shader;
			_setting = setting;
		}
		
		public function set setting(value:RenderSetting):void
		{
			_setting = value;
		}
		
		public function set shader(value:ShaderBase):void
		{
			_shader = value;
		}
		
		public function get passType():uint
		{
			return _passType;
		}
		
		public function set passType(value:uint):void
		{
			_passType = value;
		}
		
		public function get shader():ShaderBase
		{
			return _shader;
		}
		
		public function get setting():RenderSetting
		{
			return _setting;
		}
		
		public function addMesh(mesh:Mesh):Boolean
		{
			throw new Error('Abstract method was called!');
		}
		
		public function removeMesh(mesh:Mesh):Boolean
		{
			throw new Error('Abstract method was called!');
		}
		
		public function render():void
		{
			throw new Error('Abstract method was called!');
		}
	}
}