package events
{
	import flash.events.Event;
	
	/**
	 * UI数据更新事件(全局通用)
	 */
	public class UIDataEvent extends Event
	{
		public var data:Object;
		public function UIDataEvent(type:String, data:Object,bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.data = data;
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			return new UIDataEvent(type,data,bubbles,cancelable);
		}
		
		
	}
}