package akdcl.skeleton.utils {
	import akdcl.skeleton.objects.Node;
	
	/**
	 * ...
	 * @author Akdcl
	 */
	public function transfromPointWidthParent(_boneData:Node, _parentData:Node):void {
		var _dX:Number = _boneData.x - _parentData.x;
		var _dY:Number = _boneData.y - _parentData.y;
		var _r:Number = Math.atan2(_dY, _dX) - _parentData.skewY;
		var _len:Number = Math.sqrt(_dX * _dX + _dY * _dY);
		_boneData.x = _len * Math.cos(_r);
		_boneData.y = _len * Math.sin(_r);
		_boneData.skewX = _boneData.skewX - _parentData.skewX;
		_boneData.skewY = _boneData.skewY - _parentData.skewY;
	}
	
}