package nut.util.shaders.particle
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.utils.Dictionary;
	
	import nut.core.Float4;
	import nut.core.Mesh;
	import nut.core.Nut;
	import nut.core.NutScene;
	import nut.core.NutTexture;
	import nut.core.RegState;
	import nut.core.material.DataProvider;
	import nut.core.material.RegElem;
	import nut.core.material.ShaderBase;
	import nut.enum.Blending;
	import nut.enum.Culling;
	import nut.enum.DepthTest;
	import nut.enum.PassType;
	import nut.ext.effect.particle.BillboardSet;
	import nut.ext.effect.particle.ParticleSystem;
	import nut.util.shaders.particle.color.ColorFadeAffPart;
	import nut.util.shaders.particle.color.ColorRangeInitPart;
	import nut.util.shaders.particle.position.BoxInitPart;
	import nut.util.shaders.particle.position.LinearForceAffPart;
	import nut.util.shaders.particle.rotate.RotateInitPart;
	import nut.util.shaders.particle.scale.ScaleAffPart;
	import nut.util.shaders.particle.scale.ScaleRangeInitPart;

	public class ParticleShader extends ShaderBase
	{
		static private const Mask_BoxInit			:uint = 1 << 0;
		static private const Mask_LinearForce		:uint = 1 << 1;
		static private const Mask_ColorInit			:uint = 1 << 2;
		static private const Mask_LocalSpace		:uint = 1 << 3;
		static private const Mask_ScaleRangeInit	:uint = 1 << 4;
		static private const Mask_RotateInitPart	:uint = 1 << 5;
		static private const Mask_ScaleAffPart		:uint = 1 << 6;
		static private const Mask_ColorFadeAffPart	:uint = 1 << 7;
		
		static private var shaders	:Dictionary = new Dictionary();
		
		private var _boxInitPart		:BoxInitPart 		= null;
		private var _linearForceAffPart	:LinearForceAffPart = null;
		private var _colorRangeInitPart	:ColorRangeInitPart = null;
		private var _scaleRangeInitPart	:ScaleRangeInitPart = null;
		private var _scaleAffPart		:ScaleAffPart		= null;
		private var _rotateInitPart		:RotateInitPart 	= null;
		private var _colorFadeAffPart	:ColorFadeAffPart	= null;
//		private var _currTime:RegElem;
		private var _directionType:int;
		private var _axisData:Vector.<Number> = Vector.<Number>([1,0,0.5,0]);
		private var _axisReg:RegElem;
		private var _localSpace:Boolean = true;
		private var _l2wReg:RegElem;
		private var _w2vReg:RegElem;
		private var _v2sReg:RegElem;
		private var _commonDirReg:RegElem;
		private var _camDirReg:RegElem;
		private var _diffuseMapReg:RegElem;
		private var _uvTimeReg:RegElem;
		private var _rand4VReg:RegElem;
		
		public function ParticleShader(mask:uint, dirType:int)
		{
			super("ParticleShader", PassType.DEPTHSORT);
			_needSave = true;
			
			data.addProperty('diffuseMap', Nut.resMgr.getTexture('default'));
			data.addProperty('directionType', BillboardSet.DT_ORIENTED_CAMERA);
			
			_localSpace = (mask & Mask_LocalSpace) > 0;
			
			_directionType = dirType;
			if(_directionType == BillboardSet.DT_ORIENTED_COMMON || _directionType == BillboardSet.DT_PERPENDICULAR_COMMON)
			{
				data.addProperty('commonDirection', Float4.Y_AXIS);
			}
			
			if ((mask & Mask_BoxInit) > 0)
				_boxInitPart = new BoxInitPart(this);
			
			if ((mask & Mask_LinearForce) > 0)
				_linearForceAffPart = new LinearForceAffPart(this);
			
			if ((mask & Mask_ColorInit) > 0)
				_colorRangeInitPart = new ColorRangeInitPart(this);
			
			if ((mask & Mask_ScaleRangeInit) > 0)
				_scaleRangeInitPart = new ScaleRangeInitPart(this);
			
			if ((mask & Mask_RotateInitPart) > 0)
				_rotateInitPart = new RotateInitPart(this);
			
			if ((mask & Mask_ScaleAffPart) > 0)
				_scaleAffPart = new ScaleAffPart(this);
			
			if ((mask & Mask_ColorFadeAffPart) > 0)
				_colorFadeAffPart = new ColorFadeAffPart(this);
			
			this.defaultSetting.culling = Culling.NONE;
			this.defaultSetting.setBlendMode(Blending.ONE, Blending.ONE);
			this.defaultSetting.setDepthTest(false, DepthTest.LESS_EQUAL);
		}
		
		static public function getShader(ptx:ParticleSystem):ParticleShader
		{
			var data:DataProvider = ptx.material.getData("ParticleShader");
			var mask:uint = 0;
			if (data != null)
			{
				var dirType:int = BillboardSet.DT_ORIENTED_CAMERA;
				if (data.getProperty("directionType") != null)
					dirType = data.getInt("directionType");
				
				if (data.getProperty("boxXRange") != null)
					mask |= Mask_BoxInit;
				
				if (data.getProperty("forceAdj") != null)
					mask |= Mask_LinearForce;
				
				if (data.getProperty("colorMin") != null)
					mask |= Mask_ColorInit;
				
				if (ptx.localSpace)
					mask |= Mask_LocalSpace;
				
				if (data.getProperty("scaleRangeInit") != null)
					mask |= Mask_ScaleRangeInit;
				
				if (data.getProperty("rotation") != null)
					mask |= Mask_RotateInitPart;
				
				if (data.getProperty("scaleAdj") != null)
					mask |= Mask_ScaleAffPart;
				
				if (data.getProperty("colorAdj1") != null)
					mask |= Mask_ColorFadeAffPart;
				
				return new ParticleShader(mask, dirType);
			}
				
			return new ParticleShader(mask, BillboardSet.DT_ORIENTED_CAMERA);
		}
		
		override protected function getVertexCode():String
		{
			///particle///
			var op:RegElem = regCache.getOP();
			var posReg:RegElem = regCache.getVA("position", 1);
			var uv_time:RegElem = regCache.getVA("uv_time", 1);
			var randVAReg:RegElem = regCache.getVA("rand4", 1);
			var position:RegElem = regCache.getVT();
			var direction:RegElem = regCache.getVT();
			
			_uvTimeReg = regCache.getV();
			_rand4VReg = regCache.getV();
			
			_axisReg = regCache.getVC(1);
			_w2vReg = this.regCache.getVC(4);
			_v2sReg = this.regCache.getVC(4);
			if (_localSpace)
				_l2wReg = this.regCache.getVC(4);
			
			position.o = mov(posReg.o);
			
			var temp:RegElem = regCache.getVT();
			temp.x = sub(_axisReg.w, uv_time.w); //粒子已过时间
			temp.y = mov(uv_time.z);			 //粒子寿命
			
			_uvTimeReg.xy = mov(uv_time.xy);
			_uvTimeReg.z = mov(temp.x);
			_uvTimeReg.w = mov(temp.y);
			_rand4VReg.o = mov(randVAReg.o);
			
			direction.o = mov(_axisReg.yyyx);
			direction.w = mov(temp.x);
			regCache.free(temp);
			
			var rand4H:RegElem = null;
			///////boxInitializer//////
			if (_boxInitPart != null)
			{
				if (rand4H == null)
				{
					rand4H = regCache.getVT();
					rand4H.o = mov(randVAReg.o);
					rand4H.o = sub(rand4H.o, _axisReg.zzzz);
				}
				
				_boxInitPart.initPosition(position, rand4H);
			}
			
			///////hollowEllipsoidInitializer//////
			
			///////ringInitializer//////

			//////SpeedBoxInit//////
			
			//////SpeedSphereInitializer//////
			
			////centripetalForceAffector////
			
			////AxisCentripetalForceAffector////
			
			///////linearForceAffector/////////
			if (_linearForceAffPart != null)
			{
				_linearForceAffPart.affPosition(position, direction, _axisReg);
			}
			
			position.w = mov(_axisReg.x);
			var xDir:RegElem = regCache.getVT();
			var yDir:RegElem = regCache.getVT();
			var uvScale:RegElem = regCache.getVT();
			uvScale.xy = mov(uv_time.xy);
			uvScale.xy = sub(uvScale.xy, _axisReg.zz);
			
			var scale:RegElem = null;
			//////ScaleRangeInitializer//////
			if (_scaleRangeInitPart != null)
			{
				if (scale == null)
					scale = regCache.getVT();
				
				_scaleRangeInitPart.getScale(scale, randVAReg);
			}
			
			//////ScaleInterpolateAffector//////
			
			/////////ScaleAffector///////
			if (_scaleAffPart != null)
			{
				if (scale == null)
				{
					scale = regCache.getVT();
					scale.o = mov(_axisReg.xxxx);
				}
				
				_scaleAffPart.affScale(scale, direction);
			}
			
			if (scale != null)
			{
				uvScale.xy = mul(uvScale.xy, scale.xy);
				regCache.free(scale);
			}
			
			if (_directionType == BillboardSet.DT_ORIENTED_COMMON)
			{
				_commonDirReg = regCache.getVC(1);
				_camDirReg = regCache.getVC(1);
				
				yDir.o = mov(_commonDirReg.o);
				xDir.xyz = crs(yDir.xyz, _camDirReg.xyz);
				xDir.xyz = nrm(xDir.xyz);
				
				regCache.free(direction);
				if (rand4H != null)
					regCache.free(rand4H);
				
				if (_rotateInitPart != null)
					_rotateInitPart.rotate(xDir, yDir, direction, randVAReg);
				
				xDir.xyz = mul(xDir.xyz, uvScale.x);
				yDir.xyz = mul(yDir.xyz, uvScale.y);
				
				position.xyz = add(position.xyz, xDir.xyz);
				position.xyz = add(position.xyz, yDir.xyz);
			}
			else if (_directionType == BillboardSet.DT_PERPENDICULAR_COMMON)
			{
				_commonDirReg = regCache.getVC(1);
				
				yDir.xyz = mov(_axisReg.xyy);
				xDir.xyz = crs(_commonDirReg.xyz, yDir.xyy);
				yDir.xyz = crs(yDir.yxz, _commonDirReg.xyz);
				xDir.xyz = add(xDir.xyz, yDir.xyz);
				xDir.xyz = nrm(xDir.xyz);
				yDir.xyz = crs(xDir.xyz, _commonDirReg.xyz);
				
				regCache.free(direction);
				if (rand4H != null)
					regCache.free(rand4H);
				
				if (_rotateInitPart != null)
					_rotateInitPart.rotate(xDir, yDir, direction, randVAReg);
				
				xDir.xyz = mul(xDir.xyz, uvScale.x);
				yDir.xyz = mul(yDir.xyz, uvScale.y);
				
				position.xyz = add(position.xyz, xDir.xyz);
				position.xyz = add(position.xyz, yDir.xyz);
			}
			else if(_directionType == BillboardSet.DT_ORIENTED_SELF)
			{
				_camDirReg = regCache.getVC(1);
				
				yDir.o = mov(direction.o);
				xDir.xyz = crs(yDir.xyz, _camDirReg.xyz);
				xDir.xyz = nrm(xDir.xyz);
				yDir.xyz = nrm(yDir.xyz);
				
				regCache.free(direction);
				if (rand4H != null)
					regCache.free(rand4H);
				
				if (_rotateInitPart != null)
					_rotateInitPart.rotate(xDir, yDir, direction, randVAReg);
				
				xDir.xyz = mul(xDir.xyz, uvScale.x);
				yDir.xyz = mul(yDir.xyz, uvScale.y);
				
				position.xyz = add(position.xyz, xDir.xyz);
				position.xyz = add(position.xyz, yDir.xyz);
			}
			else if(_directionType == BillboardSet.DT_PERPENDICULAR_SELF)
			{
				direction.xyz = nrm(direction.xyz);
				yDir.xyz = mov(_axisReg.xyy);
				xDir.xyz = crs(direction.xyz, yDir.xyy);
				yDir.xyz = crs(yDir.yxz, direction.xyz);
				xDir.xyz = add(xDir.xyz, yDir.xyz);
				xDir.xyz = nrm(xDir.xyz);
				yDir.xyz = crs(xDir.xyz, direction.xyz);
				
				regCache.free(direction);
				if (rand4H != null)
					regCache.free(rand4H);
				
				if (_rotateInitPart != null)
					_rotateInitPart.rotate(xDir, yDir, direction, randVAReg);
				
				xDir.xyz = mul(xDir.xyz, uvScale.x);
				yDir.xyz = mul(yDir.xyz, uvScale.y);
				
				position.xyz = add(position.xyz, xDir.xyz);
				position.xyz = add(position.xyz, yDir.xyz);
			}
			
			if (_localSpace)
				position.o = m44(position.o, _l2wReg.o);
			position.o = m44(position.o, _w2vReg.o);
			
			if (_directionType == BillboardSet.DT_ORIENTED_CAMERA)
			{
				xDir.o = mov(_axisReg.xyyx);
				yDir.o = mov(_axisReg.yxyx);
				
				regCache.free(direction);
				if (rand4H != null)
					regCache.free(rand4H);
				
				if (_rotateInitPart != null)
					_rotateInitPart.rotate(xDir, yDir, direction, randVAReg);
				
				xDir.xyz = mul(xDir.xyz, uvScale.x);
				yDir.xyz = mul(yDir.xyz, uvScale.y);
				
				position.xyz = add(position.xyz, xDir.xyz);
				position.xyz = add(position.xyz, yDir.xyz);
			}
			
			regCache.free(uvScale);
		
			direction.w = slt(direction.w, uv_time.z); //粒子是否没过期
			position.o = mul(position.o, direction.w);
			
			op.o = m44(position.o, _v2sReg.o);
			
			return regCache.vertexCode;
		}
		
		override protected function getFragmentCode():String
		{
			regCache.switchCode();
			
			var oc:RegElem = this.regCache.getOC();
			_diffuseMapReg = this.regCache.getFS();
			var diffuseColor:RegElem = this.regCache.getFT();
			
			diffuseColor.o = tex(_uvTimeReg.xy, _diffuseMapReg.o, "<2d, repeat, linear, miplinear>");
			
			var color:RegElem = null;
			////colorRangeInitializer///
			if (_colorRangeInitPart != null)
			{
				if (color == null)
					color = regCache.getFT();
				_colorRangeInitPart.getColor(color, _rand4VReg);
			}
			
			///colorFadeAffector///
			if (_colorFadeAffPart != null)
			{
				if (color == null)
				{
					color = regCache.getFT();
					color.o = mov(_rand4VReg.o);
				}
				
				_colorFadeAffPart.affColor(color, _uvTimeReg);
			}
			
			///colorInterpolatorAffector///
			
			if (color != null)
				diffuseColor.o = mul(diffuseColor.o, color.o);
			
			oc.o = mov(diffuseColor.o);
			
			return regCache.fragmentCode;
		}
		
		override public function render(mesh:Mesh):void
		{
			var scene:NutScene = Nut.scene;
			var context:Context3D = scene.context3D;
			
			if (_localSpace)
				context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, _l2wReg.id, mesh.localToWorld, true);
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, _w2vReg.id, scene.camera.worldToView, true);
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, _v2sReg.id, scene.camera.project, true);
			
			_axisData[3] = (mesh as ParticleSystem).currTime;
			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, _axisReg.id, _axisData);
			
			if (_directionType == BillboardSet.DT_ORIENTED_COMMON || _directionType == BillboardSet.DT_PERPENDICULAR_COMMON)
			{
				var commonDir:Float4 = mesh.material.getFloat4(name, "commonDirection");
				context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, _commonDirReg.id, commonDir.data);
			}
			if (_directionType == BillboardSet.DT_ORIENTED_COMMON || _directionType == BillboardSet.DT_ORIENTED_SELF)
			{
				context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, _camDirReg.id, scene.camera.forward.data);
			}
			
			if (_boxInitPart != null)
			{
				_boxInitPart.setupConstants(context, mesh.material);
			}
			
			if (_linearForceAffPart != null)
			{
				_linearForceAffPart.setupConstants(context, mesh.material);
			}
			
			if (_colorRangeInitPart != null)
			{
				_colorRangeInitPart.setupConstants(context, mesh.material);
			}
			
			if (_scaleRangeInitPart != null)
			{
				_scaleRangeInitPart.setupConstants(context, mesh.material);
			}
			
			if (_rotateInitPart != null)
			{
				_rotateInitPart.setupConstants(context, mesh.material);
			}
			
			if (_scaleAffPart != null)
			{
				_scaleAffPart.setupConstants(context, mesh.material);
			}
			
			if (_colorFadeAffPart != null)
			{
				_colorFadeAffPart.setupConstants(context, mesh.material);
			}
			
			var texture:NutTexture = mesh.material.getTexture(this.name, 'diffuseMap');
			RegState.setTextureAt(_diffuseMapReg.id, texture);
			
			RegState.clear(regCache.va_next, regCache.fs_next);
			mesh.geometry.draw(context);
		}
	}
}