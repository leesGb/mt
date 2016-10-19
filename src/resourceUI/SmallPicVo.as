package resourceUI
{
	import flash.display.Bitmap;
	import flash.filesystem.File;

	public class SmallPicVo
	{		
		public var fileName:String;
		public var fileUrl:String;
		public var width:int;
		public var height:int;
		public var x:int;
		public var y:int;
		public var area:Number;
		public var bitmap:Bitmap;
		public var parent:BigPicVo;
		public function SmallPicVo(file:File=null)
		{
			if(file){
				fileUrl = file.nativePath.toLocaleLowerCase();
				fileName = file.name.substr(0,file.name.indexOf(file.type));
			}
		}
		
		public static function filterUrl(sUrl:String):String{
			if(sUrl.indexOf(Global.flaPath)==-1){
				return sUrl;
			}
			return sUrl.substr(Global.flaPath.length);				
		}
		
		public static function decUrl(sUrl:String):String{
			if(sUrl.toLocaleLowerCase().indexOf(Global.flaPath.toLocaleLowerCase())==-1){
				return String(Global.flaPath+sUrl).toLocaleLowerCase();
			}
			return sUrl.toLocaleLowerCase();
		}
	}
}