package com.game.manager
{
	import com.game.event.DragDropEvent;
	import com.game.ui.IDragDropGrid;
	
	import deltax.appframe.BaseApplication;
	import deltax.gui.component.DeltaXWindow;
	import deltax.gui.component.event.DXWndMouseEvent;
	import deltax.gui.manager.GUIManager;
	
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;

	/**
	 * 拖动管理 
	 * @author Exin
	 * 
	 */	
	public class DragDropManager extends EventDispatcher
	{
		private static var _instance:DragDropManager;
		public static function get instance():DragDropManager
		{
			return _instance?_instance:new DragDropManager();
		}
		
		
		private var m_groupTable:Dictionary = new Dictionary();
		private var m_items:Dictionary = new Dictionary();
		
		//整个拖动是否可用
		public var enabled:Boolean = true;
		
		private var m_dragTarget:IDragDropGrid;
		
		public function DragDropManager()
		{
			if (_instance) {
				throw new Error("DragDropManager");
			}
			_instance = this;
		}
		
		/**
		 * 设置拖动组关系
		 * @param	groupName			组名
		 * @param	canDropGroupArr		该组能拖进去的group数组
		 */
		public function setGroupTable(groupName:String, canDropGroupArr:Array):void
		{
			m_groupTable[groupName] = canDropGroupArr;
		}
		
		/**
		 * 添加拖动、放下格子
		 * @param	item			格子
		 * @param	groupName		组名
		 * @param	dragItem		拖动功能(true注册拖动功能)
		 * @param	dropItem		放下功能(true注册放下功能)
		 */
		public function addItem(item:IDragDropGrid,groupName:String,dragItem:Boolean=true,dropItem:Boolean=true):void
		{
			if (!m_groupTable.hasOwnProperty(groupName)) {
				//没有注册，默认可以拖到任何组
				m_groupTable[m_groupTable] = [];
			}
			//item.localDragDrop = local;
			if(dragItem){
				addDragItem(item);
			}
			if (!m_items.hasOwnProperty(groupName)) {
				m_items[groupName] = [];
			}
			if(m_items[groupName].indexOf(item) == -1)
			{
				m_items[groupName].push(item);
			}
			
			item.groupName = groupName;
		}
		
		/**
		 * 移除拖动格子
		 * @param	item			格子
		 */
		public function removeItem(item:IDragDropGrid):void
		{
			var items:Array = m_items[item.groupName];
			var index:int = items.indexOf(item);
			if (index == -1) return;
			items.splice(index, 1);
			
			item.removeEventListener(DXWndMouseEvent.MOUSE_DOWN, onDragDownHandler);
		}
		
		/**
		 * 移除一个组的格子,侦听
		 * @param groupName
		 */		
		public function removeGroup(groupName:String):void
		{
			var items:Array = m_items[groupName];
			if(!items || items.length < 1)
			{
				return;
			}
			var len:int = items.length;
			for(var i:int =0;i<len;i++)
			{
				items[i].removeEventListener(DXWndMouseEvent.MOUSE_DOWN, onDragDownHandler);
			}
			items.splice(0);
		}
			
		private function addDragItem(item:IDragDropGrid):void
		{			
			item.addEventListener(DXWndMouseEvent.MOUSE_DOWN, onDragDownHandler);
		}
		
		private function onDragDownHandler(e:DXWndMouseEvent):void 
		{
			//拖动锁定
			if (!enabled) {
				return;
			}
			if (!(e.target is IDragDropGrid)) return;
			m_dragTarget = IDragDropGrid(e.target);
			if (!m_dragTarget.canDrag/* || m_dragTarget.locked*/) {
				m_dragTarget=null;
				return;
			}
			
			var itemDisplay:DeltaXWindow = m_dragTarget.getDragCopyDisplay();
			
			if (itemDisplay) {
				MouseManager.instance.followAndTop(itemDisplay, new Point(-e.localX,-e.localY));
				//GUIManager.instance.rootWnd.addEventListener(DXWndMouseEvent.MOUSE_UP,onDragMouseUpHandler);
				StageManager.stage.addEventListener(MouseEvent.MOUSE_UP, onDragMouseUpHandler);
				//dispatchEvent(new DragDropEvent(DragDropEvent.DRAG,_dragTarget));
				//需要发送ID
				dispatchEvent(new DragDropEvent(DragDropEvent.DRAG,m_dragTarget,null,new Point(e.globalX,e.globalY)));
			}
		}
		
		private function onDragMouseUpHandler(e:MouseEvent):void {
			if(!m_dragTarget)
			{
				return;
			}
				
			var t_mouseX:int = e.stageX - BaseApplication.instance.rootUIComponent.x;
			var t_mouseY:int = e.stageY - BaseApplication.instance.rootUIComponent.y;
			var mousePosion:Point = new Point(t_mouseX,t_mouseY);
			var dropTarget:IDragDropGrid = GUIManager.instance.getWindowUnderPoint(mousePosion,1)[0] as IDragDropGrid;
			
			if(!dropTarget)
			{
				cancelDragDispatch(mousePosion);
				return;
			}
			if(dropTarget == m_dragTarget || !dropTarget.canDrop/* || dropTarget.locked*/)
			{
				cancelDrag();
				return;
			}
			
			var dragGroupArr:Array = m_groupTable[m_dragTarget.groupName];
			if(!dragGroupArr || dragGroupArr.length == 0 || dragGroupArr.indexOf(dropTarget.groupName) != -1)
			{
				//组复合要求
				//类型
				if(dropTarget.canDropTypeArray.length == 0 || dropTarget.canDropTypeArray.indexOf(m_dragTarget.item.type) != -1)
				{
					//类型匹配
					dispatchEvent(new DragDropEvent(DragDropEvent.DROP,m_dragTarget, dropTarget,mousePosion));
				}else
				{
					trace("物品拖动，类型不匹配:",m_dragTarget.groupName," > ",dropTarget.groupName," 物品类型：",m_dragTarget.item.type," > ",dropTarget.canDropTypeArray);
					dispatchEvent(new DragDropEvent(DragDropEvent.CANCEL_TYPE,m_dragTarget, dropTarget,mousePosion));
					//cancelDrag();
				}
			}else
			{
				trace(m_dragTarget.groupName," 不能拖到组： ",dropTarget.groupName);
				dispatchEvent(new DragDropEvent(DragDropEvent.CANCEL_GROUP,m_dragTarget, dropTarget,mousePosion));
				//cancelDrag();
			}
			cancelDrag();
		}
		
		private function cancelDrag():void {
			if (!m_dragTarget) {
				return;
			}
			m_dragTarget.cancelDrag(); //物品拖动无效，返回原位
			MouseManager.instance.unfollow();
			m_dragTarget = null;
			
			//EToolTips.getInstance().isShow = true;
			if (StageManager.stage.hasEventListener(MouseEvent.MOUSE_UP)){
				StageManager.stage.removeEventListener(MouseEvent.MOUSE_UP, onDragMouseUpHandler);
			}
			
		}
		private function cancelDragDispatch(postion:Point):void
		{
			dispatchEvent(new DragDropEvent(DragDropEvent.CANEL,m_dragTarget, null,postion));
			cancelDrag();
			trace("取消拖动");
		}
	}
}