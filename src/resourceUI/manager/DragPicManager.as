package resourceUI.manager
{
	import deltax.common.resource.Enviroment;
	import deltax.graphic.manager.DeltaXTextureManager;
	import deltax.gui.base.ComponentDisplayItem;
	import deltax.gui.base.ComponentDisplayStateInfo;
	import deltax.gui.base.DisplayImageInfo;
	import deltax.gui.base.WindowCreateParam;
	import deltax.gui.base.WindowResource;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.errors.IOError;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import mx.controls.Alert;
	import mx.graphics.codec.PNGEncoder;
	import resourceUI.BigPicVo;
	import resourceUI.ReousrceManagerUI;
	import resourceUI.SmallPicVo;

	public class DragPicManager
	{
		private static var _instance:DragPicManager;
		private var dragItemResConfig:XML;
		private var dragItemBigUrl:String;
		private var dragItems:Array;
		private static const DEBUG:Boolean = false;

		private var newItems:Array;
		private var newItemBigUrl:String;
		private var targetConfig:XML;
		private var defualtFolderStr:String;
		private var winRes:WindowResource;
		private var delPicList:Array;//待更新的小图列表

		private var newSmallVoUrl:String;
		public function DragPicManager()
		{			
		}
		
		public function checkIsFull(xmlDatas:Array,parentXML:XML):Boolean{
			var tmpVo:SmallPicVo = ReousrceManagerUI.picList[String(parentXML.smallPic[0].@url)];			
			var pVo:BigPicVo = tmpVo.parent;
			var vo:SmallPicVo;
			var xl:XML;
			var tmpList:Dictionary = new Dictionary();
			for each(xl in xmlDatas){
				vo = ReousrceManagerUI.picList[String(xl.@url)];
				if(vo){
					tmpList[vo.fileUrl] =  vo;
				}
			}
			//检测面积是否可填充新图
			var flag:Boolean = ReousrceManagerUI.instance.checkIsFull(tmpList,pVo.bitmap,new Point(int(parentXML.@width),int(parentXML.@height)));
			return flag;
		}
		
		public function dragPicXML(xmlDatas:Array,parentXML:XML,resParentXML:XML):void{			
			var loaded:Boolean = loadResConfig(parentXML.@name,resParentXML.@name);
			if(!loaded){
				Alert.show("加载源配置文件失败,请重新载入");
				return;
			}			
			dragItemBigUrl = String(resParentXML.@url).toLocaleLowerCase();
			newItemBigUrl = String(parentXML.@url).toLocaleLowerCase();
			this.dragItems = [];
			for each(var xl:XML in xmlDatas){
				dragItems.push(xl.copy());
			}
			if(!updatePicVoData(xmlDatas,parentXML)) return;//检测是否越界
			updateGuiFiles(parentXML.@url);
			clearCacheTexture();
			Alert.show("调整成功!");
		}	
		
		private function clearCacheTexture():void
		{
			
			var ob:* = DeltaXTextureManager.instance.createTexture(dragItemBigUrl);
			DeltaXTextureManager.instance.unregisterTexture(ob);
			var ob2:* = DeltaXTextureManager.instance.createTexture(newItemBigUrl);
			DeltaXTextureManager.instance.unregisterTexture(ob2);
		}
		
		private function updateGuiFiles(parentXMLUrl:String):void
		{
			//获取最新配置数据			
			newItems = getNewXmlItems(parentXMLUrl);
			delPicList=[];
			delPicList = getChangeDelPicList(dragItemResConfig,ReousrceManagerUI.instance.resData.source.bigPic.(@url==dragItemBigUrl)[0]);
			delPicList = delPicList.concat(getChangeDelPicList(targetConfig,ReousrceManagerUI.instance.resData.source.bigPic.(@url==newItemBigUrl)[0]));
			
			//遍历所有gui文件
			defualtFolderStr = Enviroment.ResourceRootPath + "gui/cfg/";//先测试baseui
			
			var stream:FileStream = new FileStream();
			var datas:ByteArray;		
			var filesList:Array = getAllGuiFiles(new File(defualtFolderStr));
			var hasUpdate:Boolean=false;
			for each(var file:File in filesList){
				//
				stream.open(file,FileMode.READ);
				datas = new ByteArray();
				stream.readBytes(datas,0,stream.bytesAvailable);
				stream.close();
				winRes = new WindowResource();
				winRes.parse(datas);
				
				hasUpdate = doUpate(winRes,doTextureRectUpdate);
				if(!hasUpdate) continue;//没有更新的文件不用重新写出
				//
				datas = new ByteArray();
				if(!winRes.childCreateParams)
					winRes.childCreateParams = new Vector.<WindowCreateParam>();
				winRes.write(datas);
				stream.open(file,FileMode.WRITE);
				stream.writeBytes(datas,0,datas.bytesAvailable);
				stream.close();
			}
		}
		
		private function getNewXmlItems(parentXMLUrl:String):Array
		{
			var tmp:Array=[];
			var parentXML:XML = ReousrceManagerUI.instance.resData.source.bigPic.(@url==parentXMLUrl)[0];
			var step:int=0;
			for each(var xl:XML in parentXML.elements()){
				var oldXl:XML = dragItems[step];
				if(oldXl){
					if(String(xl.@name)==String(oldXl.@name)){
						tmp.push(xl);
						step++;
					}
				}else{
					break;
				}
			}
			return tmp;
		}
		
		private function doUpate(winRes:WindowResource,updateHanlder:Function):Boolean
		{	
			var hasUpdated:Boolean = false;
			var hasLastUpdated:Boolean = false;
			var param:WindowCreateParam
			for each(param in winRes.childCreateParams){
				hasUpdated = updateHanlder(param);
				if(hasUpdated) hasLastUpdated = true;
			}			
			param = winRes.createParam;
			hasUpdated = updateHanlder(param);
			if(hasUpdated) hasLastUpdated = true;
			return hasLastUpdated;
		}
		
		//没有考虑其他图片位置
		private function doTextureRectUpdate(param:WindowCreateParam):Boolean
		{			
			var hasUpdate:Boolean = false;
			var curUpdate:Boolean = false;
			//dataUpdate
			var dragIndex:int=0;
			var newIndex:int=0;
			var dImgInfo:DisplayImageInfo;
			var tmpRect:Rectangle = new Rectangle();
			for each(var dItem:ComponentDisplayItem in param.displayItems){
				if(!dItem) continue;
				for each(var dStateInfo:ComponentDisplayStateInfo in dItem.displayStateInfos){
					if(!dStateInfo) continue;
					for(var j:int=0,len:int=dStateInfo.imageList.imageCount;j<len;j++){
						dImgInfo = dStateInfo.imageList.getImage(j);
						//update 位置
						curUpdate = updateTexture(dImgInfo);						
						if(curUpdate) hasUpdate = true;
					}					
				}
			}
			return hasUpdate;
		}
		
		private function updateTexture(dImgInfo:DisplayImageInfo):Boolean
		{		
			var updated:Boolean = false;
			if(!winRes.textureMap){return false;}			
			for each(var delVo:DelPicVo in delPicList){
				var vo:SmallPicVo = delVo.oldPicVo;
				var r:Rectangle = dImgInfo.textureRect;				
				if(equalRect(vo.x,r.x) && equalRect(vo.y,r.y) && equalRect(vo.width,r.width) && equalRect(vo.height,r.height)){
					if(winRes.textureMap.indexOf(newItemBigUrl)==-1){
						var ss:* = new Vector.<String>();
						ss.push(newItemBigUrl);
						winRes.textureMap = winRes.textureMap.concat(ss);
					}					
					vo = delVo.newPicVo;
					dImgInfo.textureRect.x = vo.x;
					dImgInfo.textureRect.y = vo.y;
					dImgInfo.textureRect.width = vo.width;
					dImgInfo.textureRect.height = vo.height;
					
					if(delVo.needChangeTextureIndex){
						/*危险操作*/
						dImgInfo.textureIndex = winRes.textureMap.indexOf(newItemBigUrl);
					}
					updated = true;
					break;
				}
			}
			return updated;
		}
		
		private function equalRect(x1:int,x2:int):Boolean{
			if(Math.abs(x1-x2)<=2){
				return true;
			}
			return false;
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
		
		//获取要更新的小图列表
		private function getChangeDelPicList(oldConfigXml:XML,newConfigXml:XML):Array
		{			
			var oldList:XMLList = oldConfigXml.bigPic.elements();
			var newList:XMLList = newConfigXml.elements();
			var target:Array = [];
			var tmpURL:String;
			for each(var oldXml:XML in oldList){
				var existAtNew:Boolean = false;
				for each(var newXml:XML in newList){					
					if(String(oldXml.@name)==String(newXml.@name)){
						if(int(oldXml.@x)!=int(newXml.@x) || int(oldXml.@y)!=int(newXml.@y) || 
							int(oldXml.@width)!=int(newXml.@width) || int(oldXml.@height)!=int(newXml.@height)){
							var sfd:* = ReousrceManagerUI.picList;
							tmpURL = String(newXml.@url);
							tmpURL = tmpURL.toLocaleLowerCase();
							target.push(new DelPicVo(oldXml,ReousrceManagerUI.picList[tmpURL]));						
						}
						existAtNew = true;
						break;
					}
				}
				if(!existAtNew){//新配置表的没有当前小图
					tmpURL = SmallPicVo.decUrl(oldXml.@url);
					tmpURL = tmpURL.toLocaleLowerCase();
					var delVo:DelPicVo = new DelPicVo(oldXml,ReousrceManagerUI.picList[tmpURL]);
					delVo.needChangeTextureIndex = true;
					target.push(delVo);
				}
			}									
			return target;
		}
		
		private function updatePicVoData(xmlDatas:Array,parentXML:XML):Boolean
		{
			//小图vo
			var tmpVo:SmallPicVo = ReousrceManagerUI.picList[String(parentXML.smallPic[0].@url)];
			//没有小图情况
			if(!tmpVo){
				var tmpParent:BigPicVo = new BigPicVo(String(parentXML.@name),String(parentXML.@url));
				tmpParent.bitmap = new Bitmap();
				tmpParent.bitmap.bitmapData = new BitmapData(int(parentXML.@width),int(parentXML.@height),true,0xFFFFFF);
				tmpVo = new SmallPicVo();
				tmpVo.parent =  tmpParent;
				tmpVo.fileName = "tmp";
				tmpVo.fileUrl = Global.flaPath+String(parentXML.@name)+"\\"+tmpVo.fileName+".png";
			}
			var pVo:BigPicVo = tmpVo.parent;
			var oldPVo:BigPicVo;
			var xl:XML;
			var vo:SmallPicVo;						
			for each(xl in xmlDatas){
				vo = ReousrceManagerUI.picList[String(xl.@url)];
				if(vo){
					oldPVo = vo.parent;
					vo.parent = pVo;
					//ReousrceManagerUI.picList[String(xl.@url)] = null;
					//newSmallVoUrl = tmpVo.fileUrl.substr(0,tmpVo.fileUrl.indexOf(tmpVo.fileName));
					//vo.fileUrl =  newSmallVoUrl+vo.fileName+".png";
					//vo.fileUrl = vo.fileUrl.toLocaleLowerCase();					
					//ReousrceManagerUI.picList[vo.fileUrl] = vo;
					//var nowParent:XML = ReousrceManagerUI.instance.resData.source.bigPic.(@name==parentXML.@name)[0];
					//nowParent.smallPic.(@name==vo.fileName)[0].@url = vo.fileUrl;					
				}
			}
			
			//大图bitmap
			var sortSuccess1:Boolean;
			var sortSuccess2:Boolean;
			ReousrceManagerUI.instance.SIZE.setTo(oldPVo.bitmap.width,oldPVo.bitmap.height);
			sortSuccess1 = ReousrceManagerUI.instance.SortAPic(oldPVo.bitmap);
			ReousrceManagerUI.instance.SIZE.setTo(pVo.bitmap.width,pVo.bitmap.height);
			sortSuccess2 = ReousrceManagerUI.instance.SortAPic(pVo.bitmap);
			if(!sortSuccess1 || !sortSuccess2) return false;//检测是否越界,false为越界了
			//更新视图树列表
			ReousrceManagerUI.instance.updateTreeNode();
			
			if(DEBUG) return true;
//			//图片文件更新
			exportPNG(oldPVo.bitmap.bitmapData,ReousrceManagerUI.instance.URL_BIGPIC+oldPVo.name+".png");
			exportPNG(pVo.bitmap.bitmapData,ReousrceManagerUI.instance.URL_BIGPIC+pVo.name+".png");
			//moveSmallPics(dragItems,parentXML);
			
			//更新xml配置表			
			var dss:* = ReousrceManagerUI.instance.resData.source.bigPic.(@name==oldPVo.name)[0];
			var dee:* = ReousrceManagerUI.instance.resData.source.bigPic.(@name==pVo.name)[0];
			ReousrceManagerUI.instance.exportXmlConfig(dss);
			ReousrceManagerUI.instance.exportXmlConfig(dee);
			return true;
		}
		
		private function moveSmallPics(xmlDatas:Array, parentXML:XML):void
		{
			var tmpVo:SmallPicVo = ReousrceManagerUI.picList[String(parentXML.smallPic[0].@url)];
			var xl:XML;
			for each(xl in xmlDatas){			
				var vo:SmallPicVo = ReousrceManagerUI.picList[tmpVo.fileUrl];
				if(vo){
					var targetUrl:String = tmpVo.fileUrl.substr(0,tmpVo.fileUrl.indexOf(tmpVo.fileName));
					movePNGFile(SmallPicVo.decUrl(String(xl.@url)),targetUrl);
				}
			}
		}
		
		public static function get instance():DragPicManager
		{
			if(!_instance) _instance = new DragPicManager();				
			return _instance;
		}
		
		public function exportPNG(curPic:BitmapData,fileUrl:String):void{
			var fs:FileStream = new FileStream();
			var test:PNGEncoder= new PNGEncoder();
			var bin:ByteArray = test.encode(curPic);
			fs.open(new File(fileUrl),FileMode.WRITE);
			fs.writeBytes(bin,0,bin.bytesAvailable);
			fs.close();
		}
		
		public function movePNGFile(srcFile:String,desFileUrl:String):Boolean{
			try{
			var file:File = new File(srcFile);
			if(file.exists){
				var desFolder:File = new File(desFileUrl+file.name);
				if(desFolder.exists){
					//Alert.show(desFolder.nativePath+"文件被覆盖");
				}
				file.moveTo(desFolder,false);
				return true;				
			}
			}catch(e:IOError){
				Alert.show(file.nativePath+"文件移动失败");				
			}
			Alert.show(file.nativePath+"文件移动失败,文件不存在");
			return false;
		}
		
		private function loadResConfig(targetConfigName:String,resConfigName:String):Boolean{
			try{
			var fs:FileStream = new FileStream();
			fs.open(new File(Global.flaPath+"uiconfig/"+resConfigName+".xml"),FileMode.READ);
			var str:String = fs.readMultiByte(fs.bytesAvailable,"utf-8");
			dragItemResConfig = new XML(str);			
			fs.close();
			fs.open(new File(Global.flaPath+"uiconfig/"+targetConfigName+".xml"),FileMode.READ);
			var str2:String = fs.readMultiByte(fs.bytesAvailable,"utf-8");
			targetConfig = new XML(str2);
			fs.close();
			}catch(e:Error){
				return false;
			}
			return true;
		}

	}
}

import resourceUI.SmallPicVo;

class DelPicVo{
	public var oldPicVo:SmallPicVo;
	public var newPicVo:SmallPicVo;
	public var needChangeTextureIndex:Boolean=false;
	public function DelPicVo(axml:XML,newVo:SmallPicVo){
		oldPicVo = new SmallPicVo();
		oldPicVo.fileName = String(axml.@name);
		oldPicVo.width = int(axml.@width);
		oldPicVo.height = int(axml.@height);
		oldPicVo.y = int(axml.@y);
		oldPicVo.x = int(axml.@x);
		var tmp:String = String(axml.@url);
		if(tmp.indexOf(Global.flaPath)==-1){
			oldPicVo.fileUrl = Global.flaPath+tmp;
		}else{
			oldPicVo.fileUrl =tmp;
		}
		oldPicVo.parent = newVo.parent;
		oldPicVo.area = oldPicVo.width*oldPicVo.height;
		
		this.newPicVo = newVo;
	}
}