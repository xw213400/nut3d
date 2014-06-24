package nut.util.shaders
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.utils.Dictionary;
	
	import nut.core.Mesh;
	import nut.core.Nut;
	import nut.core.NutScene;
	import nut.core.NutTexture;
	import nut.core.RegState;
	import nut.core.material.RegElem;
	import nut.core.material.ShaderBase;
	
	public class SkeletonDiffuseShader extends ShaderBase
	{
		static private var shaders:Dictionary = new Dictionary();
		
		private var _uvData:RegElem;
		private var _defualtPos:RegElem;
		private var _skeletonShaderPart:SkeletonShaderPart=null;
		private var _l2sReg:RegElem;
		private var _diffuseMapReg:RegElem;
		
		public function SkeletonDiffuseShader(maxBones:uint, numJoints:uint)
		{
			super('SkeletonDiffuseShader');
			data.addProperty('diffuseMap', Nut.resMgr.getTexture('default'));
			_skeletonShaderPart = new SkeletonShaderPart(this.regCache, maxBones, numJoints);
		}
		
		static public function getShader(maxBones:uint, numJoints:uint):SkeletonDiffuseShader
		{
			var id:uint = (maxBones<<16)+numJoints;
			var shader:SkeletonDiffuseShader = shaders[id];
			
			if (shader == null)
			{
				shader = new SkeletonDiffuseShader(maxBones, numJoints);
				shaders[id] = shader;
			}
			
			return shader;
		}

		override protected function getVertexCode():String
		{
			//这里登记寄存器需求  property -> regElem
			_skeletonShaderPart.initConstRegs();
			
			_l2sReg = this.regCache.getVC(4);
			
			var pos	:RegElem = this.regCache.getVA('position', 1);
			var uv	:RegElem = this.regCache.getVA('uv', 1);
			var op	:RegElem = this.regCache.getOP();
			
			var skinPos:RegElem = this.regCache.getVT();
			
			_skeletonShaderPart.skin(pos, skinPos);
			
			_uvData = this.regCache.getV();
			
			op.o = m44(skinPos.o, _l2sReg.o);
			_uvData.o = mov(uv.o);
			
			trace(regCache.vertexCode);
			
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
			oc.o = mov(diffuseColor.o);
			
			trace(regCache.fragmentCode);
			
			return regCache.fragmentCode;
		}
		
		override public function render(mesh:Mesh):void
		{
			var scene:NutScene = Nut.scene;
			var context:Context3D = scene.context3D;
			
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, _l2sReg.id, getLocalToScreen(scene.camera, mesh), true);
			_skeletonShaderPart.setupJointMatrices(scene.context3D, mesh);
			
			var texture:NutTexture = mesh.material.getTexture(this.name, 'diffuseMap');
			RegState.setTextureAt(_diffuseMapReg.id, texture);
			
			RegState.clear(regCache.va_next, regCache.fs_next);
			mesh.geometry.draw(scene.context3D);
		}
	}
}