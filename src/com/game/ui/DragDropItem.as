package com.game.ui
{
	import deltax.gui.base.style.WindowStyle;
	import deltax.gui.component.DeltaXWindow;
	import deltax.gui.component.event.DXWndEvent;
	import deltax.gui.component.subctrl.CommonWndSubCtrlType;
	import deltax.gui.component.subctrl.SubCtrlStateType;

	/**
	 * 格子物品显示对象 
	 * @author Exin
	 * 
	 */	
	public class DragDropItem extends DeltaXWindow implements IDragDropItem
	{
		
		private var m_dragType:String = null;
		
		public function DragDropItem()
		{
			this.mouseChildren = this.mouseEnabled = false;
		}
		
		/**
		 * 拖动类型
		 */
		public function get type():String
		{
			return m_dragType;
		}
		public function set type(value:String):void
		{
			m_dragType = value;
		}
		
		/**
		 * 获取拖动副本
		 */
		public function getCopyDisplay():DeltaXWindow
		{
			var win:DeltaXWindow = new DeltaXWindow();
			win.createFromRes("gui/cfg/baseui/cgbutton.gui",null);
			//win.createFromDispItemInfo("",this.properties.displayItems,WindowStyle.CHILD,null);
			//win.createFromWindowParam(this.properties.clone());
			var onCreated:Function = function(e:DXWndEvent):void
			{
				win.mouseChildren = win.mouseEnabled = false;
				win.childNotifyEnable = true;
				win.remove();
			}
			win.addEventListener(DXWndEvent.CREATED,onCreated);
			return win;
		}
	}
}