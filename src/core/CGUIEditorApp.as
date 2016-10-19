package core
{
	import deltax.appframe.BaseApplication;
	import deltax.common.localize.LanguageMgr;
	import deltax.common.resource.Enviroment;
	import deltax.common.respackage.common.LoaderCommon;
	import deltax.common.respackage.loader.LoaderManager;
	import deltax.delta;
	import deltax.graphic.manager.DeltaXTextureManager;
	import deltax.graphic.render.DeltaXRenderer;
	import deltax.graphic.render2D.rect.DeltaXRectRenderer;
	import deltax.gui.base.ComponentDisplayItem;
	import deltax.gui.base.ComponentDisplayStateInfo;
	import deltax.gui.base.DisplayImageInfo;
	import deltax.gui.base.WindowClassName;
	import deltax.gui.base.WindowCreateParam;
	import deltax.gui.base.style.WindowStyle;
	import deltax.gui.component.DeltaXButton;
	import deltax.gui.component.DeltaXComboBox;
	import deltax.gui.component.DeltaXRichWnd;
	import deltax.gui.component.DeltaXWindow;
	import deltax.gui.component.event.DXWndEvent;
	import deltax.gui.component.event.DXWndMouseEvent;
	import deltax.gui.manager.GUIManager;
	import deltax.gui.manager.IconManager;
	import deltax.gui.manager.WindowClassManager;
	
	import displayUI.select.SelectView;
	import displayUI.transformTool.TransformTool;
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.net.URLLoaderDataFormat;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	
	import manager.KeyBoardManager;
	
	import mx.controls.Tree;
	
	import resourceUI.ReousrceManagerUI;
	import resourceUI.manager.IconResManager;
	
	
	import utils.DicUtil;

	use namespace delta;

	public class CGUIEditorApp extends BaseApplication
	{
		private static const ETC:String = "/etc/";
		private var m_gameMainPane:GameMainState;
		public var properView:PropertiesView;
		public var layoutTree:Tree;
		
		public var subCtrTypeDef:Dictionary;
		public var m_defaultDisplayStateType:Dictionary;
		
		public function CGUIEditorApp()
		{
			super(ETC);			
			//initDefaultParam();
			
			/*
			subCtrTypeDef = new Dictionary();
			subCtrTypeDef[WindowClassName.NORMAL_WND] = CommonWndSubCtrlType;
			subCtrTypeDef[WindowClassName.BUTTON] = CommonWndSubCtrlType;
			subCtrTypeDef[WindowClassName.CHECK_BUTTON] = CommonWndSubCtrlType;
			subCtrTypeDef[WindowClassName.COMBOBOX] = ComboBoxSubCtrlType;
			subCtrTypeDef[WindowClassName.EDIT] = EditSubCtrlType;
			subCtrTypeDef[WindowClassName.TABLE] = ListSubCtrlType;
			subCtrTypeDef[WindowClassName.MESSAGE_BOX] = CommonWndSubCtrlType;
			subCtrTypeDef[WindowClassName.PROGRESS_BAR] = CommonWndSubCtrlType;
			subCtrTypeDef[WindowClassName.RICH_TEXTAREA] = RichWndSubCtrlType;
			subCtrTypeDef[WindowClassName.SCROLL_BAR] = ScrollBarSubCtrlType;
			subCtrTypeDef[WindowClassName.TREE] = TreeSubCtrlType;
			
			m_defaultDisplayStateType = new Dictionary();
			m_defaultDisplayStateType[WindowClassName.NORMAL_WND] = [SubCtrlStateType.ENABLE,SubCtrlStateType.DISABLE,SubCtrlStateType.HITTEST_AREA];
			m_defaultDisplayStateType[WindowClassName.BUTTON] = [SubCtrlStateType.ENABLE,SubCtrlStateType.DISABLE,SubCtrlStateType.MOUSEOVER,SubCtrlStateType.CLICKDOWN];
			m_defaultDisplayStateType[WindowClassName.CHECK_BUTTON] = [SubCtrlStateType.ENABLE,SubCtrlStateType.DISABLE,SubCtrlStateType.MOUSEOVER,SubCtrlStateType.CLICKDOWN,SubCtrlStateType.UNCHECK_CLICKDOWN,SubCtrlStateType.UNCHECK_MOUSEOVER,SubCtrlStateType.UNCHECK_ENABLE,SubCtrlStateType.UNCHECK_DISABLE];
			m_defaultDisplayStateType[WindowClassName.COMBOBOX] = ComboBoxSubCtrlType;
			m_defaultDisplayStateType[WindowClassName.EDIT] = EditSubCtrlType;
			m_defaultDisplayStateType[WindowClassName.TABLE] = ListSubCtrlType;
			m_defaultDisplayStateType[WindowClassName.MESSAGE_BOX] = CommonWndSubCtrlType;
			m_defaultDisplayStateType[WindowClassName.PROGRESS_BAR] = CommonWndSubCtrlType;
			m_defaultDisplayStateType[WindowClassName.RICH_TEXTAREA] = RichWndSubCtrlType;
			m_defaultDisplayStateType[WindowClassName.SCROLL_BAR] = ScrollBarSubCtrlType;
			m_defaultDisplayStateType[WindowClassName.TREE] = TreeSubCtrlType;	*/
		}
		
		public static function get instance():CGUIEditorApp{
			return ((BaseApplication.instance as CGUIEditorApp));
		}		
		
		override protected function onStarted():void{
			super.onStarted();			
//			this.camController.selfControlEvent = false;
//			this.camController.freeMode = false;
//			this.camController.enableSelfMouseWheel = false;
			this.m_gameMainPane = new GameMainState();
			this.m_gameMainPane.creatAsEmptyContain(GUIManager.instance.rootWnd, BaseApplication.instance.rootUIComponent.width,BaseApplication.instance.rootUIComponent.height);
			
			//root大小变化。且不影响子对象
			GUIManager.instance.rootWnd.setSize(BaseApplication.instance.rootUIComponent.width,BaseApplication.instance.rootUIComponent.height,false);
			this.m_gameMainPane.mouseEnabled = false;
			m_gameMainPane.show();			
//			camController.loadConfig((Enviroment.ConfigRootPath + "camera.xml"));
			
			layoutTree.addEventListener(MouseEvent.CLICK,layoutTreeSelectHandler);
			DeltaXRenderer.instance.backgroundR = 204/255;
			DeltaXRenderer.instance.backgroundG = 204/255;
			DeltaXRenderer.instance.backgroundB = 204/255;
//			DeltaXRenderer.instance.backgroundR = 1;
//			DeltaXRenderer.instance.backgroundG = 1;
//			DeltaXRenderer.instance.backgroundB = 1;
			
			DefaultCreateParam.getInstance().loadDefaultUI();
			ReousrceManagerUI.instance.setConfig();
				
			DicUtil.uiLanguageUrl = this.designerConfigPath + "dictionary/uilanguage.xml";
			DicUtil.svnUpdate(loadUIlanguage);		
			IconResManager.instance;
			//KeyBoardManager.instance.init(stage);
			initToolView();
			
			DebugSystem.instance.init(stage,DebugSystem.TYPE_UI_3D);
			
			//new Test();
		}
		
		private function initToolView():void
		{
			this.parent.addChild(SelectView.instance);
			TransformTool.instance.init(this.parent);
		}
		
		private function loadUIlanguage(e:Event):void
		{
			LoaderManager.getInstance().startSerialLoad();
			LoaderManager.getInstance().load(DicUtil.uiLanguageUrl, {onComplete:this.loadLanguageComplete}, LoaderCommon.LOADER_URL, false, {dataFormat:URLLoaderDataFormat.TEXT});
		}
		
		private function loadLanguageComplete(ob:Object):void{
			LanguageMgr.setup(ob["data"] as String,LanguageMgr.SETUP_UI);
		}
		
		public function get gameMainPanel():GameMainState{
			return this.m_gameMainPane;
		}
		
		public var curSelectWindow:DeltaXWindow;
		private var canMove:Boolean=false;
		override protected function onMouseDown(evt:DXWndMouseEvent):void{
			if (evt.shiftKey && evt.target!=GUIManager.CUR_ROOT_WND){				
				curSelectWindow = evt.target;
				properView.setWindow(curSelectWindow);
				DependFileListView.instance.updateBigList();
			}
			
			if (evt.altKey && evt.target!=GUIManager.instance.rootWnd){
				curSelectWindow = evt.target;
				curSelectWindow.style &= ~WindowStyle.CHILD;
				properView.setWindow(curSelectWindow);
				canMove = true;
			}
		}
		
		override protected function onMouseUp(_arg1:DXWndMouseEvent):void
		{
			if(_arg1.target is DeltaXWindow){
				properView.setLocalPos();
			}
			if(curSelectWindow && canMove){
				curSelectWindow.style |= WindowStyle.CHILD;
				properView.setWindow(curSelectWindow);
				canMove = false;
			}
			
		}
		
		override protected function updateFrame():void 
		{
			super.updateFrame();
			
			if(GUIManager.instance.cursorAttachWnd)
				properView.updateParam();
		}
		
		public function Addui(xml:XML):void {
			if(xml.name()!="n")return;			
			var guiName:String = xml.@guiName;
			var className:String = xml.@className;
			CGUIEditorApp.instance.importGui(DefaultCreateParam.getInstance().getCreateURL(guiName));
			
			
			
			return;
			var windowParam:WindowCreateParam = DefaultCreateParam.getInstance().GetCreateParam(guiName);
			var newWindowParam:WindowCreateParam = windowParam.clone();
			newWindowParam.reference();
			var refClass:Class = WindowClassManager.getComponentClassByName(className);
			if (className != WindowClassName.MESSAGE_BOX) {
				var window:DeltaXWindow = new refClass();
				/*window.create(windowParam.title, windowParam.style, windowParam.x, windowParam.y,
					windowParam.width, windowParam.height, m_gameMainPane, windowParam.fontName, windowParam.fontSize,
					windowParam.groupID,null,0,1,4278190335,4278190335,windowParam.lockFlag);
				window.properties.copyFrom(windowParam);
				*/				
				window.createFromWindowParam(newWindowParam,m_gameMainPane);
				window.setToolTipText(window.properties.tooltip);
			}else{
				window = new DeltaXButton();
				window.createFromRes("gui/cfg/dui_btn.gui",m_gameMainPane);
			}
			
			/*
			for (var i:int = 0; i < SubCtrlStateType.COUNT;i++ ) {
				var rec:Rectangle = new Rectangle(0, 0, window.properties.width, window.properties.height);				
				cds = new ComponentDisplayStateInfo();
				cds.imageList.addImage(0, "gui/tex/main08.png", rec, rec, 4278190335);
				cdi.displayStateInfos[i] = cds;
			}*/
			window.show();
			
			updateLayoutTree();
		}
		
		private var loadFileName:String;
		public function importGui(fileName:String):void {
			loadFileName = fileName;
			var window:DeltaXWindow = new DeltaXWindow();
			window.createFromRes(fileName);
			window.addEventListener(DXWndEvent.CREATED,dealImportGui);
		}
		
		private function dealImportGui(e:DXWndEvent):void{
			var win:DeltaXWindow = e.currentTarget as DeltaXWindow;
			var realWindow:DeltaXWindow = new (WindowClassManager.getComponentClassByName(win.properties.className) as Class)();				
			realWindow.createFromRes(loadFileName,this.gameMainPanel);
			realWindow.show();
			realWindow.addEventListener(DXWndEvent.CREATED,function ():void{
				updateLayoutTree();
				DependFileListView.instance.updateBigList();
			});
			
			win.dispose();				
		}
		
		public var allwindows:Array = [];
		public function updateLayoutTree():void{
			var xml:XML = new XML(<root></root>);
			//xml.appendChild(<p label="aa"><p label="bb"></p><p label="cc"></p></p>);
			allwindows = [];
			createLayoutArr(m_gameMainPane,xml);
			layoutTree.dataProvider = xml;
			layoutTree.validateNow();
			//展开所有树节点
			var xl:XML = layoutTree.dataProvider.getItemAt(0) as XML;
			for each(var xll:XML in xl.elements()){
				layoutTree.expandItem(xll,true);
				for each(var xlll:XML in xll.elements()){
					layoutTree.expandItem(xlll,true);	
				}
			}			
		}
		
		private function createLayoutArr(parentObject:DeltaXWindow,xml:XML):void{			
			allwindows.push(parentObject);
			var childXml:XML = new XML("<child label='" + parentObject.name + "' value='"+(allwindows.length - 1)+"'></child>");
			xml.appendChild(childXml);
			var i:int = 0;
			var childB:DeltaXWindow = parentObject.childBottomMost;
			if(childB){
				while (childB) {
					createLayoutArr(childB,childXml);
					childB = childB.brotherAbove;
				}
			}else {
				//childXml.appendChild("<child label='null'></child>");
			}
		}
		
		public function ResetTextureId(resetTexture:Boolean = false):void {
			TextureFileManager.getInstance().urls = new Vector.<String>();
			var fun:Function = function fun(win:DeltaXWindow):void{
				for each(var cdi:ComponentDisplayItem in win.properties.displayItems){
					for each(var cdsi:ComponentDisplayStateInfo in cdi.displayStateInfos) {
						if(cdsi){
							for each(var ii:DisplayImageInfo in cdsi.imageList.imageInfos){
								if(resetTexture == false && ii.texture!=null){
									ii.textureIndex = TextureFileManager.getInstance().GetTextureId(ii.texture.name);
								}else{
									ii.texture = DeltaXTextureManager.instance.createTexture(Enviroment.ResourceRootPath + TextureFileManager.getInstance().urls[ii.textureIndex]);								
								}
							}
						}
					}
				}
			}	
			
			var i:int = 0;
			if(m_gameMainPane.childTopMost){
				fun(m_gameMainPane.childTopMost);
			}
			var childWindow:DeltaXWindow = m_gameMainPane.childTopMost?m_gameMainPane.childTopMost.childBottomMost:null;
			while(childWindow){
				fun(childWindow);
				childWindow = childWindow.brotherAbove;
			}
		}
		
		private function checkCalledTextureUrl(urls:Vector.<String>):Vector.<String>{
			var exitCallUrlIndexs:Array=[];
			var newUrlDelIndexs:Array=[];//和原来index值的差值	
			for(var j:int=0;j<urls.length;j++){
				exitCallUrlIndexs[j] = -1;
			}
			
			//set
			var fun1:Function = function fun(win:DeltaXWindow):void{
				for each(var cdi:ComponentDisplayItem in win.properties.displayItems){
					for each(var cdsi:ComponentDisplayStateInfo in cdi.displayStateInfos) {
						if(cdsi){
							for each(var ii:DisplayImageInfo in cdsi.imageList.imageInfos){
								if(exitCallUrlIndexs[ii.textureIndex]==-1){
									if(urls[ii.textureIndex]){
										exitCallUrlIndexs[ii.textureIndex] = 0;
									}
								}
							}
						}
					}
				}
			}	
				
			//filter
			var filterFun:Function = function sfun():void{					
				var tmp:int=0;
				for(j=0;j<urls.length;j++){
					newUrlDelIndexs[j] = exitCallUrlIndexs[j];
				}
				
				for(j=0;j<urls.length;j++){
					if(newUrlDelIndexs[j]==-1){
						for(var o:int=j+1;o<urls.length;o++){
							if(newUrlDelIndexs[o]!=-1){
								newUrlDelIndexs[o]++;
							}
						}
					}
				}
			}
			
				
			var fun2:Function = function fun(win:DeltaXWindow):void{
				for(var p:int=0;p<exitCallUrlIndexs.length;p++){					
					if(exitCallUrlIndexs[p]==0)continue;
					if(p+1==exitCallUrlIndexs.length)continue;
					for each(var cdi:ComponentDisplayItem in win.properties.displayItems){
						for each(var cdsi:ComponentDisplayStateInfo in cdi.displayStateInfos) {
							if(cdsi){
								for each(var ii:DisplayImageInfo in cdsi.imageList.imageInfos){
									//
									ii.textureIndex = ii.textureIndex - newUrlDelIndexs[p];
								}
							}
						}
					}
				}
			}	
			
			if(m_gameMainPane.childTopMost){
				fun1(m_gameMainPane.childTopMost);
			}
			var childWindow:DeltaXWindow = m_gameMainPane.childTopMost?m_gameMainPane.childTopMost.childBottomMost:null;
			while(childWindow){
				fun1(childWindow);
				childWindow = childWindow.brotherAbove;
			}
			
			filterFun();
			
			if(m_gameMainPane.childTopMost){
				fun2(m_gameMainPane.childTopMost);
			}
			childWindow = m_gameMainPane.childTopMost?m_gameMainPane.childTopMost.childBottomMost:null;
			while(childWindow){
				fun2(childWindow);
				childWindow = childWindow.brotherAbove;
			}
			
			var exitCallUrls:Vector.<String> = new Vector.<String>;
			for(j=0;j<urls.length;j++){			
				if(exitCallUrlIndexs[j]!=-1){
					exitCallUrls.push(urls[j]);
					trace(j,urls[j]);
				}
			}
			
			trace(exitCallUrlIndexs);
			trace(newUrlDelIndexs);			
			
			return exitCallUrls;
		}
		
		private function layoutTreeSelectHandler(event:Event):void {
			if(layoutTree.selectedItem){
				var win:DeltaXWindow = allwindows[layoutTree.selectedItem.@value];
				//if(win is GameMainState)return;
				curSelectWindow = win;				
				properView.setWindow(curSelectWindow);
			}
		}
		
		
	}
}