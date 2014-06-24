package nut.ext.effect.particle
{
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import nut.core.Geometry;
	import nut.core.VertexComponent;
	import nut.util.NutMath;
	
	public class BillboardSet extends Geometry
	{		
		//公告板的宽沿x轴方向，高沿y轴方向
		public static const DT_ORIENTED_CAMERA		:uint	= 0;	//z轴精确朝向摄像机
		public static const DT_ORIENTED_SELF		:uint	= 1;	//y轴朝向运动方向
		public static const DT_ORIENTED_COMMON		:uint	= 2;	//y轴朝向设定方向
		public static const DT_PERPENDICULAR_SELF	:uint	= 3;	//z轴朝向运动方向
		public static const DT_PERPENDICULAR_COMMON	:uint	= 4;	//z轴朝向设定方向

		private var _activeBuffer	:ParticleList	= new ParticleList();
		private var _freeBuffer		:ParticleList	= new ParticleList();
		private var _vertices		:ByteArray		= null;
		private var _parent			:ParticleSystem = null;
		
		public function BillboardSet(parent:ParticleSystem)
		{
			_parent = parent;
			_indices = new ByteArray();
			_vertices = new ByteArray();
			_indices.endian = Endian.LITTLE_ENDIAN;
			_vertices.endian = Endian.LITTLE_ENDIAN;
			
			_activeBuffer.reSize(0);
			_freeBuffer.reSize(_parent.poolSize);

			var idx:int = 0;
			var n:int = _parent.poolSize;
			for (var i:int = 0; i != n; ++i)
			{
				var v1:int = idx++;
				var v2:int = idx++;
				var v3:int = idx++;
				var v4:int = idx++;
				
				_indices.writeShort(v1);
				_indices.writeShort(v3);
				_indices.writeShort(v2);
				
				_indices.writeShort(v2);
				_indices.writeShort(v3);
				_indices.writeShort(v4);
				
				//v1
				_vertices.writeFloat(0);
				_vertices.writeFloat(0);
				_vertices.writeFloat(0);
				_vertices.writeFloat(-1);
				
				_vertices.writeFloat(0);
				_vertices.writeFloat(0);
				_vertices.writeFloat(0);
				_vertices.writeFloat(0);
				
				_vertices.writeFloat(0);
				_vertices.writeFloat(0);
				_vertices.writeFloat(0);
				
				//v2
				_vertices.writeFloat(0);
				_vertices.writeFloat(1);
				_vertices.writeFloat(0);
				_vertices.writeFloat(-1);
				
				_vertices.writeFloat(0);
				_vertices.writeFloat(0);
				_vertices.writeFloat(0);
				_vertices.writeFloat(0);
				
				_vertices.writeFloat(0);
				_vertices.writeFloat(0);
				_vertices.writeFloat(0);
				
				//v3
				_vertices.writeFloat(1);
				_vertices.writeFloat(0);
				_vertices.writeFloat(0);
				_vertices.writeFloat(-1);
				
				_vertices.writeFloat(0);
				_vertices.writeFloat(0);
				_vertices.writeFloat(0);
				_vertices.writeFloat(0);
				
				_vertices.writeFloat(0);
				_vertices.writeFloat(0);
				_vertices.writeFloat(0);
				
				//v4
				_vertices.writeFloat(1);
				_vertices.writeFloat(1);
				_vertices.writeFloat(0);
				_vertices.writeFloat(-1);
				
				_vertices.writeFloat(0);
				_vertices.writeFloat(0);
				_vertices.writeFloat(0);
				_vertices.writeFloat(0);
				
				_vertices.writeFloat(0);
				_vertices.writeFloat(0);
				_vertices.writeFloat(0);
			}
			
			super(_indices, n*4);
			
			var uv_time:VertexComponent = new VertexComponent("uv_time", Context3DVertexBufferFormat.FLOAT_4);
			var rand4:VertexComponent = new VertexComponent("rand4", Context3DVertexBufferFormat.FLOAT_4);
			var pos:VertexComponent = new VertexComponent("position", Context3DVertexBufferFormat.FLOAT_3);
			
			_vertexbuffer.init(_vertices, [uv_time, rand4, pos]);
		}

		public function get freeBuffer():ParticleList
		{
			return _freeBuffer;
		}

		public function get activeBuffer():ParticleList
		{
			return _activeBuffer;
		}

		public function emit(num:int, e:ParticleEmitter):int
		{
			var n:int = _freeBuffer.num > num ? num : _freeBuffer.num;
			
			if (n == 0)
				return num;
			
			var elapsed:Number = _parent.currTime;
			
			var x:Number = 0;
			var y:Number = 0;
			var z:Number = 0;
			
			if (!_parent.localSpace)
			{
				var pos:Vector3D = _parent.localToWorld.position;
				x = pos.x;
				y = pos.y;
				z = pos.z;
			}
			
//			trace(x, y, z);
			var deltaLife:Number = e.maxLife-e.minLife;

			for (var i:int = 0; i != n; ++i)
			{
				var p:Particle = _freeBuffer.head;
				
				_freeBuffer.remove(null, p);
				_activeBuffer.add(p);
				
				var life:Number = NutMath.random(Particle.seed) * deltaLife + e.minLife;
				var r1:Number = NutMath.random(Particle.seed);
				var r2:Number = NutMath.random(Particle.seed);
				var r3:Number = NutMath.random(Particle.seed);
				var r4:Number = NutMath.random(Particle.seed);
				
				p.life = life;

				_vertices.position = p.i*176 + 8;

				_vertices.writeFloat(life);
				_vertices.writeFloat(elapsed);
				_vertices.writeFloat(r1);
				_vertices.writeFloat(r2);
				_vertices.writeFloat(r3);
				_vertices.writeFloat(r4);
				_vertices.writeFloat(x);
				_vertices.writeFloat(y);
				_vertices.writeFloat(z);
				
				_vertices.position += 8;
				_vertices.writeFloat(life);
				_vertices.writeFloat(elapsed);
				_vertices.writeFloat(r1);
				_vertices.writeFloat(r2);
				_vertices.writeFloat(r3);
				_vertices.writeFloat(r4);
				_vertices.writeFloat(x);
				_vertices.writeFloat(y);
				_vertices.writeFloat(z);
				
				_vertices.position += 8;
				_vertices.writeFloat(life);
				_vertices.writeFloat(elapsed);
				_vertices.writeFloat(r1);
				_vertices.writeFloat(r2);
				_vertices.writeFloat(r3);
				_vertices.writeFloat(r4);
				_vertices.writeFloat(x);
				_vertices.writeFloat(y);
				_vertices.writeFloat(z);
				
				_vertices.position += 8;
				_vertices.writeFloat(life);
				_vertices.writeFloat(elapsed);
				_vertices.writeFloat(r1);
				_vertices.writeFloat(r2);
				_vertices.writeFloat(r3);
				_vertices.writeFloat(r4);
				_vertices.writeFloat(x);
				_vertices.writeFloat(y);
				_vertices.writeFloat(z);
			}
			
			_vertexbuffer.dataDirty = true;
			
			return num-n;
		}
	}
}