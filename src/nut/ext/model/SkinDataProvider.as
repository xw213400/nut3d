package nut.ext.model
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	
	import nut.core.Mesh;
	import nut.core.material.DataProvider;
	
	public class SkinDataProvider
	{
		private var _name				:String				= null;
		private var _bindShape			:Matrix3D			= null;
		private var _joints				:Vector.<Bone>		= null;
		private var _invBindMatrices	:Vector.<Matrix3D>	= null;
		private var _jointNames			:Vector.<String>	= null;
		private var _matrices			:Vector.<Number>	= new <Number>[];

		public function SkinDataProvider(name:String, bindShape:Matrix3D)
		{
			_name			= name;
			_bindShape		= bindShape;
			_jointNames		= new Vector.<String>();
			_invBindMatrices= new Vector.<Matrix3D>();
		}
		
		public function get name():String
		{
			return _name;
		}

		public function get matrices():Vector.<Number>
		{
			return _matrices;
		}

		public function addJoint(boneName:String, matrix:Matrix3D):void
		{
			if (_jointNames.indexOf(boneName) != -1)
				return;
			
			var offset:uint = _jointNames.length * 12;
			matrix.copyRawDataTo(_matrices, offset, true);
			
			_jointNames.push(boneName);
			_invBindMatrices.push(matrix);
		}
		
		public function jointsNum():uint
		{
			return _jointNames.length;
		}

		public function initialize(skeleton:Skeleton) : void
		{
			var numJoints 	: uint	= _jointNames.length;
			
			_joints = new Vector.<Bone>(numJoints, true);
			for (var jointId : uint = 0; jointId < numJoints; ++jointId)
			{
				var joint:Bone = skeleton.bones[_jointNames[jointId]] as Bone;

				_joints[jointId] = joint;
				joint.invBindMatrix = _bindShape.clone();
				joint.invBindMatrix.append(_invBindMatrices[jointId]);
			}
		}
		
		public function inilializeMatrix() :void
		{
			var numJoints 	: uint	= _joints.length;
			for (var jointId : uint = 0; jointId < numJoints; ++jointId)
			{
				var joint : Bone = _joints[jointId];
				joint.matrix.copyFrom(joint.invBindMatrix);
				joint.matrix.append(joint.localToWrapper);
				
				var offset	:uint 		= jointId * 12;
				joint.matrix.copyRawDataTo(_matrices, offset, true);
			}
		}
		
		public function bindToMesh(mesh:Mesh) : void
		{
			// init data provider.
			mesh.skinDataProvider = this;
		}
		
		public function update() : void
		{
			var numJoints : int	= _joints.length;
			for (var i : int = 0; i < numJoints; ++i)
			{
				var joint	:Bone = _joints[i];
				var offset	:uint = i * 12;
				joint.matrix.copyRawDataTo(_matrices, offset, true);
			}
		}
		
		public function clone():SkinDataProvider
		{
			var skin:SkinDataProvider = new SkinDataProvider(_name, _bindShape);
			
			var n:uint = _jointNames.length;
			for (var i:int = 0; i != n; ++i)
			{
				var boneName:String = _jointNames[i];
				var matrix:Matrix3D = _invBindMatrices[i];
				
				skin.addJoint(boneName, matrix);
			}
			
			return skin;
		}
		
		public function encode(data:ByteArray):void
		{
			data.writeUTF(_name);
			
			var rawData:Vector.<Number> = _bindShape.rawData;
			for (var i:int = 0; i != 16; ++i)
				data.writeFloat(rawData[i]);
			
			var n:int = _joints.length;
			data.writeByte(n);
			for (i = 0; i != n; ++i)
			{
				data.writeUTF(_joints[i].name);
				rawData = _invBindMatrices[i].rawData;
				for (var j:int = 0; j != 16; ++j)
					data.writeFloat(rawData[j]);
			}
		}
		
		static public function decode(data:ByteArray):SkinDataProvider
		{
			var name:String = data.readUTF();
			var bindShape:Matrix3D = new Matrix3D(Vector.<Number>([
				data.readFloat(),data.readFloat(),data.readFloat(),data.readFloat(),
				data.readFloat(),data.readFloat(),data.readFloat(),data.readFloat(),
				data.readFloat(),data.readFloat(),data.readFloat(),data.readFloat(),
				data.readFloat(),data.readFloat(),data.readFloat(),data.readFloat()
			]));
			
			var skinData:SkinDataProvider = new SkinDataProvider(name, bindShape);
			
			var jointNum:uint = data.readUnsignedByte();
			for (var i:int = 0; i != jointNum; ++i)
			{
				var boneName:String = data.readUTF();
				var matrix:Matrix3D = new Matrix3D(Vector.<Number>([
					data.readFloat(),data.readFloat(),data.readFloat(),data.readFloat(),
					data.readFloat(),data.readFloat(),data.readFloat(),data.readFloat(),
					data.readFloat(),data.readFloat(),data.readFloat(),data.readFloat(),
					data.readFloat(),data.readFloat(),data.readFloat(),data.readFloat()
				]));
				
				skinData.addJoint(boneName, matrix);
			}
			
			return skinData;
		}
	}
}