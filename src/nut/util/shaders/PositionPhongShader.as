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
	import nut.core.light.LightPicker;
	import nut.core.material.Material;
	import nut.core.material.RegElem;
	import nut.core.material.ShaderBase;

	public class PositionPhongShader extends ShaderBase
	{
		static private var shaders:Dictionary = new Dictionary();
		
		private var _uvData:RegElem;
		private var _normalData:RegElem;
		private var _worldPosData:RegElem;
		private var _phongShaderPart:PhongShaderPart = null;
		private var _l2wReg:RegElem;
		private var _w2sReg:RegElem;
		private var _diffuseMapReg:RegElem;
		
		public function PositionPhongShader(material:Material)
		{
			super('PositionPhongShader');
			data.addProperty('diffuseMap', Nut.resMgr.getTexture('default'));
			_phongShaderPart = new PhongShaderPart(this, material);
			_needSave = true;
		}
		
		static public function getShader(mesh:Mesh):PositionPhongShader
		{
			var id:uint = 100;
			var shader:PositionPhongShader = shaders[id];
			
			if (shader == null)
			{
				shader = new PositionPhongShader(mesh.material);
				shaders[id] = shader;
			}
			
			return shader;
		}
		
		override protected function getVertexCode():String
		{
			//这里登记寄存器需求  property -> regElem
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
			_worldPosData.o = mov(worldPos.o);
			
			_phongShaderPart.genVertexCode(worldPos);
			
			op.o = m44(worldPos.o, _w2sReg.o);
			
			_uvData.o = mov(uv.o);
			
			worldPos.xyz = m33(nor.o, _l2wReg.o);
			_normalData.xyz = nrm(worldPos.o);
			_normalData.w = mov(worldPos.w);
			
			return regCache.vertexCode;
		}
		
		override protected function getFragmentCode():String
		{
			regCache.switchCode();
			
			_diffuseMapReg = this.regCache.getFS();
			var diffuseColor:RegElem = this.regCache.getFT();
			var oc:RegElem = this.regCache.getOC();
			var lightColor:RegElem = this.regCache.getFT();
			
			////////////////////////////////////
			diffuseColor.o = tex(_uvData.xy, _diffuseMapReg.o, "<2d,repeat,linear,miplinear>");
			_phongShaderPart.getColor(_normalData, _worldPosData, lightColor);
			diffuseColor.xyz = mul(diffuseColor.xyz, lightColor.xyz);
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

			_phongShaderPart.setupLightConst(context, mesh.material, camera);
			var texture:NutTexture = mesh.material.getTexture(this.name, 'diffuseMap');
			RegState.setTextureAt(_diffuseMapReg.id, texture);
			
			RegState.clear(regCache.va_next, regCache.fs_next);
			mesh.geometry.draw(context);
		}
	}
}