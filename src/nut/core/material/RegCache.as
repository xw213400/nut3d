package nut.core.material
{
	import flash.utils.Dictionary;

	public class RegCache
	{
		static public const VA_MAX	:uint = 8;
		static public const VC_MAX	:uint = 128;
		static public const VT_MAX	:uint = 8;
		static public const V_MAX	:uint = 8;
		
		static public const FS_MAX	:uint = 8;
		static public const FC_MAX	:uint = 28;
		static public const FT_MAX	:uint = 8;
		
		private var _va_next:uint = 0;
		private var _vc_next:uint = 0;
		private var _vt_mask:uint = 0;
		private var _v_next:uint = 0;
		
		private var _fs_next:uint = 0;
		private var _fc_next:uint = 0;
		private var _ft_mask:uint = 0;
		
		private var _vertexCode:String = "";
		private var _fragmentCode:String = "";
		
		private var _vaProps:Dictionary = new Dictionary();
		
		private var _vRegs:Vector.<RegElem> = new Vector.<RegElem>();
		private var _isVertexCode:Boolean = true;
		
		public function RegCache()
		{
		}
		
		public function get fs_next():uint
		{
			return _fs_next;
		}

		public function get fc_next():uint
		{
			return _fc_next;
		}

		public function get vc_next():uint
		{
			return _vc_next;
		}
		
		public function get va_next():uint
		{
			return _va_next;
		}

		public function get vaProps():Dictionary
		{
			return _vaProps;
		}
		
		public function get fragmentCode():String
		{
			return _fragmentCode;
		}

		public function get vertexCode():String
		{
			return _vertexCode;
		}
		
		public function appendCode(code:String):void
		{
			if (_isVertexCode)
				_vertexCode += code;
			else
				_fragmentCode += code;
		}

		public function getVA(prop:String, num:int):RegElem
		{
			if (_va_next+num >= VA_MAX)
				throw new Error('Too many va register!');
			
			var regElem:RegElem = new RegElem('va', _va_next, this);
			
			_va_next += num;
			_vaProps[prop] = regElem;
			
			return regElem;
		}
		
		public function getVC(num:int):RegElem
		{
			if (_vc_next+num >= VC_MAX)
				throw new Error('Too many vc register!');
			
			var regElem:RegElem = new RegElem('vc', _vc_next, this);
			
			_vc_next += num;
			
			return regElem;
		}
		
		public function getFC(num:int):RegElem
		{
			if (_fc_next+num >= FC_MAX)
				throw new Error('Too many vc register!');
			
			var regElem:RegElem = new RegElem('fc', _fc_next, this);
			
			_fc_next += num;
			
			return regElem;
		}
		
		public function getVT():RegElem
		{
			var id:int = 0;
			
			while (id < VT_MAX)
			{
				if (_vt_mask & (0x1<<id))
				{
					id++;
				}
				else
				{
					break;
				}
			}
			
			if (id == VT_MAX)
				throw new Error('Too many vt register!');
			
			var regElem:RegElem = new RegElem('vt', id, this);
			
			_vt_mask |= (0x1<<id)
			
			return regElem;
		}
		
		public function free(regElem:RegElem):void
		{
			if (regElem.type == 'vt')
			{
				_vt_mask &= ~(0x1<<regElem.id);
			}
			else if (regElem.type == 'ft')
			{
				_ft_mask &= ~(0x1<<regElem.id);
			}
		}
		
		public function getV():RegElem
		{
			if (_v_next+1 >= V_MAX)
				throw new Error('Too many v register!');
			
			var regElem:RegElem = new RegElem('v', _v_next, this);
			
			_vRegs.push(regElem);
			_v_next += 1;
			
			return regElem;
		}
		
		public function getOP():RegElem
		{
			return new RegElem('op', -1, this);
		}
		
		public function switchCode():void
		{
			_isVertexCode = false;
		}
		
		public function getFS():RegElem
		{
			if (_fs_next+1 >= FS_MAX)
				throw new Error('Too many fs register!');
			
			var regElem:RegElem = new RegElem('fs', _fs_next, this);
			
			_fs_next += 1;
			
			return regElem;
		}
		
		public function getFT():RegElem
		{
			var id:int = 0;
			
			while (id < FT_MAX)
			{
				if (_ft_mask & (0x1<<id))
				{
					id++;
				}
				else
				{
					break;
				}
			}
			
			if (id == FT_MAX)
				throw new Error('Too many ft register!');
			
			var regElem:RegElem = new RegElem('ft', id, this);
			
			_ft_mask |= (0x1<<id)
			
			return regElem;
		}
		
		public function getOC():RegElem
		{
			return new RegElem('oc', -1, this);
		}
	}
}