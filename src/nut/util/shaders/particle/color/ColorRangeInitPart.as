package nut.util.shaders.particle.color
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	
	import nut.core.Float4;
	import nut.core.material.Expression;
	import nut.core.material.Material;
	import nut.core.material.RegCache;
	import nut.core.material.RegElem;
	import nut.core.material.ShaderBase;

	public class ColorRangeInitPart extends Expression
	{
		private var _colorMin:RegElem;
		private var _colorMax:RegElem;
		private var _regCache:RegCache;
		private var _shaderName:String;
		
		public function ColorRangeInitPart(shader:ShaderBase)
		{
			_regCache = shader.regCache;
			_shaderName = shader.name;
			shader.data.addProperty("colorMin", Float4.BLACK);
			shader.data.addProperty("colorMax", Float4.WHITE);
		}
		
		public function getColor(color:RegElem, rand4:RegElem):void
		{
			_colorMin = _regCache.getFC(1);
			_colorMax = _regCache.getFC(1);
			
			color.o = mov(_colorMax.o);
			color.o = sub(color.o, _colorMin.o);
			color.o = mul(rand4.o, color.o);
			color.o = add(color.o, _colorMin.o);
		}
		
		public function setupConstants(context:Context3D, material:Material):void
		{
			var colorMin:Float4 = material.getFloat4(_shaderName, "colorMin");
			var colorMax:Float4 = material.getFloat4(_shaderName, "colorMax");

			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, _colorMin.id, colorMin.data);
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, _colorMax.id, colorMax.data);
		}
	}
}