package nut.util.shaders.particle.position
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	
	import nut.core.material.Expression;
	import nut.core.Float4;
	import nut.core.material.Material;
	import nut.core.material.RegCache;
	import nut.core.material.RegElem;
	import nut.core.material.ShaderBase;
	
	public class BoxInitPart extends Expression
	{
		private var _xRange:RegElem;
		private var _yRange:RegElem;
		private var _zRange:RegElem;
		private var _regCache:RegCache;
		private var _shaderName:String;
		
		public function BoxInitPart(shader:ShaderBase)
		{
			_regCache = shader.regCache;
			_shaderName = shader.name;
			shader.data.addProperty("boxXRange", Float4.X_AXIS);
			shader.data.addProperty("boxYRange", Float4.Y_AXIS);
			shader.data.addProperty("boxZRange", Float4.Z_AXIS);
		}
		
		public function initPosition(posReg:RegElem, randReg:RegElem):void
		{
			_xRange = _regCache.getVC(1);
			_yRange = _regCache.getVC(1);
			_zRange = _regCache.getVC(1);
			
			var range:RegElem = _regCache.getVT();

			range.o = mul(_xRange.o, randReg.x);
			posReg.o = add(posReg.o, range.o);
			
			range.o = mul(_yRange.o, randReg.y);
			posReg.o = add(posReg.o, range.o);
			
			range.o = mul(_zRange.o, randReg.z);
			posReg.o = add(posReg.o, range.o);
			
			_regCache.free(range);
		}
		
		public function setupConstants(context:Context3D, material:Material):void
		{
			var boxXRange:Float4 = material.getFloat4(_shaderName, "boxXRange");
			var boxYRange:Float4 = material.getFloat4(_shaderName, "boxYRange");
			var boxZRange:Float4 = material.getFloat4(_shaderName, "boxZRange");
			
			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, _xRange.id, boxXRange.data);
			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, _yRange.id, boxYRange.data);
			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, _zRange.id, boxZRange.data);
		}
	}
}