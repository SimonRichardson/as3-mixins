package org.osflash.mixins
{
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;

	import flash.errors.IllegalOperationError;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class Mixin implements IMixin
	{
		
		/**
		 * @private
		 */
		private const _completedSignal : ISignal = new Signal(IMixin);
		
		/**
		 * @private
		 */
		private const _errorSignal : ISignal = new Signal(IMixin, MixinError);
		
		/**
		 * @private
		 */
		protected var bindings : MixinBindingList = MixinBindingList.NIL;
		
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
			if(null == descriptor) throw new ArgumentError('Given descriptor can not be null.');
			if(null == implementation) throw new ArgumentError('Given implementation can not ' +
																					'be null');
																					
			return registerDescriptor(descriptor, implementation);
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
		 * @private
		 */
		protected function registerDescriptor(descriptor : Class, 
												implementation : Class) : IMixinBinding
		{
			if(registrationPossible(descriptor, implementation))
			{
				const binding : IMixinBinding = new MixinBinding(descriptor, implementation);
				bindings = bindings.append(binding);
				return binding;
			}
			
			return bindings.find(descriptor);
		}
		
		protected function registrationPossible(descriptor : Class,
													implementation : Class) : Boolean
		{
			if (!bindings.nonEmpty) return true;
			
			const existingBindings : IMixinBinding = bindings.find(descriptor);
			if (!existingBindings) return true;
			
			if(existingBindings.implementation != implementation)
			{
				// If the listener was previously added, definitely don't add it again.
				// But throw an exception if their once values differ.
				throw new IllegalOperationError('You cannot add() the same implementation ' + 
												 ' without removing the relationship first.');
			}
			
			return false;
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
