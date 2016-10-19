package core
{
	import deltax.common.resource.Enviroment;

	public class TextureFileManager
	{
		private static var _instance:TextureFileManager;
		public var urls:Vector.<String>;
		
		public function TextureFileManager()
		{
			urls = new Vector.<String>();
		}
		
		public static function getInstance():TextureFileManager{
			_instance?"":(_instance = new TextureFileManager());
			return _instance;
		}			
		
		public function GetTextureId(url:String):uint{
			//url = url.replace(Enviroment.ResourceRootPath,"");
			var idx:int = urls.indexOf(url);
			if(idx!=-1)
				return idx;
			
			urls.push(url);
			return urls.length - 1;
		}
	}
}