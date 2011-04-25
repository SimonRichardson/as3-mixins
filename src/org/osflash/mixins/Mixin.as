package org.osflash.mixins
{
	import org.osflash.signals.ISignal;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class Mixin implements IMixin
	{
		
		/**
		 * @private
		 */
		private var _completedSignal : ISignal;
		
		/**
		 * @private
		 */
		private var _errorSignal : ISignal;
		
		/**
		 * 
		 */
		public function Mixin()
		{
		}
		
		/**
		 * @inheritDoc
		 */
		public function add(descriptor : Class, implementation : Class) : IMixinBinding
		{
			return null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function remove(descriptor : Class, implementation : Class) : IMixinBinding
		{
			return null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function removeAll() : void
		{
			
			
			_completedSignal.removeAll();
			_errorSignal.removeAll();
		}
		
		/**
		 * @inheritDoc
		 */
		public function define(implementation : Class) : void
		{
		}
		
		/**
		 * @inheritDoc
		 */
		public function create(definitive : Class) : void
		{
		}
		
		/**
		 * @inheritDoc
		 */
		public function get completedSignal() : ISignal	{ return _completedSignal; }
		
		/**
		 * @inheritDoc
		 */
		public function get errorSignal() : ISignal	{ return _errorSignal; }
	}
}
