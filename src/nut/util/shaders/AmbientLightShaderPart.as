package nut.util.shaders
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	
	import nut.core.light.AmbientLight;
	import nut.core.material.Expression;
	import nut.core.material.Material;
	import nut.core.material.RegCache;
	import nut.core.material.RegElem;
	
	public class AmbientLightShaderPart extends Expression
	{
//		private var _ambientLight:AmbientLight = null;
//		private var _idx:int = 0;
		private var _lightData:Vector.<Number> = new Vector.<Number>(4);
		private var _regCache:RegCache = null;
		private var _lightDataReg:RegElem;
		
		public function AmbientLightShaderPart(regCache:RegCache)
		{
			super();
			_regCache = regCache;
			
//			_ambientLight = ambientLight;
//			_idx = idx;
		}
		
		public function getColor(matPhongReg:RegElem, outColor:RegElem):void
		{
			_lightDataReg = _regCache.getFC(1);
			
			outColor.o = mov(_lightDataReg.o);
			outColor.o = mul(outColor.o, _lightDataReg.w);
			outColor.o = mul(outColor.o, matPhongReg.x);
		}
		
		public function setupLightConst(context3D:Context3D, ambientLight:AmbientLight, material:Material):void
		{
			if (material.usage == Material.UsageSetting)
			{
				var fcConsts:Vector.<Number> = material.fcConsts;
				var idx:int = _lightDataReg.id*4;
				
				fcConsts[idx++] = ambientLight.colorR;
				fcConsts[idx++] = ambientLight.colorG;
				fcConsts[idx++] = ambientLight.colorB;
				fcConsts[idx++] = ambientLight.ambient;
			}
			else if (material.usage == Material.UsageStatic)
			{
				
			}
			else
			{
				_lightData[0] = ambientLight.colorR;
				_lightData[1] = ambientLight.colorG;
				_lightData[2] = ambientLight.colorB;
				_lightData[3] = ambientLight.ambient;
				
				context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, _lightDataReg.id, _lightData, 1);
			}
		}
	}
}