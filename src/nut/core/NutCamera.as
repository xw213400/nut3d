package nut.core
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;

	public class NutCamera
	{
		private var _transform		:Matrix3D	= new Matrix3D();
		private var _project		:Matrix3D	= new Matrix3D();
		private var _worldToView	:Matrix3D	= new Matrix3D();
		private var _worldToScreen	:Matrix3D	= new Matrix3D();
		private var _forward		:Float4		= new Float4();
		private var _right			:Float4		= new Float4();
		private var _up				:Float4		= new Float4();
		
		private var _frustum	:Frustum	= new Frustum();
		
		private var _fov	:Number = Math.PI*0.25;
		private var _ratio	:Number = 0.75;
		private var _near	:Number = 0.1;
		private var _far	:Number = 1000;
		
		public function NutCamera()
		{
		}

		public function get up():Float4
		{
			return _up;
		}

		public function get right():Float4
		{
			return _right;
		}

		public function get forward():Float4
		{
			return _forward;
		}

		public function get worldToScreen():Matrix3D
		{
			return _worldToScreen;
		}

		public function get worldToView():Matrix3D
		{
			return _worldToView;
		}

		public function get transform():Matrix3D
		{
			return _transform;
		}

		public function get project():Matrix3D
		{
			return _project;
		}

		public function get frustum():Frustum
		{
			return _frustum;
		}
		
		public function get position():Vector3D
		{
			return _transform.position;
		}
		
		public function setTo(eye:Vector3D, lookAt:Vector3D, up:Vector3D):void
		{
			var z:Vector3D = eye.subtract(lookAt);
			
			z.normalize();
			z.w = 0.0;
			
			var x:Vector3D = up.crossProduct(z);
			
			x.normalize();
			x.w = 0.0;
			
			var y:Vector3D = z.crossProduct(x);
			y.w = 0.0;
			
			eye.w = 1.0;
			
			_transform.copyColumnFrom(0,x);
			_transform.copyColumnFrom(1,y);
			_transform.copyColumnFrom(2,z);
			_transform.copyColumnFrom(3,eye);
			
			_worldToView.copyFrom(_transform);
			_worldToView.invert();
			
			_worldToScreen.copyFrom(_worldToView);
			_worldToScreen.append(_project);
			
			_forward.copyV3D(z);
			_forward.negate();
			_right.copyV3D(x);
			_up.copyV3D(y);
		}
		
		/** 
		 * 使用右手坐标系，和openGL,collada保持一致
		 * 
		 * @param fov	垂直方向角度
		 * @param ratio 高/宽
		 * @param near	近截面
		 * @param far	远截面
		 * 
		 */		
		public function perspective(fov:Number, ratio:Number, near:Number, far:Number):void
		{
			_fov = fov;
			_ratio = ratio;
			_near = near;
			_far = far;
			
			var f:Number = 1.0/Math.tan(fov*0.5);
			var nr:Number = 1.0/(near-far);

			_project.copyRawDataFrom(Vector.<Number>([
				f*ratio,0,		0,					0,
				0,		f,		0,					0,
				0,		0,		(far+near)*nr,		-1,
				0,		0,		2*near*far*nr,		0
			]));
			
			_worldToScreen.copyFrom(_worldToView);
			_worldToScreen.append(_project);
		}
		
		public function ortho(w:Number, h:Number, near:Number, far:Number):void
		{
			var nr :Number = 1.0/(near-far);
			
			_project.copyRawDataFrom(Vector.<Number>([
				2/w,	0,		0,		0,
				0,		2/h,	0,		0,
				0,		0,		nr,		0,
				0,		0,		near*nr,1
			]));
			
			_worldToScreen.copyFrom(_worldToView);
			_worldToScreen.append(_project);
		}
		
		public function unproject(xPercent:Number, yPercent:Number, vn:Vector3D, vf:Vector3D):void
		{
			var tanHalfFov :Number = Math.tan(_fov*0.5);
			var xp :Number = 2.0 * (xPercent-0.5);
			var yp :Number = 2.0 * (yPercent-0.5);
			var dx :Number = tanHalfFov * xp / _ratio;
			var dy :Number = -tanHalfFov * yp;
			
			//默认指向-z轴
			vn.setTo(dx*_near, dy*_near, -_near);
			vf.setTo(dx*_far, dy*_far, -_far);
			
			vn.copyFrom(_transform.transformVector(vn));
			vf.copyFrom(_transform.transformVector(vf));
		}
	}
}