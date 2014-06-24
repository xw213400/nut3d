package nut.util.shaders
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	
	import nut.core.Mesh;
	import nut.core.Nut;
	import nut.core.NutScene;
	import nut.core.NutTexture;
	import nut.core.RegState;
	import nut.core.material.RegElem;
	import nut.core.material.ShaderBase;

	public class PositionDiffuseShader extends ShaderBase
	{
		static private var _instance:PositionDiffuseShader = null;
		
		private var _uvData:RegElem;
		private var _l2wReg:RegElem;
		private var _w2sReg:RegElem;
		private var _diffuseMapReg:RegElem;
		
		public function PositionDiffuseShader()
		{
			super("PositionDiffuseShader");
			
			data.addProperty('diffuseMap', Nut.resMgr.getTexture('default'));
		}
		
		public static function get instance():PositionDiffuseShader
		{
			if (_instance == null)
				_instance = new PositionDiffuseShader();
			
			return _instance;
		}

		override protected function getVertexCode():String
		{
			//这里登记寄存器需求  property -> regElem
			var pos		:RegElem = this.regCache.getVA('position', 1);
			var uv		:RegElem = this.regCache.getVA('uv', 1);
			var temp	:RegElem = this.regCache.getVT();
			_l2wReg = this.regCache.getVC(4);
			_w2sReg = this.regCache.getVC(4);
			var op:RegElem = this.regCache.getOP();
			
			_uvData = this.regCache.getV();
			
			//////////////////////////////////
			temp.o = m44(pos.o, _l2wReg.o);
			op.o = m44(temp.o, _w2sReg.o);
			_uvData.o = mov(uv.o);
			
			trace(regCache.vertexCode);
			
			return regCache.vertexCode;
		}
		
		override protected function getFragmentCode():String
		{
			regCache.switchCode();
			
			_diffuseMapReg = this.regCache.getFS();
			var diffuseColor:RegElem = this.regCache.getFT();
			var oc:RegElem = this.regCache.getOC();
			
			////////////////////////////////////
			diffuseColor.o = tex(_uvData.xy, _diffuseMapReg.o, "<2d,repeat,linear,miplinear>");
			oc.o = mov(diffuseColor.o);
			
			trace(regCache.fragmentCode);
			
			return regCache.fragmentCode;
		}
		
		override public function render(mesh:Mesh):void
		{
			var scene:NutScene = Nut.scene;
			var context:Context3D = scene.context3D;
			
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, _l2wReg.id, mesh.localToWorld, true);
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, _w2sReg.id, scene.camera.worldToScreen, true);
			var texture:NutTexture = mesh.material.getTexture(this.name, 'diffuseMap');
			RegState.setTextureAt(_diffuseMapReg.id, texture);
			
			RegState.clear(regCache.va_next, regCache.fs_next);
			mesh.geometry.draw(context);
		}
	}
}