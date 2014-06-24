package nut.core.material
{
	public class Expression
	{
		protected function add(a:Instruction, b:Instruction):Instruction
		{
			var instruction:Instruction = new Instruction('add', a, b);
			
			return instruction;
		}
		
		protected function m44(a:Instruction, b:Instruction, address:Instruction=null):Instruction
		{
			var instruction:Instruction = new Instruction('m44', a, b);
			
			if (address != null)
				instruction.address = '[' + address.toString() + ']';
			
			return instruction;
		}
		
		protected function m34(a:Instruction, b:Instruction, address:Instruction=null):Instruction
		{
			var instruction:Instruction = new Instruction('m34', a, b);
			
			if (address != null)
				instruction.address = '[' + address.toString() + ']';
			
			return instruction;
		}
		
		protected function m33(a:Instruction, b:Instruction, address:Instruction=null):Instruction
		{
			var instruction:Instruction = new Instruction('m33', a, b);
			
			if (address != null)
				instruction.address = '[' + address.toString() + ']';
			
			return instruction;
		}
		
		protected function mov(a:Instruction, address:Instruction=null):Instruction
		{
			var instruction:Instruction = new Instruction('mov', a);
			
			if (address != null)
				instruction.address = '[' + address.toString() + ']';
			
			return instruction;
		}
		
		protected function mul(a:Instruction, b:Instruction):Instruction
		{
			var instruction:Instruction = new Instruction('mul', a, b);
			
			return instruction;
		}
		
		protected function dp3(a:Instruction, b:Instruction):Instruction
		{
			var instruction:Instruction = new Instruction('dp3', a, b);
			
			return instruction;
		}
		
		protected function dp4(a:Instruction, b:Instruction):Instruction
		{
			var instruction:Instruction = new Instruction('dp4', a, b);
			
			return instruction;
		}
		
		protected function sat(a:Instruction):Instruction
		{
			var instruction:Instruction = new Instruction('sat', a);
			
			return instruction;
		}
		
		protected function sin(a:Instruction):Instruction
		{
			var instruction:Instruction = new Instruction('sin', a);
			
			return instruction;
		}
		
		protected function cos(a:Instruction):Instruction
		{
			var instruction:Instruction = new Instruction('cos', a);
			
			return instruction;
		}
		
		protected function tex(uv:Instruction, sample:Instruction, method:String):Instruction
		{
			var instruction:Instruction = new Instruction('tex', uv, sample);
			instruction.suffix = method;
			return instruction;
		}
		
		protected function sub(a:Instruction, b:Instruction):Instruction
		{
			var instruction:Instruction = new Instruction('sub', a, b);
			
			return instruction;
		}
		
		protected function min(a:Instruction, b:Instruction):Instruction
		{
			var instruction:Instruction = new Instruction('min', a, b);
			
			return instruction;
		}
		
		protected function nrm(a:Instruction):Instruction
		{
			var instruction:Instruction = new Instruction('nrm', a);
			
			return instruction;
		}
		
		protected function pow(a:Instruction, b:Instruction):Instruction
		{
			var instruction:Instruction = new Instruction('pow', a, b);
			
			return instruction;
		}
		
		protected function crs(a:Instruction, b:Instruction):Instruction
		{
			var instruction:Instruction = new Instruction('crs', a, b);
			
			return instruction;
		}
		
		protected function frc(a:Instruction):Instruction
		{
			var instruction:Instruction = new Instruction('frc', a);
			
			return instruction;
		}
		
		protected function div(a:Instruction, b:Instruction):Instruction
		{
			var instruction:Instruction = new Instruction('div', a, b);
			
			return instruction;
		}
		
		protected function neg(a:Instruction):Instruction
		{
			var instruction:Instruction = new Instruction('neg', a);
			
			return instruction;
		}
		
		protected function slt(a:Instruction, b:Instruction):Instruction
		{
			var instruction:Instruction = new Instruction('slt', a, b);
			
			return instruction;
		}
		
		protected function sge(a:Instruction, b:Instruction):Instruction
		{
			var instruction:Instruction = new Instruction('sge', a, b);
			
			return instruction;
		}
	}
}