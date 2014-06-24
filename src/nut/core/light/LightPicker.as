package nut.core.light
{
	public class LightPicker
	{
		private var _lights:Vector.<LightBase> = new Vector.<LightBase>();
		
		public function LightPicker()
		{
		}
		
		public function addLight(light:LightBase):Boolean
		{
			var i:int = _lights.indexOf(light);
			if (i != -1)
				return false;
			
			if (light is AmbientLight)
			{
				_lights.splice(0, 0, light);
			}
			else if (light is DirectionLight)
			{
				if (_lights.length > 0 && _lights[0] is AmbientLight)
					_lights.splice(1, 0, light);
				else
					_lights.splice(0, 0, light);
			}
			else
			{
				_lights.push(light);
			}
			
			return true;
		}
		
		public function removeLight(light:LightBase):Boolean
		{
			var i:int = _lights.indexOf(light);
			if (i == -1)
				return false;
			
			_lights.splice(i, 1);
			
			return true;
		}

		public function get lights():Vector.<LightBase>
		{
			return _lights;
		}
		
		public function clone():LightPicker
		{
			var lightPicker:LightPicker = new LightPicker();
			
			lightPicker._lights = _lights.slice();
			
			return lightPicker;
		}
	}
}