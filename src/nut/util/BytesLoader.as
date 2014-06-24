package nut.util
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.CompressionAlgorithm;
	import flash.utils.Endian;
	
	
	public class BytesLoader
	{
		static public const COMPRESSED_BYTES	:int = 1;
		static public const UNCOMPRESS_BYTES	:int = 2;
		static public const TEXTURE				:int = 3;
		static public const XML_DOCUMENT		:int = 4;
		
		private var _data		:Object		= null;
		private var _onComplete :Function	= null;
		private var _format		:int		= COMPRESSED_BYTES;
		private var _userData	:Object		= null;
		
		public function BytesLoader()
		{
		}
		
		public function get data():Object
		{
			return _data;
		}
		
		public function load(url:String, onComplete:Function, format:int=COMPRESSED_BYTES, userData:Object=null):void
		{
			_onComplete = onComplete;
			_format = format;
			_userData = userData;

			var loader : URLLoader = new URLLoader();
			
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			configureListeners(loader);
			loader.load(new URLRequest(url));
		}
		
		private function configureListeners(loader:URLLoader):void
		{
			loader.addEventListener(Event.COMPLETE, onLoadURLComplete);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
		}
		
		private function securityErrorHandler(evt:Event):void
		{
			trace("securityErrorHandler: " + evt);
			onComplete();
		}
		
		private function ioErrorHandler(evt:IOErrorEvent):void
		{
			trace("ioErrorHandler: " + evt.text);
			onComplete();
		}
		
		private function onLoadURLComplete(evt:Event):void
		{
			var bytes:ByteArray = evt.currentTarget.data;
			
			bytes.endian = Endian.LITTLE_ENDIAN;

			if (_format == COMPRESSED_BYTES || _format == UNCOMPRESS_BYTES)
			{
				if (_format == COMPRESSED_BYTES)
				{
					bytes.uncompress(CompressionAlgorithm.LZMA);
				}
				_data = bytes;
				onComplete();
			}
			else if (_format == TEXTURE)
			{
				loadImage(bytes, _onComplete, _userData);
			}
			else if (_format == XML_DOCUMENT)
			{
				_data = new XML(bytes.readUTFBytes(bytes.length));
				onComplete();
			}
		}
		
		public function loadImage(bytes:ByteArray, onComplete:Function, userData:Object=null):void
		{
			_onComplete = onComplete;
			_userData = userData;
			
			var loader :Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadImageComplete);
			loader.loadBytes(bytes);
		}
		
		private function onLoadImageComplete(e:Event):void
		{
			var displayObject :DisplayObject = LoaderInfo(e.currentTarget).content;
			
			if (displayObject is Bitmap)
			{
				_data = (displayObject as Bitmap).bitmapData;
				onComplete();
			}
			else
			{
				throw new Error("Texture load failed!");
			}
		}
		
		private function onComplete():void
		{
			if (_onComplete != null)
			{
				if (_userData != null)
					_onComplete(_data, _userData);
				else
					_onComplete(_data);
			}
		}
	}
}