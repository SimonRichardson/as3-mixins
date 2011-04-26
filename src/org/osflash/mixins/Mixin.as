package org.osflash.mixins
{
	import org.osflash.mixins.generator.MixinGenerator;
	import org.flemit.bytecode.DynamicClass;
	import org.flemit.bytecode.QualifiedName;
	import org.flemit.reflection.Type;
	import org.osflash.mixins.generator.MixinGenerationSignals;

	import flash.errors.IllegalOperationError;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class Mixin implements IMixin
	{
		
		
		/**
		 * @private
		 */
		protected var bindings : MixinBindingList = MixinBindingList.NIL;
		
		/**
		 * @private
		 */
		protected const definitions : Dictionary = new Dictionary();
		
		/**
		 * @private
		 */
		protected const mixinGenerator : MixinGenerator = new MixinGenerator();
		
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
			if(null == implementation) throw new ArgumentError('Given implementation can not ' + 
																					'be null');
			
			if(definitions[implementation]) throw new ArgumentError('You cannot define() the ' + 
													'same implementation without removing the ' + 
													'relationship first.');
			
			definitions[implementation] = true;
		}
		
		/**
		 * @inheritDoc
		 */
		public function generate() : MixinGenerationSignals
		{
			const allDefinitions : Vector.<Class> = new Vector.<Class>();
			
			for each(var definition : Class in definitions)
			{
				allDefinitions.push(definition);
			}
			
			if (allDefinitions.length == 0)
			{
				throw new IllegalOperationError('No definition classes were defined. Use ' +
												'define() to create mixins.');
			}
			
			return prepareClasses(allDefinitions, createDynamicClass);
		}
		
		/**
		 * @inheritDoc
		 */
		public function create(definitive : Class) : *
		{
			const definition : Class = definitions[definitive];
			if (definition == null)
			{
				throw new ArgumentError("A class for " 
					+ getQualifiedClassName(definitive) + " has not been defined yet.");
			}
			
			
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
			
			for(var definition : Class in definitions)
			{
				delete definitions[definition];
			}
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
		
		/**
		 * @private
		 */
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
		 * @private
		 */
		protected function prepareClasses(	classesToPrepare : Vector.<Class>, 
											generator : Function
										) : MixinGenerationSignals
		{
			return null;
		}
		
		/**
		 * @private
		 */
		protected function createDynamicClass(name:QualifiedName, base:Type) : DynamicClass
		{
			const interfaces : Array = base.getInterfaces();
			const mixins : Dictionary = new Dictionary();
			
			for each (var type : Type in interfaces)
			{
				const binding : IMixinBinding = bindings.find(type.classDefinition);
				if(null != binding)
				{
					if(!binding.ignore) mixins[type] = binding.implementation;
				}
				else
				{
					throw new MixinError('Interface ' + type + ' defined on ' + base + 
											'has not being defined'); 
				}
			}
			
			return mixinGenerator.generate(name, base, mixins);
		}
	}
}
