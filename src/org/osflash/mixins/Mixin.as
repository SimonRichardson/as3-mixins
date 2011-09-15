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
	public class Mixin extends MixinAbstract implements IMixin
	{
		
		
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
		 * @private
		 */
		protected const layoutBuilder : IByteCodeLayoutBuilder = new ByteCodeLayoutBuilder();
					
		/**
		 * Empty constructor
		 */
		public function Mixin()
		{
			super();
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
					MixinError.throwError(MixinError.ARGUMENTS_ARE_REQURIED);
				else if(argsLength < constructorArgCount)
					MixinError.throwError(MixinError.CONSTRUCTOR_ARGUMENT_MISMATCH);
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
		override public function removeAll() : void
		{
			super.removeAll();
			
			cleanup();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose() : void
		{
			super.dispose();
			
			mixinGenerator.dispose();
			mixinLoader.dispose();
			layoutBuilder.dispose();
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
			
			// TODO : use the new flemit metadata... from Type.methodInfo.metadata
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
