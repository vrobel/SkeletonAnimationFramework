package akdcl.skeleton.objects
{
	import akdcl.skeleton.utils.ConstValues;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * @author Akdcl
	 */
	public class TextureData {
		public var name:String;
		
		public var clip:MovieClip;
		
		public var bitmap:Bitmap;
		
		public var texture:Object;
		
		public var subTextures:Object;
		
		private var width:uint;
		private var height:uint;
		private var isClipToBMP:Boolean;
		
		private var __xml:XML;
		public function get xml():XML{
			return __xml;
		}
		
		public function TextureData(_textureAtlasXML:XML, _byteArray:ByteArray, _isClipToBMP:Boolean = false) {
			__xml = _textureAtlasXML;
			
			name = _textureAtlasXML.attribute(ConstValues.A_NAME);
			width = uint(_textureAtlasXML.attribute(ConstValues.A_WIDTH));
			height = uint(_textureAtlasXML.attribute(ConstValues.A_HEIGHT));
			isClipToBMP = _isClipToBMP;
			
			var _loader:Loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderCompleteHandler);
			var _loaderContext:LoaderContext = new LoaderContext(false);
			_loaderContext.allowCodeImport = true;
			_loader.loadBytes(_byteArray, _loaderContext);
			
			subTextures = {};
		}
		
		public function updateBitmap():void {
			if (!bitmap && clip) {
				bitmap = new Bitmap();
				bitmap.bitmapData = new BitmapData(width, height, true, 0xff00ff);
				bitmap.bitmapData.draw(clip);
			}
			isClipToBMP = true;
		}
		
		public function getSubTextureXML(_id:String):XML {
			return __xml.elements(ConstValues.SUB_TEXTURE).(attribute(ConstValues.A_NAME) == _id)[0];
		}
		
		public function dispose():void{
			name = null;
			__xml = null;
			clip = null;
			
			if(bitmap && bitmap.bitmapData){
				bitmap.bitmapData.dispose();
			}
			bitmap = null;
			
			if(texture && ("dispose" in texture)){
				texture.dispose();
			}
			texture = null;
			
			for each(var _subTexture:Object in subTextures){
				if("dispose" in _subTexture){
					_subTexture.dispose();
				}
			}
			subTextures = null;
		}
		
		private function onLoaderCompleteHandler(_e:Event):void {
			_e.target.removeEventListener(Event.COMPLETE, onLoaderCompleteHandler);
			var _loader:Loader = _e.target.loader;
			var _content:Object = _e.target.content;
			_loader.unloadAndStop();
			
			if (_content is Bitmap) {
				bitmap = _content as Bitmap;
			}else {
				clip = _content.getChildAt(0) as MovieClip;
				clip.stop();
				if (isClipToBMP) {
					updateBitmap();
				}
			}
		}
	}
}