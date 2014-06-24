package nut.core.light
{
	public class PointLight extends LightBase
	{
		private var _diffuse	:Number	= 0.5;
		private var _specular	:Number = 0.5;
		
		public function PointLight(castShadow:Boolean=false)
		{
			super(castShadow);
		}
	}
}