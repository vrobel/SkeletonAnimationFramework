package akdcl.skeleton.animation{
	
	import akdcl.skeleton.Armature;
	import akdcl.skeleton.Bone;
	import akdcl.skeleton.events.Event;
	import akdcl.skeleton.events.SoundEventManager;
	import akdcl.skeleton.objects.AnimationData;
	import akdcl.skeleton.objects.MovementBoneData;
	import akdcl.skeleton.objects.MovementData;
	import akdcl.skeleton.objects.MovementFrameData;
	import akdcl.skeleton.utils.skeletonNamespace;
	
	use namespace skeletonNamespace;
	
	/**
	 * 
	 * @author Akdcl
	 */
	final public class Animation extends ProcessBase {
		private static var soundManager:SoundEventManager = SoundEventManager.getInstance();
		
		public var movementList:Array;
		public var movementID:String;
		
		protected var updateDisplayFun:Function;
		protected var containerFun:Function;
		
		private var animationData:AnimationData;
		private var movementData:MovementData;
		private var currentFrameData:MovementFrameData;
		
		private var armature:Armature;
		
		override public function set scale(_scale:Number):void {
			super.scale = _scale;
			for each(var _bone:Bone in armature.bones) {
				_bone.tween.scale = _scale;
			}
		}
		
		public function Animation(_armature:Armature) {
			armature = _armature;
		}
		
		public function setData(_animationData:AnimationData):void {
			if (!_animationData) {
				return;
			}
			stop();
			animationData = _animationData;
			movementList = animationData.getSearchList();
		}
		
		public function autoPlay(_movementID:Object, _durationTo:int = -1, _durationTween:int = -1, _loop:* = null, _tweenEasing:Number = NaN):void{
			if(movementID == _movementID as String){
				return;
			}
			play(_movementID, _durationTo, _durationTween, _loop, _tweenEasing);
		}
		
		override public function play(_movementID:Object, _durationTo:int = -1, _durationTween:int = -1, _loop:* = null, _tweenEasing:Number = NaN):void {
			if (!animationData) {
				return;
			}
			var _movementData:MovementData = animationData.getData(_movementID as String);
			if (!_movementData) {
				return;
			}
			currentFrameData = null;
			toIndex = 0;
			movementID = _movementID as String;
			movementData = _movementData;
			_durationTo = _durationTo < 0?movementData.durationTo:_durationTo;
			_durationTween = _durationTween < 0?movementData.durationTween:_durationTween;
			_loop = _loop === null?movementData.loop:_loop;
			_tweenEasing = isNaN(_tweenEasing)?movementData.tweenEasing:_tweenEasing;
			
			super.play(null, _durationTo, _durationTween);
			duration = movementData.duration;
			if (duration == 1) {
				loop = SINGLE;
			}else {
				if (_loop) {
					loop = LIST_LOOP_START
				}else {
					loop = LIST_START
					duration --;
				}
				durationTween = _durationTween;
			}
			
			var _movementBoneData:MovementBoneData;
			for each(var _bone:Bone in armature.bones) {
				_movementBoneData = movementData.getData(_bone.origin.name);
				if (_movementBoneData) {
					_bone.tween.play(_movementBoneData, _durationTo, _durationTween, _loop, _tweenEasing);
				}else {
					_bone.changeDisplay(-1);
					_bone.tween.stop();
				}
			}
		}
		
		override public function pause():void {
			super.pause();
			for each(var _bone:Bone in armature.bones) {
				_bone.tween.pause();
			}
		}
		
		override public function resume():void {
			super.resume();
			for each(var _bone:Bone in armature.bones) {
				_bone.tween.resume();
			}
		}
		
		override public function stop():void {
			super.stop();
			for each(var _bone:Bone in armature.bones) {
				_bone.tween.stop();
			}
		}
		
		override protected function updateHandler():void {
			if (currentPrecent >= 1) {
				switch(loop) {
					case LIST_START:
						loop = LIST;
						currentPrecent = (currentPrecent - 1) * totalFrames / durationTween;
						if (currentPrecent >= 1) {
							//播放速度太快或durationTween时间太短，进入下面的case
						}else {
							totalFrames = durationTween;
							armature.dispatchEventWith(Event.START, movementID);
							break;
						}
					case LIST:
					case SINGLE:
						currentPrecent = 1;
						isComplete = true;
						armature.dispatchEventWith(Event.COMPLETE, movementID);
						break;
					case LIST_LOOP_START:
						loop = 0;
						totalFrames = durationTween > 0?durationTween:1;
						currentPrecent %= 1;
						armature.dispatchEventWith(Event.START, movementID);
						break;
					default:
						//继续循环
						loop += int(currentPrecent);
						currentPrecent %= 1;
						toIndex = 0;
						armature.dispatchEventWith(Event.LOOP_COMPLETE, movementID);
						break;
				}
			}
			if (loop >= LIST) {
				updateFrameData(currentPrecent);
			}
		}
		
		private function updateFrameData(_currentPrecent:Number):void {
			var _length:uint = movementData.frameLength;
			if(_length == 0){
				return;
			}
			var _played:Number = duration * _currentPrecent;
			//播放头到达当前帧的前面或后面则重新寻找当前帧
			if (!currentFrameData || _played >= currentFrameData.duration + currentFrameData.start || _played < currentFrameData.start) {
				while (true) {
					currentFrameData =  movementData.getFrame(toIndex);
					if (++toIndex >= _length) {
						toIndex = 0;
					}
					if(currentFrameData && _played >= currentFrameData.start && _played < currentFrameData.duration + currentFrameData.start){
						break;
					}
				}
				if(currentFrameData.event){
					armature.dispatchEventWith(Event.MOVEMENT_EVENT_FRAME, currentFrameData.event);
				}
				if(currentFrameData.sound){
					soundManager.dispatchEventWith(Event.SOUND_FRAME, currentFrameData.sound);
				}
				if(currentFrameData.movement){
					play(currentFrameData.movement);
				}
			}
		}
	}
	
}