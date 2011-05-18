package org.osflash.mixins
{
	import flash.errors.IllegalOperationError;
	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public class MixinAbstract
	{
		
		/**
		 * @private
		 */
		protected var bindings : MixinBindingList = MixinBindingList.NIL;
		
		/**
		 * @private
		 */
		protected var definitions : MixinBindingList = MixinBindingList.NIL;
		
		/**
		 * Empty constructor
		 */
		public function MixinAbstract()
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
			if(definitions.contains(descriptor)) throw new ArgumentError('You can not ' + 
											'add a descriptor that is already a implementation');
																					
			return registerDescriptor(descriptor, implementation);
		}
		
		/**
		 * @inheritDoc
		 */
		public function define(	implementation : Class, 
								superClass : Class = null
								) : IMixinNamedBinding
		{
			if(null == implementation) throw new ArgumentError('Given implementation can not ' + 
																					'be null');
			if(bindings.contains(implementation)) throw new ArgumentError('You can not ' +
										'define() a implementation that is already a descriptor');
			if(definitions.contains(implementation)) throw new ArgumentError('You can not ' + 
					'define() the same implementation without removing the relationship first.');
			
			// If we've not got a super class then make one.
			if(null == superClass) 
				superClass = Object;
			
			return registerImplementation(implementation, superClass);
		}
		
		/**
		 * @inheritDoc
		 */
		public function remove(descriptor : Class) : IMixinBinding
		{
			const binding : IMixinBinding = bindings.find(descriptor);
			if (!binding) return null;
			
			bindings = bindings.filterNot(descriptor);
			return binding;
		}
		
		/**
		 * @inheritDoc
		 */
		public function removeAll() : void
		{
			bindings = MixinBindingList.NIL;
			definitions = MixinBindingList.NIL;
		}
		
		/**
		 * @inheritDoc
		 */
		public function dispose() : void
		{
			removeAll();
		}
		
		/**
		 * @private
		 */
		protected function registerDescriptor(	descriptor : Class, 
												implementation : Class
												) : IMixinBinding
		{
			if(registrationDescriptorPossible(descriptor, implementation))
			{
				const binding : IMixinBinding = new MixinBinding(descriptor, implementation);
				bindings = bindings.append(binding);
				return binding;
			}
			
			return bindings.find(descriptor);
		}
		
		/**
		 * @private
		 */
		protected function registrationDescriptorPossible(	descriptor : Class,
															implementation : Class
															) : Boolean
		{
			if (!bindings.nonEmpty) return true;
			
			const existingBindings : IMixinBinding = bindings.find(descriptor);
			if (!existingBindings) return true;
			
			if(existingBindings.value != implementation)
			{
				// If the listener was previously added, definitely don't add it again.
				// But throw an exception if their once values differ.
				throw new IllegalOperationError('You cannot add() the same implementation ' + 
												 ' without removing the relationship first.');
			}
			
			return false;
		}
		
		/**
		 * @private
		 */
		protected function registerImplementation(	implementation : Class, 
													superClass : Class
													) : IMixinNamedBinding
		{
			if(registrationImplementationPossible(implementation, superClass))
			{
				const binding : IMixinNamedBinding = new MixinNamedBinding(	implementation, 
																			superClass
																			);
				definitions = definitions.append(binding);
				return binding;
			}
			
			return IMixinNamedBinding(definitions.find(implementation));
		}
		
		/**
		 * @private
		 */
		protected function registrationImplementationPossible(	implementation : Class,
																superClass : Class
																) : Boolean
		{
			if (!definitions.nonEmpty) return true;
			
			const existingBindings : IMixinBinding = definitions.find(implementation);
			if (!existingBindings) return true;
			
			if(existingBindings.value != superClass)
			{
				// If the listener was previously added, definitely don't add it again.
				// But throw an exception if their once values differ.
				throw new IllegalOperationError('You cannot add() the same implementation ' + 
												 ' without removing the relationship first.');
			}
			
			return false;
		}
	}
}
