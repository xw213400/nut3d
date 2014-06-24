package nut.util.shaders
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.utils.Dictionary;
	
	import nut.core.Mesh;
	import nut.core.Nut;
	import nut.core.NutCamera;
	import nut.core.NutScene;
	import nut.core.RegState;
	import nut.core.light.DirectionLight;
	import nut.core.material.RegElem;
	import nut.core.material.ShaderBase;
	import nut.enum.PassType;
	
	public class ShadowMapShader extends ShaderBase
	{
		static private var shaders:Dictionary = new Dictionary();
		static public var light:DirectionLight = null;
		
		private var _skeletonShaderPart:SkeletonShaderPart=null;
		private var _depthData:RegElem;
		private var _bitSh:Vector.<Number> = Vector.<Number>([256. * 256. * 256., 256. * 256, 256., 1.]);
		private var _bitMask:Vector.<Number> = Vector.<Number>([0., 1. / 256., 1. / 256., 1. / 256.]);
		private var _l2wReg:RegElem;
		private var _w2sReg:RegElem;
		private var _bitShReg:RegElem;
		private var _bitMaskReg:RegElem;
		
		public function ShadowMapShader(maxBones:uint, numJoints:uint)
		{
			super("ShadowMapShader");
			if (maxBones > 0 && numJoints > 0)
				_skeletonShaderPart = new SkeletonShaderPart(this.regCache, maxBones, numJoints);
		}
		
		static public function getShader(mesh:Mesh):ShadowMapShader
		{
			var maxBones:uint = mesh.geometry.maxBones;
			var numJoints:uint = 0;
			if (mesh.skinDataProvider != null)
				numJoints = mesh.skinDataProvider.jointsNum();
			
			var id:uint = (maxBones<<16)+numJoints;
			var shader:ShadowMapShader = shaders[id];
			
			if (shader == null)
			{
				shader = new ShadowMapShader(maxBones, numJoints);
				shaders[id] = shader;
			}
			
			return shader;
		}
		
		override protected function getVertexCode():String
		{
			if (_skeletonShaderPart != null)
				_skeletonShaderPart.initConstRegs();
			
			_l2wReg = this.regCache.getVC(4);
			_w2sReg = this.regCache.getVC(4);
			
			var pos	:RegElem = this.regCache.getVA('position', 1);
			var op	:RegElem = this.regCache.getOP();
			
			var skinPos:RegElem = this.regCache.getVT();
			
			if (_skeletonShaderPart != null)
				_skeletonShaderPart.skin(pos, skinPos);
			else
				skinPos.o = mov(pos.o);
			
			_depthData = this.regCache.getV();
			
			skinPos.o = m44(skinPos.o, _l2wReg.o);
			skinPos.o = m44(skinPos.o, _w2sReg.o);
			op.o = mov(skinPos.o);
			_depthData.o = mov(skinPos.o);
			
			return regCache.vertexCode;
		}
		
		override protected function getFragmentCode():String
		{
			regCache.switchCode();
			
			_bitShReg = regCache.getFC(1);
			_bitMaskReg = regCache.getFC(1);
			
			var temp1:RegElem = this.regCache.getFT();
			var temp2:RegElem = this.regCache.getFT();
			var oc:RegElem = this.regCache.getOC();
			
			temp1.o = mul(_bitShReg.o, _depthData.z);
			temp1.o = frc(temp1.o);
			temp2.o = mul(temp1.xxyz, _bitMaskReg.o);
			
			oc.o = sub(temp1.o, temp2.o);
			
			return regCache.fragmentCode;
		}
		
		override public function render(mesh:Mesh):void
		{
			var context:Context3D = Nut.scene.context3D;
			
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, _bitShReg.id, _bitSh, 1);
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, _bitMaskReg.id, _bitMask, 1);
			
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, _l2wReg.id, mesh.localToWorld, true);
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, _w2sReg.id, light.worldToScreen, true);
			
			RegState.clear(regCache.va_next, regCache.fs_next);
			mesh.geometry.draw(context);
		}
	}
}