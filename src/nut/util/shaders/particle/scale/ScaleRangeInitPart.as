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

	public class ScaleRangeInitPart extends Expression
	{
		private var _scaleRange:RegElem;
		private var _regCache:RegCache;
		private var _shaderName:String;
		
		public function ScaleRangeInitPart(shader:ShaderBase)
		{
			_regCache = shader.regCache;
			_shaderName = shader.name;
			shader.data.addProperty("scaleRangeInit", Float4.Y_AXIS);
		}
		
		public function getScale(scaleReg:RegElem, rand4:RegElem):void
		{
			_scaleRange = _regCache.getVC(1);
			
			scaleReg.xy = mov(_scaleRange.zw);
			scaleReg.xy = sub(scaleReg.xy, _scaleRange.xy);
			scaleReg.xy = mul(scaleReg.xy, rand4.xy);
			scaleReg.xy = add(scaleReg.xy, _scaleRange.xy);
		}
		
		public function setupConstants(context:Context3D, material:Material):void
		{
			var scale:Float4 = material.getFloat4(_shaderName, "scaleRangeInit");
			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, _scaleRange.id, scale.data);
		}
	}
}