package nut.core.light
{
	public class AmbientLight extends LightBase
	{
		private var _ambient:Number = 1.0;
		
		public function AmbientLight()
		{
			super(false);
		}

		public function get ambient():Number
		{
			return _ambient;
		}

		public function set ambient(value:Number):void
		{
			_ambient = value;
		}

	}
}