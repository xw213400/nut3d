package nut.util.shaders.particle.scale
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	
	import nut.core.Float4;
	import nut.core.material.Expression;
	import nut.core.material.Material;
	import nut.core.material.RegCache;
	import nut.core.material.RegElem;
	import nut.core.material.ShaderBase;

	public class ScaleAffPart extends Expression
	{
		private var _scaleAdj:RegElem;
		private var _regCache:RegCache;
		private var _shaderName:String;
		
		public function ScaleAffPart(shader:ShaderBase)
		{
			_regCache = shader.regCache;
			_shaderName = shader.name;
			
			shader.data.addProperty("scaleAdj", Float4.Z_AXIS);
		}
		
		public function affScale(scaleReg:RegElem, direction:RegElem):void
		{
			_scaleAdj = _regCache.getVC(1);

			scaleReg.z = mul(_scaleAdj.x, direction.w);
			scaleReg.w = mul(_scaleAdj.y, direction.w);
			scaleReg.xy = add(scaleReg.xy, scaleReg.zw);
		}
		
		public function setupConstants(context:Context3D, material:Material):void
		{
			var scaleAdj:Float4 = material.getFloat4(_shaderName, "scaleAdj");
			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, _scaleAdj.id, scaleAdj.data);
		}
	}
}