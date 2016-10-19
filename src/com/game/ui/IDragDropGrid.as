package com.game.ui
{
	import deltax.gui.component.DeltaXWindow;
	
	import flash.geom.Point;

	/**
	 * 拖动格子接口 
	 * @author Exin
	 * 
	 */	
	public interface IDragDropGrid
	{
		/**
		 * 格子是否为空
		 * @get
		 * @return	true:空
		 */
		function get isEmpty():Boolean;
		
		/**
		 * 获取格子容器数据
		 * @get
		 * @return	Object
		 */
		function get data():Object;
		
		/**
		 * 获取组名
		 * @get
		 * @return	String
		 */
		function get groupName():String;
		
		function set groupName(value:String):void;
		
		/**
		 * 获取 能放入该格子类型数组
		 * @get
		 * @return	Array
		 */
		function get canDropTypeArray():Array;
		
		/**
		 * 能否放下
		 * @get
		 * @return	true:可以放下
		 */
		function get canDrop():Boolean;
		
		/**
		 * 能否拖动
		 * @get
		 * @return	true:可以拖动
		 */
		function get canDrag():Boolean;
		
		/**
		 * 唯一ID
		 * @get
		 * @return	String
		 */
		function get id():String;
		
		/**
		 * 锁定格子
		 * @set
		 * @param	lock	true:锁定
		 */
		function set locked(lock:Boolean):void;
		
		/**
		 * 获取格子item
		 * @get
		 * @return	IDragDropItem
		 */
		function get item():IDragDropItem;
		
		/**
		 * 设置格子item
		 * @set
		 */
		function set item(value:IDragDropItem):void;
		
		/**
		 * 移除格子item
		 */
		function removeItem():void;
		
		
		function get itemOffsetPoint():Point;
		
		/**
		 * 取消拖动
		 */
		function cancelDrag():void;
		
		/**
		 * 获取拖动副本
		 */
		function getDragCopyDisplay():DeltaXWindow;
		
		function addEventListener(type:String, callback:Function):void;
		
		function removeEventListener(type:String, callback:Function):void
	}
}