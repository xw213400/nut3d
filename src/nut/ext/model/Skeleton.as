package nut.ext.model
{
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Endian;
	
	import nut.core.IAsset;
	import nut.enum.ResType;

	public class Skeleton implements IAsset
	{
		private var _name	:String		= "";
		private var _bones	:Dictionary = new Dictionary();
		private var _root	:Bone;
		private var _anims	:Dictionary = new Dictionary();
		private var _onLoaded		:Function	= null;
		
		public function Skeleton()
		{
		}
		
		public function set onLoaded(value:Function):void
		{
			_onLoaded = value;
		}
		
		public function get type():uint
		{
			return ResType.SKELETON;
		}

		public function get name():String
		{
			return _name;
		}

		public function set name(value:String):void
		{
			_name = value;
		}

		public function get bones():Dictionary
		{
			return _bones;
		}

		public function get root():Bone
		{
			return _root;
		}

		public function set root(value:Bone):void
		{
			_root = value;
			addChild(_root);
		}
		
		public function hasAnim():Boolean
		{
			for each(var anim:NutAnimation in _anims)
			{
				return true;
			}
			
			return false;
		}

		private function addChild(bone:Bone):void
		{
			_bones[bone.name] = bone;
			
			for each (var b:Bone in bone.children)
			{
				addChild(b);
			}
		}
		
		public function addAnim(anim:NutAnimation):void
		{
			_anims[anim.name] = anim;
			anim.bindAnimToSkeleton(this);
		}
		
		public function updateAt(animName:String, time:Number):void
		{
			var anim:NutAnimation = _anims[animName];
			var fId:uint = anim.getFrameId(time);
			anim.upadateAnim(fId, 1);
			
			_root.update();
		}
		
		public function encode():ByteArray
		{
			var data:ByteArray = new ByteArray();
			data.endian = Endian.LITTLE_ENDIAN;
			
			_root.encode(data);
			
			for each(var anim:NutAnimation in _anims)
			{
				anim.encode(data);
			}
			
			return data;
		}
		
		public function decode(data:ByteArray):void
		{
			var root:Bone = new Bone();
			
			root.decode(data);
			this.root = root;
			
			while (data.bytesAvailable > 0)
			{
				this.addAnim(NutAnimation.decode(data));
			}
			
			if (_onLoaded != null)
				_onLoaded(this);
		}
	}
}