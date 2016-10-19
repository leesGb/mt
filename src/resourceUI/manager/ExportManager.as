package resourceUI.manager
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Rectangle;
	import resourceUI.BigPicVo;
	import resourceUI.ReousrceManagerUI;
	import resourceUI.SmallPicVo;

	public class ExportManager
	{
		private static var m_instance:ExportManager;		
		public function ExportManager()
		{
		}

		public static function get instance():ExportManager
		{
			if(!m_instance) m_instance = new ExportManager();
			return m_instance;
		}
		
		public function exportPicConfig(parentXml:XML):Boolean{
			var fs:FileStream = new FileStream();
			var selectBigName:String = (parentXml as XML).@name;
			if(parentXml){
				var exportXML:XML = parentXml as XML;
				exportXML = exportXML.copy();
				exportXML.@url = BigPicVo.filterUrl(String(exportXML.@url));
				for each(var xl:XML in exportXML.elements()){
					xl.@url = SmallPicVo.filterUrl(String(xl.@url));
				}
				var outXML:XML = <root/>;					
				outXML.appendChild(exportXML);					
				fs.open(new File(ReousrceManagerUI.instance.URL_SMALLPIC_CONFIG+selectBigName+".xml"),FileMode.WRITE);
				fs.writeMultiByte(outXML.toXMLString(),ReousrceManagerUI.CHAR_CODE);
				fs.close();
				return true;
			}
			return false;
		}
		
		public function exportFrame(parentXml:XML):Boolean{
			var fs:FileStream = new FileStream();
			var selectBigName:String = (parentXml as XML).@name;
			if(parentXml){
				var exportXML:XML = parentXml as XML;
				exportXML = exportXML.copy();
				var r:Rectangle=new Rectangle();
				var outXML:XML = <root/>;					
				for each(var xl:XML in exportXML.elements()){
					r.setTo(int(xl.@x),int(xl.@y),int(xl.@width),int(xl.@height));
					var frame:XML =<Frame/>;
					frame.@FileName = String(parentXml.@name)+".png";
					frame.@left = r.left.toString();
					frame.@top = r.top.toString();
					frame.@right = r.right.toString();
					frame.@bottom = r.bottom.toString();
					outXML.appendChild(frame);
				}
				fs.open(new File(ReousrceManagerUI.instance.URL_SMALLPIC_CONFIG+selectBigName+"_frame.xml"),FileMode.WRITE);
				fs.writeMultiByte(outXML.toXMLString(),ReousrceManagerUI.CHAR_CODE);
				fs.close();
				return true;
			}
			return false;
		}
		
		public function exportKey(parentXml:XML):Boolean{
			var fs:FileStream = new FileStream();
			var selectBigName:String = (parentXml as XML).@name;
			if(parentXml){
				var exportXML:XML = parentXml as XML;
				exportXML = exportXML.copy();
				var r:Rectangle=new Rectangle();
				var outXML:XML = <root/>;					
				for each(var xl:XML in exportXML.elements()){
					r.setTo(int(xl.@x),int(xl.@y),int(xl.@width),int(xl.@height));
					var data:XML =<data/>;
					data.@key = String(xl.@name);
					data.@x = r.x.toString();
					data.@y = r.y.toString();
					data.@width = r.width.toString();
					data.@height = r.height.toString();
					outXML.appendChild(data);
				}
				fs.open(new File(ReousrceManagerUI.instance.URL_SMALLPIC_CONFIG+selectBigName+"_key.xml"),FileMode.WRITE);
				fs.writeMultiByte(outXML.toXMLString(),ReousrceManagerUI.CHAR_CODE);
				fs.close();
				return true;
			}
			return false;
		}

	}
}