package nut.util.geometries
{
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import nut.core.Geometry;
	import nut.core.VertexComponent;
	
	public class Cube
	{
		static private const positions :Vector.<Number> = Vector.<Number>([
			// top
			0.5, 0.5, 0.5, -0.5, 0.5, -0.5, 0.5, 0.5, -0.5,
			0.5, 0.5, 0.5, -0.5, 0.5, 0.5, -0.5, 0.5, -0.5,
			// bottom
			-0.5, -0.5, -0.5, 0.5, -0.5, 0.5, 0.5, -0.5, -0.5,
			-0.5, -0.5, 0.5, 0.5, -0.5, 0.5, -0.5, -0.5, -0.5,
			// back
			0.5, -0.5, 0.5, -0.5, 0.5, 0.5, 0.5, 0.5, 0.5,
			-0.5, 0.5, 0.5, 0.5, -0.5, 0.5, -0.5, -0.5, 0.5,
			// front
			-0.5, 0.5, -0.5, -0.5, -0.5, -0.5, 0.5, 0.5, -0.5,
			-0.5, -0.5, -0.5, 0.5, -0.5, -0.5, 0.5, 0.5, -0.5,
			// left
			-0.5, -0.5, -0.5, -0.5, 0.5, 0.5, -0.5, -0.5, 0.5,
			-0.5, 0.5, 0.5, -0.5, -0.5, -0.5, -0.5, 0.5, -0.5,
			// right
			0.5, -0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, -0.5,
			0.5, 0.5, -0.5, 0.5, -0.5, -0.5, 0.5, -0.5, 0.5
			]);
		
		static private const uvs :Vector.<Number> = Vector.<Number>([
			// top
			1., 0., 0., 1., 1., 1.,
			1., 0., 0., 0., 0., 1.,
			// bottom
			0., 0., 1., 1., 1., 0.,
			0., 1., 1., 1., 0., 0.,
			// back
			0., 1., 1., 0., 0., 0.,
			1., 0., 0., 1., 1., 1.,
			// front
			0., 0., 0., 1., 1., 0.,
			0., 1., 1., 1., 1., 0.,
			// left
			1., 1., 0., 0., 0., 1.,
			0., 0., 1., 1., 1., 0.,
			// right
			1., 1., 1., 0., 0., 0.,
			0., 0., 0., 1., 1., 1.
		]);
		
		static private const _indices:ByteArray = new ByteArray();
		static private var _cube :Geometry = null;

		static public function get cube():Geometry
		{
			if (_cube == null)
			{
				_indices.endian = Endian.LITTLE_ENDIAN;
				for (var i:int = 0; i != 36; ++i)
				{
					_indices.writeShort(i);
				}
				_cube = new Geometry(_indices, 36);
				_cube.vertexbuffer.addComponentFromFloats('position', Context3DVertexBufferFormat.FLOAT_3, positions);
				_cube.vertexbuffer.addComponentFromFloats('uv', Context3DVertexBufferFormat.FLOAT_2, uvs);
			}
			
			return _cube;
		}
	}
}