package nut.core
{
	import flash.display.Stage;
	import flash.utils.Dictionary;
	
	import nut.util.NutMath;

	
	public class Nut
	{
		static private var _resMgr	:ResourceManager	= null;
		static private var _scene	:NutScene			= null;
		
		public static function get resMgr():ResourceManager
		{
			return _resMgr;
		}
		
		public static function get scene():NutScene
		{
			return _scene;
		}

		static public function initialize(baseUrl:String):void
		{
			NutMath.init();
			
			_scene = new NutScene();
			_resMgr = new ResourceManager(baseUrl);
		}
	}
}