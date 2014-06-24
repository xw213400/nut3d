package nut.util.shaders
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	
	import nut.core.Mesh;
	import nut.core.Nut;
	import nut.core.NutCamera;
	import nut.core.RegState;
	import nut.core.material.RegElem;
	import nut.core.material.ShaderBase;
	import nut.enum.Culling;
	
	public class LineShader extends ShaderBase
	{
		static private var _instance:LineShader = null;
		
		private var _colorVaring:RegElem;
		static private const zAxisData:Vector.<Number> = Vector.<Number>([0,0,1,1]);
		private var _targetSizeData:Vector.<Number> = Vector.<Number>([1000,750,0,0]);
		private var _zAxis:RegElem;
		private var _targetSize:RegElem;
		private var _l2vReg:RegElem;
		private var _projectReg:RegElem;
		
		public function LineShader()
		{
			super('LineShader');

			this.defaultSetting.culling = Culling.NONE;
		}
		
		public static function get instance():LineShader
		{
			if (_instance == null)
				_instance = new LineShader();
			
			return _instance;
		}
		
		override protected function getVertexCode():String
		{
			var start:RegElem = this.regCache.getVA('start', 1);
			var end:RegElem = this.regCache.getVA('end', 1);
			var thickness:RegElem = this.regCache.getVA('thickness', 1);
			var color:RegElem = this.regCache.getVA('color', 1);
			
			_l2vReg = this.regCache.getVC(4);
			_projectReg = this.regCache.getVC(4);
			_zAxis = this.regCache.getVC(1);
			_targetSize = this.regCache.getVC(1);
			
			var vstart:RegElem = this.regCache.getVT();
			var vdir:RegElem = this.regCache.getVT();
			var op:RegElem = this.regCache.getOP();
			
			_colorVaring = this.regCache.getV();
			
			vstart.o = m44(start.o, _l2vReg.o);
			vdir.o = m44(end.o, _l2vReg.o);
			vdir.o = sub(vdir.o, vstart.o);
			vdir.xyz = crs(vdir.xyz, _zAxis.xyz);
			
			vstart.o = m44(vstart.o, _projectReg.o);
			vdir.o = m44(vdir.o, _projectReg.o);
			
			vdir.zw = mov(_zAxis.xy);
			vdir.xyz = nrm(vdir.xyz);
			vdir.xy = div(vdir.xy, _targetSize.xy);
			vdir.xy = mul(vdir.xy, thickness.xx);
			vdir.xy = mul(vdir.xy, vstart.w);
			
			vstart.xy = add(vstart.xy, vdir.xy);

			op.o = mov(vstart.o);
			_colorVaring.o = mov(color.o);
			
			return regCache.vertexCode;
		}
		
		override protected function getFragmentCode():String
		{
			regCache.switchCode();
			
			var oc:RegElem = this.regCache.getOC();
			oc.o = mov(_colorVaring.o);
			
			return regCache.fragmentCode;
		}
		
		override public function render(mesh:Mesh):void
		{
			var context:Context3D = Nut.scene.context3D;
			var camera:NutCamera = Nut.scene.camera;
			
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, _l2vReg.id, getLocalToView(camera, mesh), true);
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, _projectReg.id, camera.project, true);
			
			_targetSizeData[0] = Nut.scene.viewport.targetWidth;
			_targetSizeData[1] = Nut.scene.viewport.targetHeight;
			
			Nut.scene.context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, _zAxis.id, zAxisData, 1);
			Nut.scene.context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, _targetSize.id, _targetSizeData, 1);
			
			RegState.clear(regCache.va_next, regCache.fs_next);
			mesh.geometry.draw(Nut.scene.context3D);
		}
	}
}