package akdcl.skeleton.factorys {
	import akdcl.skeleton.Armature;
	import akdcl.skeleton.Bone;
	import akdcl.skeleton.display.PivotBitmap;
	import akdcl.skeleton.events.EventDispatcher;
	import akdcl.skeleton.objects.AnimationData;
	import akdcl.skeleton.objects.ArmatureData;
	import akdcl.skeleton.objects.BoneData;
	import akdcl.skeleton.objects.DisplayData;
	import akdcl.skeleton.objects.FrameData;
	import akdcl.skeleton.objects.Node;
	import akdcl.skeleton.objects.SkeletonData;
	import akdcl.skeleton.objects.TextureData;
	import akdcl.skeleton.utils.ConstValues;
	import akdcl.skeleton.utils.skeletonNamespace;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	use namespace skeletonNamespace;
	
	/**
	 *
	 * @author Akdcl
	 */
	public class BaseFactory extends EventDispatcher {
		private static const matrix:Matrix = new Matrix();
		
		private static var __lastInstance:BaseFactory;
		public static function get lastInstance():BaseFactory {
			if (!__lastInstance) {
				__lastInstance = new BaseFactory();
			}
			return __lastInstance;
		}
		
		public static function getTextureDisplay(_textureData:TextureData, _fullName:String):PivotBitmap {
			var _texture:XML = _textureData.getSubTextureXML(_fullName);
			if (_texture) {
				var _rect:Rectangle = new Rectangle(
					int(_texture.attribute(ConstValues.A_X)),
					int(_texture.attribute(ConstValues.A_Y)),
					int(_texture.attribute(ConstValues.A_WIDTH)),
					int(_texture.attribute(ConstValues.A_HEIGHT))
				);
				var _img:PivotBitmap = new PivotBitmap(_textureData.bitmap.bitmapData);
				_img.scrollRect = _rect;
				_img.pX = int(_texture.attribute(ConstValues.A_PIVOT_X));
				_img.pY = int(_texture.attribute(ConstValues.A_PIVOT_Y));
				return _img;
			}
			return null;
		}
		
		private var __skeletonData:SkeletonData;
		public function get skeletonData():SkeletonData {
			return __skeletonData;
		}
		public function set skeletonData(_skeletonData:SkeletonData):void {
			__skeletonData = _skeletonData;
		}
		
		private var __textureData:TextureData;
		public function get textureData():TextureData {
			return __textureData;
		}
		public function set textureData(_textureData:TextureData):void {
			__textureData = _textureData;
		}
		
		public function BaseFactory(_skeletonData:SkeletonData = null, _textureData:TextureData = null):void {
			super();
			skeletonData = _skeletonData;
			textureData = _textureData;
		}
		
		public function buildArmature(_armatureName:String, _animationName:String = null):Armature {
			var _armatureData:ArmatureData = skeletonData.getArmatureData(_armatureName);
			if(!_armatureData){
				return null;
			}
			var _animationData:AnimationData = skeletonData.getAnimationData(_animationName || _armatureName);
			var _armature:Armature = generateArmature(_armatureName, _animationName);
			if (_armature) {
				_armature.animation.setData(_animationData);
				for each(var _boneName:String in _armatureData.getSearchList()) {
					generateBone(_armature, _armatureData, _boneName);
				}
			}
			return _armature;
		}
		
		protected function generateArmature(_armatureName:String, _animationName:String = null):Armature {
			var _armature:Armature = new Armature(new Sprite());
			_armature.addDisplayChild = addDisplayChild;
			_armature.removeDisplayChild = removeDisplayChild;
			_armature.updateDisplay = updateDisplay;
			_armature.origin.name = _armatureName;
			return _armature;
		}
		
		protected function generateBone(_armature:Armature, _armatureData:ArmatureData, _boneName:String):Bone {
			if(_armature.getBone(_boneName)){
				return null;
			}
			var _boneData:BoneData = _armatureData.getData(_boneName);
			var _parentName:String = _boneData.parent;
			if (_parentName) {
				generateBone(_armature, _armatureData, _parentName);
			}
			
			var _bone:Bone = new Bone();
			_bone.addDisplayChild = _armature.addDisplayChild;
			_bone.removeDisplayChild = _armature.removeDisplayChild;
			_bone.updateDisplay = _armature.updateDisplay;
			_bone.origin.copy(_boneData);
			
			_armature.addBone(_bone, _boneName, _parentName);
			
			var _length:uint = _boneData.displayLength;
			var _displayData:DisplayData;
			for(var _i:int = _length - 1;_i >=0;_i --){
				_displayData = _boneData.getDisplayData(_i);
				_bone.changeDisplay(_i);
				if (_displayData.isArmature) {
					_bone.display = buildArmature(_displayData.name);
				}else {
					_bone.display = generateBoneDisplay(_armature, _bone, _displayData.name);
				}
			}
			return _bone;
		}
		
		public function generateBoneDisplay(_armature:Armature, _bone:Bone, _imageName:String):Object {
			var _display:Object;
			var _clip:MovieClip = textureData.clip;
			if (_clip) {
				_clip.gotoAndStop(_clip.totalFrames);
				_clip.gotoAndStop(String(_imageName));
				if (_clip.numChildren > 0) {
					_display = _clip.getChildAt(0);
					if (!_display) {
						trace("无法获取影片剪辑，请确认骨骼 FLA 源文件导出 player 版本，与当前程序版本一致！");
					}
				}
			}else {
				textureData.updateBitmap();
				_display = getTextureDisplay(textureData, _imageName);
			}
			return _display;
		}
		
		private static function addDisplayChild(_child:Object, _parent:Object, _index:int = -1):void {
			if (_parent) {
				if(_index < 0){
					_parent.addChild(_child);
				}else{
					_parent.addChildAt(_child, Math.min(_index, _parent.numChildren));
				}
			}
		}
		
		private static function removeDisplayChild(_child:Object):void {
			if(_child.parent){
				_child.parent.removeChild(_child);
			}
		}
		
		private static function updateDisplay(_display:Object, matrix:Matrix):void {
			if (_display is PivotBitmap)
				_display.update(matrix);
			else
				_display.transform.matrix = matrix;
		}
	}
}