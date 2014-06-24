package nut.core
{
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	
	import nut.enum.PassType;
	import nut.util.shaders.PickShader;

	public class PickController
	{
		static private var _instance:PickController = null;
		
		private var _mouseX		:Number;
		private var _mouseY		:Number;
		private var _onComplete	:Function;
		private var _pickTarget	:BitmapData;
		private var _pickMask	:uint;
		
		public function PickController()
		{
			_pickTarget = new BitmapData(256, 256, false);
			RenderQueue.instance.setRenderCallBack(PassType.PICK, onPickPassStart, onPickPassEnd);
		}
		
		public static function get instance():PickController
		{
			if (_instance == null)
				_instance = new PickController();
			
			return _instance;
		}
		
		public function get pickMask():uint
		{
			return _pickMask;
		}

		public function pick(mouseX:Number, mouseY:Number, pickMask:uint, onComplete:Function):void
		{
			_mouseX = mouseX;
			_mouseY = mouseY;
			_pickMask = pickMask;
			_onComplete = onComplete;
			
			RenderQueue.instance.setPassTypeActivity(PassType.PICK, true);
		}
		
		private function onPickPassStart():void
		{
			var context:Context3D = Nut.scene.viewport.context3D;
			context.configureBackBuffer(_pickTarget.width, _pickTarget.height, 0, true);
			context.clear(0, 0, 0, 0);
		}
		
		private function onPickPassEnd():void
		{
			Nut.scene.viewport.context3D.drawToBitmapData(_pickTarget);
			Nut.scene.viewport.configureBackBuffer();
			
			var px:Number = _mouseX/Nut.scene.viewport.targetWidth * _pickTarget.width;
			var py:Number = _mouseY/Nut.scene.viewport.targetHeight * _pickTarget.height;
			var pickId:uint = _pickTarget.getPixel(px, py);
			
			RenderQueue.instance.setPassTypeActivity(PassType.PICK, false);
			
			if (_onComplete != null)
			{
				_onComplete(PickShader.getPickMesh(pickId));
			}
		}
	}
}