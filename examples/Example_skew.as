package  {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.setTimeout;
	
	import akdcl.skeleton.objects.SkeletonAndTextureRawData;
	import akdcl.skeleton.objects.SkeletonData;
	import akdcl.skeleton.objects.TextureData;
	import akdcl.skeleton.factorys.BaseFactory;
	import akdcl.skeleton.factorys.StarlingFactory;
	
	import akdcl.skeleton.Armature;
	
	import starling.core.Starling;
	
    [SWF(width="800", height="600", frameRate="30", backgroundColor="#999999")]
	public class Example_skew extends Sprite {
		[Embed(source = "./resources/Zombie_yeti.swf", mimeType = "application/octet-stream")]
		private static const ResourcesData:Class;
		
		public function Example_skew() {
			var _sat:SkeletonAndTextureRawData = new SkeletonAndTextureRawData(new ResourcesData());
			BaseFactory.lastInstance.skeletonData = 
			StarlingFactory.lastInstance.skeletonData = 
				new SkeletonData(_sat.skeletonXML);
			BaseFactory.lastInstance.textureData = 
			StarlingFactory.lastInstance.textureData = 
				new TextureData(_sat.textureXML, _sat.textureBytes);
			_sat.dispose();
			
			setTimeout(baseInit, 300);
			setTimeout(starlingInit, 300);
		}
		
		private var armature:Armature;
		private function baseInit():void {
			armature = BaseFactory.lastInstance.buildArmature("Zombie_yeti");
		
			armature.display.x = 200;
			armature.display.y = 300;
			armature.animation.play("anim_death");
			//armature.animation.play("anim_eat");
			//armature.animation.play("anim_walk");
			//armature.animation.play("anim_idle");
			addChild(armature.display as Sprite);
			addEventListener(Event.ENTER_FRAME, onEnterFrameHandler);
		}
		
		private function onEnterFrameHandler(_e:Event):void {
			armature.update();
		}
		
		private function starlingInit():void {
			var _starling:Starling = new Starling(StarlingGame, stage);
			//_starling.antiAliasing = 1;
			_starling.showStats = true;
			_starling.start();
		}
	}
}

import starling.display.Sprite;
import starling.events.EnterFrameEvent;

import akdcl.skeleton.Armature;
import akdcl.skeleton.factorys.StarlingFactory;

class StarlingGame extends Sprite {
	private var armature:Armature;
	public function StarlingGame() {
		armature = StarlingFactory.lastInstance.buildArmature("Zombie_yeti");
		
		armature.display.x = 600;
		armature.display.y = 300;
		armature.animation.play("anim_death");
		//armature.animation.play("anim_eat");
		//armature.animation.play("anim_walk");
		//armature.animation.play("anim_idle");
		addChild(armature.display as Sprite);
		addEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrameHandler);
	}
	
	private function onEnterFrameHandler(_e:EnterFrameEvent):void {
		armature.update();
	}
}
