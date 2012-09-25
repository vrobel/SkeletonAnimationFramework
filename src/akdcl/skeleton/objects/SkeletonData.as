package akdcl.skeleton.objects {
	import flash.utils.ByteArray;
	
	import akdcl.skeleton.utils.ConstValues;
	import akdcl.skeleton.utils.generateArmatureData;
	import akdcl.skeleton.utils.generateAnimationData;
	
	/**
	 * 
	 * @author Akdcl
	 */
	final public class SkeletonData extends BaseDicData {
		private var animationDatas:Object;
		
		public function SkeletonData(_skeletonXML:XML) {
			super(null);
			animationDatas = { };
			if (_skeletonXML) {
				setData(_skeletonXML);
			}
		}
		
		override public function dispose():void{
			super.dispose();
			for each(var _data:AnimationData in animationDatas){
				_data.dispose();
			}
			animationDatas = null;
		}
		
		public function getArmatureData(_name:String):ArmatureData {
			return datas[_name];
		}
		
		public function getAnimationData(_name:String):AnimationData {
			return animationDatas[_name];
		}
		
		public function addAnimationData(_data:AnimationData, _id:String = null):void{
			_id = _id || _data.name;
			if (animationDatas[_id]) {
				animationDatas[_id].dispose();
			}
			animationDatas[_id] = _data;
		}
		
		public function setData(_skeletonXML:XML):void {
			name = _skeletonXML.attribute(ConstValues.A_NAME);
			
			for each(var _armatureXML:XML in _skeletonXML.elements(ConstValues.ARMATURES).elements(ConstValues.ARMATURE)) {
				addData(generateArmatureData(_armatureXML));
			}
			
			for each(var _animationXML:XML in _skeletonXML.elements(ConstValues.ANIMATIONS).elements(ConstValues.ANIMATION)) {
				addAnimationData(generateAnimationData(_animationXML));
			}
		}
	}
}