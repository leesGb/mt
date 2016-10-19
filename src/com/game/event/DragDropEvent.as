package com.game.event
{
	import com.game.ui.IDragDropGrid;
	
	import flash.events.Event;
	import flash.geom.Point;
	
	/**
	 * 物品拖动事件 
	 * @author Exin
	 * 
	 */	
	public class DragDropEvent extends Event
	{
		/**拖动*/
		public static const DRAG:String = "拖动";
		
		/**放下*/
		public static const DROP:String = "放下";
		
		/**取消拖动*/
		public static const CANEL:String = "取消拖动";
		
		/**类型不同*/
		public static const CANCEL_TYPE:String = "类型不同";
		
		/**组不同*/
		public static const CANCEL_GROUP:String = "组不同";
		
		/** 拖动源 */
		private var dragTarget:IDragDropGrid;
		
		/** 接收源 */
		private var dropTarget:IDragDropGrid;
		
		/**坐标点*/
		public var mousePostion:Point;
		
		public function DragDropEvent(type:String,dragTarget:IDragDropGrid = null,dropTarget:IDragDropGrid = null,mousePostion:Point = null)
		{
			super(type);
			this.dragTarget = dragTarget;
			this.dropTarget = dropTarget;
			this.mousePostion = mousePostion;
		}
	}
}