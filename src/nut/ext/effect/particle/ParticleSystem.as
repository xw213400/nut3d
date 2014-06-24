package nut.ext.effect.particle
{	
	import flash.utils.ByteArray;
	
	import nut.core.Mesh;
	
	public class ParticleSystem extends Mesh
	{		
		////////////////////////////可编辑参数///////////////////////////////
		protected var	_poolSize				:uint				= 10;
		protected var	_speedFactor			:Number				= 1.0;
		protected var	_localSpace				:Boolean			= true;
		/////////////////////////////////////////////////////////////////

		private var _emitter 		:ParticleEmitter	= null;
		
		private var _billboardSet			:BillboardSet		= null;
		private var _visible				:Boolean			= true;
		private var _stoped					:Boolean			= false;
		
		private var _currTime			:Number	= 0.0;
		
		public function ParticleSystem(poolSize:int)
		{
			_poolSize = poolSize;
			_billboardSet = new BillboardSet(this);
			_emitter = new ParticleEmitter(this);
			super(_billboardSet);
		}
		
		public function set poolSize(value:uint):void
		{
			if (value != _poolSize)
			{
				_poolSize = value;
				_billboardSet.dispose();
				_geometry = _billboardSet = new BillboardSet(this);
			}
		}

		public function get emitter():ParticleEmitter
		{
			return _emitter;
		}

		public function get stoped():Boolean
		{
			return _stoped;
		}
		
		public function set stoped(value:Boolean):void
		{
			_stoped = value;
		}
		
		public function get currTime():Number
		{
			return _currTime;
		}
		
		override public function clone():Mesh
		{
			var ps :ParticleSystem	= new ParticleSystem(_poolSize);

			ps.speedFactor				= _speedFactor;
			ps.localSpace				= _localSpace;
			
			_emitter.clone(ps);
			
			return ps;
		}
		
		public function get poolSize() :uint
		{	
			return _poolSize;
		}
		
		public function get speedFactor() :Number
		{
			return _speedFactor;
		}
		
		public function set speedFactor(value :Number) :void
		{
			_speedFactor = value;
		}
		
		public function get localSpace() :Boolean
		{
			return _localSpace;
		}
		
		public function set localSpace(value :Boolean) :void
		{
			_localSpace = value;
		}
		
		public function update(deltaTime: Number):Boolean
		{
			deltaTime *= _speedFactor;
			
			_currTime += deltaTime;
			
			expire(deltaTime);
			triggerEmitters(deltaTime);
			
			return true;
		}
		
		private function expire(dt:Number) :void
		{
			var p:Particle = _billboardSet.activeBuffer.head;
			var l:Particle = null;
			
			while (p != null)
			{
				if (p.life < dt)
				{
					var temp:Particle = _billboardSet.activeBuffer.remove(l, p);
					_billboardSet.freeBuffer.add(p);
					p = temp;
				}
				else
				{
					p.life -= dt;
					l = p;
					p = p.next;
				}
			}
		}
		
		private function triggerEmitters(dt :Number) :void
		{
			if( _stoped )
				return ;
			
			var num :uint = _emitter.getEmitNum(dt);
			_billboardSet.emit(num, _emitter);
		}
		
		override public function encode(data:ByteArray):void
		{
			data.writeFloat(_speedFactor);
			data.writeBoolean(_localSpace);
			
			_emitter.encode(data);
			_material.encode(data);
		}
		
		public function decode(data:ByteArray):void
		{
			_speedFactor = data.readFloat();
			_localSpace = data.readBoolean();
			
			_emitter.decode(data);
			_material.decode(data);
		}
	}
}