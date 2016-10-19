package utils
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;

	public class FileUtil
	{
		public function FileUtil()
		{
		}
		
		public static function readFileString(value:String):String
		{
			var file:File = new File(value);
			if(!file.exists)
			{
				return "";
			}
			var fs:FileStream = new FileStream();
			fs.open(file, FileMode.READ);
			var ba:ByteArray = new ByteArray();
			fs.readBytes(ba);
			return ba.toString();
		}
	}
}