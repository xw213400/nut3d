package nut.util.camera
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import nut.core.NutCamera;

	public class ArcCameraController
	{
		private var _camera		:NutCamera;
		private var _eye		:Vector3D;
		private var _lookAt		:Vector3D;
		private var _up			:Vector3D;
		private var _forward	:Vector3D;
		private var _right		:Vector3D;
		static private var MATRIX	:Matrix3D = new Matrix3D();
		
		public function ArcCameraController(camera:NutCamera, eye:Vector3D, lookAt:Vector3D, up:Vector3D)
		{
			_camera = camera;
			_eye = eye.clone();
			_lookAt = lookAt.clone();
			_up = up.clone();
			_forward = _lookAt.subtract(_eye);
			_right = _forward.crossProduct(_up);
			
			_camera.setTo(_eye, _lookAt, _up);
		}
		
		public function get right():Vector3D
		{
			return _right;
		}

		public function get forward():Vector3D
		{
			return _forward;
		}

		public function get camera():NutCamera
		{
			return _camera;
		}

		public function zoom(ratio:Number):void
		{
			_forward = _lookAt.subtract(_eye);
			var len :Number = _forward.normalize() * ratio;
			
			_forward.scaleBy(len);
			_eye = _lookAt.subtract(_forward);
			
			_camera.setTo(_eye, _lookAt, _up);
		}
		
		public function move(x:Number, y:Number, z:Number):void
		{
			_lookAt.x += x;
			_lookAt.y += y;
			_lookAt.z += z;
			
			_eye = _lookAt.subtract(_forward);
			
			_camera.setTo(_eye, _lookAt, _up);
		}
		
		public function rotV(degree:Number):void
		{
			MATRIX.identity();
			MATRIX.appendRotation(degree, _right);
			
			_forward = MATRIX.transformVector(_forward);
			_eye = _lookAt.subtract(_forward);
			_up = MATRIX.transformVector(_up);

			_camera.setTo(_eye, _lookAt, _up);
		}
		
		public function rotH(degree:Number):void
		{
			MATRIX.identity();
			MATRIX.appendRotation(degree, Vector3D.Y_AXIS);
			
			_forward = MATRIX.transformVector(_forward);
			_eye = _lookAt.subtract(_forward);
			_up = MATRIX.transformVector(_up);
			_right = _forward.crossProduct(_up);
			
			_camera.setTo(_eye, _lookAt, _up);
		}
	}
}