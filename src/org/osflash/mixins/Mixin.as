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
	import org.flemit.util.DescribeTypeUtil;
	import org.flemit.util.MethodUtil;
	import org.osflash.mixins.generator.IMixinLoader;
	import org.osflash.mixins.generator.MixinGenerator;
	import org.osflash.mixins.generator.MixinLoader;
	import org.osflash.mixins.generator.signals.IMixinLoaderSignals;

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
		protected var definitions : MixinBindingList = MixinBindingList.NIL;
		
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
		protected const mixinLoader : IMixinLoader = new MixinLoader();
					
		/**
		 * Empty constructor
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
		public function generate() : IMixinLoaderSignals
		{
			if(!mixinLoader.contains(this)) mixinLoader.add(this);
			return mixinLoader.load(getApplicationDomain());
		}
		
		/**
		 * @inheritDoc
		 */
		public function inject(domain : ApplicationDomain) : void
		{
			var definitionsToProcess : MixinBindingList = definitions;
			while (definitionsToProcess.nonEmpty)
			{
				const definition : Class = definitionsToProcess.head.key;
				
				const qname : QualifiedName = generatedNames[definition];
				const fullName : String = qname.ns.name.concat('::', qname.name);
				if(domain.hasDefinition(fullName))
				{
					const generatedClass : Class = domain.getDefinition(fullName) as Class;
				
					classes[definition] = generatedClass;
				}
				else
				{
					throw new IllegalOperationError('Unable to locate definition with name (' +
																		fullName + ')');
				}
				
				definitionsToProcess = definitionsToProcess.tail;
			}
						
			mixinGenerator.dispose();
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
			
			const classType : Type = Type.getType(definition);
			
			const constructorArgCount : int = MethodUtil.getRequiredArgumentCount(
																			classType.constructor);
			
			// Get the parameters out of the dynamic class
			const dynamicClass : DynamicClass = dynamicClasses[definitive];
			const params : Array = dynamicClass.constructor.parameters;
			const paramsTotal : int = params.length;
			
			var i : int;
			var param : ParameterInfo;
			var paramName : String;
			
			// Parse them for the constructor.				
			var argumentValues : Array;
			if(null != args)
			{
				// Find how many arguments there are.			
				var argsLength : int = 0;
				var prop : String;
				for(prop in args) { argsLength++; }
				
				// Work out if we're correct.
				if(argsLength == 0 && constructorArgCount > 0)
					throw MixinError.ARGUMENTS_ARE_REQURIED;
				else if(argsLength < constructorArgCount)
					throw MixinError.CONSTRUCTOR_ARGUMENT_MISMATCH;
				else
				{
					argumentValues = [];
					
					for (i = 0; i < paramsTotal; i++)
					{
						param = params[i];
						paramName = param.name;
						
						if (args.hasOwnProperty(paramName))
							argumentValues.push(args[paramName]);
						else if (param.optional == false)
							throw new ArgumentError('The argument map did not contain an entry ' +
									'for "' + paramName + '" and this parameter is not optional');
						else
							argumentValues.push(null);
					}
					
					// hot path through
					if(argumentValues.length == 0)
						return ClassUtility.createClass(definition);
				}
			}
			else
			{
				// hot path through
				if(paramsTotal == 0)
					return ClassUtility.createClass(definition);
				
				argumentValues = [];
				
				// normal creation
				for (i = 0; i < paramsTotal; i++)
				{
					param = params[i];
					paramName = param.name;
					
					if (param.optional == false)
						throw new ArgumentError('The argument map did not contain an entry for "' + 
												paramName + '" and this parameter is not optional');
					else
						argumentValues.push(null);
				}
			}
			
			// generate the class with the required argument values.
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
			definitions = MixinBindingList.NIL;
			
			cleanup();
		}
		
		/**
		 * @private
		 */
		protected function cleanup() : void
		{
			// This is the most through way to clean everything up.
			var key : String;
			for(key in classes) 
				delete classes[key];
				
			for(key in generatedNames)
				delete generatedNames[key];
				
			for(key in dynamicClasses)
				delete dynamicClasses[key];
				
			mixinGenerator.dispose();
			mixinLoader.dispose();
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
		protected function createDynamicClass(	name : QualifiedName, 
												base : Type, 
												superType : Type,
												injectors : Dictionary
												) : DynamicClass
		{
			const interfaces : Array = base.getInterfaces();
			const mixins : Dictionary = new Dictionary();
			
			const total : int = interfaces.length;
			for(var i : int = 0; i<total; i++)
			{
				const type : Type = interfaces[i];
				const binding : IMixinBinding = bindings.find(type.classDefinition);
				if(null != binding)
				{
					mixins[type] = binding.value;
				}
				else
				{
					throw new MixinError('Interface ' + type.name + ' defined on ' + base.name + 
																		' has not been defined'); 
				}
			}
						
			return mixinGenerator.generate(name, base, superType, mixins, injectors);
		}
		
		/**
		 * Build the byte code layout
		 */
		public function buildByteCodeLayout() : IByteCodeLayout
		{
			// Move on to the generate the classes
			const total : int = definitions.length;
			if (total == 0)
			{
				throw new IllegalOperationError('No definition classes were defined. Use ' +
												'define() to create mixins.');
			}
			
			// Create a new layout builder
			const layoutBuilder : IByteCodeLayoutBuilder = new ByteCodeLayoutBuilder();
						
			// go through the classes to prepare and start to register them
			var definitionsToProcess : MixinBindingList = definitions;
			while (definitionsToProcess.nonEmpty)
			{
				const definitionBinding : IMixinNamedBinding = 
													IMixinNamedBinding(definitionsToProcess.head);
				const definition : Class = definitionBinding.key;
				const superClass : Class = definitionBinding.value;
				
				const type : Type = Type.getType(definition);
				const superType : Type = Type.getType(superClass);
				
				const injectors : Dictionary = getMetadataFromInjector(type, superType, superClass);
					
				const name : QualifiedName = definitionBinding.name;
				const dynamicClass : DynamicClass = createDynamicClass(	name, 
																		type, 
																		superType, 
																		injectors
																		);
				generatedNames[definition] = name;
				dynamicClasses[definition] = dynamicClass;
				
				layoutBuilder.registerType(dynamicClass);
				
				definitionsToProcess = definitionsToProcess.tail;
			}
			
			// Create the bytecode layout from the layout builder.
			return layoutBuilder.createLayout();
		}
		
		/**
		 * @private
		 */
		protected function getMetadataFromInjector(	type : Type, 
													superType : Type,
													superClass : Class
													) : Dictionary
		{
			const injectors : Dictionary = new Dictionary(true);
			if(superType.name != "Object")
			{
				const description : XML = DescribeTypeUtil.describe(superClass);
				
				const factory : XMLList = description.child('factory');
				if(factory.length() == 0) return injectors;
				
				const variables : XMLList = factory.child('variable');
				if(variables.length() == 0) return injectors;
				
				for each(var variable : XML in variables)
				{
					const metadata : XMLList = variable.child('metadata');
					
					if(metadata.@name == 'Inject')
					{
						const variableName : String = variable.@name;
						const variableType : String = String(variable.@type).replace(/::/, ":");
						
						if(variableType == type.qname.toString())
						{
							injectors[variableName] = type;
						}
						else
						{
							var found : Boolean = false;
							var bindingsToProcess : MixinBindingList = bindings;
							while(bindingsToProcess.nonEmpty)
							{
								const binding : IMixinBinding = bindingsToProcess.head;
								const descriptor : Class = binding.key;
								const implementation : Class = binding.value;
								
								const descriptorType : Type = Type.getType(descriptor);
								
								if(descriptorType.qname.toString() == variableType)
								{
									injectors[variableName] = binding;
									
									found = true;
									break;
								}
								
								bindingsToProcess = bindingsToProcess.tail;
							}
							
							if(!found)
							{
								throw new IllegalOperationError('Unable to inject type (' + 
											variableType + ') into variable (' + variableName + ')');
							}
						}
					}
				}
			}
			return injectors;
		}
	}
}
