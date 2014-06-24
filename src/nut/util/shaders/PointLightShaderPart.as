package nut.util.shaders
{
	import flash.display3D.Context3D;
	
	import nut.core.light.PointLight;
	import nut.core.material.Expression;
	import nut.core.material.Material;
	import nut.core.material.RegCache;
	import nut.core.material.RegElem;
	
	public class PointLightShaderPart extends Expression
	{
		private var _pointLight:PointLight = null;
		private var _color:Vector.<Number> = new Vector.<Number>(4);
		
		private var _lightColor:RegElem;
		private var _regCache:RegCache;
		
		public function PointLightShaderPart(regCache:RegCache)
		{
			super();
			_regCache = regCache;
		}
		
		public function setupLightConst(context3D:Context3D, pointLight:PointLight, material:Material):void
		{
			_color[0] = _pointLight.colorR;
			_color[1] = _pointLight.colorG;
			_color[2] = _pointLight.colorB;
//			_color[3] = _pointLight.diffuse;
			
//			_direction[3] = _directionLight.specular;
			
//			context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, _lightColor.id, _color, 1);
//			context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, _lightDirection.id, _direction, 1);
		}
	}
}