package resourceUI
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;

	/**
	 * 图片源数据加载器
	 */
	public class ResUIData
	{
		public static const BIG:int=1;
		public static const SMALL:int=0;
		public static var bigPicList:Dictionary=new Dictionary();//save bitmap
		public static var smallPicList:Dictionary = new Dictionary();//save bitmap
		public static var loadComCallBack:Function;
		public function ResUIData()
		{
		}
		
		/**
		 * @param picType 0小图,1大图
		 **/
		public static function getPic(picUrl:String,picType:int=0):Bitmap{
			if(picType==0 && smallPicList[picUrl]!=null) return smallPicList[picUrl];
			if(picType==1 && bigPicList[picUrl]!=null) return bigPicList[picUrl];
			var loader:Loader = new Loader();
			loader.name = picType+"$_$"+picUrl;
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loaderCom);
			loader.load(new URLRequest(picUrl));
			return null;
		}
		
		protected static function loaderCom(event:Event):void
		{
			var loader:Loader = event.target.loader;
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,loaderCom);
			var type:String = loader.name.split("$_$")[0];
			var url:String = loader.name.split("$_$")[1];
			var dic:Dictionary = int(type)==SMALL?smallPicList:bigPicList;
			dic[url] =loader.content as Bitmap;
			if(loadComCallBack!=null){
				loadComCallBack(loader.content,url);				
			}
		}
		
		public static function releaseBigPic():void{
			for(var bm:String in bigPicList){			
				bigPicList[bm].bitmapData.dispose();
				delete bigPicList[bm];
			}
			bigPicList = new Dictionary();
		}
	}
}