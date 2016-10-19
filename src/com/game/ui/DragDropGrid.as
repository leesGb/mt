package com.game.ui
{
	import com.game.manager.DragDropManager;
	
	import deltax.gui.component.DeltaXButton;
	import deltax.gui.component.DeltaXWindow;
	
	import flash.geom.Point;

	/**
	 * 拖动格子
	 * @author Exin
	 * 
	 */	
	public class DragDropGrid extends DeltaXButton implements IDragDropGrid
	{
		
		private var m_item:IDragDropItem;
		private var m_isEmpty:Boolean = true;
		private var m_localDragDrop:Boolean = false;
		private var m_itemOffsetPoint:Point = new Point();
		private var m_id:String;
		private var m_groupName:String;
		private var m_locked:Boolean = false;
		private var m_canDrop:Boolean = true;
		private var m_canDrag:Boolean = true;
		private var m_canDropTypeArray:Array=[];
		private var m_data:Object = null;
		
		public function DragDropGrid()
		{
			this.mouseChildren = false;
		}
		
		/**
		 * 获取当前是否有物品,true:空
		 * @return Boolean
		 */
		public function get isEmpty():Boolean
		{
			return m_isEmpty;
		}
		public function set isEmpty(value:Boolean):void
		{
			m_isEmpty = value;
		}
		
		public function get data():Object
		{
			return m_data;
		}
		
		public function set data(value:Object):void
		{
			m_data = value;
		}
		
		
		/**
		 * 组名
		 */
		public function get groupName():String
		{
			return m_groupName;
		}
		
		public function set groupName(value:String):void
		{
			m_groupName = value;
		}
		
		/**
		 * 格子ID
		 */
		public function get id():String
		{
			return m_id;
		}
		
		public function set id(value:String):void
		{
			m_id = value;
		}
		
		/**
		 * 能放下的拖动对象类型数组
		 */
		public function get canDropTypeArray():Array
		{
			return m_canDropTypeArray;
		}
		public function set canDropTypeArray(value:Array):void
		{
			m_canDropTypeArray = value ;
		}
		/**
		 * 拖动对象
		 */
		public function get item():IDragDropItem
		{
			return m_item;
		}
		
		public function set item(value:IDragDropItem):void
		{
			if (!value) {
				return;
			}
			if(m_item)
			{
				removeItem();
			}
			m_item = value;
			addChild(DeltaXWindow(m_item));
			
			m_isEmpty = false;
			
		}
		
		/**
		 * 能否放下 true:能
		 */
		public function get canDrop():Boolean
		{
			return m_canDrop;
		}
		public function set canDrop(value:Boolean):void
		{
			m_canDrop=value;
		}
		
		/**
		 * 能否拖动 true:能
		 */
		public function get canDrag():Boolean
		{
			return m_canDrag;
		}
		public function set canDrag(value:Boolean):void
		{
			m_canDrag = value;
		}
		
		/**
		 * 锁定 true
		 */
		public function get locked():Boolean
		{
			return m_locked;
		}
		public function set locked(value:Boolean):void
		{
			if (m_locked == value) {
				return;
			}
			m_locked = value;
		}
		
		
		/**
		 * 格子物品偏移坐标点
		 */
		public function set itemOffsetPoint(value:Point):void
		{
			m_itemOffsetPoint.x = value.x;
			m_itemOffsetPoint.y = value.y;
			
		}
		
		public function get itemOffsetPoint():Point
		{
			return m_itemOffsetPoint;
		}
		
		
		/**
		 * 获取拖动的显示对象
		 * @return EDragDropGood
		 */
		public function getDragCopyDisplay():DeltaXWindow
		{
			if (item && !isEmpty) {
				return item.getCopyDisplay();
			}
			return null;
		}
		
		/**
		 * 移除格子item,清空格子
		 */
		public function removeItem():void
		{
			if(m_item)
			{
				this.removeChild(DeltaXWindow(m_item));
			}
			m_item = null;
			m_isEmpty = true;
		}
		
		
		/**
		 * 取消拖动
		 * @return void
		 */
		public function cancelDrag():void
		{
			if (item) {
				m_isEmpty = false;
			}
		}
		
		/**
		 * 让格子拥有拖动接收拖动放下功能
		 */
		public function addDragDropItem():void
		{
			DragDropManager.instance.addItem(this, this.groupName);
		}
		
		
		protected function drawLayout():void 
		{
			
		}
		
	}
}