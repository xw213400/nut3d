package nut.ext.model
{
	import flash.geom.Matrix3D;

	public class BoneAnim
	{
		private var _boneName	:String				= "";
		private var _frameNum	:uint				= 0;
		private var _bone		:Bone				= null;
		private var _matrices	:Vector.<Matrix3D>	= new Vector.<Matrix3D>();

		public function BoneAnim(boneName:String)
		{
			_boneName = boneName;
		}
		
		public function get frameNum():uint
		{
			return _frameNum;
		}

		public function get boneName():String
		{
			return _boneName;
		}
		
		public function bindToBone(bone:Bone) :void
		{
			_bone = bone;
		}
		
		public function addMatrix(mat :Matrix3D) :void
		{
			_matrices.push(mat);
			_frameNum++;
		}
		
		public function getMatrix(idx :uint) :Matrix3D
		{
			if (idx >= 0 && idx < _frameNum)
				return _matrices[idx];
			else
				return null;
		}
		
		public function update(frameId :uint, weight :Number) :void
		{
			if (weight > 0.999)
				_bone.transform.copyFrom(_matrices[frameId]);
			else
				_bone.transform.interpolateTo(_matrices[frameId], weight);
		}
	}
}