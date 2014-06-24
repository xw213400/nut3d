package nut.ext.effect
{
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	
	import nut.ext.effect.particle.ParticleSystem;
	
	public class EffectElem extends ParticleSystem
	{
		private var	_name			:String		= "";
		private var _startTime		:Number		= 0.0;
		private var _followGround	:Boolean	= false;
		private var _enabled		:Boolean	= true;
		
		public function EffectElem(poolSize:int)
		{
			super(poolSize);
		}

		public function get followGround():Boolean
		{
			return _followGround;
		}

		public function set followGround(value:Boolean):void
		{
			_followGround = value;
		}

		public function get enabled():Boolean
		{
			return _enabled;
		}

		public function set enabled(value:Boolean):void
		{
			_enabled = value;
		}

		public function get startTime():Number
		{
			return _startTime;
		}

		public function set startTime(value:Number):void
		{
			_startTime = value;
		}
		
		public function get name() :String
		{
			return _name;
		}
		
		public function set name(value :String) :void
		{
			_name = value;
		}

		override public function encode(data:ByteArray):void
		{
			data.writeShort(_poolSize);
			
			data.writeUTF(_name);
			data.writeFloat(_startTime);
			data.writeBoolean(_followGround);
			
			var rawData:Vector.<Number> = _transform.rawData;
			
			for (var i:int = 0; i != 16; ++i)
				data.writeFloat(rawData[i]);
			
			super.encode(data);
		}
		
		static public function decode(data:ByteArray):EffectElem
		{
			var effectElem:EffectElem = new EffectElem(data.readUnsignedShort());
			
			effectElem.name = data.readUTF();
			effectElem.startTime = data.readFloat();
			effectElem.followGround = data.readBoolean();
			
			effectElem._transform.copyRawDataFrom(Vector.<Number>([
				data.readFloat(),data.readFloat(),data.readFloat(),data.readFloat(),
				data.readFloat(),data.readFloat(),data.readFloat(),data.readFloat(),
				data.readFloat(),data.readFloat(),data.readFloat(),data.readFloat(),
				data.readFloat(),data.readFloat(),data.readFloat(),data.readFloat()
			]));
			
			effectElem._localToWorldDirty = true;
			
			effectElem.decode(data);
			
			return effectElem;
		}
	}
}