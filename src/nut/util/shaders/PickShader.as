package nut.util.shaders
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.utils.Dictionary;
	
	import nut.core.Mesh;
	import nut.core.Nut;
	import nut.core.NutScene;
	import nut.core.RegState;
	import nut.core.material.RegElem;
	import nut.core.material.ShaderBase;
	import nut.enum.PassType;

	public class PickShader extends ShaderBase
	{
		static private var meshes	:Dictionary = new Dictionary();
		static private var shaders	:Dictionary = new Dictionary();
		
		private var _skeletonShaderPart:SkeletonShaderPart=null;
		private var _color:Vector.<Number> = Vector.<Number>([0, 0, 0, 1]);
		private var _l2sReg:RegElem;
		private var _colorReg :RegElem;
		
		public function PickShader(maxBones:uint, numJoints:uint)
		{
			super('PickShader', PassType.PICK);
			
			if (maxBones != 0)
				_skeletonShaderPart = new SkeletonShaderPart(this.regCache, maxBones, numJoints);
		}
		
		static public function getShader(mesh:Mesh):PickShader
		{
			var id:uint = 0;
			var shader:PickShader = null;
			
			meshes[mesh.id] = mesh;
			
			if (mesh.skinDataProvider != null)
			{
				var maxBones:uint = mesh.geometry.maxBones;
				var numJoints:uint = mesh.skinDataProvider.jointsNum();
				
				id = (maxBones<<16)+numJoints;
				shader = shaders[id];
				
				if (shader == null)
				{
					shader = new PickShader(maxBones, numJoints);
					shaders[id] = shader;
				}
			}
			else
			{
				shader = shaders[id];
				if (shader == null)
				{
					shader = new PickShader(0, 0);
					shaders[id] = shader;
				}
			}
			
			return shader;
		}
		
		static public function getPickMesh(pickId:uint):Mesh
		{
			return meshes[pickId];
		}
		
		override protected function getVertexCode():String
		{
			//这里登记寄存器需求  property -> regElem
			if (_skeletonShaderPart != null)
				_skeletonShaderPart.initConstRegs();
			
			_l2sReg = this.regCache.getVC(4);
			
			var pos	:RegElem = this.regCache.getVA('position', 1);
			var op	:RegElem = this.regCache.getOP();
			
			if (_skeletonShaderPart != null)
			{
				var skinPos:RegElem = this.regCache.getVT();
				_skeletonShaderPart.skin(pos, skinPos);
				op.o = m44(skinPos.o, _l2sReg.o);
			}
			else
			{
				op.o = m44(pos.o, _l2sReg.o);
			}
			
			return regCache.vertexCode;
		}
		
		override protected function getFragmentCode():String
		{
			regCache.switchCode();
			
			_colorReg = this.regCache.getFC(1);
			var oc:RegElem = this.regCache.getOC();
			
			////////////////////////////////////
			oc.o = mov(_colorReg.o);
			
			return regCache.fragmentCode;
		}
		
		override public function render(mesh:Mesh):void
		{
			var scene:NutScene = Nut.scene;
			var context:Context3D = scene.context3D;
			
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, _l2sReg.id, getLocalToScreen(scene.camera, mesh), true);

			var pickId:uint = mesh.id;
			
			_color[0] = (pickId >>> 16) / 255.0;
			_color[1] = ((pickId & 0xFF00) >>> 8) / 255.0;
			_color[2] = (pickId & 0xFF) / 255.0;

			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, _colorReg.id, _color, 1);
			RegState.clear(regCache.va_next, regCache.fs_next);
			mesh.geometry.draw(scene.context3D);
		}
	}
}