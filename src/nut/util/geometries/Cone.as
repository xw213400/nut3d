package nut.util.geometries
{
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Endian;
	
	import nut.core.Geometry;
	import nut.core.VertexComponent;
	import nut.util.NutMath;

	public class Cone
	{
		static private var cones:Dictionary = new Dictionary();
		
		static public function getCone(numSegments:int):Geometry
		{
			var cone:Geometry = cones[numSegments];
			
			if (cone != null)
				return cone;
			
			var indices:ByteArray = new ByteArray();

			indices.endian = Endian.LITTLE_ENDIAN;
			
			for (var idx:int = 0; idx<numSegments-1; ++idx)
			{
				indices.writeShort(0);
				indices.writeShort(idx+1);
				indices.writeShort(idx+2);
				indices.writeShort(numSegments+1);
				indices.writeShort(idx+2);
				indices.writeShort(idx+1);
			}
			// close the shape
			indices.writeShort(0);
			indices.writeShort(idx+1);
			indices.writeShort(1);
			indices.writeShort(numSegments+1);
			indices.writeShort(1);
			indices.writeShort(idx+1);
			
			var xyz:ByteArray = new ByteArray();
			xyz.endian = Endian.LITTLE_ENDIAN;
			
			xyz.writeFloat(0.0);
			xyz.writeFloat(0.5);
			xyz.writeFloat(0.0);
			
			for (var i:int = 0; i<numSegments; ++i)
			{
				var angle : Number = (NutMath.TWO_PI) * (i/numSegments);
				
				xyz.writeFloat(Math.cos(angle)*0.5);
				xyz.writeFloat(-0.5);
				xyz.writeFloat(Math.sin(angle)*0.5);
			}
			
			xyz.writeFloat(0.0);
			xyz.writeFloat(-0.5);
			xyz.writeFloat(0.0);
			
			cone = new Geometry(indices, numSegments+2);
			cone.vertexbuffer.addComponent('position',Context3DVertexBufferFormat.FLOAT_3, xyz);
			cones[numSegments] = cone;
			
			return cone;
		}
	}
}