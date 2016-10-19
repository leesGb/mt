package com.game.manager
{
	import deltax.appframe.BaseApplication;
	
	import flash.display.Stage;

	/**
	 * Stage管理 
	 * @author Exin
	 * 
	 */	
	public class StageManager
	{
		private static var _instance:StageManager;
		public static function get instance():StageManager
		{
			return _instance?_instance:new StageManager();
		}
		
		public static function get stage():Stage
		{
			return StageManager.instance.stage;
		}
		
		private var _stage:Stage;
		
		public function StageManager()
		{
			if (_instance) {
				throw new Error("StageManager");
			}
			_instance = this;
		}
		
		public function init(stage:Stage):void
		{
			_stage = stage;
		}
		
		public function get stage():Stage
		{
			if(!_stage)
			{
				_stage = BaseApplication.instance.rootUIComponent.stage;
			}
			return _stage;
		}
	}
}