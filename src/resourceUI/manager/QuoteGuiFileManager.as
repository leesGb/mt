package resourceUI.manager
{
	import deltax.common.resource.Enviroment;
	import deltax.gui.base.WindowCreateParam;
	import deltax.gui.base.WindowResource;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	import resourceUI.BigPicVo;

	public class QuoteGuiFileManager
	{
		public static const CHECKED_GUI_FILE:String = "checked_gui_file";
		private static var m_instance:QuoteGuiFileManager;
		private var defualtFolderStr:String;
		private var winRes:WindowResource;
		private var newBigPicURL:Object;		
		public function QuoteGuiFileManager()
		{
			defualtFolderStr = Enviroment.ResourceRootPath + "gui/cfg/";//先测试baseui
		}
		
		public static function get instance():QuoteGuiFileManager
		{
			if(!m_instance) m_instance = new QuoteGuiFileManager();
			return m_instance;
		}
		
		public function startCheck(newBigPicURL:String):String{
			var resultStr:String = "";
			var stream:FileStream = new FileStream();
			var datas:ByteArray;		
			var filesList:Array = getAllGuiFiles(new File(defualtFolderStr));
			var hasTheBigPic:Boolean=false;
			var rootLen:int = defualtFolderStr.length;
			for each(var file:File in filesList){
				//
				var updateFlag:int = 0;
				stream.open(file,FileMode.READ);
				datas = new ByteArray();
				stream.readBytes(datas,0,stream.bytesAvailable);
				stream.close();
				winRes = new WindowResource();
				winRes.parse(datas);								
				
				hasTheBigPic = checkBigUrl(newBigPicURL);
				if(hasTheBigPic){
					trace('file:',file.name);
					resultStr += file.nativePath.substr(rootLen)+"\n";
				}
			}
			return resultStr;
		}
		
		/**
		 * 检测gui是否存在大图名
		 */
		private function checkBigUrl(newBigPicURL:String):Boolean			
		{			
			if(!winRes.textureMap) return false;
			newBigPicURL = newBigPicURL.toLocaleLowerCase();
			var oldUrl:String = BigPicVo.decUrl(String(newBigPicURL));		
			for(var i:int=0;i<winRes.textureMap.length;i++){							
				if(winRes.textureMap[i]==oldUrl){					
					return true;
				}
			}
			return false;
		}
		
		private function getAllGuiFiles(folder:File):Array
		{						
			var list:Array = folder.getDirectoryListing();
			if(list.length==0) return [];
			var target:Array=[];
			for each(var file:File in list){
				if(file.isDirectory && file.name!=".svn"){
					target = target.concat(getAllGuiFiles(file));
				}
				if(file.type==".gui"){
					target.push(file);
				}
			}
			return target;
		}

	}
}