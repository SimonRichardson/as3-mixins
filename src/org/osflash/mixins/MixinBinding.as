package org.osflash.mixins
{
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class MixinBinding implements IMixinBinding
	{
		
		/**
		 * @private
		 */
		private var _key : Class;
		
		/**
		 * @private
		 */
		private var _value : Class;
		

		public function MixinBinding(key : Class, value : Class)
		{
			_key = key;
			_value = value;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get key() : Class { return _key; }
		public function set key(value : Class) : void { _key = value;	}
		
		/**
		 * @inheritDoc
		 */
		public function get value() : Class { return _value; }
		public function set value(value : Class) : void { _value = value; }
		
	}
}
