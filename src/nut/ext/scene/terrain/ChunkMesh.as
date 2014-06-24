package nut.ext.scene.terrain
{
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import nut.core.Geometry;
	import nut.core.Mesh;
	import nut.core.VertexBuffer;
	import nut.core.VertexComponent;

	public class ChunkMesh extends Mesh
	{
		private var _chunk	:Chunk;
		
		public function ChunkMesh(chunk:Chunk)
		{
			var indices :ByteArray = new ByteArray();
			var uvs		:ByteArray = new ByteArray();
			var uvUnit	:Number = 1.0 / Terrain.UNIT_NUM;
			
			indices.endian = Endian.LITTLE_ENDIAN;
			uvs.endian = Endian.LITTLE_ENDIAN;
			
			for (var z:int = 0; z != Terrain.VERT_NUM; ++z)
			{
				for (var x:int = 0; x != Terrain.VERT_NUM; ++x)
				{
					var base :int = x+z*Terrain.VERT_NUM;
					
					uvs.writeFloat(x * uvUnit);
					uvs.writeFloat(z * uvUnit);
					
					if (x != Terrain.UNIT_NUM && z != Terrain.UNIT_NUM)
					{
						indices.writeShort(base);
						indices.writeShort(base + Terrain.VERT_NUM + 1);
						indices.writeShort(base + Terrain.VERT_NUM);
						indices.writeShort(base);
						indices.writeShort(base + 1);
						indices.writeShort(base + Terrain.VERT_NUM + 1);
					}
				}
			}
			
			super(new Geometry(indices, Terrain.VERT_IDX_MAX));
			_geometry.vertexbuffer.addComponent('uv', Context3DVertexBufferFormat.FLOAT_2, uvs);

			_chunk = chunk;
		}

		public function get chunk():Chunk
		{
			return _chunk;
		}

		public function createGeometry():void
		{
			var position:Vector.<Number>;
			var normals	:Vector.<Number>;
			
			var posData:ByteArray = new ByteArray();
			var norData:ByteArray = new ByteArray();
			
			posData.endian = Endian.LITTLE_ENDIAN;
			norData.endian = Endian.LITTLE_ENDIAN;
			
			var idxVerts:int = 0;
			var idxNorms:int = 0;
			
			for (var z:int = 0; z != Terrain.VERT_NUM; ++z)
			{
				for (var x:int = 0; x != Terrain.VERT_NUM; ++x)
				{
					var pos_x:Number = (x-Terrain.UNIT_NUM*0.5)*Terrain.UNIT_SIZE;
					var pos_z:Number = (z-Terrain.UNIT_NUM*0.5)*Terrain.UNIT_SIZE;
					var base :int = x+z*Terrain.VERT_NUM;
					var pos_y:Number = _chunk.heightData[base];
					
					posData.writeFloat(pos_x);
					posData.writeFloat(pos_y);
					posData.writeFloat(pos_z);
					
					norData.writeFloat(0.0);
					norData.writeFloat(1.0);
					norData.writeFloat(0.0);
				}
			}
			
			var vb:VertexBuffer = _geometry.vertexbuffer;
			
			vb.addComponent('position', Context3DVertexBufferFormat.FLOAT_3, posData);
			vb.addComponent('normal', Context3DVertexBufferFormat.FLOAT_3, norData);
		}
		
		public function updateNormal():void
		{
			var vb:VertexBuffer = _geometry.vertexbuffer;
			var cp:VertexComponent = vb.getComponent('normal');
			var vs:ByteArray = vb.vertices;
			var of:uint = cp.stride * 4;
			var st:uint = vb.size * 4;

			for (var i:int = 0; i!=Terrain.VERT_IDX_MAX; ++i)
			{
				var norm:Vector3D = _chunk.getNormal(i);
				
				vs.position = i*st + of;
				vs.writeFloat(norm.x);
				vs.writeFloat(norm.y);
				vs.writeFloat(norm.z);
			}
			
			vb.dataDirty = true;
		}
		
		public function updateHeight():void
		{
			var vb:VertexBuffer = _geometry.vertexbuffer;
			var cp:VertexComponent = vb.getComponent('position');
			var vs:ByteArray = vb.vertices;
			var of:uint = cp.stride * 4;
			var st:uint = vb.size * 4;
			
			for (var z:int = 0; z != Terrain.VERT_NUM; ++z)
			{
				for (var x:int = 0; x != Terrain.VERT_NUM; ++x)
				{
					var pos_x:Number = x*Terrain.UNIT_SIZE-Terrain.HALF_CHUNK_SIZE;
					var pos_z:Number = z*Terrain.UNIT_SIZE-Terrain.HALF_CHUNK_SIZE;
					var idx:int = x+z*Terrain.VERT_NUM;
					var pos_y:Number = _chunk.heightData[idx];
					
					vs.position = idx*st + of;
					vs.writeFloat(pos_x);
					vs.writeFloat(pos_y);
					vs.writeFloat(pos_z);
				}
			}
			
			vb.dataDirty = true;
		}
	}
}