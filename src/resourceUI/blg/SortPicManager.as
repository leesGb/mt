package resourceUI.blg
{
	import flash.display.Bitmap;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import resourceUI.SmallPicVo;
	import resourceUI.blg.LowerBenchSort;

	public class SortPicManager
	{
		public static const BLG_BP:int =1;//下台阶算法
		private static var _instance:SortPicManager;
		private var bpFactory:LowerBenchSort;
		public function SortPicManager()
		{
			bpFactory = new LowerBenchSort();
		}
		
		public function sortElementList(srcList:Array):Array{
			var list:Array=[];
			
			return list;
		}
		
		public function getSolution(maxSize:Point,srcList:Array,blgType:int=BLG_BP):Boolean{
			bpFactory.getSolution(maxSize,srcList);
			return !bpFactory.isCrossBorder;
		}
		
		public static function get instance():SortPicManager
		{
			if(!_instance){
				_instance = new SortPicManager();
			}
			return _instance;
		}

	}
}
