package displayUI.transformTool
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.ui.MouseCursorData;
	
	import deltax.gui.component.DeltaXWindow;
	
	import displayUI.select.SelectView;
	
	import manager.KeyBoardManager;
	import manager.KeyCode;
	
	import utils.CommonUtil;
	
	/**
	 * 组件大小拖动控制
	 * @author Exin
	 *
	 */
	public class TransformTool
	{
		private static var _instance:TransformTool;
		public static function get instance():TransformTool
		{
			return _instance?_instance:new TransformTool();
		}
		
		private var parent:DisplayObjectContainer;
		private var child:DeltaXWindow;
		
		//箭头
		[Bindable]
		[Embed(source = "../src/assets/transform/arrowH.png")]
		private var ICON_TRANSFORM_ARROW_H:Class;
		
		//箭头
		[Bindable]
		[Embed(source = "../src/assets/transform/arrowL.png")]
		private var ICON_TRANSFORM_ARROW_L:Class;
		
		//箭头
		[Bindable]
		[Embed(source = "../src/assets/transform/arrowR.png")]
		private var ICON_TRANSFORM_ARROW_R:Class;
		
		//箭头
		[Bindable]
		[Embed(source = "../src/assets/transform/arrowV.png")]
		private var ICON_TRANSFORM_ARROW_V:Class;
		
		//注册点
		[Bindable]
		[Embed(source = "../src/assets/transform/point.png")]
		private var ICON_TRANSFORM_POINT:Class;
		
		//方框
		[Bindable]
		[Embed(source = "../src/assets/transform/rect.png")]
		private var ICON_TRANSFORM_RECT:Class;
		
		private var arrowVBmp:Sprite;
		private var arrowHBmp:Sprite;
		private var arrowLBmp:Sprite;
		private var arrowRBmp:Sprite;
		
		private var pointBmp:Sprite;
		private var rectBmpArr:Vector.<Sprite>;
		
		//根据点索引获取对应的箭头
		private var arrowData:Array=[];
		
		private var mouseStyle:String;
		private var mouseStyleIndex:int;
		private var downPoint:Point;
		private var defualtWH:Point;
		private var defualtXY:Point;
		//注册点位置相对比例
		private var pointScale:Point = new Point();
		
		private var pointDraging:Boolean;
		
		public function TransformTool()
		{
			if (_instance) {
				throw new Error("TransformTool");
			}
			_instance = this;
		}
		
		/**
		 * 初始化
		 * @param	parent		父容器
		 */
		public function init(parent:DisplayObjectContainer):void
		{
			var bmp:Bitmap;
			var mc:Sprite;
			
			rectBmpArr = new Vector.<Sprite>();
			for(var i:int =0;i<8;i++)
			{
				bmp = new ICON_TRANSFORM_RECT();
				mc = new Sprite();
				bmp.x = -bmp.width>>1;
				bmp.y = -bmp.height>>1;
				mc.addChild(bmp);
				
				rectBmpArr.push(mc);
				rectBmpArr[i].visible =false;
				rectBmpArr[i].addEventListener(MouseEvent.MOUSE_OVER,onMouseOverHandler);
				rectBmpArr[i].addEventListener(MouseEvent.MOUSE_OUT,onMouseOutHandler);
				rectBmpArr[i].addEventListener(MouseEvent.MOUSE_DOWN,onMouseDownHandler,false,int.MAX_VALUE);
				parent.addChild(rectBmpArr[i]);
			}
			
			pointBmp = new Sprite();
			bmp = new ICON_TRANSFORM_POINT();
			bmp.x = -bmp.width>>1;
			bmp.y = -bmp.height>>1;
			pointBmp.addChild(bmp);
			pointBmp.addEventListener(MouseEvent.MOUSE_OVER,onPointMouseOverHandler,false,100);
			pointBmp.addEventListener(MouseEvent.MOUSE_DOWN,onPointMouseDownHandler);
			
			pointBmp.visible =false;
			pointBmp.mouseChildren = false;
			parent.addChild(pointBmp);
			
			registerMouseCursor("arrowHBmp",ICON_TRANSFORM_ARROW_H);
			registerMouseCursor("arrowLBmp",ICON_TRANSFORM_ARROW_L);
			registerMouseCursor("arrowRBmp",ICON_TRANSFORM_ARROW_R);
			registerMouseCursor("arrowVBmp",ICON_TRANSFORM_ARROW_V);
			
			arrowData=["arrowLBmp","arrowVBmp","arrowRBmp","arrowHBmp","arrowLBmp","arrowVBmp","arrowRBmp","arrowHBmp"];
			this.parent = parent;
			
			this.parent.addEventListener(Event.ENTER_FRAME,onRender);
			
		}
		
		private function onRender(e:Event):void
		{
			updateTool();
		}
		
		/**
		 * 更新图标是否显示，图标位置
		 */
		public function updateTool():void
		{
			if(SelectView.instance.selectGuiArr.length == 1)
			{
				child = SelectView.instance.selectGuiArr[0];
			}else
			{
				child = null;
			}
			if(!child)
			{
				this.pointBmp.visible =false;
				
				//默认注册点位置.左上角值都是0，居中都是0.5
				pointScale.x = 0;
				pointScale.y = 0;
				showRectIco(false);
				return;
			}
			
			var w:int = child.width;
			var w2:int = w>>1;
			var h:int = child.height;
			var h2:int = h>>1;
			
			var p:Point = getChildGlobal();
			rectBmpArr[0].x = p.x;
			rectBmpArr[0].y = p.y;
			
			rectBmpArr[1].x = p.x + w2;
			rectBmpArr[1].y = p.y;
			
			rectBmpArr[2].x = p.x + w;
			rectBmpArr[2].y = p.y;
			
			rectBmpArr[3].x = p.x + w;
			rectBmpArr[3].y = p.y + h2;
			
			rectBmpArr[4].x = p.x + w;
			rectBmpArr[4].y = p.y + h;
			
			rectBmpArr[5].x = p.x + w2;
			rectBmpArr[5].y = p.y + h;
			
			rectBmpArr[6].x = p.x;
			rectBmpArr[6].y = p.y + h;
			
			rectBmpArr[7].x = p.x;
			rectBmpArr[7].y = p.y + h2;
			
			if(pointDraging == false)
			{
				this.pointBmp.x = pointScale.x * w + p.x;
				this.pointBmp.y = pointScale.y * h + p.y;
			}
			
			
			pointBmp.visible = true;
			showRectIco(true);
			
		}
		
		/**
		 * 鼠标经过拖动图标。更新鼠标样式
		 * @param	MouseEvent
		 *
		 */
		private function onMouseOverHandler(e:MouseEvent):void
		{
			if(this.downPoint)
			{
				return;
			}
			var index:int = rectBmpArr.indexOf(e.target);
			if( index == -1)
			{
				return;
			}
			mouseStyleIndex = index;
			mouseStyle = arrowData[index];
			if(mouseStyle)
			{
				Mouse.cursor = mouseStyle;
			}
			
		}
		
		/**
		 * 鼠标移开拖动图标。更新鼠标样式
		 * @param	MouseEvent
		 *
		 */
		private function onMouseOutHandler(e:MouseEvent):void
		{
			if(downPoint)
			{
				return;
			}
			mouseStyle = null;
			mouseStyleIndex = -1;
			updateMouseIco();
		}
		
		/**
		 * 拖动改变大小<br>
		 * @param	MouseEvent
		 *
		 */
		private function onMouseDownHandler(e:MouseEvent):void
		{
			e.stopPropagation();
			
			defualtWH = new Point(child.width,child.height);
			defualtXY = new Point(child.x,child.y);
			downPoint = new Point(parent.mouseX,parent.mouseY);
			parent.stage.addEventListener(MouseEvent.MOUSE_UP,onMouseUpHandler,false,int.MAX_VALUE);
			
			//TimerHandler.instance.addEnterFrame(onEnterFrame);
			parent.addEventListener(Event.ENTER_FRAME,onEnterFrame);
		}
		
		/**
		 * 拖动改变大小结束<br>
		 * 派发组件宽高，坐标改变事件
		 * @param	MouseEvent
		 *
		 */
		private function onMouseUpHandler(e:MouseEvent):void
		{
			var child:DeltaXWindow = SelectView.instance.selectGuiArr[0];
			
			//child.setSize(defualtWH.x,defualtWH.y);
			parent.stage.removeEventListener(MouseEvent.MOUSE_UP,onMouseUpHandler);
			mouseStyle = null;
			downPoint = null;
			updateMouseIco();
			
			//TimerHandler.instance.delEnterFrame(onEnterFrame);
			parent.removeEventListener(Event.ENTER_FRAME,onEnterFrame);
			
			CommonUtil.updateSelectProperties();
		}
		
		/**
		 * 形变注册点截取经过事件。避免点与拖动到重叠。响应不了事件
		 * @param	MouseEvent
		 *
		 */
		private function onPointMouseOverHandler(e:MouseEvent):void
		{
			e.stopPropagation();
			e.stopImmediatePropagation();
		}
		
		/**
		 * 形变注册点按下开始拖动
		 * @param	MouseEvent
		 *
		 */
		private function onPointMouseDownHandler(e:MouseEvent):void
		{
			e.stopPropagation();
			parent.stage.addEventListener(MouseEvent.MOUSE_UP,onPointMouseUpHandler,false,int.MAX_VALUE);
			pointBmp.startDrag(true,CommonUtil.getGuiBounds(child));//.getBounds(parent));
			
			pointDraging = true;
			
			//CommonUtil.getGuiBounds(child)
			//child.localToGlobal(new Point())
		}
		
		/**
		 * 形变注册点结束拖动
		 * @param	MouseEvent
		 *
		 */
		private function onPointMouseUpHandler(e:MouseEvent):void
		{
			parent.stage.removeEventListener(MouseEvent.MOUSE_UP,onPointMouseUpHandler);
			pointBmp.stopDrag();
			pointDraging = false;
			//记录注册点在child里面的相对坐标的。相对于child宽高的比例
			var p:Point = new Point(pointBmp.x,pointBmp.y);//parent.localToGlobal(new Point(pointBmp.x,pointBmp.y));
			p = child.globalToLocal(p);
			pointScale.x = p.x / child.width;
			pointScale.y = p.y / child.height;
			
			//比例修正
			if(pointScale.x >0 && pointScale.x <.05)
			{
				pointScale.x = 0;
			}else if(pointScale.x >0.45 && pointScale.x <.55)
			{
				pointScale.x = 0.5;
			}else if(pointScale.x >0.95 && pointScale.x <1)
			{
				pointScale.x = 1;
			}
			if(pointScale.y >0 && pointScale.y <.05)
			{
				pointScale.y = 0;
			}else if(pointScale.y >0.45 && pointScale.y <.55)
			{
				pointScale.y = 0.5;
			}else if(pointScale.y >0.95 && pointScale.y <1)
			{
				pointScale.y = 1;
			}
			
		}
		
		/**
		 * EnterFrame<br>
		 * 更新组件大小，位置
		 *
		 */
		private function onEnterFrame(e:Event):void
		{
			if(!downPoint || !parent)
			{
				return;
			}
			var p:Point = new Point(parent.mouseX,parent.mouseY);
			if(p.x == downPoint.x && p.y == downPoint.y)
			{
				return;
			}
			
			updateChildWidthHeight(p);
			
		}
		
		/**
		 * 组件宽高，坐标更新。<br>
		 * 直接改变组件属性。属性面板不更新，不保存记录。在停止拖动的时候做一个改变就OK
		 * @param	value	鼠标位置
		 *
		 */
		private function updateChildWidthHeight(value:Point):void
		{
			value.x = value.x - downPoint.x;
			value.y = value.y - downPoint.y;
			
			if(mouseStyleIndex == 2 || mouseStyleIndex == 3 || mouseStyleIndex == 4)
			{
				//右边拖动
				if(this.pointScale.x == 1)
				{
					return;
				}
				value.x = value.x + value.x/(1-this.pointScale.x)*this.pointScale.x;
			}else if(mouseStyleIndex == 0 || mouseStyleIndex == 6 || mouseStyleIndex == 7)
			{
				//左边拖动
				if(this.pointScale.x == 0)
				{
					return;
				}
				value.x = value.x * -1;
				value.x = value.x + value.x/(this.pointScale.x)*(1-this.pointScale.x);
			}else
			{
				//中间
			}
			
			if(mouseStyleIndex == 0 || mouseStyleIndex == 1 || mouseStyleIndex == 2)
			{
				//上拖动
				if(this.pointScale.y == 0)
				{
					return;
				}
				value.y = value.y * -1;
				value.y = value.y + value.y/(this.pointScale.y)*(1-this.pointScale.y);
				
			}else if(mouseStyleIndex == 4 || mouseStyleIndex == 5 || mouseStyleIndex == 6)
			{
				//下拖动
				if(this.pointScale.y == 1)
				{
					return;
				}
				value.y = value.y + value.y/(1-this.pointScale.y)*this.pointScale.y;
			}else
			{
				//中间
			}
			
			//value.x = value.x + value.x/(1-this.pointScale.x)*this.pointScale.x;
			//value.y = value.y + value.y/(1-this.pointScale.y)*this.pointScale.y;
			
			var w:int = defualtWH.x + value.x;
			var h:int;
			var x:int;
			var y:int;
			if(mouseStyle != arrowData[1] && 
				mouseStyle!= arrowData[5] && 
				KeyBoardManager.isKeyDown(KeyCode.SHIFT)
			)
			{
				//shift键锁定比例
				h = w*defualtWH.y/defualtWH.x;
			}else
			{
				h = defualtWH.y + value.y;
			}
			
			w = Math.max(1,w);
			h = Math.max(1,h);
			
			//坐标改变
			x = defualtXY.x - (w - defualtWH.x) * pointScale.x;
			y = defualtXY.y - (h - defualtWH.y) * pointScale.y;
			
			var opArr:Array = [];
			//var id:String = ContentData.instance.selectedChildrenMap.values[0].id;
			if(mouseStyle == arrowData[0] || mouseStyle == arrowData[2] || mouseStyle == arrowData[4] || mouseStyle == arrowData[6])
			{
				//宽高
				child.width = w;
				child.height = h;
				child.x = x;
				child.y = y;
			}else if(mouseStyle == arrowData[1] || mouseStyle == arrowData[5])
			{
				//高
				child.height = h;
				child.y = y;
			}else if(mouseStyle == arrowData[3] || mouseStyle == arrowData[7])
			{
				//宽
				child.width = w;
				child.x = x;
			}
			
			this.updateTool();
			//EventHandler.sendMsg(EditMessage.EDIT_UPDATE_MASK);
		}
		
		private function registerMouseCursor(name:String,bmpClass:Class):void
		{
			var bmp:Bitmap = new bmpClass();
			var mdata:MouseCursorData = new MouseCursorData();
			mdata.hotSpot = new Point(bmp.width>>1,bmp.height>>1);
			var data:Vector.<BitmapData> = new Vector.<BitmapData>();
			data.push(bmp.bitmapData);
			mdata.data = data;
			Mouse.registerCursor(name,mdata);
		}
		
		/**
		 * 获取child相对于在parent的坐标
		 */
		private function getChildGlobal():Point
		{
			var p:Point = child.localToGlobal(new Point());
			return p;//parent.globalToLocal(p);
		}
		
		private function showRectIco(visible:Boolean):void
		{
			var len:int = rectBmpArr.length;
			for(var i:int =0;i<len;i++)
			{
				rectBmpArr[i].visible = visible;
			}
		}
		
		private function updateMouseIco():void
		{
			if(this.mouseStyle)
			{
				Mouse.cursor = this.mouseStyle;
			}else
			{
				Mouse.cursor = MouseCursor.AUTO;
			}
			
			/*
			arrowVBmp.visible = false;
			arrowHBmp.visible = false;
			arrowRBmp.visible = false;
			arrowLBmp.visible = false;
			*/
		}
	}
}