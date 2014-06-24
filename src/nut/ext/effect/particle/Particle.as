package nut.ext.effect.particle
{
	import nut.util.NutMath;

	public class Particle
	{
		static private var _seed:int	= 0;
		
		public var life		:Number		= 0;
		public var i		:int		= 0;
		public var next		:Particle	= null;
		
		public function Particle(idx:int)
		{
			i = idx;
		}

		public static function get seed():int
		{
			if (_seed == NutMath.randTable.length)
				_seed = 0;
			
			return _seed++;
		}

	}
}