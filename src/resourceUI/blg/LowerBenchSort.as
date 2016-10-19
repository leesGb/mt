package  resourceUI.blg
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import resourceUI.SmallPicVo;

	/**
	 * 下台阶算法
	 * @author beuady
	 */
	public class LowerBenchSort 
	{
		private var sortedList:Vector.<Rectangle>;
		private const GAP:int = 3;//间隔像素
		private const MGAP:int = 1;//四周拉伸1个像素
		private var maxSize:Point;
		private var curVo:Rectangle = new Rectangle();
		private var leftLine:Rectangle;
		private var bottomLine:Rectangle;
		private var picVo:SmallPicVo;
		public var isCrossBorder:Boolean = false;//是否没越界
		public var ativeArea:Number;
		private var maxRight:int;
		private var maxBottom:int;
		public function LowerBenchSort() 
		{
			sortedList = new Vector.<Rectangle>();
		}
		
		public function getSolution(maxSize:Point, targetList:Array):Array {
			this.maxSize = maxSize;
			init();
			for (var i:int = 0; i < targetList.length; i++) {				
				this.picVo = targetList[i];
				//至于最右最高处
				toTopRight();
				godown();
				trace(picVo.x,picVo.y,picVo.width,picVo.height);
				maxRight = maxRight<curVo.right?curVo.right:maxRight;
				maxBottom = maxBottom<curVo.bottom?curVo.bottom:maxBottom;
			}
			if(!isCrossBorder)
				ativeArea = maxRight*maxBottom/maxSize.x/maxSize.y;
			return targetList;
		}
		
		private function toTopRight():void 
		{
			picVo.x = maxSize.x-picVo.width;
			picVo.y = maxSize.y;
			curVo.setTo(picVo.x, picVo.y, picVo.width+GAP, picVo.height+GAP);
		}
		
		private function godown():void {
			var maxHRect:Rectangle = getMaxHRect(curVo.x, curVo.right);
			curVo.y = maxHRect.bottom;
			if(curVo.x>MGAP){
				goleft();
			}else {
				sortedOne();
			}
		}
		
		private function goleft():void {
			var movedX:int = getMaxXRect(curVo.y, curVo.bottom);
			curVo.x = movedX;			
			var maxHR:Rectangle = getMaxHRect(curVo.x, curVo.right);
			if (maxHR.bottom < curVo.y) {
				godown();
			}else {//最左下了
				sortedOne();
			}
		}
		
		private function sortedOne():void {
			if (isCrossBorder) return;
			var newVo:Rectangle = new Rectangle();			
			newVo.copyFrom(curVo);
			sortedList.push(newVo);
			
			picVo.x = newVo.x;
			picVo.y = newVo.y;
			if (picVo.x + picVo.width > maxSize.x ||
				picVo.y +picVo.height > maxSize.y) {
				isCrossBorder = true;
			}
		}
		
		/**
		 * 获取maxH高的时候，最左的不可碰撞位置x
		 * @param	maxH
		 * @return
		 */
		private function getMaxXRect(startH:int,endH:int):int
		{
			var leftX:int = leftLine.x;
			for (var i:int = 0; i < sortedList.length; i++) {
				var vo:Rectangle = sortedList[i];				
				if (vo.y >= endH || vo.bottom <= startH) {
					
				}else {
					if (vo.right > leftX && (vo.right+curVo.width) <= curVo.right) {
						leftX = vo.right;
					}
				}
			}
			return leftX;
		}
		
		private function getMaxHRect(startX:int,endX:int):Rectangle {
			var maxRect:Rectangle = bottomLine;
			for (var i:int = 0; i < sortedList.length; i++) {
				var vo:Rectangle = sortedList[i];
				if (vo.right <= startX || vo.x >= endX) {
					
				}else{
					if (vo.bottom > maxRect.bottom && vo.bottom < curVo.bottom) {
						maxRect = vo;
					}
				}
			}
			return maxRect;
		}
		
		private function init():void {
			ativeArea = 0;
			maxRight = 0;
			maxBottom = 0;
			isCrossBorder = false;
			sortedList.length = 0;
			leftLine = new Rectangle(MGAP, 0, 0, maxSize.y);
			bottomLine = new Rectangle(0,MGAP,maxSize.x,0);
			sortedList.push(leftLine);
			sortedList.push(bottomLine);
		}
		
	}
	
}