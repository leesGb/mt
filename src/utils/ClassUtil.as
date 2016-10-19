package utils
{
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;

	/**
	 * 该类用于提取引擎常量数据类中的数据
	 */
	public class ClassUtil
	{
		public static var SUB_PACKAGE:String="deltax.gui.component.subctrl.";
		public static var STYLE_PACKAGE:String="deltax.gui.base.style.";
		public static var WINDOW_CLASS:String = "deltax.gui.base";
		private static var classXml:Dictionary = new Dictionary();
		/**
		 * 
		 * @param value 常量值(只适用用整形的常量值)
		 * @param className 包括包路径的指定类名称
		 * @return 返回常量名称
		 * 
		 */		
		public static function getConstNameByValue(value:int, className:String):String
		{
			var xml:XMLList;
			if(classXml[className]!=null){
				xml = classXml[className]; 				
			}else{
				var cls:Class = flash.utils.getDefinitionByName(className) as Class;
				xml = describeType(cls).children();
			}
			for each (var xl:XML in xml)
			{
				if (xl.name() == "constant")
				{
					if (cls[String(xl.@name)] == value)
					{
						return xl.@name;
					}
				}
			}
			return "";
		}	
		
		/**
		 * 
		 * @param className 包括包路径的指定类名称
		 * @return 所有常量名称列表的XMLList,用@name可以找到常量名称
		 * 
		 */		
		public static function getConstXMLList(className:String):XMLList{
			var xml:XMLList;
			if(classXml[className]!=null){
				xml = classXml[className]; 				
			}else{
				var cls:Class = flash.utils.getDefinitionByName(className) as Class;
				xml = describeType(cls).children();
			}
			var i:int=0;
			var list:XML = <root/>;
			for each (var xl:XML in xml)
			{
				if (xl.name() == "constant")
				{
					list.appendChild(xl);
				}
			}
			return list.children();
		}
		
		public static function getConstList(className:String):Array{
			var tmp:Array=[];
			var xml:XMLList = getConstXMLList(className);
			for each(var xl:XML in xml){
				tmp.push(String(xl.@name));
			}
			return tmp;
		}
	}
}