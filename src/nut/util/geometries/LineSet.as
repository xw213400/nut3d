package nut.util.geometries
{
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import nut.core.Geometry;
	import nut.core.VertexBuffer;
	import nut.core.VertexComponent;

	public class LineSet extends Geometry
	{
		private var _lines:Vector.<Line> = null;
		private var _thickness:Number = 1;
		
		public function LineSet(lines:Vector.<Line>, thickness:Number=1)
		{
			_lines = lines;
			_thickness = thickness;
			
			var numLines:uint = _lines.length;
			var indices:ByteArray = new ByteArray();
			
			indices.endian = Endian.LITTLE_ENDIAN;
			for (var i:int=0; i!=numLines; ++i)
			{
				var base:int = i*4;
				
				indices.writeShort(base);
				indices.writeShort(base+1);
				indices.writeShort(base+2);
				
				indices.writeShort(base+2);
				indices.writeShort(base+1);
				indices.writeShort(base+3);
			}
			
			super(indices, numLines*4);
			
			create();
		}
		
		public function get thickness():Number
		{
			return _thickness;
		}

		public function set thickness(value:Number):void
		{
			_thickness = value;
		}

		public function getLine(idx:int):Line
		{
			return _lines[idx];
		}
		
		private function create():void
		{
			var numLines:uint = _lines.length;
			var vb:VertexBuffer = this.vertexbuffer;
			
			var starts:ByteArray = new ByteArray();
			var ends:ByteArray = new ByteArray();
			var ts:ByteArray = new ByteArray();
			var colors:ByteArray = new ByteArray();
			
			starts.endian = Endian.LITTLE_ENDIAN;
			ends.endian = Endian.LITTLE_ENDIAN;
			ts.endian = Endian.LITTLE_ENDIAN;
			colors.endian = Endian.LITTLE_ENDIAN;
			
			for (var i:int=0; i!=numLines; ++i)
			{
				var line:Line = _lines[i];
				
				starts.writeFloat(line.s.x);
				starts.writeFloat(line.s.y);
				starts.writeFloat(line.s.z);
				starts.writeFloat(line.e.x);
				starts.writeFloat(line.e.y);
				starts.writeFloat(line.e.z);
				starts.writeFloat(line.s.x);
				starts.writeFloat(line.s.y);
				starts.writeFloat(line.s.z);
				starts.writeFloat(line.e.x);
				starts.writeFloat(line.e.y);
				starts.writeFloat(line.e.z);
				
				ends.writeFloat(line.e.x);
				ends.writeFloat(line.e.y);
				ends.writeFloat(line.e.z);
				ends.writeFloat(line.s.x);
				ends.writeFloat(line.s.y);
				ends.writeFloat(line.s.z);
				ends.writeFloat(line.e.x);
				ends.writeFloat(line.e.y);
				ends.writeFloat(line.e.z);
				ends.writeFloat(line.s.x);
				ends.writeFloat(line.s.y);
				ends.writeFloat(line.s.z);
				
				ts.writeFloat(-_thickness);
				ts.writeFloat(-_thickness);
				ts.writeFloat(_thickness);
				ts.writeFloat(_thickness);
				
				colors.writeFloat(line.c.r);
				colors.writeFloat(line.c.g);
				colors.writeFloat(line.c.b);
				colors.writeFloat(line.c.a);
				colors.writeFloat(line.c.r);
				colors.writeFloat(line.c.g);
				colors.writeFloat(line.c.b);
				colors.writeFloat(line.c.a);
				colors.writeFloat(line.c.r);
				colors.writeFloat(line.c.g);
				colors.writeFloat(line.c.b);
				colors.writeFloat(line.c.a);
				colors.writeFloat(line.c.r);
				colors.writeFloat(line.c.g);
				colors.writeFloat(line.c.b);
				colors.writeFloat(line.c.a);
			}
			
			vb.addComponent("start", Context3DVertexBufferFormat.FLOAT_3, starts);
			vb.addComponent("end", Context3DVertexBufferFormat.FLOAT_3, ends);
			vb.addComponent("thickness", Context3DVertexBufferFormat.FLOAT_1, ts);
			vb.addComponent("color", Context3DVertexBufferFormat.FLOAT_4, colors);
		}
		
		public function update():void
		{
			var numLines:uint = _lines.length;
			var vb:VertexBuffer = this.vertexbuffer;
			var vs:ByteArray = vb.vertices;
			
			vs.position = 0;
			for (var i:int=0; i!=numLines; ++i)
			{
				var line:Line = _lines[i];
				
				vs.writeFloat(line.s.x);
				vs.writeFloat(line.s.y);
				vs.writeFloat(line.s.z);
				vs.writeFloat(line.e.x);
				vs.writeFloat(line.e.y);
				vs.writeFloat(line.e.z);
				vs.writeFloat(-_thickness);
				vs.writeFloat(line.c.r);
				vs.writeFloat(line.c.g);
				vs.writeFloat(line.c.b);
				vs.writeFloat(line.c.a);
				
				vs.writeFloat(line.e.x);
				vs.writeFloat(line.e.y);
				vs.writeFloat(line.e.z);
				vs.writeFloat(line.s.x);
				vs.writeFloat(line.s.y);
				vs.writeFloat(line.s.z);
				vs.writeFloat(-_thickness);
				vs.writeFloat(line.c.r);
				vs.writeFloat(line.c.g);
				vs.writeFloat(line.c.b);
				vs.writeFloat(line.c.a);
				
				vs.writeFloat(line.s.x);
				vs.writeFloat(line.s.y);
				vs.writeFloat(line.s.z);
				vs.writeFloat(line.e.x);
				vs.writeFloat(line.e.y);
				vs.writeFloat(line.e.z);
				vs.writeFloat(_thickness);
				vs.writeFloat(line.c.r);
				vs.writeFloat(line.c.g);
				vs.writeFloat(line.c.b);
				vs.writeFloat(line.c.a);
				
				vs.writeFloat(line.e.x);
				vs.writeFloat(line.e.y);
				vs.writeFloat(line.e.z);
				vs.writeFloat(line.s.x);
				vs.writeFloat(line.s.y);
				vs.writeFloat(line.s.z);
				vs.writeFloat(_thickness);
				vs.writeFloat(line.c.r);
				vs.writeFloat(line.c.g);
				vs.writeFloat(line.c.b);
				vs.writeFloat(line.c.a);
			}

			vb.dataDirty = true;
		}
	}
}