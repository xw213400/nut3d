package nut.core.material
{
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import nut.core.DepthPass;
	import nut.core.Float4;
	import nut.core.IAsset;
	import nut.core.Mesh;
	import nut.core.NutTexture;
	import nut.core.PassBase;
	import nut.core.RenderSetting;
	import nut.core.light.LightBase;
	import nut.core.light.LightPicker;
	import nut.enum.PassType;
	import nut.ext.effect.particle.ParticleSystem;
	import nut.util.shaders.PositionPhongShader;
	import nut.util.shaders.SkeletonPhongShader;
	import nut.util.shaders.SuperShader;
	import nut.util.shaders.particle.ParticleShader;
	
	public class Material
	{
		static public const UsageDynamic	:int	= 1;
		static public const UsageSetting	:int	= 2;
		static public const UsageStatic		:int	= 3;
		
		private var _name			:String			= "";
		private var _mesh			:Mesh			= null;
		private var _passes			:Dictionary		= new Dictionary();
		private var _datas			:Dictionary		= new Dictionary();
		private var _lightPicker	:LightPicker	= new LightPicker();
		private var _usage			:int			= UsageDynamic;
		private var _vcConsts		:Vector.<Number>= null;
		private var _fcConsts		:Vector.<Number>= null;
		private var _castShadow		:Boolean		= false;
		private var _receiveShadow	:Boolean		= false;
		private var _dependencies	:Dictionary		= null;
		
		public function Material(mesh:Mesh)
		{
			_mesh = mesh;
		}

		public function get usage():int
		{
			return _usage;
		}

		public function set usage(value:int):void
		{
			_usage = value;
		}

		public function get fcConsts():Vector.<Number>
		{
			return _fcConsts;
		}

		public function set fcConsts(value:Vector.<Number>):void
		{
			_fcConsts = value;
		}

		public function set vcConsts(value:Vector.<Number>):void
		{
			_vcConsts = value;
		}

		public function get vcConsts():Vector.<Number>
		{
			return _vcConsts;
		}

		public function get datas():Dictionary
		{
			return _datas;
		}

		public function set name(value:String):void
		{
			_name = value;
		}

		public function get lightPicker():LightPicker
		{
			return _lightPicker;
		}
		
		public function get castShadow():Boolean
		{
			return _castShadow;
		}
		
		public function set castShadow(value:Boolean):void
		{
			if (_castShadow == value)
				return ;
			
			_castShadow = value;
			
			var len:int = _lightPicker.lights.length;
			for (var i :int = 0; i != len; ++i)
			{
				var light:LightBase = _lightPicker.lights[i];
				if (light.castShadow)
				{
					if (value)
					{
						light.addMesh(_mesh);
					}
					else
					{
						light.removeMesh(_mesh);
					}
				}
			}
		}
		
		public function get receiveShadow():Boolean
		{
			return _receiveShadow;
		}
		
		public function set receiveShadow(value:Boolean):void
		{
			_receiveShadow = value;
		}
		
		public function get name():String
		{
			return _name;
		}
		
		public function addLight(light:LightBase):void
		{
			if (_lightPicker.addLight(light))
			{
				if (light.castShadow && _castShadow)
					light.addMesh(_mesh);
				
				refreshShader(SuperShader.getShader(_mesh));
			}
		}
		
		public function removeLight(light:LightBase):void
		{
			if (_lightPicker.removeLight(light))
			{
				light.removeMesh(_mesh);
				
				refreshShader(SuperShader.getShader(_mesh));
			}
		}
		
		public function getFloat4(shaderName:String, propertyName:String):Float4
		{
			return (_datas[shaderName] as DataProvider).getFloat4(propertyName);
		}
		
		public function getTexture(shaderName:String, propertyName:String):NutTexture
		{
			return (_datas[shaderName] as DataProvider).getTexture(propertyName);
		}
		
		public function getNumber(shaderName:String, propertyName:String):Number
		{
			return (_datas[shaderName] as DataProvider).getNumber(propertyName);
		}
		
		public function getInt(shaderName:String, propertyName:String):int
		{
			return (_datas[shaderName] as DataProvider).getInt(propertyName);
		}
		
		public function getProperty(shaderName:String, propertyName:String):Property
		{
			return (_datas[shaderName] as DataProvider).getProperty(propertyName);
		}
		
		public function getData(shaderName:String):DataProvider
		{
			return _datas[shaderName];
		}
		
		public function addShader(shader:ShaderBase, passType:uint=PassType.INVALID):Boolean
		{
			if (_passes[shader.name] != null)
			{
				return false;
			}
			
			if (passType == PassType.INVALID)
				passType = shader.passType;

			var pass:PassBase = PassBase.getPass(passType, _mesh.id, shader);
			
			_passes[shader.name] = pass;
			_datas[shader.name] = shader.data.clone();
			
			pass.addMesh(_mesh);
			
			return true;
		}
		
		public function setShader(shader:ShaderBase, passType:uint=PassType.INVALID):Boolean
		{
			if (_passes[shader.name] != null)
			{
				return false;
			}
			
			if (passType == PassType.INVALID)
				passType = shader.passType;
			
			var pass:PassBase = PassBase.getPass(passType, _mesh.id, shader);
			
			_passes[shader.name] = pass;
			
			pass.addMesh(_mesh);
			
			return true;
		}
		
		public function refreshShader(shader:ShaderBase):Boolean
		{
			var oldPass:PassBase = _passes[shader.name];
			
			if (oldPass == null || oldPass.shader == shader)
				return false;

			var newPass:PassBase = PassBase.getPass(oldPass.passType, _mesh.id, shader);
			
			if (oldPass != newPass)
			{
				_passes[shader.name] = newPass;
				newPass.addMesh(_mesh);
				oldPass.removeMesh(_mesh);
			}
			
			(_datas[shader.name] as DataProvider).matchItemFrom(shader.data);
			
			return true;
		}
		
		public function getShaderAt(idx:int):ShaderBase
		{
			return _passes[idx].shader;
		}
		
		public function clearPass():void
		{
			for (var name:String in _passes)
			{
				_passes[name].removeMesh(_mesh);
				
				delete _passes[name];
				delete _datas[name];
			}
		}
		
		public function getBlendDst(shaderName:String):uint
		{
			var pass:PassBase = _passes[shaderName];
			
			return pass.setting.blendDst;
		}
		
		public function getBlendSrc(shaderName:String):uint
		{
			var pass:PassBase = _passes[shaderName];
			
			return pass.setting.blendSrc;
		}
		
		public function getCulling(shaderName:String):uint
		{
			var pass:PassBase = _passes[shaderName];
			
			return pass.setting.culling;
		}
		
		public function setBlendMode(shaderName:String, blendSrc:uint, blendDst:uint):void
		{
			var oldPass:PassBase = _passes[shaderName];
			var setting:RenderSetting;
			
			if (oldPass is DepthPass)
			{
				oldPass.setting.setBlendMode(blendSrc, blendDst);
				return ;
			}
			
			setting = oldPass.setting.clone();
			setting.setBlendMode(blendSrc, blendDst);
			
			var newPass:PassBase = PassBase.getPass(oldPass.passType, _mesh.id, oldPass.shader, setting);
			
			if (oldPass != newPass)
			{
				_passes[shaderName] = newPass;
				newPass.addMesh(_mesh);
				oldPass.removeMesh(_mesh);
			}
		}
		
		public function setDepthTest(shaderName:String, depthMask:Boolean, compareMode:uint):void
		{
			var oldPass:PassBase = _passes[shaderName];
			var setting:RenderSetting;
			
			if (oldPass is DepthPass)
			{
				oldPass.setting.setDepthTest(depthMask, compareMode);
				return ;
			}
			
			setting = oldPass.setting.clone();
			setting.setDepthTest(depthMask, compareMode);
			
			var newPass:PassBase = PassBase.getPass(oldPass.passType, _mesh.id, oldPass.shader, setting);
			
			if (oldPass != newPass)
			{
				_passes[shaderName] = newPass;
				newPass.addMesh(_mesh);
				oldPass.removeMesh(_mesh);
			}
		}
		
		public function setCulling(shaderName:String, culling:uint):void
		{
			var oldPass:PassBase = _passes[shaderName];
			var setting:RenderSetting;
			
			if (oldPass is DepthPass)
			{
				oldPass.setting.culling = culling;
				return ;
			}
			
			setting = oldPass.setting.clone();
			setting.culling = culling;
			
			var newPass:PassBase = PassBase.getPass(oldPass.passType, _mesh.id, oldPass.shader, setting);
			
			if (oldPass != newPass)
			{
				_passes[shaderName] = newPass;
				newPass.addMesh(_mesh);
				oldPass.removeMesh(_mesh);
			}
		}
		
		private function setSettingID(shaderName:String, id:uint):void
		{
			var oldPass:PassBase = _passes[shaderName];
			var setting:RenderSetting;
			
			if (oldPass is DepthPass)
			{
				oldPass.setting.id = id;
				return ;
			}
			
			setting = oldPass.setting.clone();
			setting.id = id;
			
			var newPass:PassBase = PassBase.getPass(oldPass.passType, _mesh.id, oldPass.shader, setting);
			
			if (oldPass != newPass)
			{
				_passes[shaderName] = newPass;
				newPass.addMesh(_mesh);
				oldPass.removeMesh(_mesh);
			}
		}
		
		/**
		 * priority 按升序排列
		 */
		public function setDepthPriority(shaderName:String, priority:int):void
		{
			var pass:DepthPass = _passes[shaderName];
			
			if (pass != null)
			{
				pass.priority = priority;
			}
		}
		
		public function encode(data:ByteArray):void
		{
			data.writeUTF(_name);
			
			var n:int = 0;
			var oldPos:uint = data.position;
			data.writeByte(0);
			
			for each (var pass:PassBase in _passes)
			{
				if (pass.shader.needSave)
				{
					++n;
					var shaderName:String = pass.shader.name;
					data.writeUTF(shaderName);
					data.writeUnsignedInt(pass.setting.id);
					var dataProvider:DataProvider = _datas[shaderName];
					dataProvider.encode(data);
				}
			}
			
			var newPos:uint = data.position;
			data.position = oldPos;
			data.writeByte(n);
			data.position = newPos;
		}
		
		public function get dependencies():Vector.<IAsset>
		{
			var dependencies:Vector.<IAsset> = new Vector.<IAsset>();
			
			for each (var pass:PassBase in _passes)
			{
				if (pass.shader.needSave)
				{
					var shaderName:String = pass.shader.name;
					var dataProvider:DataProvider = _datas[shaderName];
					dependencies.push(dataProvider.getTexture("diffuseMap"));
				}
			}
			
			return dependencies;
		}
		
		public function decode(data:ByteArray):void
		{
			_name = data.readUTF();
			var n:int = data.readByte();
			
			for (var i:int = 0; i != n; ++i)
			{
				var shaderName:String = data.readUTF();
				var settingID:uint = data.readUnsignedInt();
				var dataProvider:DataProvider = new DataProvider();
				dataProvider.decode(data);
				_datas[shaderName] = dataProvider;
				
				if (shaderName == "SuperShader")
					this.setShader(SuperShader.getShader(_mesh));
				if (shaderName == "ParticleShader")
					this.setShader(ParticleShader.getShader(_mesh as ParticleSystem));
				else if (shaderName == "PositionPhongShader")
					this.setShader(PositionPhongShader.getShader(_mesh));
				else if (shaderName == "SkeletonPhongShader")
					this.setShader(SkeletonPhongShader.getShader(_mesh));
				
				setSettingID(shaderName, settingID);
			}
		}
		
		public function copy(mat:Material):void
		{
			this.clearPass();
			
			this._lightPicker = mat.lightPicker.clone();
			
			for each (var pass:PassBase in mat._passes)
			{
				var shaderName:String = pass.shader.name;
				this._datas[shaderName] = mat._datas[shaderName].clone();
				this.setShader(pass.shader);
			}
		}
	}
}