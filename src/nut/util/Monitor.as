package nut.util
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.Capabilities;
	import flash.system.System;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	public class Monitor extends Sprite
	{
		private static const DEFAULT_UPDATE_RATE	:Number	= 1;
		private static const DEFAULT_BACKGROUND		:uint	= 0x1F1F0000;
		private static const DEFAULT_COLOR			:uint	= 0xffffffff;
		
		private static var _instance				:Monitor= null;
		
		private var _targets		: Dictionary	= new Dictionary();
		private var _xml			: XML			= null;
		private var _colors			: Object		= new Object();
		private var _style			: StyleSheet	= new StyleSheet();
		private var _label			: TextField		= new TextField();
		private var _numFrames		: int			= 0;
		private var _updateTime		: int			= 0;
		private var _framerate		: int			= 0;
		private var _maxMemory		: int			= 0;

		public function Monitor()
		{
			super();
			
			_xml = <monitor/>;
			_xml["version"] = "version: ";
			_xml["framerate"] = "framerate: ";
			_xml["memory"] = "memory: ";
			
			_style.setStyle("monitor", {fontSize:	"9px",
				fontFamily:	"_sans",
				leading:	"-2px"});
			
			setStyle("version", {color: "#FFFFAA"});
			setStyle("framerate", {color: "#FFAAFF"});
			setStyle("memory", {color: "#AAFFFF"});
			
			_label.styleSheet = _style;
			_label.condenseWhite = true;
			_label.autoSize = TextFieldAutoSize.LEFT;
			
			addChild(_label);
			
			_xml.version = Capabilities.version + (Capabilities.isDebugger ? " (debug)" : "")
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
		}
		
		public static function get instance():Monitor
		{
			return _instance || (_instance = new Monitor());
		}
		
		private function setStyle(property:String, value:Object) : void
		{
			_style.setStyle(property, value);
			
			if (value.color)
				_colors[property] = 0xff000000 | parseInt(value.color.substr(1), 16);
		}
		
		private function enterFrameHandler(event : Event) : void
		{
			++_numFrames;
			
			var time : int = getTimer();
			
			if ((time - _updateTime) >= 1000. / DEFAULT_UPDATE_RATE)
			{
				// framerate
				_framerate = _numFrames / ((time - _updateTime) / 1000.);
				
				if (!visible || !stage)
				{
					_updateTime = time;
					_numFrames = 0;
					
					return ;
				}
				
				// prepare bitmap data
				_xml.framerate = "framerate: " + _framerate + " / " + stage.frameRate;
				
				// memory
				var totalMemory : int = System.totalMemory;
				
				if (totalMemory > _maxMemory)
					_maxMemory = totalMemory;
				
				_xml.memory = "memory: " + ((totalMemory>>>10)*0.001).toFixed(3) + " / " + ((_maxMemory>>>10)*0.001).toFixed(3);
				
				// properties
				for (var target : Object in _targets)
				{
					var properties : Array = _targets[target];
					var numProperties : int	= properties.length;
					
					for (var i : int = 0; i < numProperties; ++i)
					{
						var property : String = properties[i];
						var value : Object = target[property];
						
						_xml[property] = property + ": " + value;
					}
				}
				
				_label.htmlText = _xml;
				
				_numFrames = 0;
				_updateTime = time;
				
				updateBackground();
			}
		}
		
		private function addedToStageHandler(e : Event) : void
		{
			_maxMemory = System.totalMemory;
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		private function removedFromStageHandler(e : Event) : void
		{
			removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		/**
		 * Watch a property of a specified object.
		 * 
		 * @param target The object containing the property to watch.
		 * @param property The name of the property to watch.
		 * @param color The color of the displayed label.
		 */
		public function watchProperty(target:Object, property:String, color:int=DEFAULT_COLOR):void
		{
			if (!_targets[target])
				_targets[target] = new Array();
			
			_targets[target].push(property);
			_xml[property] = property + ": " + target[property];
			
			setStyle(property, {color: "#" + (color as Number & 0xffffff).toString(16)});
			
			_label.htmlText = _xml;
			_label.autoSize = TextFieldAutoSize.LEFT;
		}
		
		private function updateBackground() : void
		{
			if (_label.textWidth == width && _label.textHeight == height)
				return ;
			
			graphics.clear();
			graphics.beginFill(DEFAULT_BACKGROUND & 0xffffff, (DEFAULT_BACKGROUND >>> 24) / 255.);
			graphics.drawRect(0, 0, width, height);
			graphics.endFill();
		}
	}
}