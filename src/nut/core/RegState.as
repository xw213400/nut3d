package nut.core
{
	import flash.display3D.Context3D;
	
	import nut.core.material.ShaderBase;

	public class RegState
	{
		static private var va_max	:uint = 0;
		static private var fs_max :uint = 0;
		
		static private var fs_record:Vector.<NutTexture> = new Vector.<NutTexture>(8);
		static private var geomRecord:uint = 0;
		
		static public function reset():void
		{
			for (var i:int = 0; i != 8; ++i)
			{
				fs_record[i] = null;
			}
			
			geomRecord = 0;
		}
		
		static public function setTextureAt(regId:int, texture:NutTexture):Boolean
		{
			if (fs_record[regId] == texture)
				return false;
			
			var context:Context3D = Nut.scene.context3D;
			context.setTextureAt(regId, texture.getTexture(context));
			fs_record[regId] = texture;
			
			return true;
		}
		
		static public function setGeometry(shader:ShaderBase, geom:Geometry):Boolean
		{
			var id:uint = (shader.id<<16)|geom.id;
			
			if (id == geomRecord)
				return false;
			
			geomRecord = id;
			
			return true;
		}
		
		static public function clear(vaMax:int, fsMax:int):void
		{
			var id:int = vaMax;
			var context:Context3D = Nut.scene.context3D;
			
			while (id < va_max)
			{
				context.setVertexBufferAt(id, null);
				id++;
			}
			va_max = vaMax;
			
			id = fsMax;
			while (id < fs_max)
			{
				context.setTextureAt(id, null);
				fs_record[id] = null;
				id++;
			}
			fs_max = fsMax;
		}
	}
}