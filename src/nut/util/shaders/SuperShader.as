package nut.util.shaders
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.utils.Dictionary;
	
	import nut.core.Mesh;
	import nut.core.Nut;
	import nut.core.NutCamera;
	import nut.core.NutScene;
	import nut.core.NutTexture;
	import nut.core.RegState;
	import nut.core.material.Material;
	import nut.core.material.RegElem;
	import nut.core.material.ShaderBase;
	
	public class SuperShader extends ShaderBase
	{
		static private var shaders:Dictionary = new Dictionary();
		
		private var _uvData:RegElem;
		private var _normalData:RegElem;
		private var _worldPosData:RegElem;
		private var _defualtPos:RegElem;
		private var _skeletonShaderPart:SkeletonShaderPart=null;
		private var _phongShaderPart:PhongShaderPart = null;
		private var _l2wReg:RegElem;
		private var _w2sReg:RegElem;
		private var _diffuseMapReg:RegElem;
		
		public function SuperShader(id:uint, material:Material)
		{
			super('SuperShader');
			
			_needSave = true;
			
			var numJoints:uint = id&0x0000003F;
			var maxBones :uint = (id&0x000003C0)>>>6;
			var phongId  :uint = (id&0x0003FC00)>>>10;
			
			data.addProperty('diffuseMap', Nut.resMgr.getTexture('default'));
			
			if (maxBones > 0 && numJoints > 0)
				_skeletonShaderPart = new SkeletonShaderPart(this.regCache, maxBones, numJoints);
			
			if (phongId > 0)
				_phongShaderPart = new PhongShaderPart(this, material);
		}
		
		//0~5 numJoints
		//6~9 maxBones
		//10~17 phongId
		static public function getShader(mesh:Mesh):SuperShader
		{
			var id:uint = 0;
			var maxBones:uint = mesh.geometry.maxBones;
			var numJoints:uint = 0;
			if (mesh.skinDataProvider != null)
				numJoints = mesh.skinDataProvider.jointsNum();
			var phongId:uint = PhongShaderPart.getID(mesh.material);
			
			id = (phongId<<10)|(maxBones<<6)|numJoints;
			
			var shader:SuperShader = shaders[id];
			
			if (shader == null)
			{
				shader = new SuperShader(id, mesh.material);
				shaders[id] = shader;
			}
			
			return shader;
		}
		
		override protected function getVertexCode():String
		{
			//这里登记寄存器需求  property -> regElem
			if (_skeletonShaderPart != null)
				_skeletonShaderPart.initConstRegs();
			
			_l2wReg = this.regCache.getVC(4);
			_w2sReg = this.regCache.getVC(4);
			
			var pos	:RegElem = this.regCache.getVA('position', 1);
			var nor	:RegElem = this.regCache.getVA('normal', 1);
			var uv	:RegElem = this.regCache.getVA('uv', 1);
			var op	:RegElem = this.regCache.getOP();
			
			var skinPos:RegElem = this.regCache.getVT();
			
			if (_skeletonShaderPart != null)
				_skeletonShaderPart.skin(pos, skinPos);
			else
				skinPos.o = mov(pos.o);
			
			_uvData = this.regCache.getV();
			_normalData = this.regCache.getV();
			_worldPosData = this.regCache.getV();
			
			skinPos.o = m44(skinPos.o, _l2wReg.o);
			_worldPosData.o = mov(skinPos.o);
			op.o = m44(skinPos.o, _w2sReg.o);
			
			if (_phongShaderPart != null)
				_phongShaderPart.genVertexCode(skinPos);
			
			_uvData.o = mov(uv.o);
			
			if (_skeletonShaderPart != null)
				_skeletonShaderPart.skinNorm(nor, skinPos);
			else
				skinPos.o = mov(nor.o);
			
			skinPos.xyz = m33(skinPos.o, _l2wReg.o);
			_normalData.xyz = nrm(skinPos.o);
			_normalData.w = mov(skinPos.w);
			
			return regCache.vertexCode;
		}
		
		override protected function getFragmentCode():String
		{
			regCache.switchCode();
			
			_diffuseMapReg = this.regCache.getFS();
			var diffuseColor:RegElem = this.regCache.getFT();
			var oc:RegElem = this.regCache.getOC();
			
			////////////////////////////////////
			diffuseColor.o = tex(_uvData.xy, _diffuseMapReg.o, "<2d,repeat,linear,miplinear>");
			
			if (_phongShaderPart != null)
			{
				var lightColor:RegElem = this.regCache.getFT();
				_phongShaderPart.getColor(_normalData, _worldPosData, lightColor);
				diffuseColor.xyz = mul(diffuseColor.xyz, lightColor.xyz);
			}
			
			oc.o = mov(diffuseColor.o);
			
			return regCache.fragmentCode;
		}
		
		override public function render(mesh:Mesh):void
		{
			var scene:NutScene = Nut.scene;
			var context:Context3D = scene.context3D;
			var camera:NutCamera = scene.camera;
			
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, _l2wReg.id, mesh.localToWorld, true);
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, _w2sReg.id, camera.worldToScreen, true);
			
			if (_skeletonShaderPart != null)
				_skeletonShaderPart.setupJointMatrices(context, mesh);
			
			if (_phongShaderPart != null)
				_phongShaderPart.setupLightConst(context, mesh.material, camera);
			
			var texture:NutTexture = mesh.material.getTexture(this.name, 'diffuseMap');
			RegState.setTextureAt(_diffuseMapReg.id, texture);
			
			RegState.clear(regCache.va_next, regCache.fs_next);
			mesh.geometry.draw(context);
		}
	}
}