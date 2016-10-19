package utils
{
	import deltax.common.Util;
	import deltax.common.localize.LanguageMgr;
	import deltax.common.respackage.common.LoaderCommon;
	import deltax.common.respackage.loader.LoaderManager;
	import deltax.delta;
	
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.NativeProcessExitEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoaderDataFormat;
	import flash.utils.ByteArray;
	import flash.utils.clearInterval;
	import flash.utils.flash_proxy;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	
	import mx.controls.Alert;

	use namespace delta;
	/**
	 * 翻译工具类
	 */
	public class DicUtil
	{		
		public static const DIC_RELOADED:String = "dic_reloaded";
		private static var dispatcher:EventDispatcher = new EventDispatcher();
		public static var uiLanguageUrl:String = "";
		public function DicUtil()
		{
	
		}
		
		public static function writeUpatedFile():void{
			var data:String="";
			var list:Array=[];
			var afds:* = LanguageMgr.dic;
			data += "# "+LanguageMgr.rows+"\r\n";//添加编号ID
			for(var id:int=1;id<=LanguageMgr.rows;id++){
				var keyID:String =LanguageMgr.setID(id.toString()); 
				data += keyID+":"+LanguageMgr.GetUITranslation(id.toString())+"\r\n";
			}
			
			var file:File = new File(uiLanguageUrl);
			var stream:FileStream = new FileStream();
			stream.open(file,FileMode.WRITE);
			stream.writeMultiByte(data,"UTF-8");
			stream.close();
		}
			
		public static function svnUpdate(callBack:Function=null):void
		{
			callBack(null);
			return;
			excuteSvn(callBack,"update",uiLanguageUrl);
		}
		
		public static function svnCommit(callBack:Function=null):void
		{
			
			excuteSvn(null,"commit",uiLanguageUrl,"-m","\"uieditor auto commit\"");
		}
		
		private static var svnExeURL:String = "C:/Program Files/Subversion/bin/svn.exe";
		private static function excuteSvn(callBack:Function=null,...processArgs):void{
			var cmdFile:File=new File();  
			cmdFile = cmdFile.resolvePath(svnExeURL);  
			var nativeProcessStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			try{
			nativeProcessStartupInfo.executable = cmdFile;
			}catch(e:ArgumentError){
				Alert.show("系统不存在"+svnExeURL+"文件");
				return;
			}
			nativeProcessStartupInfo.arguments = Vector.<String>(processArgs);
			nativeProcessStartupInfo.workingDirectory = File.documentsDirectory;
			
			var process:NativeProcess = new NativeProcess();
			try{
				process.start(nativeProcessStartupInfo);
			}catch(e:Error){
				Alert.show(e.message);
				return;
			}
			if(callBack!=null){
				process.addEventListener(NativeProcessExitEvent.EXIT,callBack);
				
			}
			//process.standardInput.writeUTFBytes(processArgs.toString() + "\n");			
			//process.closeInput();
		}
		
		private static function exitHandler(event:NativeProcessExitEvent):void
		{													
		}
		
		//同步更新后的配置ui翻译表
		public static function synUIDic():void
		{
			LoaderManager.getInstance().startSerialLoad();
			LoaderManager.getInstance().load(uiLanguageUrl, {onComplete:loadLanguageComplete}, LoaderCommon.LOADER_URL, false, {dataFormat:URLLoaderDataFormat.TEXT});
		}
		
		private static function loadLanguageComplete(ob:Object):void{
			LanguageMgr.setup(ob["data"] as String,LanguageMgr.SETUP_UI);
			LanguageMgr.flushUITranslation();
			dispatcher.dispatchEvent(new Event(DIC_RELOADED));
		}
		
		public static function addEventListener(reloadUIHanlder:Function){
			dispatcher.addEventListener(DIC_RELOADED,reloadUIHanlder);
		}
		
	}
}