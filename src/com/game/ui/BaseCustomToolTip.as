package com.game.ui
{
	import deltax.gui.component.DeltaXWindow;
	import deltax.gui.component.ICustomTooltip;

	/**
	 * 基础tips 
	 * @author Exin
	 * 
	 */	
	public class BaseCustomToolTip implements ICustomTooltip
	{
		public function BaseCustomToolTip()
		{
		}
		
		public function prepareContent(targetGui:DeltaXWindow, param:Object=null):Boolean
		{
			return true;
		}
		
		public function postCalcPosition(targetGui:DeltaXWindow, param:Object=null):void
		{
			
		}
	}
}