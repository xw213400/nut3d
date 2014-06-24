package nut.core.material
{
	public class RegElem
	{
		private var _name		:String = 'va0';
		private var _type		:String = 'va';
		private var _id			:int	= 0;
		private var _regCache	:RegCache = null;
		
		public function RegElem(type:String, id:int, regCache:RegCache)
		{
			_type = type;
			_id = id;
			
			if (id >= 0)
				_name = type + id.toString();
			else
				_name = type;

			_regCache = regCache;
		}

		public function get id():int
		{
			return _id;
		}

		public function get type():String
		{
			return _type;
		}
		
		public function get o():Instruction
		{
			return new Instruction('', _name);
		}
		
		public function set o(instruction:Instruction):void
		{
			_regCache.appendCode(instruction.operation + " " + o + ", " + instruction + "\n");
		}
		
		public function get x():Instruction
		{
			return new Instruction('', _name+'.x');
		}
		
		public function set x(instruction:Instruction):void
		{
			_regCache.appendCode(instruction.operation + " " + x + ", " + instruction + "\n");
		}
		
		public function get y():Instruction
		{
			return new Instruction('', _name+'.y');
		}
		
		public function set y(instruction:Instruction):void
		{
			_regCache.appendCode(instruction.operation + " " + y + ", " + instruction + "\n");
		}
		
		public function get z():Instruction
		{
			return new Instruction('', _name+'.z');
		}
		
		public function set z(instruction:Instruction):void
		{
			_regCache.appendCode(instruction.operation + " " + z + ", " + instruction + "\n");
		}
		
		public function get w():Instruction
		{
			return new Instruction('', _name+'.w');
		}
		
		public function set w(instruction:Instruction):void
		{
			_regCache.appendCode(instruction.operation + " " + w + ", " + instruction + "\n");
		}
		
		public function get xy():Instruction
		{
			return new Instruction('', _name+'.xy');
		}
		
		public function set xy(instruction:Instruction):void
		{
			_regCache.appendCode(instruction.operation + " " + xy + ", " + instruction + "\n");
		}
		
		public function get yx():Instruction
		{
			return new Instruction('', _name+'.yx');
		}
		
		public function set yx(instruction:Instruction):void
		{
			_regCache.appendCode(instruction.operation + " " + yx + ", " + instruction + "\n");
		}
		
		public function get zy():Instruction
		{
			return new Instruction('', _name+'.zy');
		}
		
		public function set zy(instruction:Instruction):void
		{
			_regCache.appendCode(instruction.operation + " " + zy + ", " + instruction + "\n");
		}
		
		public function get yz():Instruction
		{
			return new Instruction('', _name+'.yz');
		}
		
		public function set yz(instruction:Instruction):void
		{
			_regCache.appendCode(instruction.operation + " " + yz + ", " + instruction + "\n");
		}
		
		public function get zz():Instruction
		{
			return new Instruction('', _name+'.zz');
		}
		
		public function set zz(instruction:Instruction):void
		{
			_regCache.appendCode(instruction.operation + " " + zz + ", " + instruction + "\n");
		}
		
		public function get ww():Instruction
		{
			return new Instruction('', _name+'.ww');
		}
		
		public function set ww(instruction:Instruction):void
		{
			_regCache.appendCode(instruction.operation + " " + ww + ", " + instruction + "\n");
		}
		
		public function get xx():Instruction
		{
			return new Instruction('', _name+'.xx');
		}
		
		public function set xx(instruction:Instruction):void
		{
			_regCache.appendCode(instruction.operation + " " + xx + ", " + instruction + "\n");
		}
		
		public function get yy():Instruction
		{
			return new Instruction('', _name+'.yy');
		}
		
		public function set yy(instruction:Instruction):void
		{
			_regCache.appendCode(instruction.operation + " " + yy + ", " + instruction + "\n");
		}
		
		public function get zw():Instruction
		{
			return new Instruction('', _name+'.zw');
		}
		
		public function set zw(instruction:Instruction):void
		{
			_regCache.appendCode(instruction.operation + " " + zw + ", " + instruction + "\n");
		}
		
		public function get yw():Instruction
		{
			return new Instruction('', _name+'.yw');
		}
		
		public function set yw(instruction:Instruction):void
		{
			_regCache.appendCode(instruction.operation + " " + yw + ", " + instruction + "\n");
		}
		
		public function get xz():Instruction
		{
			return new Instruction('', _name+'.xz');
		}
		
		public function set xz(instruction:Instruction):void
		{
			_regCache.appendCode(instruction.operation + " " + xz + ", " + instruction + "\n");
		}
		
		public function get wz():Instruction
		{
			return new Instruction('', _name+'.wz');
		}
		
		public function set wz(instruction:Instruction):void
		{
			_regCache.appendCode(instruction.operation + " " + wz + ", " + instruction + "\n");
		}
		
		public function get xyz():Instruction
		{
			return new Instruction('', _name+'.xyz');
		}
		
		public function set xyz(instruction:Instruction):void
		{
			_regCache.appendCode(instruction.operation + " " + xyz + ", " + instruction + "\n");
		}
		
		public function get xzw():Instruction
		{
			return new Instruction('', _name+'.xzw');
		}
		
		public function set xzw(instruction:Instruction):void
		{
			_regCache.appendCode(instruction.operation + " " + xzw + ", " + instruction + "\n");
		}
		
		public function get xyy():Instruction
		{
			return new Instruction('', _name+'.xyy');
		}
		
		public function set xyy(instruction:Instruction):void
		{
			_regCache.appendCode(instruction.operation + " " + xyy + ", " + instruction + "\n");
		}
		
		public function get yxz():Instruction
		{
			return new Instruction('', _name+'.yxz');
		}
		
		public function set yxz(instruction:Instruction):void
		{
			_regCache.appendCode(instruction.operation + " " + yxz + ", " + instruction + "\n");
		}
		
		public function get yxy():Instruction
		{
			return new Instruction('', _name+'.yxy');
		}
		
		public function set yxy(instruction:Instruction):void
		{
			_regCache.appendCode(instruction.operation + " " + yxy + ", " + instruction + "\n");
		}
		
		public function get yzw():Instruction
		{
			return new Instruction('', _name+'.yzw');
		}
		
		public function set yzw(instruction:Instruction):void
		{
			_regCache.appendCode(instruction.operation + " " + yzw + ", " + instruction + "\n");
		}
		
		public function get xyzw():Instruction
		{
			return new Instruction('', _name+'.xyzw');
		}
		
		public function set xyzw(instruction:Instruction):void
		{
			_regCache.appendCode(instruction.operation + " " + xyzw + ", " + instruction + "\n");
		}
		
		public function get xyyx():Instruction
		{
			return new Instruction('', _name+'.xyyx');
		}
		
		public function set xyyx(instruction:Instruction):void
		{
			_regCache.appendCode(instruction.operation + " " + xyyx + ", " + instruction + "\n");
		}
		
		public function get yyx():Instruction
		{
			return new Instruction('', _name+'.yyx');
		}
		
		public function set yyx(instruction:Instruction):void
		{
			_regCache.appendCode(instruction.operation + " " + yyx + ", " + instruction + "\n");
		}
		
		public function get yzww():Instruction
		{
			return new Instruction('', _name+'.yzww');
		}
		
		public function set yzww(instruction:Instruction):void
		{
			_regCache.appendCode(instruction.operation + " " + yzww + ", " + instruction + "\n");
		}
		
		public function get yxyx():Instruction
		{
			return new Instruction('', _name+'.yxyx');
		}
		
		public function set yxyx(instruction:Instruction):void
		{
			_regCache.appendCode(instruction.operation + " " + yxyx + ", " + instruction + "\n");
		}
		
		public function get xxwz():Instruction
		{
			return new Instruction('', _name+'.xxwz');
		}
		
		public function set xxwz(instruction:Instruction):void
		{
			_regCache.appendCode(instruction.operation + " " + xxwz + ", " + instruction + "\n");
		}
		
		public function get zwyy():Instruction
		{
			return new Instruction('', _name+'.zwyy');
		}
		
		public function set zwyy(instruction:Instruction):void
		{
			_regCache.appendCode(instruction.operation + " " + zwyy + ", " + instruction + "\n");
		}
		
		public function get xxxx():Instruction
		{
			return new Instruction('', _name+'.xxxx');
		}
		
		public function set xxxx(instruction:Instruction):void
		{
			_regCache.appendCode(instruction.operation + " " + xxxx + ", " + instruction + "\n");
		}
		
		public function get xxyz():Instruction
		{
			return new Instruction('', _name+'.xxyz');
		}
		
		public function set xxyz(instruction:Instruction):void
		{
			_regCache.appendCode(instruction.operation + " " + xxyz + ", " + instruction + "\n");
		}
		
		public function get zzzz():Instruction
		{
			return new Instruction('', _name+'.zzzz');
		}
		
		public function set zzzz(instruction:Instruction):void
		{
			_regCache.appendCode(instruction.operation + " " + zzzz + ", " + instruction + "\n");
		}
		
		public function get yyyx():Instruction
		{
			return new Instruction('', _name+'.yyyx');
		}
		
		public function set yyyx(instruction:Instruction):void
		{
			_regCache.appendCode(instruction.operation + " " + yyyx + ", " + instruction + "\n");
		}
		
		public function get wwww():Instruction
		{
			return new Instruction('', _name+'.wwww');
		}
		
		public function set wwww(instruction:Instruction):void
		{
			_regCache.appendCode(instruction.operation + " " + wwww + ", " + instruction + "\n");
		}
	}
}