package displayUI.select
{
	import core.CGUIEditorApp;
	
	import deltax.appframe.BaseApplication;
	import deltax.gui.component.DeltaXWindow;
	import deltax.gui.component.event.DXWndMouseEvent;
	import deltax.gui.manager.GUIManager;
	
	import events.KeyEvent;
	
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	import manager.KeyBoardManager;
	import manager.KeyCode;
	
	import mx.core.UIComponent;
	
	import spark.components.RichEditableText;
	
	import utils.CommonUtil;

	/**
	 * 组件选择
	 * @author Exin
	 */
	public class SelectView extends Sprite
	{
		private static var _instance:SelectView;
		public static function get instance():SelectView
		{
			return _instance?_instance:new SelectView();
		}
		
		private var m_selectShape:Shape;
		private var m_mouseShape:Shape;
		
		private var m_mouseRect:Rectangle;
		
		//鼠标按下的是否是gui组件
		private var m_isDownGui:Boolean;
		
		//记录开始拖动的点
		private var m_dragPoint:Point;
		//记录选中组件的拖动前的坐标
		private var m_guiDragPointArr:Vector.<Point>;
		
		private var m_selectGuiArr:Vector.<DeltaXWindow> = new Vector.<DeltaXWindow>();
		
		public function get selectGuiArr():Vector.<DeltaXWindow>
		{
			return m_selectGuiArr;
		}
		
		public function SelectView()
		{
			if (_instance) {
				throw new Error("SelectView");
			}
			_instance = this;
			
			//选中的画框
			m_selectShape = new Shape();
			addChild(m_selectShape);
			
			//鼠标拖动的画框
			m_mouseShape = new Shape();
			addChild(m_mouseShape);
			
			
			this.addEventListener(Event.ADDED_TO_STAGE,onAddToStageHandler);
			GUIManager.instance.rootWnd.addEventListener(DXWndMouseEvent.MOUSE_DOWN,onGuiMouseDownHandler);
			CGUIEditorApp.instance.layoutTree.addEventListener(MouseEvent.CLICK,onTreeGuiClickHandler);
			
			this.addEventListener(Event.RESIZE,onResizeHandler);
			
			KeyBoardManager.instance.addEventListener(KeyEvent.KEY_BOARD_DOWN,onKeyDownHandler);
			onResizeHandler(null);
		}
		
		private function onAddToStageHandler(e:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE,onAddToStageHandler);
			
			addEventListener(MouseEvent.MOUSE_DOWN,onMouseDownHandler);
			
			stage.addEventListener(MouseEvent.MOUSE_UP,onMouseUpHandler);
			stage.addEventListener(MouseEvent.RELEASE_OUTSIDE,onMouseUpHandler);
			m_t = getTimer();
			this.addEventListener(Event.ENTER_FRAME,onEnterFrameHandler);
			
		}
		
		private var m_t:Number = 0;
		private function onEnterFrameHandler(e:Event):void
		{
			var t:Number = getTimer() - m_t;
			m_t = getTimer();
			onRender(t);
			
		}
		
		private function onRender(value:Number):void
		{
			drawMouseShape();
			checkSelectUI();
			drawSelectShape();
			updateGuiDragPostion();
		}
		
		private function drawMouseShape():void
		{
			if(!m_mouseRect)
			{
				return;
			}
				
			m_mouseRect.right =  this.mouseX;
			m_mouseRect.bottom =  this.mouseY;
			
			var p:Point = this.globalToLocal(new Point(this.mouseX,this.mouseY));
			m_mouseShape.graphics.clear();
			m_mouseShape.graphics.lineStyle(2,0xffffff,1);
			m_mouseShape.graphics.drawRect(m_mouseRect.x,m_mouseRect.y,m_mouseRect.width,m_mouseRect.height);
			m_mouseShape.graphics.endFill();
		}
		
		private function drawSelectShape():void
		{
			m_selectShape.graphics.clear();
			var len:int = m_selectGuiArr.length;
			var t_bounds:Rectangle;
			for(var i:int =0;i < len;i++)
			{
				t_bounds = CommonUtil.getGuiBounds(m_selectGuiArr[i]);//.bounds;
				
				m_selectShape.graphics.lineStyle(1,0xFF00FF);
				m_selectShape.graphics.drawRect(t_bounds.x,t_bounds.y,t_bounds.width,t_bounds.height);
				m_selectShape.graphics.endFill();
			}
		}
		
		
		private function checkSelectUI():void
		{
			if(!m_mouseRect)
			{
				return;
			}
			
			var gui:DeltaXWindow = CGUIEditorApp.instance.gameMainPanel.childTopMost;
			m_selectGuiArr = new Vector.<DeltaXWindow>();
			
			var t_rect:Rectangle = m_mouseRect.clone();
			if(t_rect.width < 0)
			{
				t_rect.width = t_rect.width * -1;
				t_rect.x = t_rect.x - t_rect.width; 
			}
			
			if(t_rect.height < 0)
			{
				t_rect.height = t_rect.height * -1;
				t_rect.y = t_rect.y - t_rect.height; 
			}
			while (gui) {
				//check
				//if(t_rect.intersects(gui.bounds))
				if(t_rect.intersects(CommonUtil.getGuiBounds(gui)))
				{
					m_selectGuiArr.push(gui);
				}
				gui = gui.brotherBelow;
			}
		}
		
		
		//更新拖动坐标
		private function updateGuiDragPostion():void
		{
			var len:int = m_selectGuiArr.length;
			if(!m_dragPoint || !m_guiDragPointArr || len == 0)
			{
				return;
			}
			var t_x:int = this.mouseX - m_dragPoint.x;
			var t_y:int = this.mouseY - m_dragPoint.y;
			for(var i:int = 0;i < len; i++)
			{
				m_selectGuiArr[i].setLocation(m_guiDragPointArr[i].x + t_x,m_guiDragPointArr[i].y + t_y);
			}
		}
		
		
		private function onResizeHandler(e:Event):void
		{
			this.graphics.beginFill(0xff0000,0);
			this.graphics.drawRect(0,0,BaseApplication.instance.rootUIComponent.width,BaseApplication.instance.rootUIComponent.height);
			this.graphics.endFill();
		}
		
		
		private function onMouseDownHandler(e:MouseEvent):void
		{
			//延迟处理。因为需要比onGuiMouseDownHandler慢执行
			var onDown:Function = function():void
			{
				if(m_isDownGui)
				{
					return;
				}
				m_mouseRect = new Rectangle(e.localX,e.localY);
			}
			setTimeout(onDown,0.1);
		}
		
		private function onMouseUpHandler(e:MouseEvent):void
		{
			//stage.removeEventListener(MouseEvent.MOUSE_UP,onMouseUpHandler);
			//stage.removeEventListener(MouseEvent.RELEASE_OUTSIDE,onMouseUpHandler);
			if(e.target is UIComponent)
			{
				return;
			}
			m_mouseRect = null;
			m_isDownGui = false;
			m_mouseShape.graphics.clear();
			
			if(m_selectGuiArr.length == 1)
			{
				CGUIEditorApp.instance.properView.setWindow(m_selectGuiArr[0]);
			}else
			{
				CGUIEditorApp.instance.properView.setWindow(CGUIEditorApp.instance.gameMainPanel);
			}
			if(m_selectGuiArr.length > 0)
			{
				//选中组件设置焦点
				stage.focus = this;
			}
			
			m_dragPoint = null;
			m_guiDragPointArr = null;
			
			CommonUtil.updateSelectProperties();
			
		}
		
		private function onGuiMouseDownHandler(e:DXWndMouseEvent):void
		{
			m_isDownGui = e.target!=GUIManager.CUR_ROOT_WND;
			if(m_isDownGui)
			{
				if(e.shiftKey)
				{
					var index:int = m_selectGuiArr.indexOf(e.target);
					//多选,添加移除选中组件
					if(index != -1)
					{
						//移除
						m_selectGuiArr.splice(index,1);
					}else
					{
						//添加
						m_selectGuiArr.push(e.target);
					}
				}else
				{
					if(m_selectGuiArr.length >0 && m_selectGuiArr.indexOf(e.target) != -1)
					{
						//已经选中了多个组件
						m_dragPoint = new Point(this.mouseX,this.mouseY);
						m_guiDragPointArr = new Vector.<Point>();
						
						//记录选中组件的拖动前的坐标
						for(var i:int = 0;i<m_selectGuiArr.length;i++)
						{
							m_guiDragPointArr.push(new Point(m_selectGuiArr[i].x,m_selectGuiArr[i].y));
						}
					}else
					{
						//选中了一个组件
						m_selectGuiArr[0] = e.target;
						CGUIEditorApp.instance.properView.setWindow(m_selectGuiArr[0]);
					}
				}
			}
		}
		
		//左边，组件tree。点击。画布同步选择
		private function onTreeGuiClickHandler(e:MouseEvent):void
		{
			m_selectGuiArr.splice(0,m_selectGuiArr.length);
			m_selectGuiArr[0] = CGUIEditorApp.instance.curSelectWindow;
			
			stage.focus = this;
		}
		
		//键盘事件
		private function onKeyDownHandler(e:KeyEvent):void
		{
			if(e.focusTarget is RichEditableText && RichEditableText(e.focusTarget).editable)
			{
				return;
			}
			if(e.keyCode == KeyCode.DELETE)
			{
				for(var i:int =0;i<m_selectGuiArr.length;i++)
				{
					m_selectGuiArr[i].remove();
				}
				m_selectGuiArr = new Vector.<DeltaXWindow>();
				
				CGUIEditorApp.instance.updateLayoutTree();
				CGUIEditorApp.instance.properView.setWindow(CGUIEditorApp.instance.gameMainPanel);
				return;
			}
			
			onKeyMove(e);
		}
		
		//键盘控制移动
		private function onKeyMove(e:KeyEvent):void
		{
			if(e.focusTarget is RichEditableText && RichEditableText(e.focusTarget).editable)
			{
				return;
			}
			var len:int = m_selectGuiArr.length;
			if(len == 0)
			{
				return;
			}
			//移动
			var add:int = e.shiftKey?10:1;
			var t_x:int;
			var t_y:int;
			if(e.keyCode == KeyCode.LEFT)
			{
				t_x = add * -1;
			}else if(e.keyCode == KeyCode.RIGHT)
			{
				t_x = add;
			}else if(e.keyCode == KeyCode.UP)
			{
				t_y = add * -1;
			}else if(e.keyCode == KeyCode.DOWN)
			{
				t_y = add;
			}
			if(t_x == 0 && t_y == 0)
			{
				return;
			}
			
			for(var i:int = 0;i < len;i++)
			{
				if(t_x !=0 )
				{
					m_selectGuiArr[i].x = m_selectGuiArr[i].x + t_x;
				}
				if(t_y !=0 )
				{
					m_selectGuiArr[i].y = m_selectGuiArr[i].y + t_y;
				}
			}
			
			CommonUtil.updateSelectProperties();
		}
		
		
		
		
		
		
		/*
		//获取gui的bounds。包括所有子对象的
		private function getGuiBounds(gui:DeltaXWindow):Rectangle
		{
			var rect:Rectangle = gui.globalBounds;
			var child:DeltaXWindow =  gui.childTopMost;
			while (child) {
				//check
				rect = rect.union(child.globalBounds);
				child = child.brotherBelow;
			}
			return rect;
		}
		*/
	}
}