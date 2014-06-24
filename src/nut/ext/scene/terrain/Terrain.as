package nut.ext.scene.terrain
{
	import flash.display.BitmapData;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import nut.core.Nut;
	import nut.core.NutTexture;
	import nut.ext.scene.GameScene;
	import nut.ext.scene.SegmentConst;

	public class Terrain
	{
		static public const UNIT_SIZE	:Number	= 2;
		static public const UNIT_NUM	:int	= 16;
		static public const BLEND_MAP_SIZE:int = 32;
		static public const COLOR_MAP_SIZE:int = 32;
		static public const VERT_NUM	:int	= UNIT_NUM + 1;
		static public const CHUNK_SIZE	:Number	= UNIT_SIZE * UNIT_NUM;
		static public const HALF_CHUNK_SIZE	:Number	= CHUNK_SIZE * 0.5;
		static public const VERT_IDX_MAX:int = VERT_NUM * VERT_NUM;
		static public const INVALID_HEIGHT:Number = -10000;
		static public const MAX_HEIGHT:Number = 300;
		
		protected var _xChunks	:int = 0;
		protected var _zChunks	:int = 0;
		protected var _chunks	:Vector.<Chunk> = new Vector.<Chunk>();
		protected var _chunkCount	:int = 0;
		protected var _gameScene	:GameScene;
		private var _surfaces	:Dictionary = new Dictionary();
		protected var _uvRepeats	:Dictionary = new Dictionary();
		private var _chunkLoaded:int = 0;
		private var _walkShapes:Vector.<WalkShape> = new Vector.<WalkShape>();
		
		public function Terrain(gameScene:GameScene, x_count:int, z_count:int)
		{
			_gameScene = gameScene;
			_xChunks = x_count;
			_zChunks = z_count;
			_chunkCount = _zChunks * _xChunks;
			
			for (var i:int=0; i!=_chunkCount; ++i)
			{
				_chunks.push(createChunk(i));
			}
			
			var tex:NutTexture = new NutTexture();
			tex.setContent(new BitmapData(32,32,false,0xffffffff), true);
			_surfaces[""] = tex;
			_uvRepeats[""] = 1;
		}

		public function get walkShapes():Vector.<WalkShape>
		{
			return _walkShapes;
		}

		public function get chunkCount():int
		{
			return _chunkCount;
		}

		public function get ccScene():GameScene
		{
			return _gameScene;
		}

		public function get zChunks():int
		{
			return _zChunks;
		}

		public function get xChunks():int
		{
			return _xChunks;
		}
		
		protected function createChunk(i:int):Chunk
		{
			return new Chunk(this, i);
		}
		
		public function getUVRepeat(path:String):int
		{
			if (_uvRepeats[path] == null)
				return 1;
			
			return _uvRepeats[path];
		}
		
		public function getChunk(i:int):Chunk
		{
			return _chunks[i];
		}
		
		public function getSurface(path:String):NutTexture
		{
			if (_surfaces[path] == null)
			{
				Nut.resMgr.loadTexture(path, onSurfaceLoaded);
				
				return _surfaces[""];
			}
			else
			{
				return _surfaces[path];
			}
		}
		
		private function onSurfaceLoaded(texture:NutTexture):void
		{
			_surfaces[texture.name] = texture;

			if (_uvRepeats[texture.name] == null)
				_uvRepeats[texture.name] = 2;
			
			updateChunkSurface();
		}
		
		private function updateChunkSurface():void
		{
			for (var i:int=0; i!=_chunkCount; ++i)
			{
				_chunks[i].updateSurface();
			}
		}
		
		public function encode(data:ByteArray):void
		{
			data.writeByte(SegmentConst.SEG_TERRAIN_UV);
			var uvNum:int = 0;
			var oldPos:uint = data.position;
			data.writeShort(uvNum);
			for (var key:String in _uvRepeats)
			{
				if (_surfaces[key] == null)
					continue;
				
				++uvNum;
				data.writeUTF(key);
				data.writeByte(_uvRepeats[key]);
			}
			var newPos:uint = data.position;
			data.position = oldPos;
			data.writeShort(uvNum);
			data.position = newPos;
			
			if (_walkShapes.length != 0)
			{
				data.writeByte(SegmentConst.SEG_TERRAIN_WalkShape);
				data.writeByte(_walkShapes.length);
				for (var i:int = 0; i != _walkShapes.length; ++i)
				{
					_walkShapes[i].exportWalkShape(data);
				}
			}

			data.writeByte(SegmentConst.SEG_TERRAIN_Chunks);
			prepareWalkHeight();
			for (i = 0; i != _chunkCount; ++i)
			{
				_chunks[i].exportChunk(data);
			}
			
			data.writeByte(SegmentConst.SEG_End);
		}
		
		public function decode(data:ByteArray):void
		{
			while (data.bytesAvailable != 0)
			{
				var segment:int = data.readByte();
				
				if (segment == SegmentConst.SEG_TERRAIN_UV)
				{
					var uvNum:int = data.readShort();
					for (var i:int=0; i!= uvNum; ++i)
					{
						_uvRepeats[data.readUTF()] = data.readByte();
					}
				}
				else if (segment == SegmentConst.SEG_TERRAIN_WalkShape)
				{
					var shapeNum:int = data.readByte();
					for (i=0; i!=shapeNum; ++i)
					{
						var ws:WalkShape = new WalkShape();
						ws.importWalkShape(data);
						_walkShapes.push(ws);
					}
				}
				else if (segment == SegmentConst.SEG_TERRAIN_Chunks)
				{
					for (i=0; i!=_chunkCount; ++i)
					{
						_chunks[i].importChunk(data);
					}
					
					this.updateNormal();
				}
				else if (segment == SegmentConst.SEG_End)
				{
					break;
				}
			}
		}
		
		public function materialUsageSetting():void
		{
			for (var i:int = 0; i != _chunkCount; ++i)
			{
				_chunks[i].materialUsageSetting();
			}
		}
		
		public function prepareWalkHeight():void
		{
			for (var i:int=0; i!=_chunkCount; ++i)
			{
				var chunk:Chunk = _chunks[i];
				var wss:Vector.<WalkShape> = findOverlayWalkShapes(chunk);
				
				if (wss.length == 0)
				{
					chunk.walkHeight = null;
					continue;
				}
				
				var ck_x:Number = chunk.idx_x*CHUNK_SIZE-_xChunks*HALF_CHUNK_SIZE;
				var ck_z:Number = chunk.idx_z*CHUNK_SIZE-_zChunks*HALF_CHUNK_SIZE;
				
				chunk.initWalkHeight();
				for (var j:int=0; j!=wss.length; ++j)
				{
					var ws:WalkShape = wss[j];
					var wh:Vector.<Number> = chunk.walkHeight;
					
					for (var z:int = 0; z != VERT_NUM; ++z)
					{
						for (var x:int = 0; x != VERT_NUM; ++x)
						{
							var idx:int = z*VERT_NUM+x;
							var h:Number = ws.getHeight(ck_x+x*UNIT_SIZE,ck_z+z*UNIT_SIZE);
							if (h > -9999)
								wh[idx] = h;
						}
					}
				}
			}
		}
		
		private function findOverlayWalkShapes(chunk:Chunk):Vector.<WalkShape>
		{
			var wss:Vector.<WalkShape> = new Vector.<WalkShape>();
			for (var i:int=0; i!=_walkShapes.length; ++i)
			{
				var ws:WalkShape = _walkShapes[i];
				if (ws.overlay(chunk))
				{
					wss.push(ws);
				}
			}
			return wss;
		}
		
		public function pick(rayPosition:Vector3D, rayDirection:Vector3D, isWalk:Boolean=true):Vector3D
		{
			var p1:Vector3D = new Vector3D();
			var p2:Vector3D = new Vector3D();
			
			if (!clipRay(rayPosition, rayDirection, p1, p2))
			{
				return null;
			}
			
			var h1 :Number = getHeight(p1.x, p1.z, isWalk);
			var dh1:Number = p1.y - h1;
			
			if (dh1 < 0)
			{
				return null;
			}
			
			if (!linearSearch(p1, p2, isWalk))
			{
				return null;
			}
			
			h1 = getHeight(p1.x, p1.z, isWalk);
			dh1 = p1.y - h1;
			
			var h2 :Number = getHeight(p2.x, p2.z, isWalk);
			var dh2:Number = p2.y - h2;
			
			if (Math.abs(dh1) < 0.03)
				return p1;
			
			if (Math.abs(dh2) < 0.03)
				return p2;
			
			return binarySearch(p1, p2, 0, isWalk);
		}
		
		private function clipRay(rayPos:Vector3D, rayDir:Vector3D, p1:Vector3D, p2:Vector3D):Boolean
		{
			var x_half:Number = _xChunks * HALF_CHUNK_SIZE;
			var z_half:Number = _zChunks * HALF_CHUNK_SIZE;
			
			rayDir.normalize();
			var dir:Vector3D = rayDir.clone();
			
			if (rayPos.x < -x_half && rayDir.x <= 0)
				return false;
			
			if (rayPos.x > x_half && rayDir.x >= 0)
				return false;
			
			if (rayPos.z < -z_half && rayDir.z <= 0)
				return false;
			
			if (rayPos.z > z_half && rayDir.z >= 0)
				return false;
			
			if (rayPos.y < -MAX_HEIGHT && rayDir.y <= 0)
				return false;
			
			if (rayPos.y > MAX_HEIGHT && rayDir.y >= 0)
				return false;
			
			p1.copyFrom(rayPos);
			
			var f1x:Number = Math.abs(rayPos.x) - x_half;
			var f1y:Number = Math.abs(rayPos.y) - MAX_HEIGHT;
			var f1z:Number = Math.abs(rayPos.z) - z_half;
			
			if (f1x>=0 || f1y>=0 || f1z>=0)
			{
				f1x = f1x>0 ? Math.abs(f1x/dir.x) : 0;
				f1y = f1y>0 ? Math.abs(f1y/dir.y) : 0;
				f1z = f1z>0 ? Math.abs(f1z/dir.z) : 0;
				
				var f1:Number = Math.max(f1x, f1y, f1z);
				dir.scaleBy(Math.abs(f1)+0.01);
				p1.incrementBy(dir);
			}
			
			var rayPos2:Vector3D = rayDir.clone();
			rayPos2.scaleBy(600);
			rayPos2.incrementBy(rayPos);
			p2.copyFrom(rayPos2);
			
			var f2x:Number = Math.abs(rayPos2.x) - x_half;
			var f2y:Number = Math.abs(rayPos2.y) - MAX_HEIGHT;
			var f2z:Number = Math.abs(rayPos2.z) - z_half;
			
			if (f2x>=0 || f2y>=0 || f2z>=0)
			{
				dir.copyFrom(rayDir);
				
				f2x = f2x>0 ? Math.abs(f2x/dir.x) : 0;
				f2y = f2y>0 ? Math.abs(f2y/dir.y) : 0;
				f2z = f2z>0 ? Math.abs(f2z/dir.z) : 0;
				
				var f2:Number = Math.max(f2x, f2y, f2z);
				dir.scaleBy(Math.abs(f2)+0.01);
				dir.negate();
				p2.incrementBy(dir);
			}
			
			if (p1.x < -x_half || p1.x > x_half || p1.z < -z_half || 
				p1.z > z_half || p1.y < -MAX_HEIGHT || p1.y > MAX_HEIGHT ||
				p2.x < -x_half || p2.x > x_half || p2.z < -z_half || 
				p2.z > z_half || p2.y < -MAX_HEIGHT || p2.y > MAX_HEIGHT)
				return false;
			
			return true;
		}
		
		private function linearSearch(p1:Vector3D, p2:Vector3D, isWalk:Boolean):Boolean
		{
			var intersect:Boolean = false;
			var step:Vector3D = p2.subtract(p1);
			var p:Vector3D = p1.clone();
			
			step.scaleBy(0.02);
			
			for (var i:int=0; i!=50; ++i)
			{
				p.incrementBy(step);
				var dh:Number = p.y - getHeight(p.x, p.z, isWalk);
				if (dh <= 0)
				{
					intersect = true;
					p1.copyFrom(p);
					p1.decrementBy(step);
					p2.copyFrom(p);
					
					break;
				}
			}

			return intersect;
		}
		
		private function binarySearch(p1:Vector3D, p2:Vector3D, num:int, isWalk:Boolean):Vector3D
		{
			if (num > 16)
				return null;
			
			var p:Vector3D = p1.add(p2);
			p.scaleBy(0.5);
			
			var h:Number = getHeight(p.x, p.z, isWalk);
			var dh:Number = p.y - h;
			
			if (dh < -0.03)
			{
				return binarySearch(p1, p, num+1, isWalk);
			}
			else if (dh > 0.03)
			{
				return binarySearch(p, p2, num+1, isWalk);
			}
			else
			{
				return p;
			}
		}
		
		public function getHeight(x:Number, z:Number, isWalk:Boolean=true):Number
		{
			var x_half:Number = _xChunks * HALF_CHUNK_SIZE;
			var z_half:Number = _zChunks * HALF_CHUNK_SIZE;
			
			if (x > x_half || x < -x_half || z > z_half || z < -z_half)
				return INVALID_HEIGHT;
			
			if (x == x_half)
				x -= 0.000001;
			
			if (z == z_half)
				z -= 0.000001;
			
			var x_i:int = (x+x_half) / CHUNK_SIZE;
			var z_i:int = (z+z_half) / CHUNK_SIZE;
			
			var x_offset:Number = x+x_half - x_i*CHUNK_SIZE;
			var z_offset:Number = z+z_half - z_i*CHUNK_SIZE;

			return _chunks[x_i+z_i*_xChunks].getHeight(x_offset, z_offset, isWalk);
		}
		
		public function dispose():void
		{
			for (var i:int=0; i!=_chunkCount; ++i)
			{
				_gameScene.scene.removeChild(_chunks[i].chunkMesh);
				_chunks[i].chunkMesh.geometry.dispose();
			}
		}
		
		public function updateNormal():void
		{
			for (var i:int=0; i!=_chunkCount; ++i)
			{
				_chunks[i].chunkMesh.updateNormal();
			}
		}		
	}
}