package displayUI
{
	import deltax.gui.base.ComponentDisplayItem;
	import deltax.gui.base.ComponentDisplayStateInfo;
	import deltax.gui.base.DisplayImageInfo;
	import deltax.gui.component.DeltaXCheckBox;
	import deltax.gui.component.DeltaXComboBox;
	import deltax.gui.component.DeltaXScrollBar;
	import deltax.gui.component.DeltaXTable;
	import deltax.gui.component.DeltaXTree;
	import deltax.gui.component.DeltaXWindow;
	import deltax.gui.component.subctrl.ComboBoxSubCtrlType;
	import deltax.gui.component.subctrl.CommonWndSubCtrlType;
	import deltax.gui.component.subctrl.ListSubCtrlType;
	import deltax.gui.component.subctrl.ScrollBarSubCtrlType;
	import deltax.gui.component.subctrl.TreeSubCtrlType;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	

	public class DisplayItemManager
	{
		private static var _instance:DisplayItemManager;
		public function DisplayItemManager()
		{
		}
		
		public function setRect(window:DeltaXWindow,displayItem:ComponentDisplayItem):void{
			var rect:Rectangle = displayItem.rect;			
			var targetWin:DeltaXWindow =  getTargetWin(window,displayItem);			
			
			if(targetWin){
				trace(targetWin.bounds);				
				for each(var disStateInfo:ComponentDisplayStateInfo in displayItem.displayStateInfos){
					if(disStateInfo){						
						var srcRect:Rectangle = disStateInfo.imageList.bounds;
						if(srcRect){
							disStateInfo.imageList.scaleAll(rect.width-srcRect.width,rect.height-srcRect.height);
						}
					}
				}
				if(targetWin.parent is DeltaXScrollBar){
					targetWin.setLocation(rect.x-targetWin.parent.x,rect.y-targetWin.parent.y);
				}else{
					targetWin.setLocation(rect.x,rect.y);
				}
				
//				targetWin.setSize(rect.width,rect.height);
			}
		}	
		
		public function getTargetWin(window:DeltaXWindow,displayItem:ComponentDisplayItem):DeltaXWindow{
			var targetWin:DeltaXWindow;		
			if(window is DeltaXScrollBar){
				if(displayItem==window.properties.displayItems[ScrollBarSubCtrlType.THUMB-1]){
					targetWin = (window as DeltaXScrollBar).thumbBtn;					
				}else if(displayItem==window.properties.displayItems[ScrollBarSubCtrlType.UP_BUTTON-1]){
					targetWin = (window as DeltaXScrollBar).incrementBtn;
				}else if(displayItem==window.properties.displayItems[ScrollBarSubCtrlType.DOWN_BUTTON-1]){
					targetWin = (window as DeltaXScrollBar).decrementBtn;
				}
			}else if(window is DeltaXTable){
				if(displayItem==window.properties.displayItems[ListSubCtrlType.VERTICAL_SCROLLBAR-1]){
					targetWin = (window as DeltaXTable).verticalScrollBar;					
				}else if(displayItem==window.properties.displayItems[ListSubCtrlType.VERTICAL_SCROLLBAR_DOWN_BTN-1]){
					if(targetWin = (window as DeltaXTable).verticalScrollBar)
						targetWin = (window as DeltaXTable).verticalScrollBar.decrementBtn;
				}else if(displayItem==window.properties.displayItems[ListSubCtrlType.VERTICAL_SCROLLBAR_THUMB-1]){
					if(targetWin = (window as DeltaXTable).verticalScrollBar)
						targetWin = (window as DeltaXTable).verticalScrollBar.thumbBtn;
				}else if(displayItem==window.properties.displayItems[ListSubCtrlType.VERTICAL_SCROLLBAR_UP_BTN-1]){
					if(targetWin = (window as DeltaXTable).verticalScrollBar)
						targetWin = (window as DeltaXTable).verticalScrollBar.incrementBtn;
				}else if(displayItem==window.properties.displayItems[ListSubCtrlType.HORIZON_SCROLLBAR-1]){
					targetWin = (window as DeltaXTable).horizontalScrollBar;
				}else if(displayItem==window.properties.displayItems[ListSubCtrlType.HORIZON_SCROLLBAR_DOWN_BTN-1]){
					if(targetWin = (window as DeltaXTable).horizontalScrollBar)
						targetWin = (window as DeltaXTable).horizontalScrollBar.decrementBtn;
				}else if(displayItem==window.properties.displayItems[ListSubCtrlType.HORIZON_SCROLLBAR_THUMB-1]){
					if(targetWin = (window as DeltaXTable).horizontalScrollBar)
						targetWin = (window as DeltaXTable).horizontalScrollBar.thumbBtn;
				}else if(displayItem==window.properties.displayItems[ListSubCtrlType.HORIZON_SCROLLBAR_UP_BTN-1]){
					if(targetWin = (window as DeltaXTable).horizontalScrollBar)
						targetWin = (window as DeltaXTable).horizontalScrollBar.incrementBtn;
				}
			}else if(window is DeltaXTree){
				if(displayItem==window.properties.displayItems[TreeSubCtrlType.VERTICAL_SCROLLBAR-1]){
					targetWin = (window as DeltaXTree).verticalScrollBar;					
				}else if(displayItem==window.properties.displayItems[TreeSubCtrlType.VERTICAL_SCROLLBAR_THUMB-1]){
					targetWin = (window as DeltaXTree).verticalScrollBar.thumbBtn;
				}else if(displayItem==window.properties.displayItems[TreeSubCtrlType.VERTICAL_SCROLLBAR_UP_BTN-1]){
					targetWin = (window as DeltaXTree).verticalScrollBar.incrementBtn;
				}else if(displayItem==window.properties.displayItems[TreeSubCtrlType.VERTICAL_SCROLLBAR_DOWN_BTN-1]){
					targetWin = (window as DeltaXTree).verticalScrollBar.decrementBtn;
				}
			}else if(window is DeltaXComboBox){
				if(displayItem==window.properties.displayItems[ComboBoxSubCtrlType.DROP_BUTTON-1]){
					targetWin = (window as DeltaXComboBox).dropDownButton;					
				}else if(displayItem==window.properties.displayItems[ComboBoxSubCtrlType.LISTBOX_BACKGROUND-1]){
					targetWin = (window as DeltaXComboBox).getPopupList();
				}else if(displayItem==window.properties.displayItems[ComboBoxSubCtrlType.LISTBOX_SCROLLBAR-1]){
					targetWin = (window as DeltaXComboBox).verticalScrollBar;
				}else if(displayItem==window.properties.displayItems[ComboBoxSubCtrlType.LISTBOX_SCROLLBAR_DOWN_BTN-1]){
					targetWin = (window as DeltaXComboBox).verticalScrollBar.decrementBtn;
				}else if(displayItem==window.properties.displayItems[ComboBoxSubCtrlType.LISTBOX_SCROLLBAR_THUMB-1]){
					targetWin = (window as DeltaXComboBox).verticalScrollBar.thumbBtn;
				}else if(displayItem==window.properties.displayItems[ComboBoxSubCtrlType.LISTBOX_SCROLLBAR_UP_BTN-1]){
					targetWin = (window as DeltaXComboBox).verticalScrollBar.decrementBtn;
				}
			}
			return targetWin;
		}
		
		public function setToRect(window:DeltaXWindow):void{
			var dItem:ComponentDisplayItem;
			if(!window)return;
			if(!window.properties)return;
			for each(dItem in window.properties.displayItems){
				if(!dItem) continue;
				var delWin:DeltaXWindow = getTargetWin(window,dItem);
				if(	delWin && dItem.rect){
					if(delWin.parent && delWin.childTopMost==null){						
						dItem.rect.setTo(delWin.parent.x+delWin.x,delWin.parent.y+delWin.y,delWin.width,delWin.height);
					}else{
						dItem.rect.setTo(delWin.x,delWin.y,delWin.width,delWin.height);
						for each(var disStateInfo:ComponentDisplayStateInfo in dItem.displayStateInfos){
							if(disStateInfo){						
								var srcRect:Rectangle = disStateInfo.imageList.bounds;
								if(srcRect){
									disStateInfo.imageList.scaleAll(dItem.rect.width-srcRect.width,dItem.rect.height-srcRect.height);
								}
							}
						}
					}
				}
			}
		}
		

		public static function get instance():DisplayItemManager
		{
			if(!_instance) _instance = new DisplayItemManager();
			return _instance;
		}

	}
}