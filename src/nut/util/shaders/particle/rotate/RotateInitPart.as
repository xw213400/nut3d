package nut.util.shaders.particle.rotate
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	
	import nut.core.Float4;
	import nut.core.material.Expression;
	import nut.core.material.Material;
	import nut.core.material.RegCache;
	import nut.core.material.RegElem;
	import nut.core.material.ShaderBase;
	
	public class RotateInitPart extends Expression
	{
		private var _rotation:RegElem;
		private var _regCache:RegCache;
		private var _shaderName:String;
		
		public function RotateInitPart(shader:ShaderBase)
		{
			_regCache = shader.regCache;
			_shaderName = shader.name;
			shader.data.addProperty("rotation", Float4.BLACK);
		}
		
		public function rotate(xDir:RegElem, yDir:RegElem, direction:RegElem, rand4:RegElem):void
		{
			_rotation = _regCache.getVC(1);
			
			var angle:RegElem = _regCache.getVT();
			var temp1:RegElem = _regCache.getVT();
			var temp2:RegElem = _regCache.getVT();
			
			angle.zw = mov(_rotation.yw);
			angle.zw = sub(angle.zw, _rotation.xz);
			angle.zw = mul(angle.zw, rand4.w);
			angle.zw = add(angle.zw, _rotation.xz);
			angle.w = mul(angle.w, direction.w);
			angle.z = add(angle.z, angle.w);
			
			xDir.w = sin(angle.z);
			yDir.w = cos(angle.z);
			
			temp1.xyz = mul(xDir.xyz, yDir.w);
			temp2.xyz = mul(yDir.xyz, xDir.w);
			
			angle.xyz = sub(temp1.xyz, temp2.xyz);
			
			temp1.xyz = mul(xDir.xyz, xDir.w);
			temp2.xyz = mul(yDir.xyz, yDir.w);
			
			yDir.xyz = add(temp1.xyz, temp2.xyz);
			xDir.xyz = mov(angle.xyz);
			
			_regCache.free(angle);
			_regCache.free(temp1);
			_regCache.free(temp2);
		}
		
		public function setupConstants(context:Context3D, material:Material):void
		{
			var rotation:Float4 = material.getFloat4(_shaderName, "rotation");
			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, _rotation.id, rotation.data);
		}
	}
}