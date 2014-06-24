package nut.util.shaders.particle.position
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	
	import nut.core.Float4;
	import nut.core.material.Expression;
	import nut.core.material.Material;
	import nut.core.material.RegCache;
	import nut.core.material.RegElem;
	import nut.core.material.ShaderBase;
	
	public class LinearForceAffPart extends Expression
	{
		private var _forceAdj:RegElem;
		private var _regCache:RegCache;
		private var _shaderName:String;
		
		public function LinearForceAffPart(shader:ShaderBase)
		{
			_regCache = shader.regCache;
			_shaderName = shader.name;
			shader.data.addProperty("forceAdj", Float4.Y_AXIS);
		}
		
		public function affPosition(posReg:RegElem, dirReg:RegElem, axisReg:RegElem):void
		{
			_forceAdj = _regCache.getVC(1);
			var distance:RegElem = _regCache.getVT();
			distance.o = mul(_forceAdj.o, dirReg.w);
			dirReg.xyz = add(dirReg.xyz, distance.xyz);
			distance.o = mul(distance.o, dirReg.w);
			distance.o = mul(distance.o, axisReg.z);
			posReg.o = add(posReg.o, distance.o);
			_regCache.free(distance);
		}
		
		public function setupConstants(context:Context3D, material:Material):void
		{
			var forceAdj:Float4 = material.getFloat4(_shaderName, "forceAdj");
			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, _forceAdj.id, forceAdj.data);
		}
	}
}