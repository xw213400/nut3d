package nut.ext.scene.terrain
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;

	public class WalkShape
	{
		private var _pos_x		:Number	= 0.0;
		private var _pos_y		:Number	= 0.0;
		private var _pos_z		:Number = 0.0;
		private var _rotation	:Number = 0.0;
		private var _size_x		:Number = 16;
		private var _size_z		:Number = 16;
		private var _arc		:Number = 0.0;
		private var _slope		:Number = 0.0;
		
		public function WalkShape()
		{
		}
		
		public function get slope():Number
		{
			return _slope;
		}

		public function set slope(value:Number):void
		{
			_slope = value;
		}

		public function get arc():Number
		{
			return _arc;
		}

		public function set arc(value:Number):void
		{
			_arc = value;
		}

		public function get size_z():Number
		{
			return _size_z;
		}

		public function set size_z(value:Number):void
		{
			_size_z = value;
		}

		public function get size_x():Number
		{
			return _size_x;
		}

		public function set size_x(value:Number):void
		{
			_size_x = value;
		}

		public function get rotation():Number
		{
			return _rotation;
		}

		public function set rotation(value:Number):void
		{
			_rotation = value;
		}

		public function get pos_z():Number
		{
			return _pos_z;
		}

		public function set pos_z(value:Number):void
		{
			_pos_z = value;
		}

		public function get pos_y():Number
		{
			return _pos_y;
		}

		public function set pos_y(value:Number):void
		{
			_pos_y = value;
		}

		public function get pos_x():Number
		{
			return _pos_x;
		}

		public function set pos_x(value:Number):void
		{
			_pos_x = value;
		}

		public function getHeight(x:Number, z:Number):Number
		{
			var height:Number = Terrain.INVALID_HEIGHT;
			
			x -= _pos_x;
			z -= _pos_z;
			
			var sinr:Number = Math.sin(-_rotation/180*Math.PI);
			var cosr:Number = Math.cos(-_rotation/180*Math.PI);
			
			var px:Number = cosr*x + sinr*z;
			var pz:Number = cosr*z - sinr*x;
			var half_x:Number = _size_x * 0.5;
			var half_z:Number = _size_z * 0.5;
			
			if (px > half_x || px < -half_x)
				return height;
			
			if (pz > half_z || pz < -half_z)
				return height;
			
			var abs_arc:Number = Math.abs(_arc);
			
			if (abs_arc < 0.001 || abs_arc > 3.141)
			{
				height = _pos_y;
			}
			else
			{
				var half_arc:Number = abs_arc * 0.5;
				var r:Number = half_z / Math.sin(half_arc);
				var h1:Number = r - r * Math.cos(half_arc);
				var h2:Number = r - Math.sqrt(r*r - pz*pz);
				height = h1 - h2 + _pos_y;
				height *= abs_arc/_arc;
			}
			
			var hslope:Number = Math.tan(_slope)*pz;
			height += hslope;
			
			return height;
		}
		
		public function exportWalkShape(data:ByteArray):void
		{
			data.writeFloat(_pos_x);
			data.writeFloat(_pos_y);
			data.writeFloat(_pos_z);
			data.writeFloat(_rotation);
			data.writeFloat(_size_x);
			data.writeFloat(_size_z);
			data.writeFloat(_arc);
			data.writeFloat(_slope);
		}
		
		public function importWalkShape(data:ByteArray):void
		{
			_pos_x = data.readFloat();
			_pos_y = data.readFloat();
			_pos_z = data.readFloat();
			_rotation = data.readFloat();
			_size_x = data.readFloat();
			_size_z = data.readFloat();
			_arc = data.readFloat();
			_slope = data.readFloat();
		}
		
		public function overlay(chunk:Chunk):Boolean
		{
			var half_x:Number = _size_x * 0.5;
			var half_z:Number = _size_z * 0.5;
			var mat:Matrix3D = new Matrix3D();
			
			mat.appendRotation(_rotation, Vector3D.Y_AXIS);
			var p:Vector3D = new Vector3D(half_x, 0, half_z);
			var p1:Vector3D = mat.transformVector(p);
			p.x = -half_x;
			var p2:Vector3D = mat.transformVector(p);
			p.z = -half_z;
			var p3:Vector3D = mat.transformVector(p);
			p.x = half_x;
			var p4:Vector3D = mat.transformVector(p);
			
			p1.x += _pos_x;
			p1.z += _pos_z;
			p2.x += _pos_x;
			p2.z += _pos_z;
			p3.x += _pos_x;
			p3.z += _pos_z;
			p4.x += _pos_x;
			p4.z += _pos_z;
			
			if (chunk.inChunkArea(p1.x, p1.z) ||
				chunk.inChunkArea(p2.x, p2.z) ||
				chunk.inChunkArea(p3.x, p3.z) ||
				chunk.inChunkArea(p4.x, p4.z))
				return true;
			
			var x:Number = chunk.idx_x*Terrain.CHUNK_SIZE - chunk.terrain.xChunks*Terrain.HALF_CHUNK_SIZE;
			var z:Number = chunk.idx_z*Terrain.CHUNK_SIZE - chunk.terrain.zChunks*Terrain.HALF_CHUNK_SIZE;
			
			var q1:Vector3D = new Vector3D(x, 0, z);
			var q2:Vector3D = new Vector3D(x+Terrain.CHUNK_SIZE, 0, z);
			var q3:Vector3D = new Vector3D(x+Terrain.CHUNK_SIZE, 0, z+Terrain.CHUNK_SIZE);
			var q4:Vector3D = new Vector3D(x, 0, z+Terrain.CHUNK_SIZE);
			
			if (getHeight(q1.x, q1.z) > -9999 ||
				getHeight(q2.x, q2.z) > -9999 ||
				getHeight(q3.x, q3.z) > -9999 ||
				getHeight(q4.x, q4.z) > -9999)
				return true;
			
			if (intersect(p1, p2, q1, q2))
				return true;	
			if (intersect(p1, p2, q2, q3))
				return true;
			if (intersect(p1, p2, q3, q4))
				return true;
			if (intersect(p1, p2, q4, q1))
				return true;
			
			if (intersect(p2, p3, q1, q2))
				return true;
			if (intersect(p2, p3, q2, q3))
				return true;
			if (intersect(p2, p3, q3, q4))
				return true;
			if (intersect(p2, p3, q4, q1))
				return true;
			
			if (intersect(p3, p4, q1, q2))
				return true;
			if (intersect(p3, p4, q2, q3))
				return true;
			if (intersect(p3, p4, q3, q4))
				return true;
			if (intersect(p3, p4, q4, q1))
				return true;
			
			if (intersect(p4, p1, q1, q2))
				return true;
			if (intersect(p4, p1, q2, q3))
				return true;
			if (intersect(p4, p1, q3, q4))
				return true;
			if (intersect(p4, p1, q4, q1))
				return true;
			
			return false;
		}
		
		private function intersect(a:Vector3D, b:Vector3D, c:Vector3D, d:Vector3D):Boolean
		{
			return intersectSide(a, b, c, d) && intersectSide(c, d, a, b);
		}
		
		//a, b是否在向量c,d的两侧
		private function intersectSide(a:Vector3D, b:Vector3D, c:Vector3D, d:Vector3D):Boolean
		{
			var fc:Vector3D = a.subtract(c).crossProduct(c.subtract(d));
			var fd:Vector3D = b.subtract(c).crossProduct(c.subtract(d));
			
			return fc.dotProduct(fd) < 0;
		}
	}
}