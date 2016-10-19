package core
{
	import deltax.gui.base.ComponentDisplayItem;
	import deltax.gui.base.ComponentDisplayStateInfo;
	import deltax.gui.base.WindowClassName;
	import deltax.gui.base.WindowCreateParam;
	import deltax.gui.base.WndSoundFxType;
	import deltax.gui.base.style.WindowStyle;
	import deltax.gui.component.DeltaXWindow;
	import deltax.gui.component.event.DXWndEvent;
	import deltax.gui.component.subctrl.CommonWndSubCtrlType;
	import deltax.gui.component.subctrl.EditSubCtrlType;
	import deltax.gui.component.subctrl.SubCtrlStateType;
	import deltax.gui.manager.WindowClassManager;
	
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	public class DefaultCreateParam
	{
		private static var _instance:DefaultCreateParam;
//		public static var WindowClasss:Array = [WindowClassName.BUTTON,WindowClassName.CHECK_BUTTON,WindowClassName.COMBOBOX,
//												  WindowClassName.EDIT,WindowClassName.MESSAGE_BOX,
//												  WindowClassName.PROGRESS_BAR,WindowClassName.RICH_TEXTAREA,WindowClassName.SCROLL_BAR,
//												  WindowClassName.TABLE,WindowClassName.TREE,
//												  "CloseButton","ToggleButton","EmptyWnd","BackWnd"
//												  ];//WindowClassName.NORMAL_WND,
		public static var guiFileNameList:Array;
		private var m_loadWindows:Array = [];
		private var m_windowParams:Dictionary;
		private var m_windowUrls:Dictionary = new Dictionary();
		
		private var m_defaultParam:WindowCreateParam;
		public function DefaultCreateParam()
		{
			m_windowParams = new Dictionary();
			initDefaultParams();
			//initParams();
		}
		
		public function loadDefaultUI():void
		{
			dispose();
			var guiPath:String;
			var window:DeltaXWindow;
			var i:int = 0;
			for each(var classType:String in guiFileNameList){				
				guiPath = "gui/cfg/baseui/" + classType + ".gui";
				window = new DeltaXWindow();
				window.createFromRes(guiPath,CGUIEditorApp.instance.gameMainPanel);
				window.show();
				window.addEventListener(DXWndEvent.CREATED,dxWndCreateHandler);
				
				m_windowUrls[classType] = guiPath;
				m_loadWindows[i] = window;
				i++;
			}
		}
		
		private function dispose():void
		{
			for(var str:* in m_windowParams){
				if(m_windowParams[str] is WindowCreateParam){
					(m_windowParams[str] as WindowCreateParam).dispose();
				}
				delete m_windowParams[str];
			}
			m_windowParams = new Dictionary();
		}
		
		private function dxWndCreateHandler(event:DXWndEvent):void{
			var window:DeltaXWindow = event.currentTarget as DeltaXWindow;
			var idx:int = m_loadWindows.indexOf(window);
			if("CGComboBox"==guiFileNameList[idx]){
				trace();
			}
			m_windowParams[guiFileNameList[idx]] = window.properties;
			
			CGUIEditorApp.instance.gameMainPanel.removeChild(window);
		}
		
		public static function getInstance():DefaultCreateParam{
			_instance = (_instance?_instance:new DefaultCreateParam());
			return _instance;
		}
		
		private function initDefaultParams():void{
			m_defaultParam = new WindowCreateParam();
			m_defaultParam.id = "default";
			m_defaultParam.className = "";
			m_defaultParam.title = "titlett";
			m_defaultParam.style = WindowStyle.REQUIRE_CHILD_NOTIFY;
			m_defaultParam.x = 0;
			m_defaultParam.y = 0;
			m_defaultParam.width = 100;
			m_defaultParam.height = 22;
			m_defaultParam.xBorder = 0;
			m_defaultParam.yBorder = 0;
			m_defaultParam.fontName = "微软雅黑";
			m_defaultParam.fontSize = 12;
			m_defaultParam.textHorzDistance = 0;
			m_defaultParam.textVertDistance = 0;
			m_defaultParam.lockFlag = 0;
			m_defaultParam.tooltip = "";
			m_defaultParam.userClassName = "";
			m_defaultParam.userInfo = "";
			var haveSoundFx:Boolean = false; 
			var i:int = 0;
			var soundFxVec:Vector.<String> = new Vector.<String>(WndSoundFxType.COUNT, true);
			while (i < WndSoundFxType.COUNT) {
				soundFxVec[i] = "";
				if (soundFxVec[i]){
					soundFxVec[i] = "";
					haveSoundFx = true;
				}
				i++;
			}
			if (haveSoundFx)
				m_defaultParam.soundFxs = soundFxVec.concat();
			
			m_defaultParam.fadeDuration = 0;
			m_defaultParam.makeDefaultSubCtrlInfos(CommonWndSubCtrlType);
		}
		
		private function initParams():void{
			m_windowParams = new Dictionary();
			
			/*
			var windowParam:WindowCreateParam;
			for each(var classType:String in WindowClasss){
				windowParam = new WindowCreateParam(m_defaultParam);
				windowParam.className = classType;
				var cdi:ComponentDisplayItem;
				var cds:ComponentDisplayStateInfo;
				var wrec:Rectangle;
				var trec:Rectangle;				
				switch(classType) {
					case WindowClassName.NORMAL_WND:
						windowParam.width = 400;
						windowParam.height =400;
						windowParam.title = "";
						cdi = windowParam.getSubCtrlInfo(CommonWndSubCtrlType.BACKGROUND);						
						wrec = new Rectangle(0, 0, windowParam.width, windowParam.height);
						cds = new ComponentDisplayStateInfo();
						trec = new Rectangle(0, 0, windowParam.width, windowParam.height);
						cds.imageList.addImage(0, "gui/tex/main09.png", trec, wrec, 0xFFFFFFFF);			
						cdi.displayStateInfos[SubCtrlStateType.ENABLE] = cds;											
						break;					
					case WindowClassName.BUTTON:
						windowParam.width = 58;
						windowParam.height = 24;
						windowParam.title = "button";
						cdi = windowParam.getSubCtrlInfo(CommonWndSubCtrlType.BACKGROUND);						
						wrec = new Rectangle(0, 0, windowParam.width, windowParam.height);
						cds = new ComponentDisplayStateInfo();
						trec = new Rectangle(120, 329, windowParam.width, windowParam.height);
						cds.imageList.addImage(0, "gui/tex/main01.png", trec, wrec, 0xFFFFFFFF);			
						cdi.displayStateInfos[SubCtrlStateType.ENABLE] = cds;
						cds = new ComponentDisplayStateInfo();
						trec = new Rectangle(182, 329, windowParam.width, windowParam.height);
						cds.imageList.addImage(0, "gui/tex/main01.png", trec, wrec, 0xFFFFFFFF);
						cdi.displayStateInfos[SubCtrlStateType.MOUSEOVER] = cds;			
						cds = new ComponentDisplayStateInfo();
						trec = new Rectangle(244, 329, windowParam.width, windowParam.height);
						cds.imageList.addImage(0, "gui/tex/main01.png", trec, wrec, 0xFFFFFFFF);
						cdi.displayStateInfos[SubCtrlStateType.CLICKDOWN] = cds;
						cds = new ComponentDisplayStateInfo();
						trec = new Rectangle(306, 329, windowParam.width, windowParam.height);
						cds.imageList.addImage(0, "gui/tex/main01.png", trec, wrec, 0xFFFFFFFF);
						cdi.displayStateInfos[SubCtrlStateType.DISABLE] = cds;							
						break;
					case WindowClassName.EDIT:
						windowParam.width = 167;
						windowParam.height = 26;
						windowParam.xBorder = 7;
						windowParam.yBorder = 7;
						//windowParam.style = 0x45800000;
						var arr:Array = 
						[
							[null,[
									[0,0,[
										[0,0,"",new Rectangle(0,0,45,19),new Rectangle(0,0,45,19),0xff00000000]
										]],
									[0,0,[
										[0,15,"",new Rectangle(0,0,45,19),new Rectangle(0,0,45,19),0xff00000000],
										[0,15,"",new Rectangle(0,0,45,19),new Rectangle(0,0,43,17),0xffffffffe1]
										]],
									[0xffffffff,0,[
										[1,15,"main01",new Rectangle(72,101,2,2),new Rectangle(10,10,147,6),0xffffffff],
										[0,5,"main01",new Rectangle(66,90,10,10),new Rectangle(0,0,10,10),0xffffffff],
										[0,10,"main01",new Rectangle(90,106,10,10),new Rectangle(157,16,10,10),0xffffffff],
										[0,6,"main01",new Rectangle(90,90,10,10),new Rectangle(157,0,10,10),0xffffffff],
										[1,14,"main01",new Rectangle(90,97,10,2),new Rectangle(157,10,10,6),0xffffffff],
										[1,7,"main01",new Rectangle(82,90,6,10),new Rectangle(10,0,147,10),0xffffffff],
										[1,11,"main01",new Rectangle(82,106,6,10),new Rectangle(10,16,147,10),0xffffffff],
										[1,13,"main01",new Rectangle(66,103,10,2),new Rectangle(0,10,10,6),0xffffffff],
										[0,9,"main01",new Rectangle(66,106,10,10),new Rectangle(0,16,10,10),0xffffffff]							
										]]
									]
							]								
						];
						cdi = windowParam.getSubCtrlInfo(EditSubCtrlType.BACKGROUND);
						cdi.rect = arr[0][0];
						for(var i:int = 0;i<arr[0][1].length;i++){
							var arrT:Array = arr[0][1][i];
							cds = new ComponentDisplayStateInfo();
							cds.fontColor = arrT[0];
							cds.fontEdgeColor = arrT[1];
							for(var j:int = 0;j<arrT[2].length;j++){
								cds.imageList.addImage(j, "gui/tex/"+arrT[2][j][2]+".png", arrT[2][j][3], arrT[2][j][4], arrT[2][j][5],arrT[2][j][1],arrT[2][j][0]);							
							}
							cdi.displayStateInfos[i] = cds;
						}
								
						cdi = windowParam.getSubCtrlInfo(EditSubCtrlType.BACKGROUND);
						cdi = windowParam.getSubCtrlInfo(EditSubCtrlType.HORIZON_SCROLLBAR);
						cdi = windowParam.getSubCtrlInfo(EditSubCtrlType.HORIZON_SCROLLBAR_DOWN_BTN);
						cdi = windowParam.getSubCtrlInfo(EditSubCtrlType.HORIZON_SCROLLBAR_UP_BTN);
						cdi = windowParam.getSubCtrlInfo(EditSubCtrlType.HORIZON_SCROLLBAR_THUMB);
						cdi = windowParam.getSubCtrlInfo(EditSubCtrlType.VERTICAL_SCROLLBAR);
						cdi = windowParam.getSubCtrlInfo(EditSubCtrlType.VERTICAL_SCROLLBAR_DOWN_BTN);
						cdi = windowParam.getSubCtrlInfo(EditSubCtrlType.VERTICAL_SCROLLBAR_UP_BTN);
						cdi = windowParam.getSubCtrlInfo(EditSubCtrlType.VERTICAL_SCROLLBAR_THUMB);
						break;
				}
				m_windowParams[classType] = windowParam;
			}*/
		}
		
		public function GetCreateParam(type:String):WindowCreateParam{
			return m_windowParams[type]?m_windowParams[type]:m_defaultParam;
		}
		
		public function getCreateURL(type:String):String
		{
			return m_windowUrls[type];
		}
	}
}