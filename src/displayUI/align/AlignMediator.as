package displayUI.align
{
	
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.core.UIComponent;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	import spark.components.Button;
	
	import deltax.gui.component.DeltaXWindow;
	
	import displayUI.select.SelectView;
	
	import events.KeyEvent;
	
	import manager.KeyBoardManager;
	import manager.KeyCode;

	public class AlignMediator
	{
		/**
		 * 对齐
		 * @author Exin
		 */
		
		private static var _instance:AlignMediator;
		public static function get instance():AlignMediator
		{
			return _instance?_instance:new AlignMediator();
		}
		
		//水平左对齐
		[Bindable]
		[Embed(source = "../src/assets/align/a1.png")]
		private var ICON_ALIGN_XLEFT:Class;
		
		//水平居中
		[Bindable]
		[Embed(source = "../src/assets/align/a2.png")]
		private var ICON_ALIGN_XCENTER:Class;
		
		//水平右对齐
		[Bindable]
		[Embed(source = "../src/assets/align/a3.png")]
		private var ICON_ALIGN_XRIGHT:Class;
		
		
		//顶对齐
		[Bindable]
		[Embed(source = "../src/assets/align/b1.png")]
		private var ICON_ALIGN_TOP:Class;
		
		//垂直居中
		[Bindable]
		[Embed(source = "../src/assets/align/b2.png")]
		private var ICON_ALIGN_YCENTER:Class;
		
		//底对齐
		[Bindable]
		[Embed(source = "../src/assets/align/b3.png")]
		private var ICON_ALIGN_BOTTOM:Class;
		
		//分布-顶部
		[Bindable]
		[Embed(source = "../src/assets/align/c1.png")]
		private var ICON_DIS_TOP:Class;
		
		//分布-垂直居中
		[Bindable]
		[Embed(source = "../src/assets/align/c2.png")]
		private var ICON_DIS_YCENTER:Class;
		
		//分布-底部
		[Bindable]
		[Embed(source = "../src/assets/align/c3.png")]
		private var ICON_DIS_BOTTOM:Class;
		
		//分布-左侧
		[Bindable]
		[Embed(source = "../src/assets/align/d1.png")]
		private var ICON_DIS_LEFT:Class;
		
		//分布-水平居中
		[Bindable]
		[Embed(source = "../src/assets/align/d2.png")]
		private var ICON_DIS_XCENTER:Class;
		
		//分布-右侧
		[Bindable]
		[Embed(source = "../src/assets/align/d3.png")]
		private var ICON_DIS_XRIGHT:Class;
		
		//间隔-垂直平均间隔
		[Bindable]
		[Embed(source = "../src/assets/align/e1.png")]
		private var ICON_GAP_YCENTER:Class;
		
		//间隔-水平平均间隔
		[Bindable]
		[Embed(source = "../src/assets/align/e2.png")]
		private var ICON_GAP_XCENTER:Class;
		
		//匹配大小-宽
		[Bindable]
		[Embed(source = "../src/assets/align/f1.png")]
		private var ICON_SAME_WIDTH:Class;
		
		//匹配大小-高
		[Bindable]
		[Embed(source = "../src/assets/align/f2.png")]
		private var ICON_SAME_HEIGHT:Class;
		
		//匹配大小-宽高
		[Bindable]
		[Embed(source = "../src/assets/align/f3.png")]
		private var ICON_SAME_WIDTH_HEIGHT:Class;
		
		
		private var _initIcon:Boolean = false;
		private var _view:AlignView;
		private var _main:UIEditor;
		private var _gapType:String;
		
		private function set showNumStep(visible:Boolean):void
		{
			this._view.numStep.visible = visible;
		}
		
		public function AlignMediator()
		{
			if (_instance) {
				throw new Error("AlignMediator");
			}
			_instance = this;
			
			KeyBoardManager.instance.addEventListener(KeyEvent.KEY_BOARD_DOWN,onKeyDownHandler);
		}
		
		public function init(main:UIEditor):void
		{
			_main = main;
		}
		
		public function open():void
		{
			initView();
			
			if(_view.isPopUp)
			{
				return;
			}
			
			PopUpManager.addPopUp(_view, _main,false);
			updateXY();
			
			onInitIcon();
			initListener();
		}
		
		public function close():void
		{
			if(_view && _view.isPopUp){
				PopUpManager.removePopUp(_view);
				removeListener();
			}
		}
		
		public function openClose():void
		{
			initView();
			if(!_view.isPopUp)
			{
				this.open();
			}else
			{
				this.close();
			}
		}
		
		private function initView():void
		{
			if(!_view)
			{
				_view = new AlignView();
				
			}
			
		}
		
		
		private function onInitIcon():void
		{
			if(_initIcon)
			{
				return;
			}
			_initIcon = true;
			
			this.setIcon(_view.alignLeftBtn,		ICON_ALIGN_XLEFT);
			this.setIcon(_view.alignXCenterBtn,		ICON_ALIGN_XCENTER);
			this.setIcon(_view.alignXRightBtn,		ICON_ALIGN_XRIGHT);
			this.setIcon(_view.alignTopBtn,			ICON_ALIGN_TOP);
			this.setIcon(_view.alignYCenterBtn,		ICON_ALIGN_YCENTER);
			this.setIcon(_view.alignBottomBtn,		ICON_ALIGN_BOTTOM);
			/*
			this.setIcon(_view.disTopBtn,			ICON_DIS_TOP);
			this.setIcon(_view.disYCenterBtn,		ICON_DIS_YCENTER);
			this.setIcon(_view.disBottomBtn,		ICON_DIS_BOTTOM);
			this.setIcon(_view.disLeftBtn,			ICON_DIS_LEFT);
			this.setIcon(_view.disXCenterBtn,		ICON_DIS_XCENTER);
			this.setIcon(_view.disRightBtn,			ICON_DIS_XRIGHT);
			*/
			this.setIcon(_view.gapYCenterBtn,		ICON_GAP_YCENTER);
			this.setIcon(_view.gapXCenterBtn,		ICON_GAP_XCENTER);
			
			this.setIcon(_view.sameWidthBtn,		ICON_SAME_WIDTH);
			this.setIcon(_view.sameHeightBtn,		ICON_SAME_HEIGHT);
			this.setIcon(_view.sameWHBtn,			ICON_SAME_WIDTH_HEIGHT);
			
			this._view.numStep.visible = false;
			
		}
		
		private function setIcon(value:Button,icon:Object):void
		{
			var bmp:Bitmap = new icon();
			var s:mx.core.UIComponent = new mx.core.UIComponent();
			s.addChild(bmp);
			s.move(value.x+(value.width-bmp.width)/2,value.y+(value.height-bmp.height)/2);
			s.mouseChildren = s.mouseEnabled = false;
			this._view.addElement(s);
		}
			
		
		private function initListener():void
		{
			this._view.addEventListener(CloseEvent.CLOSE,onClickCloseHandler);
			this._view.addEventListener(MouseEvent.CLICK,onClickHandler);
			this._view.numStep.addEventListener(Event.CHANGE,onNumStepChangeHandler);
			this._view.stage.addEventListener(Event.RESIZE,onResizeHandler);
		}
		
		private function removeListener():void
		{
			this._view.removeEventListener(CloseEvent.CLOSE,onClickCloseHandler);
			this._view.removeEventListener(MouseEvent.CLICK,onClickHandler);
			this._view.numStep.removeEventListener(Event.CHANGE,onNumStepChangeHandler);
			if(this._view.stage)
			{
				this._view.stage.removeEventListener(Event.RESIZE,onResizeHandler);
			}
			
		}
		
		private function updateXY():void
		{
			this._view.move(this._view.stage.stageWidth-425,243);
		}
		
		
		
		private function onResizeHandler(e:Event):void
		{
			updateXY();
		}
		
		private function onClickCloseHandler(e:CloseEvent):void
		{
			this.close();
		}
		
		private function onClickHandler(e:MouseEvent):void
		{
			this.showNumStep = false;
			var target:Object = e.target;
			while(target.parent)
			{
				if(target.parent == _view.numStep)
				{
					this.showNumStep = true;
				}
					
				target = target.parent;
			}
			
			switch(e.target)
			{
				case _view.alignLeftBtn:
					align("x",AlignType.LEFT);
					break;
				case _view.alignXCenterBtn:
					align("x",AlignType.CENTER);
					break;
				case _view.alignXRightBtn:
					align("x",AlignType.RIGHT);
					break;
				case _view.alignTopBtn:
					align("y",AlignType.TOP);
					break;
				case _view.alignYCenterBtn:
					align("y",AlignType.MIDDLE);
					break;
				case _view.alignBottomBtn:
					align("y",AlignType.BOTTOM);
					break;
				case _view.sameWidthBtn:
					sameWidth();
					break;
				case _view.sameHeightBtn:
					sameHeight();
					break;
				case _view.sameWHBtn:
					sameWidth();
					sameHeight();
					break;
				case _view.gapXCenterBtn:
					gapAvg("x");
					break;
				case _view.gapYCenterBtn:
					gapAvg("y");
					break;
				case _view.gapXBtn:
					_gapType = null;
					this.showNumStep = true;
					this._view.numStep.value = 0;
					_gapType = "x";
					break;
				case _view.gapYBtn:
					_gapType = null;
					this.showNumStep = true;
					this._view.numStep.value = 0;
					_gapType = "y";
					break;
			}
			
		}
		
		private function onKeyDownHandler(e:KeyEvent):void
		{
			if(e.ctrlKey && e.keyCode == KeyCode.L)
			{
				this.openClose();
			}
		}
		
		private function onNumStepChangeHandler(e:Event):void
		{
			if(!_gapType)
			{
				return;
			}
			
			var gap:int = this._view.numStep.value;
			
			var arr:Vector.<DeltaXWindow> = SelectView.instance.selectGuiArr;
			var i:int;
			var len:int = arr ? arr.length : 0;
			var child:DeltaXWindow;
			
			var xArr:Array=[];
			var opArr:Array = [];
			if(len<2)
			{
				return;
			}
			for(i = 0; i < len; i++)
			{
				child = arr[i];
				xArr.push({x:child.x,
					y:child.y,
					width:child.width,
					height:child.height,
					child:arr[i]});
			}
			if(_gapType == "x")
			{
				xArr.sortOn("x",Array.NUMERIC);
			}else if(_gapType == "y")
			{
				xArr.sortOn("y",Array.NUMERIC);
			}else
			{
				throw(new Error("类型错误：onNumStepChangeHandler"));
				return;
			}
			
			len = xArr.length;
			var targetValue:int = _gapType == "x"?xArr[0].x:xArr[0].y;
			for(i = 0; i < len; i++)
			{
				if(_gapType == "x")
				{
					xArr[i].child.x = targetValue;
					//CommonMediator.setChildX(xArr[i].child,xArr[i].childIns,targetValue,opArr);
					targetValue += gap + xArr[i].width;
				}else
				{
					xArr[i].child.y = targetValue;
					//CommonMediator.setChildY(xArr[i].child,xArr[i].childIns,targetValue,opArr);
					targetValue += gap + xArr[i].height;
				}
				
			}
			
			
		}
		
		/**
		 * 平均间隔<br>
		 * x轴，取最左最右组件，平均分布
		 * 
		 */
		private function gapAvg(type:String):void
		{
			
			var arr:Vector.<DeltaXWindow> = SelectView.instance.selectGuiArr;
			var i:int;
			var len:int = arr ? arr.length : 0;
			var child:DeltaXWindow;
			
			var xArr:Array=[];
			var opArr:Array = [];
			if(len<3)
			{
				return;
			}
			for(i = 0; i < len; i++)
			{
				child = arr[i];
				xArr.push({x:child.x,
					y:child.y,
					width:child.width,
					height:child.height,
					child:child});
			}
			if(type == "x")
			{
				xArr.sortOn("x",Array.NUMERIC);
			}else if(type == "y")
			{
				xArr.sortOn("y",Array.NUMERIC);
			}else
			{
				throw(new Error("类型错误：gapAvg"));
				return;
			}
			
			len = xArr.length;
			var countValue:int = 0;
			for(i=0;i<len-1;i++)
			{
				if(_gapType == "x")
				{
					countValue += xArr[i].width;
				}else
				{
					countValue += xArr[i].height;
				}
			}
			
			var gap:int;
			if(type == "x")
			{
				gap = (xArr[xArr.length - 1].x - xArr[0].x - countValue)/(len-1);
			}else
			{
				gap = (xArr[xArr.length - 1].y - xArr[0].y - countValue)/(len-1);
			}
			
			
			var targetValue:int = type == "x"?xArr[0].x:xArr[0].y;
			for(i = 0; i < len; i++)
			{
				if(type == "x")
				{
					xArr[i].child.x = targetValue;
					//CommonMediator.setChildX(xArr[i].child,xArr[i].childIns,targetValue,opArr);
					targetValue += gap + xArr[i].width;
				}else
				{
					xArr[i].child.y = targetValue;
					//CommonMediator.setChildY(xArr[i].child,xArr[i].childIns,targetValue,opArr);
					targetValue += gap + xArr[i].height;
				}
				
			}
			
			
		}
		
		
		/**
		 * 对齐
		 * @param	type		类型,x：x对齐，y：y对齐
		 * @param	alignType	对齐类型在AlignType里面
		 */
		private function align(type:String,alignType:String):void
		{
			
			var arr:Vector.<DeltaXWindow> = SelectView.instance.selectGuiArr;
			var i:int;
			var len:int = arr ? arr.length : 0;
			var child:DeltaXWindow;
			
			var xArr:Array=[];
			if(len<2)
			{
				return;
			}
			for(i = 0; i < len; i++)
			{
				child = arr[i];
				xArr.push({value:type=="x"?child.x:child.y,
					child:child});
			}
			if(type == "x")
			{
				xArr.sortOn("value",Array.NUMERIC);
			}else
			{
				xArr.sortOn("value",Array.NUMERIC);
			}
				
			
			var targetX:int;
			if(alignType == AlignType.LEFT)
			{
				targetX = xArr[0].value;
			}else if(alignType == AlignType.CENTER)
			{
				targetX = (xArr[0].value + xArr[xArr.length - 1].value)/2;
			}else if(alignType == AlignType.RIGHT)
			{
				targetX = xArr[xArr.length - 1].value;
			}else if(alignType == AlignType.TOP)
			{
				targetX = xArr[0].value;
			}else if(alignType == AlignType.MIDDLE)
			{
				targetX = (xArr[0].value + xArr[xArr.length - 1].value)/2;
			}else if(alignType == AlignType.BOTTOM)
			{
				targetX = xArr[xArr.length - 1].value;
			}
			
			len = xArr.length;
			for(i=0;i<len;i++)
			{
				if(type == "x")
				{
					xArr[i].child.x = targetX;
				}else if(type == "y")
				{
					xArr[i].child.y = targetX;
				}
			}
			
			arr = null;
			child = null;
			xArr = null;
			
		}
		
		private function sameWidth():void
		{
			
			var arr:Vector.<DeltaXWindow> = SelectView.instance.selectGuiArr;
			var i:int;
			var len:int = arr ? arr.length : 0;
			var child:DeltaXWindow;
			
			var xArr:Array=[];
			if(len<2)
			{
				return;
			}
			for(i = 0; i < len; i++)
			{
				child = arr[i];
				xArr.push({value:child.width,child:child});
			}
			xArr.sortOn("value",Array.NUMERIC);
			
			len = xArr.length;
			var targetValue:int = xArr[xArr.length - 1].value;
			for(i=0;i<len;i++)
			{
				xArr[i].child.width = targetValue;
			}
			
			
		}
		
		private function sameHeight():void
		{
			
			var arr:Vector.<DeltaXWindow> = SelectView.instance.selectGuiArr;
			var i:int;
			var len:int = arr ? arr.length : 0;
			var child:DeltaXWindow;
			
			var xArr:Array=[];
			var opArr:Array = [];
			if(len<2)
			{
				return;
			}
			for(i = 0; i < len; i++)
			{
				child = arr[i];
				xArr.push({value:child.height,child:child});
			}
			xArr.sortOn("value",Array.NUMERIC);
			
			len = xArr.length;
			var targetValue:int = xArr[xArr.length - 1].value;
			for(i=0;i<len;i++)
			{
				xArr[i].child.height = targetValue;
			}
			
		}
	}
}