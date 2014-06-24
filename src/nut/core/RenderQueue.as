package nut.core
{
	import nut.enum.PassType;

	public class RenderQueue
	{
		static private var _instance:RenderQueue;
		
		private var _passes			:Vector.<Pass>		= new Vector.<Pass>();
		private var _depthPasses	:Vector.<DepthPass>	= new Vector.<DepthPass>();
		private var _startCBs		:Vector.<Function>	= new Vector.<Function>(256);
		private var _endCBs			:Vector.<Function>	= new Vector.<Function>(256);
		private var _activities		:Vector.<Boolean>	= new Vector.<Boolean>(256);
		
		public function RenderQueue()
		{
			for (var i:int = 0; i != 256; ++i)
			{
				_activities[i] = true;
			}
		} 
		
		public static function get instance():RenderQueue
		{
			if (_instance == null)
				_instance = new RenderQueue();
			
			return _instance;
		}
		
		public function notifyActive(pass:Pass):Boolean
		{
			var i:int = _passes.indexOf(pass);
			if (i != -1)
				return false;
			
			var n:int = _passes.length;
			
			if (n == 0)
			{
				_passes.push(pass);
			}
			else
			{
				var inserted:Boolean = false;
				
				for (i = 0; i != n; ++i)
				{
					if (pass.id <= _passes[i].id)
					{
						_passes.splice(i, 0, pass);
						inserted = true;
						break;
					}
				}
				
				if (!inserted)
					_passes.push(pass);
			}
			
			return true;
		}
		
		public function notifyFree(pass:Pass):Boolean
		{
			var i:int = _passes.indexOf(pass);
			
			if (i == -1)
				return false;
			
			_passes.splice(i, 1);
			
			return true;
		}
		
		public function addDepthPass(pass:DepthPass):Boolean
		{
			var i:int = _depthPasses.indexOf(pass);
			
			if (i != -1)
				return false;
			
			_depthPasses.push(pass);
			
			return true;
		}
		
		public function removeDepthPass(pass:DepthPass):Boolean
		{
			var i:int = _depthPasses.indexOf(pass);
			
			if (i == -1)
				return false;
			
			_depthPasses.splice(i, 1);
			
			return true;
		}

		public function render():void
		{
			var depthPassRendered:Boolean = false;
			var n:int = _passes.length;
			var priority:uint = PassType.INVALID;
			
			for (var i:int = 0; i != n; ++i)
			{
				var pass:Pass = _passes[i];
				var newPriority:uint = pass.passType;
				
				if (!_activities[newPriority])
					continue;
				
				if (priority != newPriority)
				{
					if (priority != PassType.INVALID)
					{
						var ecb:Function = _endCBs[priority];
						if (ecb != null)
							ecb();
					}
					
					if (priority < PassType.DEPTHSORT && newPriority > PassType.DEPTHSORT)
					{
						updateDepth();
						
						var sortdqs:Vector.<DepthPass> = _depthPasses.sort(sortPriority);
						var len :int = sortdqs.length;
						
						for (var j:int = 0; j != len; ++j)
						{
							_depthPasses[j].render();
						}
						
						depthPassRendered = true;
					}
					
					var scb:Function = _startCBs[newPriority];
					if (scb != null)
						scb();
					
					priority = newPriority;
				}
				
				pass.render();
			}
			
			if (!depthPassRendered)
			{
				updateDepth();
				
				sortdqs = _depthPasses.sort(sortPriority);
				len = sortdqs.length;
				
				for (j = 0; j != len; ++j)
				{
					_depthPasses[j].render();
				}
			}
		}
		
		private function updateDepth():void
		{
			var n :int = _depthPasses.length;
			
			for (var i:int = 0; i != n; ++i)
			{
				var pass:DepthPass = _depthPasses[i];
				
				pass.depth = pass.mesh.derivedPosition.subtract(Nut.scene.camera.position).lengthSquared;
			}
		}
		
		private function sortPriority(dqm1:DepthPass, dqm2:DepthPass):Number
		{
			var a:Number = dqm1.priority;
			var b:Number = dqm2.priority;
			if (a < b)
			{
				return -1;
			}
			else if (a > b)
			{
				return 1;
			}
			else
			{
				return sortDq(dqm1, dqm2);
			}
		}
		
		private function sortDq(dqm1:DepthPass, dqm2:DepthPass):Number
		{
			var a:Number = dqm1.depth;
			var b:Number = dqm2.depth;
			if (a < b)
			{
				return 1;
			}
			else if (a > b)
			{
				return -1;
			}
			else
			{
				return 0;
			}
		}
		
		public function setPassTypeActivity(priority:uint, activity:Boolean):void
		{
			_activities[priority] = activity;
		}
		
		public function setRenderCallBack(priority:uint, onStart:Function, onEnd:Function):Boolean
		{
			if (priority > 255)
				return false;
			
			_startCBs[priority] = onStart;
			_endCBs[priority] = onEnd;
			
			return true;
		}
	}
}