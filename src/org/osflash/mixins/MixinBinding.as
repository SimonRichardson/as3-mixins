package org.osflash.mixins
{
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class MixinBinding implements IMixinBinding
	{
		
		private var _descriptor : Class;
		
		private var _implementation : Class;
		
		private var _ignore : Boolean;

		public function MixinBinding(descriptor : Class, implementation : Class)
		{
			_descriptor = descriptor;
			_implementation = implementation;
			
			_ignore = false;
		}
		
		public function get implementation() : Class
		{
			return _implementation;
		}

		public function set implementation(value : Class) : void
		{
			_implementation = value;
		}

		public function get ignore() : Boolean
		{
			return _ignore;
		}

		public function set ignore(value : Boolean) : void
		{
			_ignore = value;
		}
	}
}
