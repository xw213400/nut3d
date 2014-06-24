package nut.util.shaders
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.geom.Vector3D;
	
	import nut.core.Float4;
	import nut.core.Mesh;
	import nut.core.Nut;
	import nut.core.NutScene;
	import nut.core.RegState;
	import nut.core.material.RegElem;
	import nut.core.material.ShaderBase;
	
	public class PositionColorShader extends ShaderBase
	{
		static private var _instance:PositionColorShader = null;

		private var _l2sReg:RegElem;
		private var _colorReg :RegElem
		
		public function PositionColorShader()
		{
			super("PositionColorShader");
			
			data.addProperty('color', new Float4(1, 1, 1, 1));
		}
		
		public static function get instance():PositionColorShader
		{
			if (_instance == null)
				_instance = new PositionColorShader();
			
			return _instance;
		}
		
		override protected function getVertexCode():String
		{
			//这里登记寄存器需求  property -> regElem
			var pos		:RegElem = this.regCache.getVA('position', 1);
			_l2sReg = this.regCache.getVC(4);
			var op:RegElem = this.regCache.getOP();
			
			//////////////////////////////////
			op.o = m44(pos.o, _l2sReg.o);
			
			return regCache.vertexCode;
		}
		
		override protected function getFragmentCode():String
		{
			regCache.switchCode();
			
			_colorReg = this.regCache.getFC(1);
			var oc:RegElem = this.regCache.getOC();
			
			////////////////////////////////////
			oc.o = mov(_colorReg.o);
			
			return regCache.fragmentCode;
		}
		
		override public function render(mesh:Mesh):void
		{
			var scene:NutScene = Nut.scene;
			var context:Context3D = scene.context3D;
			
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, _l2sReg.id, getLocalToScreen(scene.camera, mesh), true);
			
			var cv:Float4 = mesh.material.getFloat4(this.name, 'color');
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, _colorReg.id, cv.data, 1);
			
			RegState.clear(regCache.va_next, regCache.fs_next);
			mesh.geometry.draw(scene.context3D);
		}
	}
}

