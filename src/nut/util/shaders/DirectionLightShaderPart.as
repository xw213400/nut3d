package nut.util.shaders
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.geom.Vector3D;
	
	import nut.core.light.DirectionLight;
	import nut.core.material.Expression;
	import nut.core.material.Material;
	import nut.core.material.RegCache;
	import nut.core.material.RegElem;
	
	public class DirectionLightShaderPart extends Expression
	{
		private var _color:Vector.<Number> = Vector.<Number>([1, 1, 1, 0]);
		private var _lightDir:Vector.<Number> = Vector.<Number>([0, 0, 1, 1]);
		private var _lightProp:Vector.<Number> = Vector.<Number>([0.5, 0.5, 20, 0]);
		
		private var _lightColor:RegElem;
		private var _lightDirection:RegElem;
		private var _lightProperty:RegElem;
		private var _regCache:RegCache;
		private var _lightName:String;
		
		private var _shadowShaderPart:SoftShadowShaderPart;
		
		public function DirectionLightShaderPart(regCache:RegCache, hasShadow:Boolean)
		{
			super();
			_regCache = regCache;
			
			if (hasShadow)
				_shadowShaderPart = new SoftShadowShaderPart(regCache);
		}
		
		public function genVertexCode(worldPos:RegElem):void
		{
			if (_shadowShaderPart != null)
			{
				_shadowShaderPart.genVertextCode(worldPos);
			}
		}
		
		public function getColor(matPhongReg:RegElem, camDir:RegElem, inNormal:RegElem, outColor:RegElem):void
		{
			_lightColor = _regCache.getFC(1);
			_lightDirection = _regCache.getFC(1);
			_lightProperty = _regCache.getFC(1);
			
			var temp:RegElem = _regCache.getFT();
			
			outColor.o = mov(_lightColor.o);
			outColor.o = mul(outColor.o, _lightProperty.x);
			outColor.o = mul(outColor.o, matPhongReg.y);
			temp.w = dp3(_lightDirection.xyz, inNormal.xyz);
			temp.w = sat(temp.w);
			outColor.o = mul(outColor.o, temp.w);
			
			if (_shadowShaderPart != null)
			{
				_shadowShaderPart.getShadowFactor(temp);
				outColor.o = mul(outColor.o, temp.w);
			}
			
			temp.o = mov(camDir.o);
			temp.o = add(temp.o, _lightDirection.o);
			temp.xyz = nrm(temp.o);
			temp.w = dp3(temp.xyz, inNormal.xyz);
			temp.w = sat(temp.w);
			temp.w = pow(temp.w, _lightProperty.z);
			temp.w = mul(temp.w, _lightProperty.y);
			temp.w = mul(temp.w, matPhongReg.z);
			temp.o = mul(_lightColor.o, temp.w);
			
			outColor.o = add(outColor.o, temp.o);
			
			_regCache.free(temp);
		}
		
		public function setupLightConst(context:Context3D, directionLight:DirectionLight, material:Material):void
		{
			if (material.usage == Material.UsageSetting)
			{
				var fcConsts:Vector.<Number> = material.fcConsts;
				var idx:int = _lightColor.id*4;
				
				fcConsts[idx++] = directionLight.colorR;
				fcConsts[idx++] = directionLight.colorG;
				fcConsts[idx++] = directionLight.colorB;
				
				var dir:Vector3D = directionLight.getLightDirection();
				idx = _lightDirection.id*4;
				
				fcConsts[idx++] = dir.x;
				fcConsts[idx++] = dir.y;
				fcConsts[idx++] = dir.z;
				
				idx = _lightProperty.id*4;
				
				fcConsts[idx++] = directionLight.diffuse;
				fcConsts[idx++] = directionLight.specular;
				fcConsts[idx++] = directionLight.shininess;
			}
			else if (material.usage == Material.UsageStatic)
			{
				
			}
			else
			{
				_color[0] = directionLight.colorR;
				_color[1] = directionLight.colorG;
				_color[2] = directionLight.colorB;
				
				dir = directionLight.getLightDirection();
				
				_lightDir[0] = dir.x;
				_lightDir[1] = dir.y;
				_lightDir[2] = dir.z;
				
				_lightProp[0] = directionLight.diffuse;
				_lightProp[1] = directionLight.specular;
				_lightProp[2] = directionLight.shininess;
				
				context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, _lightColor.id, _color, 1);
				context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, _lightDirection.id, _lightDir, 1);
				context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, _lightProperty.id, _lightProp, 1);
				
				if (_shadowShaderPart != null)
					_shadowShaderPart.setupConsts(context, directionLight);
			}
		}
	}
}