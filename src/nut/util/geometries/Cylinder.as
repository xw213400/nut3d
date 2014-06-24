package nut.util.geometries
{
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Endian;
	
	import nut.core.Geometry;
	import nut.core.VertexComponent;

	public class Cylinder
	{
		static private var cylinders:Dictionary = new Dictionary();
		
		static public function getCylinder(numColumns:uint, numRows:uint):Geometry
		{
			var id:uint = (numColumns<<16)+numRows;
			var cylinder:Geometry = cylinders[id];
			
			if (cylinder != null)
				return cylinder;
			
			var indices	:ByteArray	= new ByteArray();
			var ii  	:uint 		= 0;
			
			indices.endian = Endian.LITTLE_ENDIAN;
			
			for (var ik : uint = 0 ; ik != numColumns - 1; ++ik)
			{
				for (var jk : uint = 0; jk != numRows - 1; jk++)
				{
					indices.writeShort(ii);
					indices.writeShort(ii + numRows + 1);
					indices.writeShort(ii + 1);
					indices.writeShort(ii + numRows);
					indices.writeShort(ii + numRows + 1);
					indices.writeShort(ii++);
				}
				++ii;
			}
			
			var xyz:Vector.<Number>	= new <Number>[];
			var uv:Vector.<Number> = new <Number>[];
			
			for (var i : uint = 0; i < numColumns; ++i)
			{
				var ix : Number = i / (numColumns - 1) * Math.PI * 2.0;
				for (var j : uint = 0; j < numRows; ++j)
				{
					var iy : Number = j / (numRows - 1) - 0.5;
					
					xyz.push(0.5 * Math.cos(ix), iy, 0.5 * Math.sin(ix));
					uv.push(i / (numColumns - 1), 1. - j / (numRows - 1));
				}
			}
			
			cylinder = new Geometry(indices, numColumns*numRows);
			cylinder.vertexbuffer.addComponentFromFloats('position', Context3DVertexBufferFormat.FLOAT_3, xyz);
			cylinder.vertexbuffer.addComponentFromFloats('uv', Context3DVertexBufferFormat.FLOAT_2, uv);
			cylinders[id] = cylinder;
			
			return cylinder;
		}
	}
}