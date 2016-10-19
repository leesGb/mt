package utils
{
	import deltax.gui.base.DisplayImageInfo;
	
	import flash.utils.Dictionary;
	/**
	 * 全局剪贴板管理器
	 */
	public class ClipBoardManager
	{
		public static const DisplayImageInfoList:String="DisplayImageInfoList";
		private static var _instance:ClipBoardManager;
		private var dic:Dictionary;
		
		public function ClipBoardManager()
		{
			dic = new Dictionary();
		}
		
		public function paste(key:String):Object
		{
			if(!dic[key]) return null;
			return clone(key,dic[key]);
		}
		
		public function copy(key:String,data:Object):void
		{
			dic[key] = clone(key,data);
		}
		
		private function clone(type:String,data:Object):Object{
			switch(type)
			{
				case DisplayImageInfoList:
					return cloneDisplayImageInfoList(data);				
					
				default:
				{
					return null;
				}
			}
		}
		
		private function cloneDisplayImageInfoList(data:Object):Vector.<DisplayImageInfo>
		{
			var tmp:Vector.<DisplayImageInfo> = new Vector.<DisplayImageInfo>();
			var ad:Vector.<DisplayImageInfo> = data as Vector.<DisplayImageInfo>;
			for(var j:int=0;j<ad.length;j++){
				tmp.push(ad[j].clone());
			}
			return tmp;
		}
		
		public static function get instance():ClipBoardManager
		{
			if(!_instance){
				_instance = new ClipBoardManager();
			}
			return _instance;
		}

	}
}