package akdcl.skeleton.factorys {
	import flash.geom.Rectangle;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.SubTexture;
	import starling.textures.Texture;
	
	import akdcl.skeleton.Armature;
	import akdcl.skeleton.Bone;
	import akdcl.skeleton.objects.Node;
	import akdcl.skeleton.objects.SkeletonData;
	import akdcl.skeleton.objects.TextureData;
	import akdcl.skeleton.utils.ConstValues;
	
	import akdcl.skeleton.utils.skeletonNamespace;
	
	use namespace skeletonNamespace;
	
	/**
	 * 
	 * @author Akdcl
	 */
	public class StarlingFactory extends BaseFactory {
		
		private static var __lastInstance:StarlingFactory;
		public static function get lastInstance():StarlingFactory {
			if (!__lastInstance) {
				__lastInstance = new StarlingFactory();
			}
			return __lastInstance;
		}
		
		public static function getTextureDisplay(_textureData:TextureData, _fullName:String):Image {
			var _texture:XML = _textureData.getTextureXML(_fullName);
			if (_texture) {
				var _subTexture:SubTexture = _textureData.subTextures[_fullName];
				if(!_subTexture){
					var _rect:Rectangle = new Rectangle(
						int(_texture.attribute(ConstValues.A_X)), 
						int(_texture.attribute(ConstValues.A_Y)), 
						int(_texture.attribute(ConstValues.A_WIDTH)), 
						int(_texture.attribute(ConstValues.A_HEIGHT))
					);
					_subTexture = new SubTexture(_textureData.texture as Texture, _rect);
					_textureData.subTextures[_fullName] = _subTexture;
				}
				var _img:Image = new Image(_subTexture);
				_img.pivotX = int(_texture.attribute(ConstValues.A_PIVOT_X));
				_img.pivotY = int(_texture.attribute(ConstValues.A_PIVOT_Y));
				return _img;
			}
			return null;
		}
		
		override public function set skeletonData(_skeletonData:SkeletonData):void {
			super.skeletonData = _skeletonData;
			if (skeletonData) {
				skeletonData.textureData.updateBitmap();
			}
		}
		
		public function StarlingFactory(_skeletonData:SkeletonData = null):void {
			super(_skeletonData);
		}
		override protected function generateArmature(_armatureName:String, _animationName:String = null):Armature {
			if (!skeletonData.textureData.texture) {
				skeletonData.textureData.texture = Texture.fromBitmap(skeletonData.textureData.bitmap);
				//
				skeletonData.textureData.bitmap.bitmapData.dispose();
			}
			
			var _armature:Armature = new Armature(new Sprite());
			_armature.addDisplayChild = addDisplayChild;
			_armature.removeDisplayChild = removeDisplayChild;
			_armature.updateDisplay = updateDisplay;
			_armature.info.name = _armatureName;
			return _armature;
		}
		
		override public function generateBoneDisplay(_armature:Armature, _bone:Bone, _imageName:String):Object {
			return getTextureDisplay(skeletonData.textureData, _imageName);
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
		
		private static function updateDisplay(_display:Object, _node:Node):void {
			_display.x = _node.x;
			_display.y = _node.y;
			_display.skewX = _node.skewX;
			_display.skewY = _node.skewY;
			_display.scaleX = _node.scaleX;
			_display.scaleY = _node.scaleY;
		}
	}
}