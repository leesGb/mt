package manager
{
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	import events.KeyEvent;

	/**
	 * 当按钮被按下的时候发布。
	 * @eventType com.xgame.gui.events.KeyEvent.KEY_BOARD_DOWN
	 */
	[Event(name = "keyBoardDown", type = "com.xgame.gui.events.KeyEvent")]

	/**
	 * 当按钮被释放的时候发布。
	 * @eventType com.xgame.gui.events.KeyEvent.KEY_BOARD_UP
	 */
	[Event(name = "keyBoardUp", type = "com.xgame.gui.events.KeyEvent")]

	/**
	 * 按钮管理器。
	 * @author pengzhitao
	 *
	 */
	public class KeyBoardManager extends EventDispatcher
	{
		private static var _instance:KeyBoardManager;

		public var downKeyCodes:Dictionary;
		private var _isMouseDown:Boolean;
		private var _lastMouseDownObject:DisplayObject;
		private var _keyEnabled:Boolean;

		private var _stage:Stage;
		
		
		
		/**
		 * 鼠标是否按下。
		 */
		public static function get isMouseDown():Boolean
		{
			return instance._isMouseDown;
		}
		
		public static function get lastMouseDownObject():DisplayObject
		{
			return instance._lastMouseDownObject;
		}
		
		/**
		 * 是否响应按钮。
		 */
		public static function get keyEnabled():Boolean
		{
			return instance._keyEnabled;
		}
		
		public static function set keyEnabled(value:Boolean):void
		{
			instance._keyEnabled = value;
		}
		
		
		
		
		/**
		 * 构造函数。
		 */
		public function KeyBoardManager()
		{
		}
		
		public static function get instance():KeyBoardManager
		{
			if(!_instance)
			{
				_instance = new KeyBoardManager();
			}
			return _instance;
		}
		
		public function init(stage:Stage):void
		{
			_stage = stage;
			
			_lastMouseDownObject = stage;
			_keyEnabled = true;
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		
		/**
		 * 判断某键是否按下。
		 * @param keyCode 键的 code 值
		 * @return
		 */
		public static function isKeyDown(keyCode:uint):Boolean
		{
			if(!KeyBoardManager.instance.downKeyCodes)
			{
				return false;
			}
			return Boolean(KeyBoardManager.instance.downKeyCodes[keyCode]);
		}


		private function keyDownHandler(event:KeyboardEvent):void
		{
			if(!downKeyCodes)
				downKeyCodes = new Dictionary();

			downKeyCodes[event.keyCode] = true;

			if(!_lastMouseDownObject)
				return;

			if(!_keyEnabled)
				return;

			var keyEvent:KeyEvent = new KeyEvent(KeyEvent.KEY_BOARD_DOWN);
			keyEvent.charCode = event.charCode;
			keyEvent.keyCode = event.keyCode;
			keyEvent.keyLocation = event.keyLocation;
			keyEvent.ctrlKey = event.ctrlKey;
			keyEvent.altKey = event.altKey;
			keyEvent.shiftKey = event.shiftKey;
			keyEvent.focusTarget = event.target;
			//_lastMouseDownObject.dispatchEvent(keyEvent);
			dispatchEvent(keyEvent);
		}

		private function keyUpHandler(event:KeyboardEvent):void
		{
			if(!downKeyCodes)
				return;
			delete downKeyCodes[event.keyCode];

			if(!_lastMouseDownObject)
				return;

			if(!_keyEnabled)
				return;

			var keyEvent:KeyEvent = new KeyEvent(KeyEvent.KEY_BOARD_UP);
			keyEvent.charCode = event.charCode;
			keyEvent.keyCode = event.keyCode;
			keyEvent.keyLocation = event.keyLocation;
			keyEvent.ctrlKey = event.ctrlKey;
			keyEvent.altKey = event.altKey;
			keyEvent.shiftKey = event.shiftKey;
			//_lastMouseDownObject.dispatchEvent(keyEvent);
			dispatchEvent(keyEvent);
		}

		private function mouseDownHandler(event:MouseEvent):void
		{
			_isMouseDown = true;
			_lastMouseDownObject = event.target as DisplayObject;
		}

		private function mouseUpHandler(event:MouseEvent):void
		{
			_isMouseDown = false;
		}

	}
}
