package events
{
	import flash.events.Event;

	/**
	 * 按键后由焦点显示对象发布的按键事件。与 KeyboardEvent 不同的是，本事件不依赖于 Flash 自带的焦点机制，而是由框架管理。
	 * @author pengzhitao
	 */
	public class KeyEvent extends Event
	{
		/**
		 * 当按键被按下
		 */
		public static const KEY_BOARD_DOWN:String = "keyBoardDown";

		/**
		 * 当按键被抬起
		 */
		public static const KEY_BOARD_UP:String = "keyBoardUp";

		/**
		 * Enter键被按下的事件。
		 */
		public static const ENTER:String = "enter";

		/**
		 * 在 Windows 中，指示 Alt 键是处于活动状态 (true) 还是非活动状态 (false)；在 Mac OS 中，指示 Option 键是否处于活动状态。
		 */
		public var altKey:Boolean;

		/**
		 * 包含按下或释放的键的字符代码值。
		 */
		public var charCode:uint;

		/**
		 * 在 Windows 中，指示 Ctrl 键是处于活动状态 (true) 还是非活动状态 (false)；在 Mac OS 中，指示 Ctrl 键或 Command 键是否处于活动状态。
		 */
		public var ctrlKey:Boolean;

		/**
		 * 按下或释放的键的键控代码值。
		 */
		public var keyCode:uint;

		/**
		 * 指示键在键盘上的位置。
		 */
		public var keyLocation:uint;

		/**
		 * 指示 Shift 功能键是处于活动状态 (true) 还是非活动状态 (false)。
		 */
		public var shiftKey:Boolean;

		/**
		 * 自定义的焦点对象
		 */
		public var focusTarget:*;

		/**
		 * 构造函数
		 * @param type 事件的类型。可能的值为：KeyEvent.KEY_DOWN 和 KeyEvent.KEY_UP
		 * @param bubbles 确定 Event 对象是否参与事件流的冒泡阶段。
		 * @param cancelable 确定是否可以取消 Event 对象。
		 * @param charCodeValue 按下或释放的键的字符代码值。返回的字符代码值为英文键盘值。例如，如果您按 Shift+3，则 getASCIICode() 方法在日文键盘上将返回 #，就像在英文键盘上一样。
		 * @param keyCodeValue 按下或释放的键的键控代码值。
		 * @param keyLocationValue 按键在键盘上的位置。
		 * @param ctrlKeyValue 在 Windows 中，指示是否已激活 Ctrl 键。在 Mac 中，指示是否已激活 Ctrl 键或 Command 键。
		 * @param altKeyValue 指示是否已激活 Alt 功能键（仅限 Windows）。
		 * @param shiftKeyValue 指示是否已激活 Shift 功能键。
		 */
		public function KeyEvent(type:String, bubbles:Boolean = true, cancelable:Boolean = false, charCodeValue:uint = 0, keyCodeValue:uint = 0, keyLocationValue:uint = 0, ctrlKeyValue:Boolean = false, altKeyValue:Boolean = false, shiftKeyValue:Boolean = false)
		{
			super(type, bubbles, cancelable);

			charCode = charCodeValue;
			keyCode = keyCodeValue;
			keyLocation = keyLocationValue;
			ctrlKey = ctrlKeyValue;
			altKey = altKeyValue;
			shiftKey = shiftKeyValue;
		}
	}
}
