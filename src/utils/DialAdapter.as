package utils
{
	import deltax.gui.base.ComponentDisplayStateInfo;
	import deltax.gui.base.DisplayImageInfo;
	import deltax.gui.base.ImageDrawFlag;
	import deltax.gui.base.style.LockFlag;
	import deltax.gui.util.ImageList;
	
	import flash.geom.Rectangle;

	/**
	 * 九宫格适配器
	 **/
	public class DialAdapter
	{
		public static const Sudoku:int= 1;//九宫格
		public static const LMR:int= 2;//左中右
		public static const TMB:int= 3;//上中下
		private static var dialGrids:Vector.<DisplayImageInfo>;//左上，上中，右上，左中，中中，右中，左下，下中，右下	
		private static var _isDial:Boolean;
		private static const ruleNames:Array=["lt","lm","lb","mt","mm","mb","rt","rm","rb"];
		
		//picNames序列和imaeInfo序列一致
		public static function setup(imageList:ImageList,picNames:Array,dialType:int):Boolean{
			if(!isDialPicName(picNames,dialType)){
				return false;
			}
			
			var i:int=0;
			for(i=0;i<imageList.imageCount;i++){
				var disInfo:DisplayImageInfo = imageList.imageInfos[i];
				var picName:String = picNames[i];
				var charaterName:String =picName.substr(picName.length-2); 
				if(charaterName.indexOf(ruleNames[0])!=-1){
					disInfo.lockFlag = LockFlag.LEFT | LockFlag.TOP;							
				}else if(charaterName.indexOf(ruleNames[1])!=-1){
					disInfo.lockFlag = LockFlag.LEFT | LockFlag.BOTTOM | LockFlag.TOP;
				}else if(charaterName.indexOf(ruleNames[2])!=-1){
					disInfo.lockFlag = LockFlag.LEFT | LockFlag.BOTTOM;
				}else if(charaterName.indexOf(ruleNames[3])!=-1){
					disInfo.lockFlag = LockFlag.LEFT | LockFlag.RIGHT | LockFlag.TOP;
				}else if(charaterName.indexOf(ruleNames[4])!=-1){
					disInfo.lockFlag = LockFlag.ALL;
				}else if(charaterName.indexOf(ruleNames[5])!=-1){
					disInfo.lockFlag = LockFlag.LEFT | LockFlag.RIGHT | LockFlag.BOTTOM;
				}else if(charaterName.indexOf(ruleNames[6])!=-1){
					disInfo.lockFlag = LockFlag.RIGHT | LockFlag.TOP;
				}else if(charaterName.indexOf(ruleNames[7])!=-1){
					disInfo.lockFlag = LockFlag.RIGHT | LockFlag.TOP | LockFlag.BOTTOM;
				}else if(charaterName.indexOf(ruleNames[8])!=-1){
					disInfo.lockFlag = LockFlag.RIGHT | LockFlag.BOTTOM;
				}
			}		
			
			changeDrawFlag(imageList);
			return true;
		}
		
		//检查文件名是否为存为九宫格
		private static function isDialPicName(picNames:Array,dialType:int):Boolean{
			var flag:int=0;
			var an:String;
			if(picNames.length==0)return false;
			switch(dialType)
			{
				case Sudoku:					
					for(var i:int=0;i<ruleNames.length;i++){
						for each(an in picNames){
							an = an.substr(an.length-2);
							if(an.indexOf(ruleNames[i])!=-1){
								flag++;
								break;
							}
						}
					}
					return flag==9;
				case LMR:
					for each(an in picNames){
						an = an.substr(an.length-2);
						if(an.indexOf(ruleNames[1])!=-1){
							flag++;							
						}
						if(an.indexOf(ruleNames[4])!=-1){
							flag++;						
						}
						if(an.indexOf(ruleNames[7])!=-1){
							flag++;						
						}
					}
					return flag==3;
				case TMB:
					for each(an in picNames){
						an = an.substr(an.length-2);
						if(an.indexOf(ruleNames[3])!=-1){
							flag++;							
						}
						if(an.indexOf(ruleNames[4])!=-1){
							flag++;						
						}
						if(an.indexOf(ruleNames[5])!=-1){
							flag++;						
						}
					}				
					return flag==3;
			}
			return false;
		}
		
		public static function isDial(imageList:ImageList=null):Boolean
		{						
			//if(imageList && imageList.imageCount!=3 && imageList.imageCount!=9)return false;			
			if(imageList){
				initDialGrids(imageList);
			}
			var flag:Boolean = true;
			//
			for each(var ob:* in dialGrids){
				if(!ob) {
					flag = false;
					break;
				}
			}
			if(flag) return true;
			//
			if(dialGrids[3] && dialGrids[4] && dialGrids[5]) return true;
			if(dialGrids[1] && dialGrids[4] && dialGrids[7]) return true;
			return false;
		}
		
		private static function initDialGrids(imageList:ImageList):void{			
			var dImgInfo:DisplayImageInfo;
			var i:int=0;
			var lens:int=0;
			dialGrids = new Vector.<DisplayImageInfo>(9);//左上，上中，右上，左中，中中，右中，左下，下中，右下
			for(i=0,lens=imageList.imageCount;i<lens;i++){				
				dImgInfo = imageList.getImage(i);
				switch(dImgInfo.lockFlag)
				{
					case LockFlag.LEFT | LockFlag.TOP:
						dialGrids[0]=dImgInfo;break;
					case LockFlag.LEFT | LockFlag.RIGHT | LockFlag.TOP:
						dialGrids[1]=dImgInfo;break;
					case LockFlag.RIGHT | LockFlag.TOP:
						dialGrids[2]=dImgInfo;break;
					//============
					case LockFlag.LEFT | LockFlag.TOP | LockFlag.BOTTOM:
						dialGrids[3]=dImgInfo;break;
					case LockFlag.ALL:
						dialGrids[4]=dImgInfo;break;
					case LockFlag.RIGHT | LockFlag.TOP | LockFlag.BOTTOM:
						dialGrids[5]=dImgInfo;break;
					//============
					case LockFlag.LEFT | LockFlag.BOTTOM:
						dialGrids[6]=dImgInfo;break;
					case LockFlag.LEFT | LockFlag.RIGHT | LockFlag.BOTTOM:
						dialGrids[7]=dImgInfo;break;
					case LockFlag.RIGHT | LockFlag.BOTTOM:
						dialGrids[8]=dImgInfo;break;
				}
			}
		}
		
		private static function check3Dial(imageList:ImageList):void{
			var dImgInfo:DisplayImageInfo;
			var i:int=0;
			var lens:int=0;
			for(i=0,lens=imageList.imageCount;i<lens;i++){
				dImgInfo = imageList.getImage(i);
				dImgInfo.wndRect.width = dImgInfo.textureRect.width;
				dImgInfo.wndRect.height = dImgInfo.textureRect.height;
				switch(dImgInfo.lockFlag)
				{//左1,右2,,上4,   下8
					case LockFlag.LEFT | LockFlag.TOP://左上 5   
						dImgInfo.wndRect.x = 0;
						dImgInfo.wndRect.y = 0;
						break;
					case LockFlag.LEFT | LockFlag.RIGHT | LockFlag.TOP://上中  7
						dImgInfo.wndRect.x = dialGrids[0]!=null?dialGrids[0].wndRect.right:0;
						dImgInfo.wndRect.y = 0;
						break;
					case LockFlag.RIGHT | LockFlag.TOP://右上 6
						dImgInfo.wndRect.x = dialGrids[1]!=null?dialGrids[1].wndRect.right:0;
						dImgInfo.wndRect.y = 0;
						break;
					//============
					case LockFlag.LEFT | LockFlag.TOP | LockFlag.BOTTOM://左中 
						dImgInfo.wndRect.x = 0;
						dImgInfo.wndRect.y = dialGrids[1]!=null?dialGrids[1].wndRect.bottom:0;
						break;
					case LockFlag.ALL://中中
						dImgInfo.wndRect.x = dialGrids[3]!=null?dialGrids[3].wndRect.right:0;
						dImgInfo.wndRect.y = dialGrids[1]!=null?dialGrids[1].wndRect.bottom:0;
						break;
					case LockFlag.RIGHT | LockFlag.TOP | LockFlag.BOTTOM://右中
						dImgInfo.wndRect.x = dialGrids[4]!=null?dialGrids[4].wndRect.right:0;
						dImgInfo.wndRect.y = dialGrids[4]!=null?dialGrids[4].wndRect.y:0;
						break;
					//============
					case LockFlag.LEFT | LockFlag.BOTTOM://左下
						dImgInfo.wndRect.x = 0;
						dImgInfo.wndRect.y = dialGrids[4]!=null?dialGrids[4].wndRect.bottom:0;
						break;
					case LockFlag.LEFT | LockFlag.RIGHT | LockFlag.BOTTOM://下中
						dImgInfo.wndRect.x = dialGrids[4]!=null?dialGrids[4].wndRect.x:0;
						dImgInfo.wndRect.y = dialGrids[4]!=null?dialGrids[4].wndRect.bottom:0;
						break;
					case LockFlag.RIGHT | LockFlag.BOTTOM://右下
						dImgInfo.wndRect.x = dialGrids[4]!=null?dialGrids[4].wndRect.right:0;
						dImgInfo.wndRect.y = dialGrids[4]!=null?dialGrids[4].wndRect.bottom:0;
						break;
				}
				
			}	
		}
				
		
		public static function updateWndRect(imageList:ImageList):void
		{
			var dImgInfo:DisplayImageInfo;
			var i:int=0;
			var lens:int=0;
			//装配					
			initDialGrids(imageList);
			if(isDial()){
				//优先处理,[0],[1],[3],[4]
				if(imageList.imageCount==3){
					check3Dial(imageList);
				}else{
					//order
					var orders:Array = orderTheImageListInfo(imageList);					
					
					//处理					
					for(i=0,lens=imageList.imageCount;i<lens;i++){
						dImgInfo = orders[i];
						if(!dImgInfo)continue;
						dImgInfo.wndRect.width = dImgInfo.textureRect.width;
						dImgInfo.wndRect.height = dImgInfo.textureRect.height;
						switch(dImgInfo.lockFlag)
						{//左1,右2,,上4,   下8
							case LockFlag.LEFT | LockFlag.TOP://左上 5   
								dImgInfo.wndRect.x = 0;
								dImgInfo.wndRect.y = 0;
								break;
							case LockFlag.LEFT | LockFlag.RIGHT | LockFlag.TOP://上中  7
								dImgInfo.wndRect.x = dialGrids[0]!=null?dialGrids[0].wndRect.right:0;
								dImgInfo.wndRect.y = 0;
								break;
							case LockFlag.RIGHT | LockFlag.TOP://右上 6
								dImgInfo.wndRect.x = dialGrids[1]!=null?dialGrids[1].wndRect.right:0;
								dImgInfo.wndRect.y = 0;
								break;
							//============
							case LockFlag.LEFT | LockFlag.TOP | LockFlag.BOTTOM://左中 
								dImgInfo.wndRect.x = 0;
								dImgInfo.wndRect.y = dialGrids[1]!=null?dialGrids[1].wndRect.bottom:0;
								break;
							case LockFlag.ALL://中中
								dImgInfo.wndRect.x = dialGrids[3]!=null?dialGrids[3].wndRect.right:0;
								dImgInfo.wndRect.y = dialGrids[1]!=null?dialGrids[1].wndRect.bottom:0;
								break;
							case LockFlag.RIGHT | LockFlag.TOP | LockFlag.BOTTOM://右中
								dImgInfo.wndRect.x = dialGrids[4]!=null?dialGrids[4].wndRect.right:0;
								dImgInfo.wndRect.y = dialGrids[4]!=null?dialGrids[4].wndRect.y:0;
								break;
							//============
							case LockFlag.LEFT | LockFlag.BOTTOM://左下
								dImgInfo.wndRect.x = 0;
								dImgInfo.wndRect.y = dialGrids[4]!=null?dialGrids[4].wndRect.bottom:0;
								break;
							case LockFlag.LEFT | LockFlag.RIGHT | LockFlag.BOTTOM://下中
								dImgInfo.wndRect.x = dialGrids[4]!=null?dialGrids[4].wndRect.x:0;
								dImgInfo.wndRect.y = dialGrids[4]!=null?dialGrids[4].wndRect.bottom:0;
								break;
							case LockFlag.RIGHT | LockFlag.BOTTOM://右下
								dImgInfo.wndRect.x = dialGrids[4]!=null?dialGrids[4].wndRect.right:0;
								dImgInfo.wndRect.y = dialGrids[4]!=null?dialGrids[4].wndRect.bottom:0;
								break;
						}
					}//end for
					trace('===================');
				}//end else				
			}else{//非九宫格的wndRect
				/**
				 * bug 没有考虑拉伸过的非9宫图片的宽高变化,2013.6.3
				 */
				for(i=0,lens=imageList.imageCount;i<lens;i++){
					dImgInfo = imageList.getImage(i);
					dImgInfo.wndRect.width = dImgInfo.textureRect.width;
					dImgInfo.wndRect.height = dImgInfo.textureRect.height;
				}
			}
			
			dialGrids = null;
		}
		
		private static function orderTheImageListInfo(imageList:ImageList):Array
		{
			var dImgInfo:DisplayImageInfo;
			var orders:Array = [];
			for(var p:int=0;p<imageList.imageCount;p++){				
				dImgInfo = imageList.getImage(p);				
				switch(dImgInfo.lockFlag)
				{//左1,右2,,上4,   下8
					case LockFlag.LEFT | LockFlag.TOP://左上 5   
						orders[0]=dImgInfo;
						break;
					case LockFlag.LEFT | LockFlag.RIGHT | LockFlag.TOP://上中  7
						orders[1]=dImgInfo;
						break;
					case LockFlag.RIGHT | LockFlag.TOP://右上 6
						orders[2]=dImgInfo;
						break;
					//============
					case LockFlag.LEFT | LockFlag.TOP | LockFlag.BOTTOM://左中
						orders[3]=dImgInfo;
						break;
					case LockFlag.ALL://中中
						orders[4]=dImgInfo;
						break;
					case LockFlag.RIGHT | LockFlag.TOP | LockFlag.BOTTOM://右中
						orders[5]=dImgInfo;
						break;
					//============
					case LockFlag.LEFT | LockFlag.BOTTOM://左下
						orders[6]=dImgInfo;
						break;
					case LockFlag.LEFT | LockFlag.RIGHT | LockFlag.BOTTOM://下中
						orders[7]=dImgInfo;
						break;
					case LockFlag.RIGHT | LockFlag.BOTTOM://右下
						orders[8]=dImgInfo;
						break;
					default:						
						break;
				}
			}
			return orders;
		}
		
		private static function changeDrawFlag(imageList:ImageList):void{
			var i:int;
			var lens:int;
			for(i=0,lens=imageList.imageCount;i<lens;i++){				
				var ob:DisplayImageInfo = imageList.imageInfos[i];
				ob.drawFlag = ob.drawFlag | ImageDrawFlag.ZOOM_WHILE_SCALE;					
			}
		}
		
		public static function getUnionRect(imageList:ImageList):Rectangle{
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
	
	}
}