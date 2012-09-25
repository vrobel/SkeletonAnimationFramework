package akdcl.skeleton.objects
{
	import flash.utils.ByteArray;

	public final class SkeletonAndTextureRawData
	{
		public var skeletonXML:XML;
		public var textureXML:XML;
		public var textureBytes:ByteArray;
		public function SkeletonAndTextureRawData(_byteArray:ByteArray)
		{
			extractDatas(_byteArray);
		}
		
		public function dispose():void{
			skeletonXML = null;
			textureXML = null;
			textureBytes = null;
		}
		
		public function extractDatas(_byteArray:ByteArray):void {
			if (_byteArray) {
				try {
					_byteArray.position = _byteArray.length - 4;
					var _strSize:int = _byteArray.readInt();
					var _position:uint = _byteArray.length - 4 - _strSize;
					
					var _xmlByte:ByteArray = new ByteArray();
					_xmlByte.writeBytes(_byteArray, _position, _strSize);
					_xmlByte.uncompress();
					_byteArray.length = _position;
					
					skeletonXML =XML(_xmlByte.readUTFBytes(_xmlByte.length));
					
					_byteArray.position = _byteArray.length - 4;
					_strSize = _byteArray.readInt();
					_position = _byteArray.length - 4 - _strSize;
					
					_xmlByte.length = 0;
					_xmlByte.writeBytes(_byteArray, _position, _strSize);
					_xmlByte.uncompress();
					_byteArray.length = _position;
					
					textureXML = XML(_xmlByte.readUTFBytes(_xmlByte.length));
					
					textureBytes = _byteArray;
				}catch (_e:Error) {
					throw "无效的骨骼数据！！！";
				}
			}
		}
	}
}