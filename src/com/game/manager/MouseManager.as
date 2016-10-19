package com.game.manager
{
	import deltax.appframe.BaseApplication;
	import deltax.gui.component.DeltaXWindow;
	import deltax.gui.manager.GUIManager;
	
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Mouse;
	import flash.ui.MouseCursorData;

	/**
	 * 鼠标样式、跟随管理 
	 * @author Exin
	 * 
	 */	
	public class MouseManager
	{
		private static var _instance:MouseManager;
		public static function get instance():MouseManager
		{
			return _instance?_instance:new MouseManager();
		}
		
		private var m_follow:DeltaXWindow;
		
		//跟随偏移坐标
		private var m_offsetPoint:Point = new Point();
		
		//跟随限制范围
		private var m_bounds:Rectangle;
		
		private var m_root:DeltaXWindow;
		
		public function MouseManager()
		{
			if (_instance) {
				throw new Error("MouseManager");
			}
			_instance = this;
			
			
		}
		
		public function set cursor(value:String):void
		{
			Mouse.cursor = value;
		}
		
		public function registerCursor(name:String,cursor:MouseCursorData):void
		{
			Mouse.registerCursor(name,cursor);
		}
		
		public function hide():void
		{
			Mouse.hide();
		}
		
		public function show():void
		{
			Mouse.show();
		}
		
		private function get root():DeltaXWindow
		{
			if(!m_root)
			{
				m_root = GUIManager.instance.rootWnd;//.getChildByName("GameMainState"); 
			}
			return m_root;
		}
		
		public function follow(mc:DeltaXWindow,offsetPoint:Point=null, bounds:Rectangle = null):void
		{
			this.removeFollow();
			m_follow = mc;
			m_offsetPoint.x = offsetPoint?offsetPoint.x:0;
			m_offsetPoint.y = offsetPoint?offsetPoint.y:0;
			
			//有限制范围，加入宽高、根据注册点。自动计算真实范围.
			if (bounds != null) {
				//加入宽高计算
				//注册点
			}else {
				m_bounds = null;
			}
			
			onRenderHandler();
			startRender();
		}
		
		public function followAndTop(mc:DeltaXWindow,offsetPoint:Point=null, bounds:Rectangle = null):void
		{
			follow(mc, offsetPoint, bounds);
			this.root.addChild(mc);
			
		}
		
		private function startRender():void
		{
			//TimerManager.getInstance().addRender(onRenderHandler);
			//_stage.addEventListener(MouseEvent.MOUSE_MOVE,onRenderHandler);
			BaseApplication.instance.rootUIComponent.addEventListener(Event.ENTER_FRAME,onRenderHandler);
		}
		
		private function stopRender():void
		{
			//TimerManager.getInstance().removeRender(onRenderHandler);
			//TimerManager.getInstance().removeEventListener(TimerManagerEvent.TIMER_BASE,onRenderHandler);
			//_stage.removeEventListener(MouseEvent.MOUSE_MOVE,onRenderHandler);
			BaseApplication.instance.rootUIComponent.removeEventListener(Event.ENTER_FRAME,onRenderHandler);
		}
		
		private function onRenderHandler(value:Event = null):void 
		{
			if (!m_follow) {
				stopRender();
				return;
			}
			var _mouseX:Number = this.root.mouseX;
			var _mouseY:Number = this.root.mouseY;
			
			
			if (m_follow) {
				//限制
				var _x:Number = _mouseX + m_offsetPoint.x;
				var _y:Number = _mouseY + m_offsetPoint.y;
				
				if (m_bounds != null) {
					//限制处理
					if (_x < m_bounds.x) {
						_x = m_bounds.x;
					}else if (_x > m_bounds.right) {
						_x = m_bounds.right;
					}
					
					if (_y < m_bounds.y) {
						_y = m_bounds.y;
					}else if (_y > m_bounds.bottom) {
						_y = m_bounds.bottom;
					}
				}
				m_follow.x = _x;
				m_follow.y = _y;
			}
			
			//置顶处理.....
			/*
			var _childIndex:int = _stage.getChildIndex(this);
			var _numchildren:int = _stage.numChildren-1;
			if (_childIndex < _numchildren) {
				_stage.swapChildrenAt(_childIndex,_numchildren)
			}
			*/
			if(m_follow.childTopMost != m_follow)
			{
				this.root.addChild(m_follow);
			}
		}
		
		/**
		 * 移除跟随
		 */
		public function unfollow():void
		{
			this.removeFollow();
		}
		
		//移除跟随
		private function removeFollow():void
		{
			if (m_follow) {
				m_follow.remove();
				m_follow = null;
			}
		}
		
	}
}