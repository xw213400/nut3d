package nut.core
{
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import nut.enum.ResType;
	import nut.ext.effect.EffectNode;
	import nut.ext.model.Model;
	import nut.ext.model.Skeleton;
	import nut.ext.scene.GameScene;
	import nut.util.BytesLoader;

	public class ResourceManager
	{
		static public var DFT_BITMAP:BitmapData = new BitmapData(1, 1, false, 0xFFFFFF);
		
		private var _baseUrl	:String = "./";
		private var _textures	:Dictionary = new Dictionary();
		private var _models		:Dictionary = new Dictionary();
		private var _skeletons	:Dictionary = new Dictionary();
		private var _scenes		:Dictionary = new Dictionary();
		private var _effects	:Dictionary = new Dictionary();
		private var _urls		:Vector.<String> = new Vector.<String>();
		
		public function ResourceManager(baseUrl:String)
		{
			this.baseUrl = baseUrl;
			
			var texture :NutTexture = new NutTexture();
			
			texture.name = "default";
			texture.setContent(DFT_BITMAP);
			
			_textures["default"] = texture;
		}
		
		public function set baseUrl(value:String):void
		{
			_baseUrl = value;
			
			if (_baseUrl.charAt(baseUrl.length-1) != "/")
				_baseUrl += "/";
			
			initResUrl();
		}

		public function get baseUrl():String
		{
			return _baseUrl;
		}
		
		public function getResUrl(resType:int):String
		{
			return _urls[resType];
		}
		
		private function initResUrl():void
		{
			_urls.splice(0, _urls.length);
			
			_urls.push(_baseUrl+"texture/");
			_urls.push(_baseUrl+"model/");
			_urls.push(_baseUrl+"scene/");
			_urls.push(_baseUrl+"skeleton/");
			_urls.push(_baseUrl+"effect/");
		}

		public function loadTexture(name:String, onComplete:Function=null, mipmap:Boolean=true):NutTexture
		{
			var texture:NutTexture = _textures[name];
			
			if (texture)
			{
				if (onComplete != null)
					onComplete(texture);
			}
			else
			{
				_textures[name] = texture = new NutTexture();
				texture.setContent(DFT_BITMAP, mipmap);
				texture.name = name;
				
				var loader:BytesLoader = new BytesLoader();
				loader.load(_urls[ResType.TEXTURE]+name, onTextureLoaded, 
					BytesLoader.TEXTURE, {res:texture, cb:onComplete});
			}
			
			return texture;
		}
		
		private function onTextureLoaded(bitmapData:BitmapData, obj:Object):void
		{
			var texture:NutTexture = obj.res as NutTexture;
			
			texture.onLoaded = obj.cb;
			texture.setContent(bitmapData);
		}
		
		public function loadModel(name:String, onComplete:Function=null):Model
		{
			var model:Model = _models[name];
			
			if (model)
			{
				if (onComplete != null)
					onComplete(name);
			}
			else
			{
				_models[name] = model = new Model();
				model.name = name;
				
				var loader:BytesLoader = new BytesLoader();
				loader.load(_urls[ResType.MODEL]+name, onModelLoaded, 
					BytesLoader.COMPRESSED_BYTES, {res:model, cb:onComplete});
			}
			
			return model;
		}
		
		private function onModelLoaded(data:ByteArray, obj:Object):void
		{
			var model:Model = obj.res as Model;
			
			model.onLoaded = obj.cb;
			model.decode(data);
		}
		
		public function loadSkeleton(name:String, onComplete:Function=null):Skeleton
		{
			var skeleton:Skeleton = _skeletons[name];
			
			if (skeleton)
			{
				if (onComplete != null)
					onComplete(name);
			}
			else
			{
				_skeletons[name] = skeleton = new Skeleton();
				skeleton.name = name;
				
				var loader:BytesLoader = new BytesLoader();
				loader.load(_urls[ResType.SKELETON]+name, onSkeletonLoaded, 
					BytesLoader.COMPRESSED_BYTES, {res:skeleton, cb:onComplete});
			}
			
			return skeleton;
		}
		
		private function onSkeletonLoaded(data:ByteArray, obj:Object):void
		{
			var skeleton:Skeleton = obj.res as Skeleton;
			
			skeleton.onLoaded = obj.cb;
			skeleton.decode(data);
		}
		
		public function loadEffect(name:String, onComplete:Function=null):EffectNode
		{
			var effect:EffectNode = _effects[name];
			
			if (effect)
			{
				if (onComplete != null)
					onComplete(name);
			}
			else
			{
				_effects[name] = effect = new EffectNode();
				effect.name = name;
				
				var loader:BytesLoader = new BytesLoader();
				loader.load(_urls[ResType.EFFECT]+name, onEffectLoaded, 
					BytesLoader.COMPRESSED_BYTES, {res:effect, cb:onComplete});
			}
			
			return effect;
		}
		
		private function onEffectLoaded(data:ByteArray, obj:Object):void
		{
			var effect:EffectNode = obj.res as EffectNode;
			
			effect.onLoaded = obj.cb;
			effect.decode(data);
		}
		
		public function loadScene(name:String, onComplete:Function=null):GameScene
		{
			var scene:GameScene = _skeletons[name];
			
			if (scene)
			{
				if (onComplete != null)
					onComplete(name);
			}
			else
			{
				_scenes[name] = scene = new GameScene();
				scene.name = name;
				
				var loader:BytesLoader = new BytesLoader();
				loader.load(_urls[ResType.SCENE]+name, onSceneLoaded, 
					BytesLoader.COMPRESSED_BYTES, {res:scene, cb:onComplete});
			}
			
			return scene;
		}
		
		private function onSceneLoaded(data:ByteArray, obj:Object):void
		{
			var scene:GameScene = obj.res as GameScene;
			
			scene.onLoaded = obj.cb;
			scene.decode(data);
		}
		
		public function load(type:uint, name:String, onComplete:Function=null):IAsset
		{
			if (type == ResType.TEXTURE)
				return loadTexture(name, onComplete);
			else if (type == ResType.MODEL)
				return loadModel(name, onComplete);
			else if (type == ResType.SKELETON)
				return loadSkeleton(name, onComplete);
			else if (type == ResType.EFFECT)
				return loadEffect(name, onComplete);
			else
				return null;
		}
		
		public function solvePath(name:String, resType:int):String
		{
			var filename:String = name.split('/').pop();
			
			return name.substr(0, name.length-filename.length);
		}
		
		public function solveName(url:String, resType:int):String
		{
			if (url.search(_urls[resType]) >= 0)
			{
				return url.substr(_urls[resType].length);
			}
			
			return "";
		}
		
		public function getTexture(name:String):NutTexture
		{
			return _textures[name];
		}
	}
}