package akdcl.skeleton.utils {
	import akdcl.skeleton.objects.ArmatureData;
	import akdcl.skeleton.objects.BoneData;
	import akdcl.skeleton.objects.MovementData;
	
	/**
	 * ...
	 * @author Akdcl
	 */
	public function generateMovementData(_movementName:String, _movementXML:XML, _armatureData:ArmatureData, _movementData:MovementData = null):MovementData {
		if(!_movementData){
			_movementData = new MovementData(_movementName);
		}
		_movementData.setValues(
			int(_movementXML.attribute(ConstValues.A_DURATION)),
			int(_movementXML.attribute(ConstValues.A_DURATION_TO)),
			int(_movementXML.attribute(ConstValues.A_DURATION_TWEEN)),
			Boolean(int(_movementXML.attribute(ConstValues.A_LOOP)) == 1),
			Number(_movementXML.attribute(ConstValues.A_TWEEN_EASING)[0])
		);
		
		var _xmlList:XMLList = _movementXML.elements(ConstValues.BONE);
		for each(var _boneXML:XML in _xmlList) {
			var _boneName:String = _boneXML.attribute(ConstValues.A_NAME);
			var _boneData:BoneData = _armatureData.getData(_boneName);
			_movementData.addData(
				generateMovementBoneData(
					_boneName, 
					_boneXML, 
					_xmlList.(attribute(ConstValues.A_NAME) == _boneData.parent)[0], 
					_boneData,
					_movementData.getData(_boneName)
				),
				_boneName
			);
		}
		return _movementData;
	}
	
}