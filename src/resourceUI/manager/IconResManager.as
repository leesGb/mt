package resourceUI.manager
{
	import com.stimuli.string.printf;
	
	import deltax.common.math.MathUtl;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import mx.controls.Alert;
	import mx.graphics.codec.PNGEncoder;
	import resourceUI.ReousrceManagerUI;

	public class IconResManager
	{
		public static var BIG_PIC_WIDTH:int = 512;
		public static var BIG_PIC_HEIGHT:int = 512;
		
		public static const C_ICON_SIZE:uint = 50;
		public static const C_ICON_GAP:uint = 1;
		public static const C_ICON_COUNT_PER_ROW:uint = 10;
		public static const C_ICON_COUNT_PER_TEXTURE:int = 100;
		public static const C_BIG_ICON_NAME:String = "icon_";
		public static var   C_OUTPUT_PATH:String;
		
		public static var BIG_ICON_NAME:String = "icon_";
		public static var ICON_SIZE:uint = 50;
		public static var ICON_SPAN:uint = 51;
		public static var ICON_COUNT_PER_ROW:uint = 10;
		public static var ICON_COUNT_PER_TEXTURE:int = 100;
		public static var OUTPUT_PATH:String;
		
		public static var URL_ICON_CONFIG:String;
		private static var _instance:IconResManager;
		private var bigPicList:Dictionary;//大图bitmapdata
		private var smallPicList:Dictionary;//小图bitmapdata
		private var loader:Loader = new Loader();
		private var fileList:Vector.<File>;
		
		//加载用的字段
		//public static const LOAD_MAX_SIZE:int = 200;
		private var curLoaderIndex:int=0;
		private var totalLoadIndex:int;
		
		private var curLoadMaxIconID:int;//当前加载最大值的小图ID
		
		public function IconResManager()
		{
//			loadBigPics();
//			importPicFolder();
//			startLoadPicList();
//			loadAllComplete();
//			setupBigPic();
//			exportAllBigPic();
			C_OUTPUT_PATH = ReousrceManagerUI.instance.URL_BIGPIC+"icons/";
			OUTPUT_PATH = ReousrceManagerUI.instance.URL_BIGPIC;
		}
		
		public function startExport():void{
			loadBigPics();
			importPicFolder();
		}
		
		private function loadBigPics():void
		{
			bigPicList = new Dictionary();
		}
		
		private function exportAllBigPic(needExportPicNameDic:Dictionary):void
		{
			var influenceTip:String="";
			for(var bigIndex:String in needExportPicNameDic){
				influenceTip += "影响了"+needExportPicNameDic[bigIndex]+"\n";
				exportPNG(bigPicList[bigIndex],needExportPicNameDic[bigIndex]);
			}
			Alert.show(influenceTip);
		}
		
		private function loadAllComplete():void
		{
			var needExportPic:Dictionary = new Dictionary();
			var bigPic:BitmapData;
			for(var idx:String in smallPicList){
				var iconID:int = int(idx);
				var icon:BitmapData = smallPicList[idx];
				var bigIndex:uint = ((MathUtl.max(1, iconID) - 1) / ICON_COUNT_PER_TEXTURE);				
				var bigPicName:String = BIG_ICON_NAME+printf("%0"+2+"s",bigIndex);
				needExportPic[bigIndex] = bigPicName;
				if(!bigPicList[bigIndex]){					
					bigPicList[bigIndex] = new BitmapData(BIG_PIC_WIDTH,BIG_PIC_HEIGHT,true,0xFFFFFF);
				}
				bigPic = bigPicList[bigIndex]; 
				drawSmallPic(bigPic,icon,iconID);				
			}			
			
			exportAllBigPic(needExportPic);
			
		}
		
		private function drawSmallPic(bigPic:BitmapData, icon:BitmapData, iconID:int):void
		{
			var smallIndex:uint = ((MathUtl.max(1, iconID) - 1) % ICON_COUNT_PER_TEXTURE);
			var rect:Rectangle = new Rectangle();
			rect.left = ((smallIndex % ICON_COUNT_PER_ROW) * ICON_SPAN);
			rect.right = (rect.left + ICON_SIZE);
			rect.top = (uint((smallIndex / ICON_COUNT_PER_ROW)) * ICON_SPAN);
			rect.bottom = (rect.top + ICON_SIZE);
			bigPic.fillRect(rect,0xFFFFFF);
			bigPic.copyPixels(icon,icon.rect,new Point(rect.x,rect.y),null,null,false);
		}
		
		private function importPicFolder():void
		{			
			reset();
			var file:File = new File(Global.flaPath);
			file.browseForDirectory("选择图标资源目录");
			file.addEventListener(Event.SELECT,selectFolder);
		}
		
		private function reset():void
		{
			curLoaderIndex=0;
			curLoadMaxIconID=0;
			totalLoadIndex = 0;
			smallPicList = new Dictionary();
		}
		
		protected function selectFolder(event:Event):void
		{
			try{
			var file:File = event.target as File;
			fileList = getAllValidPicFile(file);
			totalLoadIndex = fileList.length;
			//for each(file in fileList){
			file = fileList.pop();
			loader.name = file.name.substr(0,file.name.lastIndexOf("."));
			loader.load(new URLRequest(file.nativePath));
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,apicLoadComplete);
			//}
			}catch(e:Error){
				throw new Error(e.message);
			}
		}
		
		protected function apicLoadComplete(event:Event):void
		{
			
			var bitmap:Bitmap = event.target.loader.content as Bitmap;
			smallPicList[event.target.loader.name] = bitmap.bitmapData;
			event.target.loader.unload();			
			var file:File = fileList.pop();
			if(file){
				loader.name = file.name.substr(0,file.name.lastIndexOf("."));
				loader.load(new URLRequest(file.nativePath));
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE,apicLoadComplete);
			}
			curLoaderIndex++;
			if(curLoaderIndex==totalLoadIndex){
				loadAllComplete();
			}
			
		}
		
		private function getAllValidPicFile(file:File):Vector.<File>
		{			
			var list:Vector.<File> = new Vector.<File>();
			if(!file.exists) return list;
			if(file.isDirectory){
				var tmp:Array = file.getDirectoryListing();
				for each(var afile:File in tmp){
					list = list.concat(getAllValidPicFile(afile));
				}
			}else{
				if(file.type==".png"||file.type==".PNG"){
					list.push(file);
					var tmpNum:* = parseInt((file.name.substr(0,file.name.lastIndexOf("."))));
					if(isNaN(tmpNum)){
						throw new Error("读取的"+file.nativePath+"图标文件格式不符");
					}
					curLoadMaxIconID = curLoadMaxIconID<tmpNum?tmpNum:curLoadMaxIconID;
				}
			}
			return list;
		}		
		
		public function exportPNG(curPic:BitmapData,fileName:String):void{
			var fs:FileStream = new FileStream();
			var test:PNGEncoder= new PNGEncoder();
			var bin:ByteArray = test.encode(curPic);
			fs.open(new File(OUTPUT_PATH+fileName+".png"),FileMode.WRITE);
			fs.writeBytes(bin,0,bin.bytesAvailable);
			fs.close();
		}

		public static function get instance():IconResManager
		{
			if(!_instance){
				_instance = new IconResManager();
			}
			return _instance;
		}
	}
}