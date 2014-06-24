package nut.core.material
{
	import com.adobe.utils.AGALMiniAssembler;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Program3D;
	import flash.geom.Matrix3D;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import nut.core.Geometry;
	import nut.core.Mesh;
	import nut.core.Nut;
	import nut.core.NutCamera;
	import nut.core.RegState;
	import nut.core.RenderSetting;
	import nut.enum.PassType;

	public class ShaderBase extends Expression
	{
		static private var next_id		:int = 0;
		static private var assembler	:AGALMiniAssembler = new AGALMiniAssembler();
		static private var matrix		:Matrix3D = new Matrix3D();
		
		protected var _defaultSetting	:RenderSetting;
		
		private var _passType		:uint;
		private var _name			:String;
		private var _program		:Program3D;
		private var _regCache		:RegCache		= new RegCache();
		private var _id				:int			= 0;
		private var _data			:DataProvider	= new DataProvider();
		protected var _needSave		:Boolean		= false;
		
		public function ShaderBase(name:String, passType:uint=PassType.OPAQUE)
		{
			super();
			_passType = passType;
			_id = next_id++;
			_name = name;
			_defaultSetting = new RenderSetting();
		}

		public function get needSave():Boolean
		{
			return _needSave;
		}

		public function get data():DataProvider
		{
			return _data;
		}

		public function get passType():uint
		{
			return _passType;
		}

		public function get defaultSetting():RenderSetting
		{
			return _defaultSetting;
		}

		public function get id():int
		{
			return _id;
		}

		public function get regCache():RegCache
		{
			return _regCache;
		}

		public function get name():String
		{
			return _name;
		}

		protected function getVertexCode():String
		{
			throw new Error('Abstract method was called!');
		}
		
		protected function getFragmentCode():String
		{
			throw new Error('Abstract method was called!');
		}
		
		public function apply():void
		{
			var context:Context3D = Nut.scene.context3D;
			
			if (_program == null)
			{
				_program = context.createProgram();
				
				var vStr:String = getVertexCode();
				var vcode:ByteArray = assembler.assemble(Context3DProgramType.VERTEX, vStr);
				
				var fStr:String = getFragmentCode();
				var fcode:ByteArray = assembler.assemble(Context3DProgramType.FRAGMENT, fStr);
				
				trace("------",name,"------");
				trace(vStr);
				trace(fStr);
				
				_program.upload(vcode, fcode);
			}
			
			context.setProgram(_program);
		}
		
		public function render(mesh:Mesh):void
		{
			throw new Error('Abstract method "ShaderBase.render" was called!');
		}
		
		public function setupVertexAttribute(geom:Geometry):void
		{
			if (RegState.setGeometry(this, geom))
			{
				var regs:Dictionary = regCache.vaProps;
				for (var name:String in regs)
				{
					geom.vertexbuffer.setupVertexBuffer(name, regs[name].id);
				}
			}
		}
		
		protected function getLocalToScreen(camera:NutCamera, mesh:Mesh):Matrix3D
		{
			matrix.copyFrom(mesh.localToWorld);
			matrix.append(camera.worldToScreen);
			
			return matrix;
		}
		
		protected function getLocalToView(camera:NutCamera, mesh:Mesh):Matrix3D
		{
			matrix.copyFrom(mesh.localToWorld);
			matrix.append(camera.worldToView);
			
			return matrix;
		}

//		protected function setupTexture(material:Material):void
//		{
//			var regs:Dictionary = regCache.fsProps;
//			
//			for (var key:String in regs)
//			{
//				var texture:NutTexture = material.getTexture(this.name, key);
//				var reg:RegElem = regs[key];
//				
//				RegState.setTextureAt(reg.id, texture);
//			}
//		}
	}
}