package nut.ext.effect
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import nut.core.IAsset;
	import nut.core.Node;
	import nut.enum.ResType;

	public class EffectNode extends Node implements IAsset
	{
		private var _name		:String		= "";
		private var _elements	:Vector.<EffectElem>;
		private var _lifeTime	:Number		= 0.0;
		private var _speedFactor:Number		= 1.0;
		private var _currTime	:Number		= 0.0;
		private var _alive		:Boolean	= true;
		private var _onLoaded	:Function	= null;
		
		public function EffectNode():void
		{
			_elements = new Vector.<EffectElem>();
		}
		
		public function get type():uint
		{
			return ResType.EFFECT;
		}

		public function get name():String
		{
			return _name;
		}

		public function set name(value:String):void
		{
			_name = value;
		}
		
		public function set onLoaded(value:Function):void
		{
			_onLoaded = value;
		}
		
		public function get lifeTime():Number
		{
			return _lifeTime;
		}
		
		public function set lifeTime(value:Number):void
		{
			_lifeTime = value;
		}

		public function get alive():Boolean
		{
			return _alive;
		}

		public function set alive(value:Boolean):void
		{
			_alive = value;
		}

		public function get elements():Vector.<EffectElem>
		{
			return _elements;
		}
		
		public function addElement(elem:EffectElem):void
		{
			_elements.push(elem);
			this.addChild(elem);
		}

		public function update(dt:Number):Boolean
		{
			if (!_alive)
				return false;
			
			_alive = false;
			dt *= _speedFactor;
			_currTime += dt;

			var n:int = _elements.length;
			for (var i:int = 0; i != n; ++i)
			{
				var elem:EffectElem = _elements[i];
				
				if (_currTime > elem.startTime)
				{
					var et:Number = _currTime - elem.startTime;
					if (et < dt)
						dt = et;
					
					if (elem.update(dt))
						_alive = true;
				}
			}
			
			return true;
		}
		
		public function encode():ByteArray
		{
			var data:ByteArray = new ByteArray();
			data.endian = Endian.LITTLE_ENDIAN;
			
			data.writeFloat(_lifeTime);
			data.writeByte(_elements.length);
			for (var i:int = 0; i != _elements.length; ++i)
			{
				_elements[i].encode(data);
			}
			
			return data;
		}
		
		public function decode(data:ByteArray):void
		{
			_lifeTime = data.readFloat();
			var n:int = data.readUnsignedByte();
			for (var i:int = 0; i != n; ++i)
			{
				_elements.push(EffectElem.decode(data));
			}
			
			if (_onLoaded != null)
				_onLoaded(this);
		}
	}
}