package nut.ext.model
{
	import flash.geom.Matrix3D;

	public class JointAnim
	{
		private static const TMP_SKINNING_MATRIX	:Matrix3D 	= new Matrix3D();
		
		private var _boneName			:String						= "";
		private var _invBindMatrix		:Matrix3D					= null;
		private var _bone				:Bone						= null;
		private var _matrices			:Vector.<Matrix3D>	= new Vector.<Matrix3D>();
		
		public function JointAnim(boneName :String, invBindMatrix :Matrix3D)
		{
			_boneName = boneName;
			_invBindMatrix = invBindMatrix;
		}
		
		public function get boneName():String
		{
			return _boneName;
		}

		public function bindToBone(bone:Bone) :void
		{
			_bone = bone as Bone;
		}
		
		public function addFrame() :void
		{
			TMP_SKINNING_MATRIX.copyFrom(_invBindMatrix);
			TMP_SKINNING_MATRIX.append(_bone.localToWrapper);
			_matrices.push(TMP_SKINNING_MATRIX.clone());
		}
		
		public function update(frameId :uint) :void
		{
			_bone.matrix.copyFrom(_matrices[frameId]);
		}
	}
}