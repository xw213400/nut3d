package nut.util.shaders
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.utils.Dictionary;
	
	import nut.core.Float4;
	import nut.core.Mesh;
	import nut.core.Nut;
	import nut.core.NutCamera;
	import nut.core.NutScene;
	import nut.core.NutTexture;
	import nut.core.RegState;
	import nut.core.material.Material;
	import nut.core.material.RegElem;
	import nut.core.material.ShaderBase;
	import nut.enum.PassType;
	
	public class TerrainShader extends ShaderBase
	{
		static private var shaders:Dictionary = new Dictionary();
		
		private var _uvData:RegElem;
		private var _normalData:RegElem;
		private var _worldPosData:RegElem;
		private var _phongShaderPart:PhongShaderPart = null;
		private var _defualtUVRepeat:Float4 = new Float4(2,2,2,2);
		private var _l2wReg:RegElem;
		private var _w2sReg:RegElem;
		private var _uvRepeatReg:RegElem;
		
		private var _surface0Reg :RegElem;
		private var _surface1Reg :RegElem;
		private var _surface2Reg :RegElem;
		private var _surface3Reg :RegElem;
		private var _blendMapReg :RegElem;
		private var _colorMapReg :RegElem;
		
		public function TerrainShader(material:Material)
		{
			super('TerrainShader', PassType.TERRAIN);
			
			var tex:NutTexture = Nut.resMgr.getTexture('default');
			data.addProperty('surface0', tex);
			data.addProperty('surface1', tex);
			data.addProperty('surface2', tex);
			data.addProperty('surface3', tex);
			data.addProperty('blendMap', tex);
			data.addProperty('colorMap', tex);
			data.addProperty('uvRepeat', _defualtUVRepeat);
			_phongShaderPart = new PhongShaderPart(this, material);
		}
		
		static public function getShader(mesh:Mesh):TerrainShader
		{
			var id:uint = 100;
			var shader:TerrainShader = shaders[id];
			
			if (shader == null)
			{
				shader = new TerrainShader(mesh.material);
				shaders[id] = shader;
			}
			
			return shader;
		}
		
		override protected function getVertexCode():String
		{
			_l2wReg = this.regCache.getVC(4);
			_w2sReg = this.regCache.getVC(4);
			
			var pos	:RegElem = this.regCache.getVA('position', 1);
			var nor	:RegElem = this.regCache.getVA('normal', 1);
			var uv	:RegElem = this.regCache.getVA('uv', 1);
			var op	:RegElem = this.regCache.getOP();
			
			var worldPos:RegElem = this.regCache.getVT();
			
			_uvData = this.regCache.getV();
			_normalData = this.regCache.getV();
			_worldPosData = this.regCache.getV();
			
			worldPos.o = m44(pos.o, _l2wReg.o);
			op.o = m44(worldPos.o, _w2sReg.o);
			
			_uvData.o = mov(uv.o);
			_normalData.xyz = m33(nor.o, _l2wReg.o);
			_normalData.w = mov(nor.w);
			_worldPosData.o = mov(worldPos.o);
			
			return regCache.vertexCode;
		}
		
		override protected function getFragmentCode():String
		{
			regCache.switchCode();
			
			_surface0Reg = this.regCache.getFS();
			_surface1Reg = this.regCache.getFS();
			_surface2Reg = this.regCache.getFS();
			_surface3Reg = this.regCache.getFS();
			_blendMapReg = this.regCache.getFS();
			_colorMapReg = this.regCache.getFS();
			_uvRepeatReg = this.regCache.getFC(1);
			var blendData:RegElem = this.regCache.getFT();
			var tempColor:RegElem = this.regCache.getFT();
			var diffuseColor:RegElem = this.regCache.getFT();
			var oc:RegElem = this.regCache.getOC();
			var lightColor:RegElem = this.regCache.getFT();
			
			////////////////////////////////////
			blendData.o = tex(_uvData.xy, _blendMapReg.o, "<2d,linear,mipnone>");
			blendData.w = sub(blendData.w, blendData.x);
			blendData.w = sub(blendData.w, blendData.y);
			blendData.w = sub(blendData.w, blendData.z);
			
			tempColor.xy = mul(_uvData.xy, _uvRepeatReg.xx);
			tempColor.o = tex(tempColor.xy, _surface0Reg.o, "<2d,repeat,linear,miplinear>");
			diffuseColor.o = mul(tempColor.o, blendData.x);
			
			tempColor.xy = mul(_uvData.xy, _uvRepeatReg.yy);
			tempColor.o = tex(tempColor.xy, _surface1Reg.o, "<2d,repeat,linear,miplinear>");
			tempColor.o = mul(tempColor.o, blendData.y);
			diffuseColor.o = add(diffuseColor.o, tempColor.o);
			
			tempColor.xy = mul(_uvData.xy, _uvRepeatReg.zz);
			tempColor.o = tex(tempColor.xy, _surface2Reg.o, "<2d,repeat,linear,miplinear>");
			tempColor.o = mul(tempColor.o, blendData.z);
			diffuseColor.o = add(diffuseColor.o, tempColor.o);
			
			tempColor.xy = mul(_uvData.xy, _uvRepeatReg.ww);
			tempColor.o = tex(tempColor.xy, _surface3Reg.o, "<2d,repeat,linear,miplinear>");
			tempColor.o = mul(tempColor.o, blendData.w);
			diffuseColor.o = add(diffuseColor.o, tempColor.o);
			
			tempColor.o = tex(_uvData.xy, _colorMapReg.o, "<2d,linear,mipnone>");
			tempColor.xyz = div(tempColor.xyz, tempColor.w);
			diffuseColor.xyz = mul(diffuseColor.xyz, tempColor.yzw);
			
			_phongShaderPart.getColor(_normalData, _worldPosData, lightColor);
			diffuseColor.xyz = mul(diffuseColor.xyz, lightColor.xyz);
			
			oc.o = mov(diffuseColor.o);
			
			return regCache.fragmentCode;
		}
		
		override public function render(mesh:Mesh):void
		{
			var material:Material = mesh.material;
			var scene:NutScene = Nut.scene;
			var camera:NutCamera = scene.camera;
			var context:Context3D = scene.context3D;
			
			if (material.usage == Material.UsageSetting)
			{
				var vcConsts:Vector.<Number> = new Vector.<Number>(regCache.vc_next*4);
				var fcConsts:Vector.<Number> = new Vector.<Number>(regCache.fc_next*4);
				
				material.vcConsts = vcConsts;
				material.fcConsts = fcConsts;
				mesh.localToWorld.copyRawDataTo(vcConsts, _l2wReg.id*4, true);
				camera.worldToScreen.copyRawDataTo(vcConsts, _w2sReg.id*4, true);
				
				_phongShaderPart.setupLightConst(context, mesh.material, camera);
				
				var uvRepeat:Float4 = mesh.material.getFloat4(name, 'uvRepeat');
				
				var idx:int = _uvRepeatReg.id*4;
				fcConsts[idx++] = uvRepeat.x;
				fcConsts[idx++] = uvRepeat.y;
				fcConsts[idx++] = uvRepeat.z;
				fcConsts[idx++] = uvRepeat.w;
				
				context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, vcConsts);
				context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, fcConsts);
				
				material.usage = Material.UsageStatic;
			}
			else if (material.usage == Material.UsageStatic)
			{
				vcConsts = material.vcConsts;
				camera.worldToScreen.copyRawDataTo(vcConsts, _w2sReg.id*4, true);
				context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, vcConsts);
			}
			else
			{	
				context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, _l2wReg.id, mesh.localToWorld, true);
				context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, _w2sReg.id, camera.worldToScreen, true);
				
				_phongShaderPart.setupLightConst(context, mesh.material, camera);
				
				uvRepeat = mesh.material.getFloat4(name, 'uvRepeat');
				context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, _uvRepeatReg.id, uvRepeat.data, 1);
			}
			
			var surface0:NutTexture = mesh.material.getTexture(this.name, 'surface0');
			RegState.setTextureAt(_surface0Reg.id, surface0);
			
			var surface1:NutTexture = mesh.material.getTexture(this.name, 'surface1');
			RegState.setTextureAt(_surface1Reg.id, surface1);
			
			var surface2:NutTexture = mesh.material.getTexture(this.name, 'surface2');
			RegState.setTextureAt(_surface2Reg.id, surface2);
			
			var surface3:NutTexture = mesh.material.getTexture(this.name, 'surface3');
			RegState.setTextureAt(_surface3Reg.id, surface3);
			
			var blendMap:NutTexture = mesh.material.getTexture(this.name, 'blendMap');
			RegState.setTextureAt(_blendMapReg.id, blendMap);
			
			var colorMap:NutTexture = mesh.material.getTexture(this.name, 'colorMap');
			RegState.setTextureAt(_colorMapReg.id, colorMap);
			
			RegState.clear(regCache.va_next, regCache.fs_next);
			mesh.geometry.draw(context);
		}
	}
}