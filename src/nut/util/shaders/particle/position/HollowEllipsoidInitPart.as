package nut.util.shaders.particle.position
{
	import nut.core.material.Expression;
	import nut.core.Float4;
	import nut.core.material.Material;
	import nut.core.material.RegCache;
	import nut.core.material.RegElem;
	import nut.core.material.ShaderBase;
	
	public class HollowEllipsoidInitPart extends Expression
	{
		private var _hollowXRange:RegElem;
		private var _hollowYRange:RegElem;
		private var _hollowZRange:RegElem;
		private var _regCache:RegCache;
		private var _shaderName:String;
		
		public function HollowEllipsoidInitPart(shader:ShaderBase)
		{
			_regCache = shader.regCache;
			_shaderName = shader.name;
			shader.data.addProperty("hollowXRange", new Float4());
			shader.data.addProperty("hollowYRange", new Float4());
			shader.data.addProperty("hollowZRange", new Float4());
		}
		
		public function affectPosition(posReg:RegElem, randReg:RegElem):void
		{
			_hollowXRange = _regCache.getVC(1);
			_hollowYRange = _regCache.getVC(1);
			_hollowZRange = _regCache.getVC(1);
			
			var inner:RegElem = _regCache.getVT();
			inner.x = mov(_hollowXRange.w);
			inner.y = mov(_hollowYRange.w);
			inner.z = mov(_hollowZRange.w);
			
			var xyz:RegElem = _regCache.getVT();
//			xyz.o = mov(randReg.yzw);
//			var degfac	:SFloat = xyz.yzx;
//			degfac.scaleBy(2).incrementBy(float3(-1,-1,-1));
//			degfac.normalize();
//			xyz.scaleBy(subtract(float3(1,1,1), inner));
//			xyz.incrementBy(inner);
//			xyz.scaleBy(degfac);
//			
//			hollowXRange.scaleBy(xyz.x);
//			hollowYRange.scaleBy(xyz.y);
//			hollowZRange.scaleBy(xyz.z);
//			
//			position.incrementBy(hollowXRange);
//			position.incrementBy(hollowYRange);
//			position.incrementBy(hollowZRange);
			
			var range:RegElem = _regCache.getVT();
			
			range.o = mul(_hollowXRange.o, xyz.x);
			posReg.o = add(posReg.o, range.o);
		}
		
		public function setupConstants(material:Material):void
		{
			var hollowXRange:Float4 = material.getFloat4(_shaderName, "hollowXRange");
			var hollowYRange:Float4 = material.getFloat4(_shaderName, "hollowYRange");
			var hollowZRange:Float4 = material.getFloat4(_shaderName, "hollowZRange");
		}
	}
}