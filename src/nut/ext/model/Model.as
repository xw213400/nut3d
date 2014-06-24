package nut.ext.model
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import flash.utils.CompressionAlgorithm;
	import flash.utils.Dictionary;
	import flash.utils.Endian;
	
	import nut.core.IAsset;
	import nut.core.Mesh;
	import nut.core.Node;
	import nut.core.Nut;
	import nut.core.light.LightBase;
	import nut.enum.ResType;
	
	public class Model extends Node implements IAsset
	{
		private var _name			:String		= "";
		private var _meshToBone		:Dictionary = new Dictionary();	//Mesh -> BoneName;
		private var _skeleton		:Skeleton	= null;
		private var _skinProviders	:Dictionary = null;
		private var _dependencies	:Dictionary = null;
		private var _dependCount	:uint		= 0;
		private var _depLoadedNum	:uint		= 0;
		private var _onLoaded		:Function	= null;
		private var _parseFinish	:Boolean	= false;
		
		public function Model()
		{
			super();
		}
		
		public function get skeleton():Skeleton
		{
			return _skeleton;
		}
		
		public function set onLoaded(value:Function):void
		{
			_onLoaded = value;
		}
		
		public function get type():uint
		{
			return ResType.MODEL;
		}

		public function get name():String
		{
			return _name;
		}

		public function set name(value:String):void
		{
			_name = value;
		}

		public function get meshToBone():Dictionary
		{
			return _meshToBone;
		}

		public function set skeleton(value:Skeleton):void
		{
			_skeleton = value;
		}
		
		public function addSkinProvider(skinProvider:SkinDataProvider) :void
		{
			if (_skinProviders == null)
				_skinProviders = new Dictionary();
			
			_skinProviders[skinProvider.name] = skinProvider;
			skinProvider.initialize(_skeleton);
		}
		
		public function addBindMesh(boneName:String, mesh:Mesh):void
		{
			_meshToBone[mesh] = boneName;
			addChild(mesh);
		}
		
		public function addLight(light:LightBase):void
		{
			for (var mesh:Object in _meshToBone)
			{
				mesh.material.addLight(light);
			}
		}
		
		public function removeLight(light:LightBase):void
		{
			for (var mesh:Object in _meshToBone)
			{
				mesh.material.removeLight(light);
			}
		}
		
		public function set castShadow(value:Boolean):void
		{
			for (var mesh:Object in _meshToBone)
			{ 
				mesh.material.castShadow = value;
			}
		}
		
		public function set receiveShadow(value:Boolean):void
		{
			for (var mesh:Object in _meshToBone)
			{ 
				mesh.material.receiveShadow = value;
			}
		}
		
		public function updateAt(animName:String, time:Number):void
		{
			(_skeleton as Skeleton).updateAt(animName, time);
			
			if (_skinProviders != null)
			{
				for each (var skin:SkinDataProvider in _skinProviders)
				{
					skin.update();
				}
			}
			
			for (var mesh:Object in _meshToBone)
			{
				var bone:Bone = _skeleton.bones[_meshToBone[mesh]];
				mesh.transform = bone.localToWrapper;
			}
		}
		
		public function encode():ByteArray
		{
			var data:ByteArray = new ByteArray();
			data.endian = Endian.LITTLE_ENDIAN;
			
			var deps:Dictionary = this.dependencies;
			data.writeShort(_dependCount);
			for each (var asset:IAsset in deps)
			{
				data.writeByte(asset.type);
				data.writeUTF(asset.name);
			}
			
			var hasSkinData:Boolean = _skinProviders != null;
			data.writeBoolean(hasSkinData);
			
			var n:int = 0;
			var oldPos:uint = data.position;
			var newPos:uint;
			
			if (hasSkinData)
			{
				data.writeShort(0);
				
				for each (var skin:SkinDataProvider in _skinProviders)
				{
					skin.encode(data);
					++n;
				}
				
				newPos = data.position;
				data.position = oldPos;
				data.writeShort(n);
				data.position = newPos;
				oldPos = newPos;
			}
			
			data.writeShort(0);
			n = 0;
			
			for (var m:Object in _meshToBone)
			{
				var mesh:Mesh = m as Mesh;
				mesh.encode(data);
				data.writeUTF(_meshToBone[mesh]);
				++n;
			}
			
			newPos = data.position;
			data.position = oldPos;
			data.writeShort(n);
			data.position = newPos;
			
			return data;
		}
		
		public function get dependencies():Dictionary
		{
			if (_dependencies == null)
			{
				_dependencies = new Dictionary();
				
				for (var m:Object in _meshToBone)
				{
					var mesh:Mesh = m as Mesh;
					var deps:Vector.<IAsset> = mesh.material.dependencies;
					
					for (var i:int = 0; i != deps.length; ++i)
					{
						_dependencies[deps[i].name] = deps[i];
					}
				}
				
				if (_skeleton.hasAnim())
				{
					_dependencies[_skeleton.name] = _skeleton;
				}
				
				for each (var a:IAsset in _dependencies)
				{
					_dependCount++;
				}
			}
			
			return _dependencies;
		}
		
		public function clone():Model
		{
			var model:Model = new Model();
			
			model.name = this.name;
			model.skeleton = this.skeleton;
			
			if (_skinProviders != null)
			{
				for each (var skin:SkinDataProvider in _skinProviders)
				{
					model.addSkinProvider(skin.clone());
				}
			}
			
			for (var m:Object in _meshToBone)
			{
				var mesh:Mesh = m as Mesh;
				var boneName:String = _meshToBone[mesh];
				
				model.addBindMesh(boneName, mesh.clone());
			}
			
			model.bindSkin();
			
			return model;
		}
		
		private function bindSkin():void
		{
			for (var m:Object in _meshToBone)
			{
				var mesh:Mesh = m as Mesh;
				
				(_skinProviders[mesh.skinName] as SkinDataProvider).bindToMesh(mesh);
			}
		}
		
		public function decode(data:ByteArray):void
		{
			data.position = 0;
			
			_dependCount = data.readUnsignedShort();
			if (_dependCount > 0 && _dependencies == null)
				_dependencies = new Dictionary();
			
			for (i = 0; i != _dependCount; ++i)
			{
				var type:uint = data.readUnsignedByte();
				var assetName:String = data.readUTF();
				_dependencies[assetName] = null;
				Nut.resMgr.load(type, assetName, onDepLoaded);
			}
			
			var n:uint;
			var hasSkinData:Boolean = data.readBoolean();
			
			if (hasSkinData)
			{
				_skinProviders = new Dictionary();
				n = data.readUnsignedShort();
				for (i = 0; i != n; ++i)
				{
					var skin:SkinDataProvider = SkinDataProvider.decode(data);
					_skinProviders[skin.name] = skin;
				}
			}
			
			n = data.readUnsignedShort();
			
			for (var i:int = 0; i != n; ++i)
			{
				var mesh:Mesh = Mesh.decode(data, _skinProviders);
				var boneName:String = data.readUTF();
				
				addBindMesh(boneName, mesh);
			}
			
			_parseFinish = true;
			
			if (_depLoadedNum == _dependCount)
			{
				if (_onLoaded != null)
					_onLoaded(this);
			}
		}
		
		private function onDepLoaded(asset:IAsset):void
		{
			if (_dependencies[asset.name] == null)
			{
				_dependencies[asset.name] = asset;
				
				if (asset.type == ResType.SKELETON)
				{
					this.skeleton = asset as Skeleton;
					
					if (_skinProviders != null)
					{
						for each (var skin:SkinDataProvider in _skinProviders)
						{
							skin.initialize(_skeleton);
						}
					}
				}
				
				if (++_depLoadedNum == _dependCount && _parseFinish)
				{
					if (_onLoaded != null)
						_onLoaded(this);
				}
			}
		}
	}
}