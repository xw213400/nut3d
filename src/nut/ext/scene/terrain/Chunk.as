package nut.ext.scene.terrain
{
	import flash.display.BitmapData;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	
	import nut.core.Float4;
	import nut.core.Nut;
	import nut.core.NutTexture;
	import nut.core.material.Material;
	import nut.ext.scene.SegmentConst;
	import nut.util.BytesLoader;
	import nut.util.shaders.TerrainShader;

	public class Chunk
	{
		static public const DEFAULT_BLEND :BitmapData	= new BitmapData(32, 32, false, 0xFF0000);
		static public const DEFAULT_COLOR :BitmapData	= new BitmapData(32, 32, true, 0xFF00FFFF);
		
		private var _terrain		:Terrain;
		private var _idx			:int;
		private var _idx_x			:int;
		private var _idx_z			:int;
		protected var _chunkMesh	:ChunkMesh;
		protected var _heightData		:Vector.<Number>	= new Vector.<Number>(Terrain.VERT_IDX_MAX);
		protected var _walkHeight		:Vector.<Number>	= null;
		protected var _surfaces		:Vector.<String>	= Vector.<String>(['','','','']);
		protected var _blendTexture	:NutTexture			= new NutTexture();
		private var _uvRepeats		:Float4				= new Float4(2,2,2,2);
		protected var _colorTexture	:NutTexture			= new NutTexture();
		protected var _pointLights	:Vector.<uint>		= new Vector.<uint>();
		
		public function Chunk(terrain:Terrain, idx:int)
		{
			_terrain = terrain;
			
			_blendTexture.setContent(DEFAULT_BLEND, false);
			_colorTexture.setContent(DEFAULT_COLOR, false);
			
			_idx = idx;
			_idx_x = idx % _terrain.xChunks;
			_idx_z = idx / _terrain.zChunks;
		}

		public function set walkHeight(value:Vector.<Number>):void
		{
			_walkHeight = value;
		}

		public function get walkHeight():Vector.<Number>
		{
			return _walkHeight;
		}

		public function get idx():int
		{
			return _idx;
		}

		public function get colorTexture():NutTexture
		{
			return _colorTexture;
		}

		public function get uvRepeats():Float4
		{
			return _uvRepeats;
		}

		public function get blendTexture():NutTexture
		{
			return _blendTexture;
		}

		public function get idx_z():int
		{
			return _idx_z;
		}

		public function get idx_x():int
		{
			return _idx_x;
		}

		public function get chunkMesh():ChunkMesh
		{
			return _chunkMesh;
		}

		public function get terrain():Terrain
		{
			return _terrain;
		}

		public function get heightData():Vector.<Number>
		{
			return _heightData;
		}

		public function initWalkHeight():void
		{
			_walkHeight = new Vector.<Number>(Terrain.VERT_IDX_MAX);
			for (var i:int=0; i!=Terrain.VERT_IDX_MAX; ++i)
				_walkHeight[i] = _heightData[i];
		}
		
		public function getSurface(idx:int):NutTexture
		{
			return _terrain.getSurface(_surfaces[idx]);
		}
		
		public function getSurfacePath(idx:int):String
		{
			return _surfaces[idx];
		}
		
		public function setSurfacePath(idx:int, path:String):void
		{
			_surfaces[idx] = path;
			_chunkMesh.material.getProperty('TerrainShader','surface'+idx.toString()).value = getSurface(idx);
		}
		
		public function updateSurface():void
		{
			if (_chunkMesh == null)
				return ;
			
			_chunkMesh.material.getProperty('TerrainShader','surface0').value = getSurface(0);
			_chunkMesh.material.getProperty('TerrainShader','surface1').value = getSurface(1);
			_chunkMesh.material.getProperty('TerrainShader','surface2').value = getSurface(2);
			_chunkMesh.material.getProperty('TerrainShader','surface3').value = getSurface(3);
		}
		
		public function updateUVRepeat():void
		{
			_uvRepeats.x = _terrain.getUVRepeat(_surfaces[0]);
			_uvRepeats.y = _terrain.getUVRepeat(_surfaces[1]);
			_uvRepeats.z = _terrain.getUVRepeat(_surfaces[2]);
			_uvRepeats.w = _terrain.getUVRepeat(_surfaces[3]);
		}

		public function createMesh(isCreateGeometry:Boolean):void
		{
			_chunkMesh = new ChunkMesh(this);
			
			_chunkMesh.material.addLight(_terrain.ccScene.ambientLight);
			_chunkMesh.material.addLight(_terrain.ccScene.sunLight);
			_chunkMesh.material.addShader(TerrainShader.getShader(_chunkMesh));
			
			_chunkMesh.material.getProperty('TerrainShader','surface0').value = getSurface(0);
			_chunkMesh.material.getProperty('TerrainShader','surface1').value = getSurface(1);
			_chunkMesh.material.getProperty('TerrainShader','surface2').value = getSurface(2);
			_chunkMesh.material.getProperty('TerrainShader','surface3').value = getSurface(3);
			_chunkMesh.material.getProperty('TerrainShader','blendMap').value = _blendTexture;
			_chunkMesh.material.getProperty('TerrainShader','colorMap').value = _colorTexture;
			_chunkMesh.material.getProperty('TerrainShader','uvRepeat').value = _uvRepeats;
			
			var x:Number = (_idx_x-_terrain.xChunks*0.5 + 0.5)*Terrain.CHUNK_SIZE;
			var z:Number = (_idx_z-_terrain.zChunks*0.5 + 0.5)*Terrain.CHUNK_SIZE;
			
			_chunkMesh.position = new Vector3D(x, 0, z);
			Nut.scene.addChild(_chunkMesh);
			
			if (!isCreateGeometry)
				return ;
			
			for (var i:int=0; i!=Terrain.VERT_IDX_MAX; ++i)
			{
				_heightData[i] = 0.0;
			}
			
			_chunkMesh.createGeometry();
		}
		
		public function materialUsageSetting():void
		{
			_chunkMesh.material.usage = Material.UsageSetting;
		}
		
		public function inChunkArea(x:Number, z:Number):Boolean
		{
			var px:Number = (_idx_x-_terrain.xChunks*0.5 + 0.5)*Terrain.CHUNK_SIZE;
			var pz:Number = (_idx_z-_terrain.zChunks*0.5 + 0.5)*Terrain.CHUNK_SIZE;
			var half:Number = Terrain.HALF_CHUNK_SIZE;
			
			if (x < px-half || x > px+half)
				return false;
			
			if (z < pz-half || z > pz+half)
				return false;
			
			return true;
		}
		
		public function exportChunk(data:ByteArray):void
		{
			
		}
		
		public function importChunk(data:ByteArray):void
		{
			while (data.bytesAvailable != 0)
			{
				var segment:int = data.readByte();
				
				if (segment == SegmentConst.SEG_CHUNK_Surface)
				{
					for (i=0; i!=4; ++i)
					{
						_surfaces[i] = data.readUTF();
						_uvRepeats.data[i] = _terrain.getUVRepeat(_surfaces[i]);
					}
				}
				else if (segment == SegmentConst.SEG_CHUNK_Height)
				{
					createMesh(false);
					
					for (var i:int=0; i!=Terrain.VERT_IDX_MAX; ++i)
					{
						_heightData[i] = data.readShort() * 0.01;
					}
					
					_chunkMesh.createGeometry();
				}
				else if (segment == SegmentConst.SEG_CHUNK_WalkHeight)
				{
					_walkHeight = new Vector.<Number>(Terrain.VERT_IDX_MAX);
					for (i=0; i!=Terrain.VERT_IDX_MAX; ++i)
					{
						_walkHeight[i] = data.readShort() * 0.01;
					};
				}
				else if (segment == SegmentConst.SEG_CHUNK_BlendMap)
				{
					var blendData:ByteArray = new ByteArray();
					var blendDataLength:uint = data.readUnsignedInt();
					var blendLoader:BytesLoader = new BytesLoader();
					data.readBytes(blendData, 0, blendDataLength);
					blendLoader.loadImage(blendData, onBlendLoaded);
				}
				else if (segment == SegmentConst.SEG_CHUNK_ColorMap)
				{
					var colorData:ByteArray = new ByteArray();
					var colorDataLength:uint = data.readUnsignedInt();
					var colorLoader:BytesLoader = new BytesLoader();
					data.readBytes(colorData, 0, colorDataLength);
					colorLoader.loadImage(colorData, onColorLoaded);
				}
				else if (segment == SegmentConst.SEG_End)
				{
					break;
				}
			}
		}
		
		private function onBlendLoaded(data:BitmapData):void
		{
			_blendTexture.setContent(data);
		}
		
		private function onColorLoaded(data:BitmapData):void
		{
			_colorTexture.setContent(data);
		}
		
		public function getHeight(x:Number, z:Number, isWalk:Boolean):Number
		{
			var xi :int = x / Terrain.UNIT_SIZE;
			var zi :int = z / Terrain.UNIT_SIZE;
			var idx:int = xi+zi*Terrain.VERT_NUM;
			
			var h00:Number;
			var h01:Number;
			var h10:Number;
			var h11:Number;
			
			if (isWalk && _walkHeight != null)
			{
				h00 = _walkHeight[idx];
				h01 = _walkHeight[idx+1];
				h10 = _walkHeight[idx+Terrain.VERT_NUM];
				h11 = _walkHeight[idx+1+Terrain.VERT_NUM];
			}
			else
			{
				h00 = _heightData[idx];
				h01 = _heightData[idx+1];
				h10 = _heightData[idx+Terrain.VERT_NUM];
				h11 = _heightData[idx+1+Terrain.VERT_NUM];
			}
			
			var tx :Number = (x-xi*Terrain.UNIT_SIZE) / Terrain.UNIT_SIZE;
			var tz :Number = (z-zi*Terrain.UNIT_SIZE) / Terrain.UNIT_SIZE;
			var txtz :Number = tx * tz;
			
			return h00*(1.0-tz-tx+txtz) + h01*(tx-txtz) + h11*txtz + h10*(tz-txtz); 
		}
		
		public function getNormal(i:int):Vector3D
		{
			var x:int = i % Terrain.VERT_NUM;
			var z:int = i / Terrain.VERT_NUM;
			var normal:Vector3D = Vector3D.Y_AXIS.clone();
			var h00:Number;
			var h01:Number;
			var h10:Number;
			var h11:Number;
			var h:Number = _heightData[i];
			var ck:Chunk = null;

			if (x == 0)
			{
				ck = getChunk(_idx_x-1, _idx_z);
				if (ck == null)
					h00 = h;
				else
					h00 = ck.heightData[z*Terrain.VERT_NUM+Terrain.VERT_NUM-2];
			}
			else
			{
				h00 = _heightData[i-1];
			}
			
			if (x == Terrain.VERT_NUM-1)
			{
				ck = getChunk(_idx_x+1, _idx_z);
				if (ck == null)
					h01 = h;
				else
					h01 = ck.heightData[z*Terrain.VERT_NUM+1];
			}
			else
			{
				h01 = _heightData[i+1];
			}
			
			if (z == 0)
			{
				ck = getChunk(_idx_x, _idx_z-1);
				if (ck == null)
					h10 = h;
				else
					h10 = ck.heightData[(Terrain.VERT_NUM-2)*Terrain.VERT_NUM+x];
			}
			else
			{
				h10 = _heightData[i-Terrain.VERT_NUM];
			}
			
			if (z == Terrain.VERT_NUM-1)
			{
				ck = getChunk(_idx_x, _idx_z+1);
				if (ck == null)
					h11 = h;
				else
					h11 = ck.heightData[Terrain.VERT_NUM+x];
			}
			else
			{
				h11 = _heightData[i+Terrain.VERT_NUM];
			}
			

			normal.x = h00 - h01;
			normal.y = 4;
			normal.z = h10 - h11;
			normal.normalize(); 
			
			return normal;
		}
		
		private function getChunk(x:int, z:int):Chunk
		{
			if (x < 0 || x >= _terrain.xChunks || z < 0 || z >= _terrain.zChunks)
				return null;
			
			return _terrain.getChunk(z*_terrain.xChunks+x);
		}
	}
}