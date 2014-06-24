package nut.util.shaders
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.geom.Vector3D;
	
	import nut.core.RegState;
	import nut.core.light.DirectionLight;
	import nut.core.material.Expression;
	import nut.core.material.Instruction;
	import nut.core.material.RegCache;
	import nut.core.material.RegElem;
	
	public class SoftShadowShaderPart extends Expression
	{
		private var _regCache:RegCache;
		private var _shadowMapReg:RegElem;
		private var _worldToUVReg:RegElem;
		private var _uv:RegElem;
		private var _bitSh:Vector.<Number> = Vector.<Number>([1. / (256. * 256. * 256.), 1. / (256. * 256.), 1. / 256., 1.]);
		private var _uvDelta:Vector.<Number> = Vector.<Number>([-1./1024., 0, 1./1024., 0.2]);
		private var _bitShReg:RegElem;
		private var _uvDeltaReg:RegElem;
		
		public function SoftShadowShaderPart(regCache:RegCache)
		{
			super();
			_regCache = regCache;
		}
		
		public function genVertextCode(worldPos:RegElem):void
		{
			_worldToUVReg = _regCache.getVC(4);
			_uv = _regCache.getV();
			
			_uv.o = m44(worldPos.o, _worldToUVReg.o);
		}
		
		public function getShadowFactor(shadowFactor:RegElem):void
		{
			_shadowMapReg = _regCache.getFS();
			_bitShReg = _regCache.getFC(1);
			_uvDeltaReg = _regCache.getFC(1);
			
			var depth:RegElem = _regCache.getFT();
			var uvt:RegElem = _regCache.getFT();
			
			depth.o = tex(_uv.xy, _shadowMapReg.o, "<2d,disable,clamp>");
			depth.w = dp4(depth.o, _bitShReg.o);
			shadowFactor.w = sge(depth.w, _uv.z);
			
			uvt.xy = add(_uv.xy, _uvDeltaReg.xy);
			depth.o = tex(uvt.xy, _shadowMapReg.o, "<2d,disable,clamp>");
			depth.w = dp4(depth.o, _bitShReg.o);
			depth.w = sge(depth.w, _uv.z);
			shadowFactor.w = add(depth.w, shadowFactor.w);
			
			uvt.xy = add(_uv.xy, _uvDeltaReg.zy);
			depth.o = tex(uvt.xy, _shadowMapReg.o, "<2d,disable,clamp>");
			depth.w = dp4(depth.o, _bitShReg.o);
			depth.w = sge(depth.w, _uv.z);
			shadowFactor.w = add(depth.w, shadowFactor.w);
			
			uvt.xy = add(_uv.xy, _uvDeltaReg.yx);
			depth.o = tex(uvt.xy, _shadowMapReg.o, "<2d,disable,clamp>");
			depth.w = dp4(depth.o, _bitShReg.o);
			depth.w = sge(depth.w, _uv.z);
			shadowFactor.w = add(depth.w, shadowFactor.w);
			
			uvt.xy = add(_uv.xy, _uvDeltaReg.yz);
			depth.o = tex(uvt.xy, _shadowMapReg.o, "<2d,disable,clamp>");
			depth.w = dp4(depth.o, _bitShReg.o);
			depth.w = sge(depth.w, _uv.z);
			shadowFactor.w = add(depth.w, shadowFactor.w);

			shadowFactor.w = mul(shadowFactor.w, _uvDeltaReg.w);
			
			_regCache.free(depth);
			_regCache.free(uvt);
		}
		
		public function setupConsts(context:Context3D, directionLight:DirectionLight):void
		{
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, _worldToUVReg.id, directionLight.worldToUV, true);
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, _bitShReg.id, _bitSh, 1);
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, _uvDeltaReg.id, _uvDelta, 1);
			RegState.setTextureAt(_shadowMapReg.id, directionLight.shadowMap);
		}
	}
}