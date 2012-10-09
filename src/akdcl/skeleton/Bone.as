package akdcl.skeleton {
	import akdcl.skeleton.animation.Tween;
	import akdcl.skeleton.events.EventDispatcher;
	import akdcl.skeleton.objects.BoneData;
	import akdcl.skeleton.objects.Node;
	
	import akdcl.skeleton.utils.skeletonNamespace;
	
	use namespace skeletonNamespace;
	
	/**
	 * 
	 * @author akdcl
	 */
	public class Bone extends EventDispatcher {
		public var userData:Object;
		
		public var origin:BoneData;
		public var node:Node;
		public var tween:Tween;
		
		public var globalX:Number;
		public var globalY:Number;
		public var globalSkewX:Number;
		public var globalSkewY:Number;
		public var globalScaleX:Number;
		public var globalScaleY:Number;
		
		protected var children:Vector.<Bone>;
		
		skeletonNamespace var addDisplayChild:Function;
		skeletonNamespace var removeDisplayChild:Function;
		skeletonNamespace var updateDisplay:Function;
		
		private var tweenNode:Node;
		
		private var displayList:Array;
		private var displayIndex:int = -1;
		
		private var __armature:Armature;
		public function get armature():Armature{
			return __armature;
		}
		
		private var __parent:Bone;
		public function get parent():Bone{
			return __parent;
		}
		
		protected var __display:Object;
		public function get display():Object {
			return __display;
		}
		public function set display(_display:Object):void {
			if(__display == _display) {
				return;
			}
			
			if (__display) {
				removeDisplayChild(__display);
				__display = null;
			}else if (displayList[displayIndex] is Armature) {
				removeChild(displayList[displayIndex] as Bone);
			}else {
				
			}
			
			if (_display is Armature) {
				displayList[displayIndex] = _display;
				addChild(_display as Bone);
			}else if (_display) {
				displayList[displayIndex] = _display;
				if(__armature){
					addDisplayChild(_display, __armature.display, origin.z);
				}
				__display = _display;
			}else {
				if(displayIndex >= 0){
					displayList[displayIndex] = false;
				}
			}
		}
		
		skeletonNamespace function changeDisplay(_displayIndex:int):void {
			if(displayIndex == _displayIndex){
				return;
			}
			
			displayIndex = _displayIndex;
			if(displayIndex < 0){
				display = null;
			}else{
				var _display:Object = displayList[displayIndex];
				if(_display){
					display = _display;
				}else if (_display === false) {
					display = null;
				}
			}
			if(__armature){
				__armature.bonesIndexChanged = true;
			}
		}
		
		public function Bone() {
			globalX = 0;
			globalY = 0;
			globalSkewX = 0;
			globalSkewY = 0;
			globalScaleX = 0;
			globalScaleY = 0;
			
			origin = new BoneData();
			displayList = [];
			
			children = new Vector.<Bone>;
			node = new Node();
			
			tween = new Tween(this);
			tweenNode = tween.node;
		}
		
		public function update():void {
			if (__armature) {
				tween.update();
				
				var _transformX:Number = origin.x + node.x + tweenNode.x;
				var _transformY:Number = origin.y + node.y + tweenNode.y;
				var _transformSkewX:Number = origin.skewX + node.skewX + tweenNode.skewX;
				var _transformSkewY:Number = origin.skewY + node.skewY + tweenNode.skewY;
				
				if (__parent != __armature) {
					var _r:Number = Math.atan2(_transformY, _transformX) + __parent.globalSkewY;
					var _len:Number = Math.sqrt(_transformX * _transformX + _transformY * _transformY);
					_transformX = _len * Math.cos(_r) + __parent.globalX;
					_transformY = _len * Math.sin(_r) + __parent.globalY;
					_transformSkewX += __parent.globalSkewX;
					_transformSkewY += __parent.globalSkewY;
				}
				/*
				if(
					globalX != _transformX ||
					globalY != _transformY ||
					globalSkewX != _transformSkewX ||
					globalSkewY != _transformSkewY ||
					globalScaleX != tweenNode.scaleX ||
					globalScaleY != tweenNode.scaleY
				){*/
					globalX = _transformX;
					globalY = _transformY;
					globalSkewX = _transformSkewX;
					globalSkewY = _transformSkewY;
					globalScaleX = tweenNode.scaleX;
					globalScaleY = tweenNode.scaleY;
					if (__display) {
						updateDisplay(__display, globalX, globalY, globalSkewX, globalSkewY, globalScaleX, globalScaleY);
					}
				//}
			}
			
			if(origin.name == "头"){
				//trace(origin, origin.parent, parent?parent.origin.name:"!!!!!");
			}
			
			for each(var _child:Bone in children) {
				_child.update();
			}
		}
		
		public function dispose():void{
			for each(var _child:Bone in children){
				_child.dispose();
			}
			
			setParent(null);
			
			userData = null;
			origin = null;
			node = null;
			tween = null;
			tweenNode = null;
			children = null;
			
			__armature = null;
			__parent = null;
			__display = null;
			
			displayList = null;
		}
		
		public function addChild(_child:Bone):void {
			if (children.indexOf(_child) < 0) {
				children.push(_child);
				_child.removeFromParent();
				_child.setParent(this);
			}
		}
		
		public function removeChild(_child:Bone, _dispose:Boolean = false):void {
			var _index:int = children.indexOf(_child);
			if (_index >= 0) {
				_child.setParent(null);
				children.splice(_index, 1);
				if(_dispose){
					_child.dispose();
				}
			}else{
				
			}
		}
		
		public function removeFromParent(_dispose:Boolean = false):void{
			if(__parent){
				__parent.removeChild(this, _dispose);
			}
		}
		
		private function setParent(_parent:Bone):void{
			var _ancestor:Bone = _parent;
			while (_ancestor != this && _ancestor != null){
				_ancestor = _ancestor.parent;
			}
			
			if (_ancestor == this){
				throw new ArgumentError("An Bone cannot be added as a child to itself or one of its children (or children's children, etc.)");
			}else{
				__parent = _parent;
			}
			var _child:Bone;
			if(__parent){
				origin.parent = __parent.origin.name;
				__armature = (__parent as Armature) || __parent.armature;
				if (__armature) {
					if(__display){
						addDisplayChild(__display, __armature.display, origin.z);
					}
					__armature.addToBones(this);
					if(!this is Armature){
						for each(_child in children){
							if(_child.display){
								addDisplayChild(_child.display, __armature.display, origin.z);
							}
							__armature.addToBones(_child);
						}
					}
				}
			}else{
				if (__armature) {
					if(!this is Armature){
						for each(_child in children){
							removeDisplayChild(_child.display);
							__armature.removeFromBones(_child);
						}
					}
					if(__display){
						removeDisplayChild(__display);
					}
					__armature.removeFromBones(this);
					__armature = null;
				}
				origin.parent = null;
			}
		}
	}
	
}