package resourceUI.manager
{
	import deltax.common.resource.Enviroment;
	import deltax.gui.base.ComponentDisplayItem;
	import deltax.gui.base.ComponentDisplayStateInfo;
	import deltax.gui.base.DisplayImageInfo;
	import deltax.gui.base.WindowCreateParam;
	import deltax.gui.base.WindowResource;
	import deltax.gui.base.style.LockFlag;
	import deltax.gui.util.ImageList;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	
	import mx.controls.Alert;
	import mx.events.Request;
	
	import spark.primitives.Rect;
	
	import utils.DialAdapter;
	import resourceUI.BigPicVo;
	import resourceUI.ReousrceManagerUI;
	import resourceUI.SmallPicVo;

	public class GuiFileManger
	{
		public static const GUI_UPDATE_COMPLETE:String="gui_update_complete";
		public var dispatcher:EventDispatcher = new EventDispatcher();
		private static var _instance:GuiFileManger;
		public function GuiFileManger()
		{			
			_instance = this;
		}

		public static function get instance():GuiFileManger
		{
			if(!_instance) _instance = new GuiFileManger();
			return _instance;
		}
		
		private var url:String = "";
		private var resConfigXml:XML;//源大图配置表
		private var newConfigXml:XML;//更新的大图配置表

		private var delPicList:Array;//待更新的小图列表

		private var defualtFolderStr:String;

		protected var winRes:WindowResource;
		protected var curFile:File;
		public function startUpdate(resConfigURL:String,newConfigXml:XML):void{
			this.newConfigXml = newConfigXml;
			readResConfig(resConfigURL);
			defualtFolderStr = Enviroment.ResourceRootPath + "gui/cfg/";//先测试baseui
		}		
		
		private function readResConfig(resConfigURL:String):void
		{
			var file:File = new File(resConfigURL);
			resConfigURL = file.nativePath;			
			var load:URLLoader = new URLLoader();
			load.dataFormat = URLLoaderDataFormat.TEXT;
			load.load(new URLRequest(resConfigURL));
			load.addEventListener(Event.COMPLETE,onCom);
			load.addEventListener(IOErrorEvent.IO_ERROR,errorHandler);
		}			
		
		protected function errorHandler(event:IOErrorEvent):void
		{
			Alert.show(event.toString());
		}
		
		protected function onCom(event:Event):void
		{								
			resConfigXml = new XML((event.target as URLLoader).data as String);
			(event.target as URLLoader).removeEventListener(Event.COMPLETE,onCom);		
			(event.target as URLLoader).close();
			trace("选中的大图原始配置表加载成功");
			
			//needUpdateSmallPic
			delPicList = getChangeDelPicList();
			trace("delPicList.length",delPicList.length);
			var newBigPicURL:String = String(newConfigXml.@url);
			if(String(newConfigXml.@url)==BigPicVo.decUrl(String(resConfigXml.bigPic[0].@url))){
				if(delPicList.length==0) {
					trace("没有一张变化的小图不执行更新");
					setTimeout(function():void{dispatcher.dispatchEvent(new Event(GUI_UPDATE_COMPLETE));},100);
					return;
				}
			}
			
			//
			var stream:FileStream = new FileStream();
			var datas:ByteArray;
			var filesList:Array = getAllGuiFiles(new File(defualtFolderStr));
			var hasUpdate:Boolean=false;
			for each(var file:File in filesList){
				//
				var updateFlag:int = 0;
				stream.open(file,FileMode.READ);
				datas = new ByteArray();
				stream.readBytes(datas,0,stream.bytesAvailable);
				stream.close();
				winRes = new WindowResource();
				winRes.parse(datas);
				
				trace('file:',file.name);
				
				hasUpdate = changeBigUrl(newBigPicURL);
				if(hasUpdate) {
					updateFlag++;
				}
				hasUpdate = doUpate(winRes,doDataUpdate);
				if(hasUpdate) updateFlag++;
				if(updateFlag==0) continue;//没有更新的文件不用重新写出
				//
				datas = new ByteArray();
				if(!winRes.childCreateParams)
					winRes.childCreateParams = new Vector.<WindowCreateParam>();
				winRes.write(datas);
				stream.open(file,FileMode.WRITE);
				stream.writeBytes(datas,0,datas.bytesAvailable);
				stream.close();
			}
			setTimeout(function():void{dispatcher.dispatchEvent(new Event(GUI_UPDATE_COMPLETE));},100);
		}
		
		/**
		 * 修改大图名
		 */
		private function changeBigUrl(newBigPicURL:String):Boolean			
		{			
			if(!winRes.textureMap) return false;
			newBigPicURL = newBigPicURL.toLocaleLowerCase();
			var flag:Boolean = false;
			var oldUrl:String = BigPicVo.decUrl(String(resConfigXml.bigPic[0].@url));		
			for(var i:int=0;i<winRes.textureMap.length;i++){							
				if(winRes.textureMap[i]==oldUrl){
					winRes.textureMap[i] = newBigPicURL;
					flag = true;
					break;
				}
			}
			return flag;
		}
		
		/**
		 * 主要更新:
		 * 主窗体的width,height
		 * displayItem的 rect
		 * displayItemState的ImageList的textureRect
		 * displayItemState的ImageList的WndRect
		 */
		private function doUpate(winRes:WindowResource,updateHanlder:Function):Boolean
		{	
			var hasUpdated:Boolean = false;
			var hasLastUpdated:Boolean = false;
			var param:WindowCreateParam
			for each(param in winRes.childCreateParams){
				trace('params:',param.id);
				if(param.id=="bg_gold"){
					trace();
				}
				hasUpdated = updateHanlder(param);
				if(hasUpdated) hasLastUpdated = true;
			}			
			param = winRes.createParam;
			trace('params:',param.id||"");			
			hasUpdated = updateHanlder(param);
			if(hasUpdated) hasLastUpdated = true;
			return hasLastUpdated;
		}
		
		/**
		 * 1.检测是否为该大图的小图配置,是寻找对应的textureRect,并修改成新的
		 * 2.检测是否存在九宫格配置 ,修改wndRect
		 * 3.1,2条件调整完毕后，重置width和height影响的wndRect
		 */
		private function doDataUpdate(param:WindowCreateParam):Boolean
		{			
			var hasUpdate:Boolean = false;
			var curUpdate:Boolean = false;
			//dataUpdate
			var dImgInfo:DisplayImageInfo;
			for each(var dItem:ComponentDisplayItem in param.displayItems){
				if(!dItem) continue;
				for each(var dStateInfo:ComponentDisplayStateInfo in dItem.displayStateInfos){
					if(!dStateInfo) continue;
					var stateInfoHasUpdate:Boolean = false;
					for(var j:int=0,len:int=dStateInfo.imageList.imageCount;j<len;j++){
						dImgInfo = dStateInfo.imageList.getImage(j);
						curUpdate = updateTextRect(dImgInfo);
						//if(curUpdate) stateInfoHasUpdate = true;
						if(curUpdate) hasUpdate = true;
					}
					if(stateInfoHasUpdate){//大图由修改过
						DialAdapter.updateWndRect(dStateInfo.imageList);
						//updateWndRect(dStateInfo);
						//if(DialAdapter.isDial(dStateInfo.imageList)){
						var r:Rectangle = DialAdapter.getUnionRect(dStateInfo.imageList);
						if(r){
							if(dItem.rect && (dItem.rect.width!=0 && dItem.rect.height!=0)){//不更新那些依赖这个dItem矩形的wndRect
								updateScale(dStateInfo,dItem.rect.width-r.width,dItem.rect.height-r.height);
							}else{
								updateScale(dStateInfo,param.width-r.width,param.height-r.height);
							}
						}
						//}
					}
				}
			}
			return hasUpdate;
		}
		
		private function getOrignalSize(imageList:ImageList):Rectangle
		{
			var r:Rectangle = new Rectangle(0,0,1,1);
			var dImgInfo:DisplayImageInfo;
			var i:int=0;
			var lens:int=0;
			for(i=0,lens=imageList.imageCount;i<lens;i++){
				dImgInfo = imageList.getImage(i);
				r = r.union(dImgInfo.wndRect);
			}
			return r;
		}
		
		private function updateScale(dStateInfo:ComponentDisplayStateInfo, delWidth:int, delHeight:int):void
		{			
			dStateInfo.imageList.scaleAll(delWidth,delHeight);
		}				
		
		//区分九宫格情况,更新wndRect和textureRect
		private function updateTextRect(dImgInfo:DisplayImageInfo):Boolean
		{		
			var updated:Boolean = false;
			if(!winRes.textureMap){
				trace("winRes.textureMap为null");
				return false;
			}
			if(winRes.textureMap[dImgInfo.textureIndex]!=String(newConfigXml.@url)) return false;
			
			for each(var delVo:DelPicVo in delPicList){
				var vo:SmallPicVo = delVo.oldPicVo;
				var r:Rectangle = dImgInfo.textureRect;
				//if(vo.x==dImgInfo.textureRect.x && 
				//	vo.y==dImgInfo.textureRect.y &&
				//	vo.width==dImgInfo.textureRect.height &&
				//	vo.height==dImgInfo.textureRect.height){//找到原来的那个textureRect
				if(equalRect(vo.x,r.x) && equalRect(vo.y,r.y) && equalRect(vo.width,r.width) && equalRect(vo.height,r.height)){
					vo = delVo.newPicVo;
					dImgInfo.textureRect.x = vo.x;
					dImgInfo.textureRect.y = vo.y;
					dImgInfo.textureRect.width = vo.width;
					dImgInfo.textureRect.height = vo.height;
					//trace(dImgInfo.textureRect);
					updated = true;
					break;
				}
			}
			return updated;
		}
		
		//判断是否为对应的textureRect
		private function equalRect(x1:int,x2:int):Boolean{
			if(Math.abs(x1-x2)<=2){
				return true;
			}
			return false;
		}
		
		//获取要更新的小图列表
		private function getChangeDelPicList():Array
		{			
			var resList:XMLList = resConfigXml.bigPic.elements();
			var newList:XMLList = newConfigXml.elements();
			var target:Array = [];
			for each(var oldXml:XML in resList){
				for each(var newXml:XML in newList){
					if(String(oldXml.@name)!=String(newXml.@name))continue;
										
					if(int(oldXml.@x)!=int(newXml.@x) || int(oldXml.@y)!=int(newXml.@y) || 
						int(oldXml.@width)!=int(newXml.@width) || int(oldXml.@height)!=int(newXml.@height)){
						var sfd:* = ReousrceManagerUI.picList;
						var tmpURL:String = String(newXml.@url);//Global.flaPath.replace(/\//g,"\\")+
						tmpURL = tmpURL.toLocaleLowerCase();
						target.push(new DelPicVo(oldXml,ReousrceManagerUI.picList[tmpURL]));						
					}
					break;
				}
			}
			return target;
		}
		
		public function getAllGuiFiles(folder:File):Array
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
		
		private var deleteTarget:Object="";//{rect,}
		private var deleteTargetQuote:String="";//被引用的位置		
		/**
		 *是否被gui文件调用要删除的图片 
		 * @param deleteTarget
		 * @return 
		 * 
		 */		
		public function checkIsBeCall(deleteTarget:Object):String{
			this.deleteTarget = deleteTarget;
			deleteTargetQuote="";			
			defualtFolderStr = Enviroment.ResourceRootPath + "gui/cfg/";//先测试baseui
			var stream:FileStream = new FileStream();
			var datas:ByteArray;		
			var filesList:Array = getAllGuiFiles(new File(defualtFolderStr));
			for each(var file:File in filesList){
				//
				stream.open(file,FileMode.READ);
				datas = new ByteArray();
				stream.readBytes(datas,0,stream.bytesAvailable);
				stream.close();
				winRes = new WindowResource();
				winRes.parse(datas);
				curFile = file;
				doUpate(winRes,doDeleteDataCheck);				
			}
			return deleteTargetQuote;
		}
		
		private function doDeleteDataCheck(param:WindowCreateParam):Boolean{
			//
			var dImgInfo:DisplayImageInfo;
			var r:Rectangle=deleteTarget.rect;
			for each(var dItem:ComponentDisplayItem in param.displayItems){
				if(!dItem) continue;
				for each(var dStateInfo:ComponentDisplayStateInfo in dItem.displayStateInfos){
					if(!dStateInfo) continue;
					for(var j:int=0,len:int=dStateInfo.imageList.imageCount;j<len;j++){
						dImgInfo = dStateInfo.imageList.getImage(j);						
						if(winRes.textureMap && winRes.textureMap[dImgInfo.textureIndex]==deleteTarget.url.toLocaleLowerCase()){
							if(dImgInfo.textureRect.equals(r)){
								deleteTargetQuote+=curFile.nativePath.substr(Enviroment.ResourceRootPath.length)+"的"+param.id+"引用\n";
							}
						}
					}				
				}
			}
			return true;
		}			

	}
}
import resourceUI.SmallPicVo;

class DelPicVo{
	public var oldPicVo:SmallPicVo;
	public var newPicVo:SmallPicVo;
	
	public function DelPicVo(axml:XML,newVo:SmallPicVo){
		oldPicVo = new SmallPicVo();
		oldPicVo.fileName = String(axml.@name);
		oldPicVo.width = int(axml.@width);
		oldPicVo.height = int(axml.@height);
		oldPicVo.y = int(axml.@y);
		oldPicVo.x = int(axml.@x);
		oldPicVo.fileUrl = String(axml.@url);
		oldPicVo.parent = newVo.parent;
		oldPicVo.area = oldPicVo.width*oldPicVo.height;
		
		this.newPicVo = newVo;
	}
}