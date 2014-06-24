package nut.core
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DTriangleFace;
	import flash.utils.ByteArray;
	
	import nut.enum.Blending;
	import nut.enum.Culling;
	import nut.enum.DepthTest;

	public class RenderSetting
	{
		static public const blendList :Vector.<String> = new <String>[
			Context3DBlendFactor.DESTINATION_ALPHA,
			Context3DBlendFactor.DESTINATION_COLOR,
			Context3DBlendFactor.ONE,
			Context3DBlendFactor.ONE_MINUS_DESTINATION_ALPHA,
			Context3DBlendFactor.ONE_MINUS_DESTINATION_COLOR,
			Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA,
			Context3DBlendFactor.ONE_MINUS_SOURCE_COLOR,
			Context3DBlendFactor.SOURCE_ALPHA,
			Context3DBlendFactor.SOURCE_COLOR,
			Context3DBlendFactor.ZERO
		];
		
		static public const compareList :Vector.<String> 	= new <String>[
			Context3DCompareMode.NEVER,
			Context3DCompareMode.GREATER,
			Context3DCompareMode.GREATER_EQUAL,
			Context3DCompareMode.EQUAL,
			Context3DCompareMode.LESS_EQUAL,
			Context3DCompareMode.LESS,
			Context3DCompareMode.NOT_EQUAL,
			Context3DCompareMode.ALWAYS
		];
		
		static public const cullingList : Vector.<String> = new <String>[
			Context3DTriangleFace.NONE,
			Context3DTriangleFace.FRONT,
			Context3DTriangleFace.BACK,
			Context3DTriangleFace.FRONT_AND_BACK
		];
		
		private var _id				:uint		= 0;
		private var _blendSrc		:uint		= Blending.ONE;
		private var _blendDst		:uint		= Blending.ZERO;
		private var _depthMask		:Boolean	= true;
		private var _compareMode	:uint		= DepthTest.LESS_EQUAL;
		private var _culling		:uint		= Culling.BACK;
		
		public function RenderSetting()
		{
			_id = (_blendSrc<<20)|(_blendDst<<16)|((_depthMask?1:0)<<15)|(_compareMode<<12)|(_culling<<10);
		}
		
		public function set id(value:uint):void
		{
			_id = value;
			_blendSrc = (_id & 0x00F00000)>>>20;
			_blendDst = (_id & 0x000F0000)>>>16;
			_depthMask = ((_id & 0x00008000)>>>15) == 1;
			_compareMode = (_id & 0x00007000)>>>12;
			_culling = (_id & 0x00000C00)>>>10;
		}

		public function get culling():uint
		{
			return _culling;
		}

		public function set culling(value:uint):void
		{
			_culling = value;
			
			_id &= 0xFFFFF3FF;
			_id |= (_culling<<10);
		}

		public function get compareMode():uint
		{
			return _compareMode;
		}

		public function set compareMode(value:uint):void
		{
			setDepthTest(_depthMask, value);
		}

		public function get depthMask():Boolean
		{
			return _depthMask;
		}

		public function set depthMask(value:Boolean):void
		{
			setDepthTest(value, _compareMode);
		}

		public function get blendDst():uint
		{
			return _blendDst;
		}

		public function set blendDst(value:uint):void
		{
			setBlendMode(_blendSrc, value);
		}

		public function get blendSrc():uint
		{
			return _blendSrc;
		}

		public function set blendSrc(value:uint):void
		{
			setBlendMode(value, _blendDst);
		}

		public function get id():uint
		{
			
			return _id;
		}
		
		public function clone():RenderSetting
		{
			var setting:RenderSetting = new RenderSetting();
			
			setting._id = _id;
			setting._blendSrc = _blendSrc;
			setting._blendDst = _blendDst;
			setting._depthMask = _depthMask;
			setting._compareMode = _compareMode;
			setting._culling = _culling;
			
			return setting;
		}
		
		public function setBlendMode(blendSrc:uint, blendDst:uint):void
		{
			_blendSrc = blendSrc;
			_blendDst = blendDst;
			
			_id &= 0xFF00FFFF;
			_id |= (_blendSrc<<20)|(_blendDst<<16);
		}
		
		public function setDepthTest(depthMask:Boolean, compareMode:uint):void
		{
			_depthMask = depthMask;
			_compareMode = compareMode;
			
			_id &= 0xFFFF0FFF;
			_id |= ((_depthMask?1:0)<<15)|(_compareMode<<12);
		}
		
		public function apply():void
		{
			var context:Context3D = Nut.scene.context3D;
			context.setBlendFactors(blendList[_blendSrc], blendList[_blendDst]);
			context.setDepthTest(_depthMask, compareList[_compareMode]);
			context.setCulling(cullingList[_culling]);
		}
	}
}