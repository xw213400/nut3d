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

	public class ColorFadeAffPart extends Expression
	{
		private var _colorAdj1:RegElem;
		private var _colorAdj2:RegElem;
		private var _timePhase:RegElem;
		
		private var _regCache:RegCache;
		private var _shaderName:String;
		
		public function ColorFadeAffPart(shader:ShaderBase)
		{
			_regCache = shader.regCache;
			_shaderName = shader.name;
			
			shader.data.addProperty("colorAdj1", Float4.ZERO);
			shader.data.addProperty("colorAdj2", Float4.ZERO);
			shader.data.addProperty("timePhase", Float4.BLACK);
		}
		
		public function affColor(colorReg:RegElem, uvTimeReg:RegElem):void
		{
			_colorAdj1 = _regCache.getFC(1);
			_colorAdj2 = _regCache.getFC(1);
			_timePhase = _regCache.getFC(1);
			
			var cofaT:RegElem = _regCache.getFT();
			var temp1:RegElem = _regCache.getFT();
			var temp2:RegElem = _regCache.getFT();
			
			cofaT.x = sub(uvTimeReg.w, _timePhase.x); //启动2的时间
			cofaT.y = sub(uvTimeReg.z, cofaT.x);
			cofaT.z = slt(cofaT.y, _timePhase.z);
			cofaT.w = sub(_timePhase.w, cofaT.z);
			
			temp1.o = mul(_colorAdj1.o, cofaT.z);
			temp2.o = mul(_colorAdj2.o, cofaT.w);
			temp2.o = add(temp1.o, temp2.o);
			temp2.o = mul(temp2.o, cofaT.y);
			temp1.o = mul(_colorAdj1.o, cofaT.x);
			temp2.o = add(temp2.o, temp1.o);
			
			colorReg.o = add(colorReg.o, temp2.o);
			
			_regCache.free(cofaT);
			_regCache.free(temp1);
			_regCache.free(temp2);
		}
		
		public function setupConstants(context:Context3D, material:Material):void
		{
			var colorAdj1:Float4 = material.getFloat4(_shaderName, "colorAdj1");
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, _colorAdj1.id, colorAdj1.data);
			
			var colorAdj2:Float4 = material.getFloat4(_shaderName, "colorAdj2");
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, _colorAdj2.id, colorAdj2.data);
			
			var timePhase:Float4 = material.getFloat4(_shaderName, "timePhase");
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, _timePhase.id, timePhase.data);
		}
	}
}