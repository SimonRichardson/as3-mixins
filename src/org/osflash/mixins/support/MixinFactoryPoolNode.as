package org.osflash.mixins.support
{
	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	internal final class MixinFactoryPoolNode
	{
		
		private var _mixin : Object;
		
		private var _active : Boolean;

		public function MixinFactoryPoolNode(mixin : Object)
		{
			if(null == mixin)
				throw new ArgumentError('Given mixin can not be null.');
			
			_mixin = mixin;
			_active = false;
		}

		public function get mixin() : Object
		{
			return _mixin;
		}

		public function get active() : Boolean
		{
			return _active;
		}

		public function set active(value : Boolean) : void
		{
			_active = value;
		}
	}
}
