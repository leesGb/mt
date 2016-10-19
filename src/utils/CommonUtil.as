package utils
{
	import deltax.gui.base.ComponentDisplayItem;
	import deltax.gui.base.ComponentDisplayStateInfo;
	import deltax.gui.component.DeltaXWindow;
	import deltax.gui.component.subctrl.CommonWndSubCtrlType;
	
	import displayUI.DisplayItemManager;
	import displayUI.select.SelectView;
	
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * 公共工具类
	 */
	public class CommonUtil
	{
		public function CommonUtil()
		{
		}
		
		/**
		 * 十进制转换成16进制数字字符
		 */
		public static function toBin(color:uint):String{
			var str:String=color.toString(16);
			str = str.toUpperCase();
			var del:int = 8-str.length;
			var i:int;
			if(del>=0){
				for(i=0;i<del;i++){
					str = "0"+str;
				}
				return "0x"+str;
			}
			return null;
		}
		
		/**
		 * 16进制数字字符转换成10进制整形
		 */
		public static function parseBin(color:String):uint{			
			return uint(color);
		}
		
		//获取gui的bounds。包括所有子对象的
		public static function getGuiBounds(gui:DeltaXWindow):Rectangle
		{
			var rect:Rectangle = gui.globalBounds;
			var child:DeltaXWindow =  gui.childTopMost;
			while (child) {
				//check
				rect = rect.union(child.globalBounds);
				child = child.brotherBelow;
			}
			return rect;
		}
		
		public static function updateSelectProperties():void
		{
			for(var i:int=0;i<SelectView.instance.selectGuiArr.length;i++)
			{
				updateProperties(SelectView.instance.selectGuiArr[i]);
			}
		}
		public static function updateProperties(gui:DeltaXWindow):void
		{
			if(gui.x != gui.properties.x)
			{
				gui.properties.x = gui.x;
			}
			if(gui.y != gui.properties.y)
			{
				gui.properties.y = gui.y;
			}
			var tmp:Point = new Point(gui.properties.width,gui.properties.height);
			var changed:Boolean = false; 
			if(gui.width != gui.properties.width)
			{
				gui.properties.width = gui.width;
				changed = true;
			}
			if(gui.height != gui.properties.height)
			{
				gui.properties.height = gui.height;
				changed = true;
			}
			if(changed){
				setWindowSize(gui,gui.width-tmp.x,gui.height-tmp.y);
			}
		}
		
		public static function setWindowSize(window:DeltaXWindow,delWidth:int,delHeight:int):void{
			if(window.properties.displayItems){
				var dItem:ComponentDisplayItem = window.properties.displayItems[CommonWndSubCtrlType.BACKGROUND-1];
				if(dItem){
					for each(var dStateItem:ComponentDisplayStateInfo in dItem.displayStateInfos){
						if(!dStateItem)continue;
						dStateItem.imageList.scaleAll(delWidth,delHeight);														
					}																				
				}
				
				DisplayItemManager.instance.setToRect(window);											
			}
		}
	}
}