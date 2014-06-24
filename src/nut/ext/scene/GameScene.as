package nut.ext.scene
{
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Endian;
	
	import nut.core.IAsset;
	import nut.core.Nut;
	import nut.core.NutScene;
	import nut.core.light.AmbientLight;
	import nut.core.light.DirectionLight;
	import nut.core.light.PointLight;
	import nut.enum.ResType;
	import nut.ext.scene.SegmentConst;
	import nut.ext.scene.terrain.Terrain;
	import nut.util.BytesLoader;
	
	public class GameScene implements IAsset
	{
		protected var _name		:String		= null;
		protected var _terrain	:Terrain	= null;
		private var _scene		:NutScene	= null;
		private var _ambientLight:AmbientLight = null;
		private var _sunLight	:DirectionLight = null;
		private var _onLoaded		:Function	= null;

		public function GameScene()
		{
		}
		
		public function get type():uint
		{
			return ResType.SCENE;
		}
		
		public function set onLoaded(value:Function):void
		{
			_onLoaded = value;
		}
		
		public function set name(value:String):void
		{
			_name = value;
		}

		public function get scene():NutScene
		{
			return _scene;
		}
		
		public function get terrain():Terrain
		{
			return _terrain;
		}
		
		public function get name():String
		{
			return _name;
		}
		
		public function get sunLight():DirectionLight
		{
			return _sunLight;
		}
		
		public function get ambientLight():AmbientLight
		{
			return _ambientLight;
		}
		
		public function set sunLight(value:DirectionLight):void
		{
			_sunLight = value;
		}
		
		public function set ambientLight(value:AmbientLight):void
		{
			_ambientLight = value;
		}
		
		protected function newTerrain(x_count:int, z_count:int):void
		{
			_terrain = new Terrain(this, x_count, z_count);
		}
		
		public function decode(data:ByteArray):void
		{	
			while (data.bytesAvailable != 0)
			{
				var segment:int = data.readByte();
				
				if (segment == SegmentConst.SEG_Global)
				{
					importGlobal(data);
				}
				else if (segment == SegmentConst.SEG_Terrain)
				{
					var x_count:int = data.readByte();
					var z_count:int = data.readByte();
					newTerrain(x_count, z_count);
					_terrain.decode(data);
				}
			}
			
			if (_onLoaded != null)
			{
				_onLoaded(this);
			}
		}
		
		public function encode():ByteArray
		{
			var data:ByteArray = new ByteArray();
			data.endian = Endian.LITTLE_ENDIAN;
			
			data.writeByte(SegmentConst.SEG_Global);
			exportGlobal(data);
			
			if (_terrain != null)
			{
				data.writeByte(SegmentConst.SEG_Terrain);
				data.writeByte(_terrain.xChunks);
				data.writeByte(_terrain.zChunks);
				_terrain.encode(data);
			}
			
			return data;
		}
		
		private function exportGlobal(data:ByteArray):void
		{	
			data.writeFloat(_sunLight.diffuse);
			data.writeFloat(_sunLight.specular);
		}
		
		protected function importGlobal(data:ByteArray):void
		{
			_sunLight.diffuse = data.readFloat();
			_sunLight.specular = data.readFloat();
		}

		public function dispose():void
		{
			if (_terrain != null)
				_terrain.dispose();
		}
	}
}