package nut.core
{
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	import flash.geom.Matrix;
	
	import nut.enum.ResType;

	public class NutTexture implements IAsset
	{
		static public const MAX_SIZE		:uint = 2048;
		static private var  TMP_MATRIX		:Matrix = new Matrix();
		
		private var _name		:String		= "";
		private var _texture	:Texture	= null;
		private var _mipmap		:Boolean	= false;
		private var _bitmapData	:BitmapData	= null;
		private var _width		:uint		= 0;
		private var _height		:uint		= 0;
		private var _dirty		:Boolean	= false;
		private var _onLoaded	:Function	= null;
		
		public function get dirty():Boolean
		{
			return _dirty;
		}
		
		public function set onLoaded(value:Function):void
		{
			_onLoaded = value;
		}
		
		public function get type():uint
		{
			return ResType.TEXTURE;
		}

		public function set name(value:String):void
		{
			_name = value;
		}

		public function get bitmapData():BitmapData
		{
			return _bitmapData;
		}

		public function get name():String
		{
			return _name;
		}

		public function get width() : uint
		{
			return _width;
		}

		public function get height() : uint
		{
			return _height;
		}
		
		public function NutTexture(width:uint=0, height:uint=0)
		{
            _width = width;
            _height = height;
		}

		public function setContent(bitmapData:BitmapData, mipmap:Boolean=true):void
		{	
			_bitmapData = bitmapData;
			
			if (_texture && (mipmap != _mipmap
					|| bitmapData.width != _width
					|| bitmapData.height != _height))
			{
				_texture.dispose();
				_texture = null;
			}
			
			_width 	= bitmapData.width;
			_height = bitmapData.height;
			_mipmap	= mipmap;
			
			_dirty = true;
			
			if (_onLoaded != null)
				_onLoaded(this);
		}
		
		public function invalidateContent():void
		{
			_dirty = true;
		}

		public function getTexture(context:Context3D):Texture
		{
			if (!_texture && _width && _height)
			{
				_texture = context.createTexture(
					_width,
					_height,
					Context3DTextureFormat.BGRA,
					_bitmapData == null
				);
			}

			if (_dirty)
			{
				_dirty = false;
				uploadBitmapDataWithMipMaps();
			}
			
			return _texture;
		}
		
		private function uploadBitmapDataWithMipMaps() : void
		{
			if (_bitmapData)
			{
				if (_mipmap)
				{
					var level 		: uint 			= 0;
					var size		: uint 			= _width > _height ? _width : _height;
					var transparent	: Boolean		= _bitmapData.transparent;
					var tmp 		: BitmapData 	= new BitmapData(_width, _height, transparent, 0);
					var transform 	: Matrix		= new Matrix();
					
					while (size >= 1)
					{
						tmp.draw(_bitmapData, transform, null, null, null, true);
						_texture.uploadFromBitmapData(tmp, level);
						
						transform.scale(.5, .5);
						level++;
						size >>= 1;
						
						if (tmp.transparent)
							tmp.fillRect(tmp.rect, 0);
					}
					
					tmp.dispose();
				}
				else
				{
					_texture.uploadFromBitmapData(_bitmapData, 0);
				}
			}
		}
		
		public function dispose() : void
		{
			if (_texture)
			{
				_texture.dispose();
				_texture = null;
			}
		}
		
		public function toString():String
		{
			return _name;
		}
	}
}
