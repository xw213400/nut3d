package nut.core.light
{
	import flash.display3D.Context3D;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import nut.core.Frustum;
	import nut.core.Mesh;
	import nut.core.Nut;
	import nut.core.NutScene;
	import nut.core.NutTexture;
	import nut.core.RenderQueue;
	import nut.core.RenderSetting;
	import nut.enum.PassType;
	import nut.util.shaders.ShadowMapShader;

	public class DirectionLight extends LightBase
	{
		private static const SCREEN_TO_UV:Matrix3D	= new Matrix3D(Vector.<Number>([
			.5,		.0,		.0,		.0,
			.0, 	-.5,	.0,		.0,
			.0,		.0,		1,	.0,
			.5, 	.5,		0,	1.])
		);
		
		public var shadowmapSize:uint	= 1024;
		
		private var _diffuse	:Number	= 1.0;
		private var _specular	:Number = 1.0;
		private var _shininess	:Number = 50;
		
		private var _transform		:Matrix3D	= new Matrix3D();
		private var _worldToView	:Matrix3D	= new Matrix3D();
		private var _project		:Matrix3D	= new Matrix3D();
		private var _worldToScreen	:Matrix3D	= new Matrix3D();
		private var _worldToUV		:Matrix3D	= new Matrix3D();
		
		private var _zFar:Number = 100;
		private var _width:Number = 20;
		
		private var _frustum	:Frustum	= new Frustum();
		
		private var _shadowMap	:NutTexture	= new NutTexture(1024, 1024);
		
		public function DirectionLight(castShadow:Boolean=false)
		{
			super(castShadow);
			
			setTo(new Vector3D(0, 20, 20), new Vector3D(0,0,0), new Vector3D(0,1,0))
		}
		
		public function get worldToView():Matrix3D
		{
			return _worldToView;
		}

		public function setTo(eye:Vector3D, lookAt:Vector3D, up:Vector3D):void
		{
			var z:Vector3D = lookAt.subtract(eye);
			
			z.normalize();
			z.w = 0.0;
			
			var x:Vector3D = z.crossProduct(up);
			
			x.normalize();
			x.w = 0.0;
			
			var y:Vector3D = x.crossProduct(z);
			y.w = 0.0;
			
			eye.w = 1.0;
			
			_transform.copyColumnFrom(0,x);
			_transform.copyColumnFrom(1,y);
			_transform.copyColumnFrom(2,z);
			_transform.copyColumnFrom(3,eye);
		}
		
		public function get worldToUV():Matrix3D
		{
			return _worldToUV;
		}

		public function get worldToScreen():Matrix3D
		{
			return _worldToScreen;
		}
		
		public function get shadowMap():NutTexture
		{
			return _shadowMap;
		}

		public function get transform():Matrix3D
		{
			return _transform;
		}

		public function get shininess():Number
		{
			return _shininess;
		}

		public function set shininess(value:Number):void
		{
			_shininess = value;
		}

		public function get specular():Number
		{
			return _specular;
		}

		public function set specular(value:Number):void
		{
			_specular = value;
		}

		public function get diffuse():Number
		{
			return _diffuse;
		}

		public function set diffuse(value:Number):void
		{
			_diffuse = value;
		}
		
		public function getLightDirection():Vector3D
		{
			var dir:Vector3D = _transform.deltaTransformVector(Vector3D.Z_AXIS);
			dir.negate();
			
			return dir;
		}
		
		override public function renderShadowMap():void
		{
//			if (_shadowMap == null)
//			{
//				_shadowMap = new NutTexture(shadowmapSize, shadowmapSize);
				
				_project.copyRawDataFrom(Vector.<Number>([
					2. / _width, 	0., 			0.,			0.,
					0., 			2. / _width, 	0.,			0.,
					0., 			0., 			1./_zFar,  0.,
					0., 			0., 			0.,			1.])
				);
				
				_worldToView.copyFrom(_transform);
				_worldToView.invert();
				
				_worldToScreen.copyFrom(_worldToView);
				_worldToScreen.append(_project);
				
				_worldToUV.copyFrom(_worldToScreen);
				_worldToUV.append(SCREEN_TO_UV);
//			}

			var context:Context3D = Nut.scene.context3D;
			context.setRenderToTexture(_shadowMap.getTexture(context), true);
			context.configureBackBuffer(_shadowMap.width, _shadowMap.height, 0);
			context.clear(0, 0, 0, 0);
			
			ShadowMapShader.light = this;

			for each (var mesh:Mesh in _meshes)
			{
				if (mesh.visible && mesh.material.castShadow)
				{
					var shader:ShadowMapShader = ShadowMapShader.getShader(mesh);
					var setting:RenderSetting = shader.defaultSetting;
					
					setting.apply()
					shader.apply();
					
					shader.setupVertexAttribute(mesh.geometry);
					shader.render(mesh);
				}
			}
			
			context.setRenderToBackBuffer();
			Nut.scene.viewport.configureBackBuffer();
		}
	}
}