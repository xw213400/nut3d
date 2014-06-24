package nut.util.geometries
{
	import flash.geom.Vector3D;
	
	import nut.core.Float4;

	public class Line
	{
		public var s:Vector3D = null;
		public var e:Vector3D = null;
		public var c:Float4	= null;
		
		public function Line(start:Vector3D, end:Vector3D, color:Float4)
		{
			s = start;
			e = end;
			c = color;
		}
	}
}