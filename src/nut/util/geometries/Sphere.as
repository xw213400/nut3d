package nut.util.geometries
{
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Endian;
	
	import nut.core.Geometry;
	import nut.core.VertexComponent;

	public class Sphere
	{
		static private var spheres:Dictionary = new Dictionary();
		
		static public function getSphere(numParallels:uint, numMeridians:uint):Geometry
		{
			var id:uint = (numParallels<<16)+numMeridians;
			var sphere:Geometry = spheres[id];
			
			if (sphere != null)
				return sphere;
			
			var numPara:uint = numParallels;
			var numMeri:uint = numMeridians;
			
			var numFaces	: uint			= (numPara - 2) * (numMeri) * 2;
			var	indices		:ByteArray	= new ByteArray();
			indices.endian = Endian.LITTLE_ENDIAN;
			
			numMeri++;
			for (var c : uint = 0, j : uint = 0; j < numPara - 3; j++)
			{
				for (var i : uint = 0; i < numMeri - 1; i++)
				{
					indices.writeShort(j * numMeri + i);
					indices.writeShort(j * numMeri + i + 1);
					indices.writeShort((j + 1) * numMeri + i + 1);
					
					indices.writeShort(j * numMeri + i);
					indices.writeShort((j + 1) * numMeri + i + 1);
					indices.writeShort((j + 1) * numMeri + i);
				}
			}
			
			for (i = 0; i < numMeridians - 1; i++)
			{
				indices.writeShort((numPara - 2) * numMeri);
				indices.writeShort(i + 1);
				indices.writeShort(i);
				
				indices.writeShort((numPara - 2) * numMeri + 1);
				indices.writeShort((numPara - 3) * numMeri + i);
				indices.writeShort((numPara - 3) * numMeri + i + 1);
			}
			
			var numVertices	: int		= (numParallels - 2) * (numMeridians + 1) + 2;
			var xyz:Vector.<Number>	= new <Number>[];
			var uv:Vector.<Number> = new <Number>[];
			var nor:Vector.<Number> = new <Number>[];
			var k : uint = 0;
			
			c = 0;
			
			numMeri--;
			for (j = 1; j < numPara - 1; j++)
			{
				for (i = 0; i < numMeri + 1; i++, c += 3, k += 2)
				{
					var theta 	: Number	= j / (numPara - 1) * Math.PI;
					var phi 	: Number	= i / numMeri * Math.PI * 2;
					
					var x : Number 	= Math.sin(theta) * Math.cos(phi) * .5;
					var y : Number	= Math.cos(theta) * .5;
					var z : Number	= -Math.sin(theta) * Math.sin(phi) * .5;
					
					// xyz
					xyz.push(x, y, z);
					
					// uv
					uv.push(1-i/numMeri, j/(numPara-1));
					
					//nor
					nor.push(x * 2, y * 2, z * 2);
				}
			}
			
			// top
			xyz.push(0.0, 0.5, 0.0);
			uv.push(0.5, 0.0);
			nor.push(0, 1, 0);
			
			// bottom
			xyz.push(0.0, -0.5, 0.0);
			uv.push(0.5, 1.0);
			nor.push(0, -1, 0);
			
			sphere = new Geometry(indices, numVertices);
			sphere.vertexbuffer.addComponentFromFloats('position', Context3DVertexBufferFormat.FLOAT_3, xyz);
			sphere.vertexbuffer.addComponentFromFloats('normal', Context3DVertexBufferFormat.FLOAT_3, nor);
			sphere.vertexbuffer.addComponentFromFloats('uv', Context3DVertexBufferFormat.FLOAT_2, uv);
			spheres[id] = sphere;
			
			return sphere;
		}
	}
}