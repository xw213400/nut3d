package nut.core
{	
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import nut.core.material.Material;
	import nut.ext.model.SkinDataProvider;

	public class Mesh extends Node
	{
		static private var next_id:uint = 0;
		private var _extra			:Object		= null;
		private var _id				:uint		= 0;
		protected var _material		:Material	= null;
		protected var _geometry		:Geometry	= null;
		private var _skinName		:String		= null;
		private var _skinDataProvider:SkinDataProvider = null;

		public function Mesh(geometry:Geometry)
		{
			_id = ++next_id;
			_material = new Material(this);
			_geometry = geometry as Geometry;
		}

		public function get skinName():String
		{
			return _skinName;
		}

		public function get id():uint
		{
			return _id;
		}

		public function get skinDataProvider():SkinDataProvider
		{
			return _skinDataProvider;
		}

		public function set skinDataProvider(value:SkinDataProvider):void
		{
			_skinDataProvider = value;
			_skinName = _skinDataProvider.name;
		}

		public function get extra():Object
		{
			return _extra;
		}

		public function set extra(value:Object):void
		{
			_extra = value;
		}

		public function get geometry():Geometry
		{
			return _geometry;
		}

		public function get material():Material
		{
			return _material;
		}
		
		public function clone():Mesh
		{
			var mesh:Mesh = new Mesh(this.geometry);
			
			mesh._skinName = _skinName;
			mesh.material.copy(this.material);
			
			return mesh;
		}
		
		public function encode(data:ByteArray):void
		{	
			_geometry.encode(data);
			
			var rawData:Vector.<Number> = _transform.rawData;
			for (var i:int = 0; i != 16; ++i)
				data.writeFloat(rawData[i]);
			
			var hasSkin:Boolean = _skinName != null;
			data.writeBoolean(hasSkin);
			if (hasSkin)
				data.writeUTF(_skinName);
			
			_material.encode(data);
		}
		
		static public function decode(data:ByteArray, skins:Dictionary):Mesh
		{	
			var mesh:Mesh = new Mesh(Geometry.decode(data));
			
			mesh._transform.copyRawDataFrom(Vector.<Number>([
				data.readFloat(),data.readFloat(),data.readFloat(),data.readFloat(),
				data.readFloat(),data.readFloat(),data.readFloat(),data.readFloat(),
				data.readFloat(),data.readFloat(),data.readFloat(),data.readFloat(),
				data.readFloat(),data.readFloat(),data.readFloat(),data.readFloat()
			]));
			
			mesh.localToWorldDirty();
			
			var hasSkin:Boolean = data.readBoolean();
			if (hasSkin)
			{
				var skinName:String = data.readUTF();
				mesh.skinDataProvider = skins[skinName];
			}
			
			mesh.material.decode(data);
			
			return mesh;
		}
	}
}