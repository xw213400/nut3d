package nut.util.shaders
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	
	import nut.core.Mesh;
	import nut.core.material.Expression;
	import nut.core.material.RegCache;
	import nut.core.material.RegElem;
	
	public class SkeletonShaderPart extends Expression
	{
		static private const jointAttrs:Vector.<String> = Vector.<String>(['bone12', 'bone34', 'bone56', 'bone78']);
		static private const _defualtPosData:Vector.<Number> = Vector.<Number>([0,0,0,1]);
		
		private var _maxBones:uint;
		private var _numJoints:uint;
		private var _defualtPos:RegElem;
		private var _jointMatrices:RegElem;
		private var _jointAttrs:Vector.<RegElem> = new Vector.<RegElem>();
		private var _regCache:RegCache;
		
		public function SkeletonShaderPart(regCache:RegCache, maxBones:uint, numJoints:uint)
		{
			super();
			_regCache = regCache;
			_maxBones = maxBones;
			_numJoints = numJoints;
			
			for (var i:uint = 0; i < (_maxBones>>1); ++i)
			{
				_jointAttrs.push( _regCache.getVA(jointAttrs[i], 1) );
			}
		}
		
		public function initConstRegs():void
		{
			_jointMatrices = _regCache.getVC(_numJoints*3);
			_defualtPos = _regCache.getVC(1);
		}
		
		public function skin(inData:RegElem, outData:RegElem):void
		{
			var jointOutVertexPosition:RegElem = _regCache.getVT();
			
			for (var i:uint = 0; i < (_maxBones>>1); ++i)
			{
				var jointAttr:RegElem = _jointAttrs[i];
				
				jointOutVertexPosition.o = mov(_defualtPos.o);
				jointOutVertexPosition.xyz = m34(inData.o, _jointMatrices.o, jointAttr.x);
				jointOutVertexPosition.o = mul(jointOutVertexPosition.o, jointAttr.y);
				
				if (i == 0)
					outData.o = mov(jointOutVertexPosition.o);
				else
					outData.o = add(outData.o, jointOutVertexPosition.o);
				
				jointOutVertexPosition.o = mov(_defualtPos.o);
				jointOutVertexPosition.xyz = m34(inData.o, _jointMatrices.o, jointAttr.z);
				jointOutVertexPosition.o = mul(jointOutVertexPosition.o, jointAttr.w);
				
				outData.o = add(outData.o, jointOutVertexPosition.o);
			}
			
			_regCache.free(jointOutVertexPosition);
		}
		
		public function skinNorm(inData:RegElem, outData:RegElem):void
		{
			var jointOutVertexPosition:RegElem = _regCache.getVT();
			
			for (var i:uint = 0; i < (_maxBones>>1); ++i)
			{
				var jointAttr:RegElem = _jointAttrs[i];
				
				jointOutVertexPosition.o = mov(_defualtPos.o);
				jointOutVertexPosition.xyz = m33(inData.o, _jointMatrices.o, jointAttr.x);
				jointOutVertexPosition.o = mul(jointOutVertexPosition.o, jointAttr.y);
				
				if (i == 0)
					outData.o = mov(jointOutVertexPosition.o);
				else
					outData.o = add(outData.o, jointOutVertexPosition.o);
				
				jointOutVertexPosition.o = mov(_defualtPos.o);
				jointOutVertexPosition.xyz = m33(inData.o, _jointMatrices.o, jointAttr.z);
				jointOutVertexPosition.o = mul(jointOutVertexPosition.o, jointAttr.w);
				
				outData.o = add(outData.o, jointOutVertexPosition.o);
			}
			
			_regCache.free(jointOutVertexPosition);
		}
		
		public function setupJointMatrices(context3D:Context3D, mesh:Mesh):void
		{
			var matrices:Vector.<Number> = mesh.skinDataProvider.matrices;
			
			context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, _jointMatrices.id, matrices, _numJoints*3);
			context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, _defualtPos.id, _defualtPosData, 1);
		}
	}
}