package org.osflash.mixins
{
	import org.flemit.bytecode.ByteCodeLayoutBuilder;
	import org.flemit.bytecode.DynamicClass;
	import org.flemit.bytecode.IByteCodeLayout;
	import org.flemit.bytecode.IByteCodeLayoutBuilder;
	import org.flemit.bytecode.QualifiedName;
	import org.flemit.reflection.ParameterInfo;
	import org.flemit.reflection.Type;
	import org.flemit.util.ClassUtility;
	import org.flemit.util.MethodUtil;
	import org.osflash.mixins.generator.MixinGenerationSignals;
	import org.osflash.mixins.generator.MixinGenerator;
	import org.osflash.mixins.generator.MixinLoaderGenerator;
	import org.osflash.mixins.generator.MixinQualifiedName;
	import org.osflash.signals.ISignal;

	import flash.errors.IllegalOperationError;
	import flash.system.ApplicationDomain;
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
		protected const definitions : Vector.<Class> = new Vector.<Class>();
		
		/**
		 * @private
		 */
		protected const dynamicClasses : Dictionary = new Dictionary();
		
		/**
		 * @private
		 */
		protected const classes : Dictionary = new Dictionary();
		
		/**
		 * @private
		 */		
		protected const generatedNames : Dictionary = new Dictionary();
				
		/**
		 * @private
		 */
		protected const mixinGenerator : MixinGenerator = new MixinGenerator();
		
		/**
		 * @private
		 */
		protected var loaderCompletedSignal : ISignal;
		
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
			const index : int = definitions.indexOf(implementation);
			if(index != -1) throw new ArgumentError('You cannot define() the same implementation ' +
													'without removing the relationship first.');
			definitions.push(implementation);
		}
		
		/**
		 * @inheritDoc
		 */
		public function generate() : MixinGenerationSignals
		{
			if (definitions.length == 0)
			{
				throw new IllegalOperationError('No definition classes were defined. Use ' +
												'define() to create mixins.');
			}
			
			const layoutBuilder : IByteCodeLayoutBuilder = new ByteCodeLayoutBuilder();
			
			// go through the classes to prepare and start to register them
			const total : int = definitions.length;
			for(var i : int = 0; i<total; i++)
			{
				const implementation : Class = definitions[i];
				
				const type : Type = Type.getType(implementation);
				const name : QualifiedName = MixinQualifiedName.create(type);
				const dynamicClass : DynamicClass = createDynamicClass(name, type);
				
				generatedNames[implementation] = name;
				dynamicClasses[implementation] = dynamicClass;
				
				layoutBuilder.registerType(dynamicClass);
			}
			
			// Create the bytecode layout from the layout builder.
			const layout : IByteCodeLayout = layoutBuilder.createLayout();
						
			// Generate a new loader with the containing bytecode
			return createLoader(layout);
		}
		
		/**
		 * @inheritDoc
		 */
		public function inject(applicationDomain : ApplicationDomain) : void
		{
			const total : int = definitions.length;
			for(var i : int = 0; i<total; i++)
			{
				const implementation : Class = definitions[i];
				const qname : QualifiedName = generatedNames[implementation];
				const fullName : String = qname.ns.name.concat('::', qname.name);
				const generatedClass : Class = applicationDomain.getDefinition(fullName) as Class;
					
				// Type.getType(generatedClass);
				classes[implementation] = generatedClass;
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function create(definitive : Class, args : Object = null) : *
		{
			const definition : Class = classes[definitive];
			if (definition == null)
			{
				throw new ArgumentError("A class for " 
					+ getQualifiedClassName(definitive) + " has not been defined yet.");
			}
			
			const dynamicClass : DynamicClass = dynamicClasses[definitive];
			const classType : Type = Type.getType(definition);
			const params : Array = dynamicClass.constructor.parameters;
			
			const argumentValues : Array = [];
			if(null != args)
			{
				const constructorArgCount : int = MethodUtil.getRequiredArgumentCount(
																			classType.constructor);
				
				// Work out how many items in the args Object
				var argsLength : int = 0;
				var prop : String;
				for(prop in args)
				{
					argsLength++;
				}
				
				// Make sure they both add up.
				if (argsLength != constructorArgCount)
				{
					throw new ArgumentError('Constructor expects at least ' + 
																constructorArgCount + 'arguemnts');
				}
				
				const total : int = params.length;
				for (var i : int = 0; i < total;  i++)
				{
					const param : ParameterInfo = params[i];
					const paramName : String = param.name;
					
					if (args.hasOwnProperty(paramName))
						argumentValues.push(args[paramName]);
					else if (!param.optional)
						throw new ArgumentError('The argument map did not contain an entry for "' + 
												paramName + '" and this parameter is not optional');
				}
			}
			
			return ClassUtility.createClass(definition, argumentValues);
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
			
			var index : int = definitions.length;
			while(--index > -1)
			{
				definitions.pop();
			}
			definitions.length = 0;
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
		protected function createLoader(layout : IByteCodeLayout) : MixinGenerationSignals
		{
			// Set the current application domain.
			const loaderDomain : ApplicationDomain = getApplicationDomain();
			const domain : ApplicationDomain = new ApplicationDomain(loaderDomain);
			
			// Create the loader			
			const mixinLoader : MixinLoaderGenerator = new MixinLoaderGenerator(layout, domain);
			
			// Using the signals generate loader feedback
			const signals : MixinGenerationSignals = new MixinGenerationSignals(this, mixinLoader);
			
			// Load the bytes
			mixinLoader.load();
			
			return signals;
		}
				
		/**
		 * @private
		 */
		protected function getApplicationDomain() : ApplicationDomain
		{
			return ApplicationDomain.currentDomain;
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
