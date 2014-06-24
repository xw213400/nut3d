package nut.core
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.events.Event;
	
	import nut.core.material.RegCache;

	public class Viewport extends Sprite
	{
		private var _stage3D		:Stage3D	= null;
		private var _context3D		:Context3D	= null;
		private var _antiAlias		:uint		= 2;
		private var _targetWidth	:uint		= 800;
		private var _targetHeight	:uint		= 600;
		private var _backgroundColor:Float4		= new Float4(0.5, 0.5, 0.5, 1);
		
		public function Viewport(stage:Stage, w:uint, h:uint, antiAlias:uint=2)
		{
			_targetWidth = w;
			_targetHeight = h;

			_stage3D	= stage.stage3Ds[0];
			_antiAlias	= antiAlias;
			
			_stage3D.addEventListener(Event.CONTEXT3D_CREATE, initStage3D);
			_stage3D.requestContext3D();
		}

		public function set backgroundColor(value:Float4):void
		{
			_backgroundColor = value;
		}

		public function get targetHeight():uint
		{
			return _targetHeight;
		}

		public function get targetWidth():uint
		{
			return _targetWidth;
		}

		public function get context3D():Context3D
		{
			return _context3D;
		}

		public function get backgroundColor():Float4
		{
			return _backgroundColor;
		}

		public function get sprite():Sprite
		{
			return this;
		}
		
		public function resetPosition(x:int, y:int):void
		{
			super.x = x;
			super.y = y;
			
			_stage3D.x = x;
			_stage3D.y = y;
		}
		
		public function resetSize(w:int, h:int):void
		{
			if (w < 32 || h < 32)
				return ;
			
			super.width = w;
			super.height = w;
			_targetWidth = w;
			_targetHeight = h;
			
			configureBackBuffer();
		}
		
		public function configureBackBuffer():void
		{
			_context3D.configureBackBuffer(_targetWidth, _targetHeight, _antiAlias, true);
			_context3D.clear(_backgroundColor.r, _backgroundColor.g, _backgroundColor.b, _backgroundColor.a);
		}
		
		private function initStage3D(event:Event):void
		{
			_context3D = _stage3D.context3D;
			
			configureBackBuffer();
		}
		
		public function render():Boolean
		{
			if (_context3D == null)
				return false;

//			trace('=========== one frame ===========');
			_context3D.clear(_backgroundColor.r, _backgroundColor.g, _backgroundColor.b, _backgroundColor.a);
			
			Nut.scene.viewport = this;
			Nut.scene.render();
			
			_context3D.present();
			
			return true;
		}
	}
}