package resourceUI
{
	import deltax.common.resource.Enviroment;
	
	import flash.display.Bitmap;

	public class BigPicVo
	{
		public var name:String;
		public var url:String;
		public var size:int;
		public var bitmap:Bitmap;
		public function BigPicVo(name:String="",url:String="")
		{
			this.name = name;
			this.url = url;		
		}
		
		public static function filterUrl(sUrl:String):String{
			if(sUrl.indexOf(Enviroment.ResourceRootPath)==-1){
				return sUrl;
			}
			return sUrl.substr(Enviroment.ResourceRootPath.length);				
		}
		
		public static function decUrl(sUrl:String):String{
			if(sUrl.toLocaleLowerCase().indexOf(Enviroment.ResourceRootPath.toLocaleLowerCase())==-1){
				return String(Enviroment.ResourceRootPath+sUrl).toLocaleLowerCase();
			}
			return sUrl.toLocaleLowerCase();
		}
	}
}