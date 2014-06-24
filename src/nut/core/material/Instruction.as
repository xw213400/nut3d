package nut.core.material
{
	public class Instruction
	{
		private var _operation	:String;
		private var _params		:Array;
		private var _suffix		:String = null;
		private var _address	:String = null;
		
		public function Instruction(operation:String, ...params)
		{
			_operation = operation;
			_params = params;
		}

		public function set address(value:String):void
		{
			_address = value;
		}

		public function set suffix(value:String):void
		{
			_suffix = value;
		}

		public function get operation():String
		{
			return _operation;
		}
		
		public function toString():String
		{
			var code:String = "";
			var len:int = _params.length;
			
			if (len == 2)
			{
				code += _params[0] + ", ";
				code += _params[1];
			}
			else if (len == 1)
			{
				code += _params[0];
			}
			else
			{
				
			}
			
			if (_suffix != null)
				code += " " + _suffix;
			
			if (_address != null)
			{
				var param:String;
				if (len == 2)
					param = _params[1];
				else if (len == 1)
					param = _params[0];
				
				if (param.length == 4)
					code = code.substr(0, code.length-2);
				else if (param.length == 3)
					code = code.substr(0, code.length-1);
					
				code += _address;
			}
			
			return code;
		}
	}
}