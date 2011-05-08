package org.osflash.mixins.support.init.impl
{
	import flash.display.Sprite;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class BasicImpl extends Sprite
	{
		
		private var _initCalled : Boolean = false;
		
		public function __init__() : void
		{
			_initCalled = true;
		}
		
		public function reset() : void
		{
			_initCalled = false;
		}

		public function get initCalled() : Boolean
		{
			return _initCalled;
		}
	}
}
