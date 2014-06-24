package nut.util.shaders
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.geom.Vector3D;
	
	import nut.core.NutCamera;
	import nut.core.light.AmbientLight;
	import nut.core.light.DirectionLight;
	import nut.core.light.LightBase;
	import nut.core.light.LightPicker;
	import nut.core.light.PointLight;
	import nut.core.material.Expression;
	import nut.core.material.Material;
	import nut.core.material.RegCache;
	import nut.core.material.RegElem;
	import nut.core.material.ShaderBase;

	public class PhongShaderPart extends Expression
	{
		private var _lightShaderParts:Vector.<Expression> = new Vector.<Expression>();
		private var _materialData:Vector.<Number> = Vector.<Number>([0.6, 0.8, 0.0, 1.0]);
		private var _regCache:RegCache;
		private var _shaderName:String;
		private var _matPhongReg:RegElem;
		private var _camDirReg:RegElem;
		
		public function PhongShaderPart(parent:ShaderBase, material:Material)
		{
			super();
			
			_shaderName = parent.name;
			_regCache = parent.regCache;
			
			var lightPicker:LightPicker = material.lightPicker;
			var light:LightBase;
			var len:int = lightPicker.lights.length;
			var i:int;
			
			for (i=0; i!=len; ++i)
			{
				light = lightPicker.lights[i]
				if (light is AmbientLight)
				{
					_lightShaderParts.push(new AmbientLightShaderPart(_regCache));
				}
			}
			for (i=0; i!=len; ++i)
			{
				light = lightPicker.lights[i]
				if (light is DirectionLight)
				{
					_lightShaderParts.push(new DirectionLightShaderPart(_regCache, light.castShadow && material.receiveShadow));
				}
			}
			for (i=0; i!=len; ++i)
			{
				light = lightPicker.lights[i]
				if (light is PointLight)
				{
					_lightShaderParts.push(new PointLightShaderPart(_regCache));
				}
			}
			
			parent.data.addProperty("ambient", 0.6);
			parent.data.addProperty("diffuse", 0.8);
			parent.data.addProperty("specular", 0.0);
		}
		
		static public function getID(material:Material):uint
		{
			var lightPicker:LightPicker = material.lightPicker;
			
			var len:int = lightPicker.lights.length;
			var i:int;
			var a:int=0;
			var d:int=0;
			var p:int=0;
			var s:int=0;
			
			for (i=0; i!=len; ++i)
			{
				var light:LightBase = lightPicker.lights[i]
				if (light is AmbientLight)
					++a;
				else if (light is DirectionLight)
				{
					++d;
					if (light.castShadow && material.receiveShadow)
						++s;
				}
				else if (light is PointLight)
					++p;
			}
			
			return (p<<4)|(d<<2)|(s<<1)|a;
		}
		
		public function genVertexCode(worldPos:RegElem):void
		{
			var len:int = _lightShaderParts.length;
			for (var i:int=0; i!=len; ++i)
			{
				var part:Expression = _lightShaderParts[i];
				if (part is DirectionLightShaderPart)
				{
					var directionPart:DirectionLightShaderPart = part as DirectionLightShaderPart;
					directionPart.genVertexCode(worldPos);
				}
			}
		}
		
		public function getColor(inNormal:RegElem, worldPos:RegElem, outColor:RegElem):void
		{
			var lightColor:RegElem = _regCache.getFT();
			_matPhongReg = _regCache.getFC(1);
			_camDirReg = _regCache.getFC(1);
			
			var len:int = _lightShaderParts.length;
			
			if (len == 0)
				outColor.o = mov(_matPhongReg.wwww);
			
			for (var i:int=0; i!=len; ++i)
			{
				var part:Expression = _lightShaderParts[i];
				if (part is AmbientLightShaderPart)
				{
					var ambientPart:AmbientLightShaderPart = part as AmbientLightShaderPart;
					ambientPart.getColor(_matPhongReg, lightColor);
				}
				else if (part is DirectionLightShaderPart)
				{
					var directionPart:DirectionLightShaderPart = part as DirectionLightShaderPart;
					directionPart.getColor(_matPhongReg, _camDirReg, inNormal, lightColor);
				}
				else if (part is PointLightShaderPart)
				{
					var pointPart:PointLightShaderPart = part as PointLightShaderPart;
				}
				
				if (i==0)
					outColor.o = mov(lightColor.o);
				else
					outColor.o = add(outColor.o, lightColor.o);
			}

			_regCache.free(lightColor);
		}
		
		public function setupLightConst(context3D:Context3D, material:Material, camera:NutCamera):void
		{
			if (material.usage == Material.UsageSetting)
			{
				var fcConsts:Vector.<Number> = material.fcConsts;
				if (fcConsts == null)
					fcConsts = material.fcConsts = new Vector.<Number>(_regCache.fc_next*4);
				
				var idx:int = _matPhongReg.id*4;
				
				fcConsts[idx++] = material.getNumber(_shaderName, 'ambient');
				fcConsts[idx++] = material.getNumber(_shaderName, 'diffuse');
				fcConsts[idx++] = material.getNumber(_shaderName, 'specular');
				
				idx = _camDirReg.id*4;
				
				fcConsts[idx++] = camera.forward.x;
				fcConsts[idx++] = camera.forward.y;
				fcConsts[idx++] = camera.forward.z;
				
				var len:int = _lightShaderParts.length;
				var lights:Vector.<LightBase> = material.lightPicker.lights;
				
				for (var i:int=0; i!=len; ++i)
				{
					var part:Expression = _lightShaderParts[i];
					if (part is AmbientLightShaderPart)
					{
						var ambientPart:AmbientLightShaderPart = part as AmbientLightShaderPart;
						ambientPart.setupLightConst(context3D, lights[i] as AmbientLight, material);
					}
					else if (part is DirectionLightShaderPart)
					{
						var directionPart:DirectionLightShaderPart = part as DirectionLightShaderPart;
						directionPart.setupLightConst(context3D, lights[i] as DirectionLight, material);
					}
					else if (part is PointLightShaderPart)
					{
						var pointPart:PointLightShaderPart = part as PointLightShaderPart;
						pointPart.setupLightConst(context3D, lights[i] as PointLight, material);
					}
				}
				
			}
			else if (material.usage == Material.UsageStatic)
			{
				fcConsts = material.fcConsts;
				
				idx = _camDirReg.id*4;
				
				fcConsts[idx++] = camera.forward.x;
				fcConsts[idx++] = camera.forward.y;
				fcConsts[idx++] = camera.forward.z;
			}
			else
			{
				len = _lightShaderParts.length;
				
				_materialData[0] = material.getNumber(_shaderName, 'ambient');
				_materialData[1] = material.getNumber(_shaderName, 'diffuse');
				_materialData[2] = material.getNumber(_shaderName, 'specular');
				
				context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, _matPhongReg.id, _materialData, 1);
				context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, _camDirReg.id, camera.forward.data, 1);
				
				lights = material.lightPicker.lights;
				for (i=0; i!=len; ++i)
				{
					part = _lightShaderParts[i];
					if (part is AmbientLightShaderPart)
					{
						ambientPart = part as AmbientLightShaderPart;
						ambientPart.setupLightConst(context3D, lights[i] as AmbientLight, material);
					}
					else if (part is DirectionLightShaderPart)
					{
						directionPart = part as DirectionLightShaderPart;
						directionPart.setupLightConst(context3D, lights[i] as DirectionLight, material);
					}
					else if (part is PointLightShaderPart)
					{
						pointPart = part as PointLightShaderPart;
						pointPart.setupLightConst(context3D, lights[i] as PointLight, material);
					}
				}
			}
		}
	}
}