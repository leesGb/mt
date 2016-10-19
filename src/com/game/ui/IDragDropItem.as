package com.game.ui
{
	import deltax.gui.component.DeltaXWindow;

	/**
	 * 拖动item接口
	 * @author Exin
	 * 
	 */	
	public interface IDragDropItem
	{
		/**
		 * item类型
		 * @get
		 * @return	String
		 */
		function get type():String;
		
		/**
		 * 获取显示副本
		 */
		function getCopyDisplay():DeltaXWindow;
	}
}