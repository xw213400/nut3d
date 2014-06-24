package nut.ext.effect.particle
{
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	
	import nut.util.NutMath;
	
	public class ParticleEmitter
	{
		////////////////////////////可编辑参数///////////////////////////////
		private var	_emissionRate		:Number	= 10;
		private var	_durationMin		:Number	= -1.0;
		private var	_durationMax		:Number	= -1.0;
		private var	_repeatDelay		:Number	= 0.0;
		private var	_minLife			:Number	= 1.0;
		private var	_maxLife			:Number	= 1.0;
		/////////////////////////////////////////////////////////////////
		
		private var _durationRemain		:Number	= 0.0;
		private var	_repeatDelayRemain	:Number	= 0.0;
		private var	_remainder				:Number	= -1.0;
		private var	_fractionEmitNum		:Number	= 0.0;
		private var	_currTime					:Number	= 0.0;
		
		private var _parentSystem :ParticleSystem = null;
		
		public function ParticleEmitter(parentSystem :ParticleSystem)
		{
			_parentSystem = parentSystem;
		}
		
		public function get repeatDelay():Number
		{
			return _repeatDelay;
		}

		public function set repeatDelay(value:Number):void
		{
			_repeatDelay = value;
		}

		public function get parentSystem():ParticleSystem
		{
			return _parentSystem;
		}

		public function get emissionRate() :Number
		{
			return _emissionRate;
		}
		
		public function set emissionRate(value :Number) :void
		{
			_emissionRate = value;
		}
		
		public function get durationMin() :Number
		{
			return _durationMin;
		}
		
		public function set durationMin(value :Number) :void
		{
			_durationMin = value;
		}
		
		public function get durationMax() :Number
		{
			return _durationMax;
		}
		
		public function set durationMax(value :Number) :void
		{
			_durationMax = value;
		}

		public function get minLife() :Number
		{
			return _minLife;
		}
		
		public function set minLife(value :Number) :void
		{
			_minLife = value;
		}
		
		public function get maxLife() :Number
		{
			return _maxLife;
		}
		
		public function set maxLife(value :Number) :void
		{
			_maxLife = value;
		}
		
		public function clone(parentSystem :ParticleSystem) :ParticleEmitter
		{
			var pe :ParticleEmitter = new ParticleEmitter(parentSystem);
			
			pe.emissionRate		= _emissionRate;
			pe.durationMin		= _durationMin;
			pe.durationMax		= _durationMax;
			pe.repeatDelay		= _repeatDelay;
			pe.minLife		= _minLife;
			pe.maxLife		= _maxLife;

			pe.initRemainTime();

			return pe;
		}

		public function initRemainTime() :void
		{
			_durationRemain		= NutMath.random(Particle.seed)*(_durationMax-_durationMin) + _durationMin;
			_repeatDelayRemain	= _repeatDelay;
		}
		
		public function getEmitNum(dt:Number) :int
		{
			var emitNum:Number;
			var num:int;
			
			if (_durationMin <= 0.0 || _durationMax <= 0.0)
			{
				emitNum = _emissionRate * dt + _fractionEmitNum;
				num = Math.floor(emitNum);
				
				_fractionEmitNum = emitNum - num;
				
				return num;
			}
			
			if( _durationRemain > 0 )
			{
				if( _remainder > 0 )
				{
					dt += _remainder;
					_remainder = -1;
				}
				
				_durationRemain -= dt;
				
				if( _durationRemain <= 0 )
				{
					_remainder = -_durationRemain;
					dt -= _remainder;
				}
				
				emitNum = _emissionRate * dt + _fractionEmitNum;
				num =  Math.floor(emitNum);
				
				_fractionEmitNum = emitNum - num;
				
				return num;
			}
			else
			{
				if (_repeatDelay <= 0)
				{
					return 0;
				}
				else
				{
					if (_repeatDelayRemain > 0)
					{
						if( _remainder > 0 )
						{
							dt += _remainder;
							_remainder = -1;
						}
						
						_repeatDelayRemain -= dt;
						
						if (_repeatDelayRemain <= 0)
						{
							_remainder = -_repeatDelayRemain;
							initRemainTime();
						}
						
						return 0;
					}
				}
			}
			
			return 0;
		}
		
		public function encode(data:ByteArray):void
		{
			data.writeFloat(_emissionRate);
			data.writeFloat(_durationMin);
			data.writeFloat(_durationMax);
			data.writeFloat(_repeatDelay);
			data.writeFloat(_minLife);
			data.writeFloat(_maxLife);
		}
		
		public function decode(data:ByteArray):void
		{
			_emissionRate = data.readFloat();
			_durationMin = data.readFloat();
			_durationMax = data.readFloat();
			_repeatDelay = data.readFloat();
			_minLife = data.readFloat();
			_maxLife = data.readFloat();
			
			initRemainTime();
		}
	}
}