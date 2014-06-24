package nut.ext.model
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	public class NutAnimation
	{
		private var _name			:String				= "";
		private var _duration		:Number			= 0.0;
		private var _fps				:Number			= 30.0;
		private var _boneAnims			:Dictionary		= new Dictionary(); // bone_name, animation
		private var _jointAnims	:Dictionary		= new Dictionary(); // bone_name, JointAnim
		private var _localToWrappers	:Dictionary= new Dictionary(); // bone_name, MatrixVector
		private var _skeleton  :Skeleton = null;
		
		private var _initialized		:Boolean	= false;
		
		public function NutAnimation(name :String)
		{
			_name = name;
		}
		
		public function get duration():Number
		{
			return _duration;
		}

		public function get name():String
		{
			return _name;
		}

		public function addAnim(anim:BoneAnim) :void
		{
			_boneAnims[anim.boneName] = anim;
			if (_duration == 0.0)
				_duration = 1.0 / _fps * (anim.frameNum-1);
		}
		
		public function bindAnimToSkeleton(skeleton:Skeleton):void
		{
			_skeleton = skeleton;
			
			for each (var anim:BoneAnim in _boneAnims)
			{
				anim.bindToBone(_skeleton.bones[anim.boneName]);
			}
		}
		
		public function bindJointToSkeleton(skeleton:Skeleton):void
		{
			_skeleton = skeleton;
			
			for each (var jointAnim:JointAnim in _jointAnims)
			{
				jointAnim.bindToBone(_skeleton.bones[jointAnim.boneName]);
			}
		}
//		
//		public function preCalculate(model :FModel) :void
//		{
//			if (_initialized)
//				return ;
//			
//			_initialized = true;
//			
//			bindAnimToModel(model);
//			
//			var frameNum :uint = _duration * _fps + 0.001;
//			for (var frameId :uint = 0; frameId != frameNum; ++frameId)
//			{
//				for each(var anim :FAnimation in _boneAnims)
//				{
//					anim.update(frameId, 1.0);
//				}
//				model.rootBone.preCalcSkeleton();
//				
//				var bones :Dictionary = model.bones;
//				for each(var bone :Bone in bones)
//				{
//					if (_localToWrappers[bone.name] == null)
//						_localToWrappers[bone.name] = new Vector.<Matrix3D>();
//					_localToWrappers[bone.name].push(bone.localToWrapper.clone());
//					
//					if (bone.invBindMatrix == null)
//						continue;
//					
//					var jointAnim :JointAnim = _jointAnims[bone.name];
//					if (jointAnim == null)
//					{
//						jointAnim = new JointAnim(bone.name, bone.invBindMatrix);
//						_jointAnims[bone.name] = jointAnim;
//						jointAnim.bindToBone(bone);
//					}
//
//					jointAnim.addFrame();
//				}
//			}
//		}
		
		public function getFrameId(time :Number) :uint
		{
			time %= _duration;
			var framePos :Number = time * _fps;
			var frameId :uint = framePos;
			
			return frameId;
		}
		
		public function upadateAnim(frameId :uint, weight :Number) :void
		{
			for each (var anim:BoneAnim in _boneAnims)
			{
				anim.update(frameId, weight);
			}
		}
		
		public function updateJoint(frameId :uint) :void
		{
			for each (var jointAnim:JointAnim in _jointAnims)
			{
				jointAnim.update(frameId);
			}
		}
		
		public function updateBone(frameId:uint, blendId :uint = 3) :void
		{
			for (var key :String in _localToWrappers)
			{
				var bone:Bone = _skeleton.bones[key] as Bone;
				var matrices:Vector.<Matrix3D> = _localToWrappers[key];
				bone.localToWrapper = matrices[frameId];
			}
		}
		
		public function encode(data :ByteArray) :void
		{
			data.writeUTF(_name);
			
			var animNum :uint = 0;
			var oneAnim :BoneAnim = null;
			for each(var anim :BoneAnim in _boneAnims)
			{
				if (oneAnim == null)
					oneAnim = anim;
				animNum++;
			}
			
			data.writeByte(animNum);
			data.writeShort(oneAnim.frameNum);
			
			for (var key :String in _boneAnims)
			{
				anim = _boneAnims[key];
				data.writeUTF(key);
				
				for (var j :uint = 0; j != anim.frameNum; ++j)
				{
					var matrix :Matrix3D = anim.getMatrix(j);
					
					var comps:Vector.<Vector3D> = matrix.decompose();
					
					data.writeFloat(comps[0].x);
					data.writeFloat(comps[0].y);
					data.writeFloat(comps[0].z);
					
					data.writeFloat(comps[1].x);
					data.writeFloat(comps[1].y);
					data.writeFloat(comps[1].z);
					
					data.writeFloat(comps[2].x);
					data.writeFloat(comps[2].y);
					data.writeFloat(comps[2].z);
				}
			}
		}
		
		static public function decode(data:ByteArray):NutAnimation
		{
			var anims:NutAnimation = new NutAnimation(data.readUTF());			
			var animNum	:uint = data.readUnsignedByte();
			var frameNum:uint = data.readUnsignedShort();
			
			var comps:Vector.<Vector3D> = new Vector.<Vector3D>(3);
			var pos:Vector3D = new Vector3D();
			var rot:Vector3D = new Vector3D();
			var scl:Vector3D = new Vector3D();
			
			comps[0] = pos;
			comps[1] = rot;
			comps[2] = scl;
			
			for (var i :uint = 0; i != animNum; ++i)
			{
				var anim :BoneAnim = new BoneAnim(data.readUTF());
				
				for (var j :uint = 0; j != frameNum; ++j)
				{
					pos.x = data.readFloat();
					pos.y = data.readFloat();
					pos.z = data.readFloat();
					
					rot.x = data.readFloat();
					rot.y = data.readFloat();
					rot.z = data.readFloat();
					
					scl.x = data.readFloat();
					scl.y = data.readFloat();
					scl.z = data.readFloat();
					
					var mat:Matrix3D = new Matrix3D()
					mat.recompose(comps);
					anim.addMatrix(mat);
				}
				
				anims.addAnim(anim);
			}
			
			return anims;
		}
	}
}