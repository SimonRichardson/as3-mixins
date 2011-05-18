package org.osflash.mixins.generator.generators
{
	import org.flemit.bytecode.BCNamespace;
	import org.flemit.bytecode.DynamicClass;
	import org.flemit.bytecode.DynamicMethod;
	import org.flemit.bytecode.Instructions;
	import org.flemit.bytecode.NamespaceKind;
	import org.flemit.bytecode.QualifiedName;
	import org.flemit.reflection.MemberVisibility;
	import org.flemit.reflection.MethodInfo;
	import org.flemit.reflection.ParameterInfo;
	import org.flemit.reflection.PropertyInfo;
	import org.flemit.reflection.Type;
	import org.osflash.mixins.IMixinBinding;

	import flash.errors.IllegalOperationError;
	import flash.utils.Dictionary;
	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public class MixinIntialiserGenerator implements IGenerator
	{
		
		/**
		 * @private
		 */
		private var _base : Type;
		
		/**
		 * @private
		 */
		private var _mixins : Dictionary;
		
		/**
		 * @private
		 */
		private var _superType : Type;
		
		/**
		 * @private
		 */
		private var _injectors : Dictionary;
		
		/**
		 * @inheritDoc
		 */
		public function generator(dynamicClass : DynamicClass) : void
		{
			dynamicClass.addMethodBody(	dynamicClass.constructor, 
										generateInitialiser(	dynamicClass, 
																mixins, 
																base,
																superType,
																injectors
																)
										);
		}

		/**
		 * @inheritDoc
		 */
		public function dispose() : void
		{
		}
		
		/**
		 * @private
		 */
		protected function generateInitialiser(	dynamicClass : DynamicClass, 
												mixins : Dictionary,
												base : Type,
												superType : Type,
												injectors : Dictionary
												) : DynamicMethod
		{
			const baseConstructor : MethodInfo = dynamicClass.baseType.constructor;
			const baseConstructorArgCount : int = baseConstructor.parameters.length;
			
			const instructions : Array = [	[Instructions.GetLocal_0],
											[Instructions.PushScope],
											[Instructions.GetLocal_0],
											[Instructions.ConstructSuper, baseConstructorArgCount],
											[Instructions.GetLocal_0]
											];
			
			const constructor : MethodInfo = dynamicClass.constructor;
			const constructorArgCount : int = constructor.parameters.length;
			for(var i : int = 0; i<constructorArgCount; i++)
			{
				instructions.push([Instructions.GetLocal, i + 1]);
			}
			
			// initialise the mixins here.
			const ns : BCNamespace = new BCNamespace('', NamespaceKind.PACKAGE_NAMESPACE);
			
			for(var key : Object in mixins)
			{
				const descriptorType : Type = Type(key);
				if(!descriptorType.isInterface) throw new IllegalOperationError('Descriptor (' +
										descriptorType.name + ') should be a type of Interface.');
											
				const descriptorTypeName : QualifiedName = buildMixinProxyPropertyName(	
																				ns, 
																				descriptorType
																				);
				const impl : Class = mixins[key];
				
				const implType : Type = Type.getType(impl);
				
				instructions.push([Instructions.GetLocal_0]);
				instructions.push([Instructions.FindPropertyStrict, implType.qname]);
				
				// work out here if we need to push the mixin.
				const paramCount : int = implType.constructor.parameters.length;
				if(paramCount == 1) instructions.push([Instructions.GetLocal_0]);
				if(paramCount > 1) throw new IllegalOperationError('More than one constructor ' +
											'argument is not supported (' + implType.name + ').');
				
				instructions.push([Instructions.ConstructProp, implType.qname, paramCount]);
				instructions.push([Instructions.SetProperty, descriptorTypeName]);
			}
			
			// create the __init__ method 
			const initMethod : MethodInfo = generateInitMethod(	dynamicClass, 
																mixins, 
																base,
																superType,
																injectors
																);
			// Finish the constructor
			instructions.push(
				[Instructions.CallPropVoid, initMethod.qname, constructorArgCount],
				[Instructions.ReturnVoid]
			);
			
			const argumentBytes : int = constructorArgCount * 9;		
			return new DynamicMethod(	constructor, 
										6 + argumentBytes, 
										3 + argumentBytes, 
										4, 
										5, 
										instructions
										);
		}
		
		/**
		 * @private
		 */
		protected function generateInitMethod(	dynamicClass : DynamicClass,
												mixins : Dictionary,
												base : Type,
												superType : Type,
												injectors : Dictionary
												) : MethodInfo
		{
			var i : int;
			var total : int;
			
			var propertyInfo : PropertyInfo;
			var properties : Array = dynamicClass.getProperties();
			
			const params:Array = [];
						
			total = properties.length;
			for (i = 0; i < total; i++) 
			{
				propertyInfo = properties[i];
				if(!propertyInfo.canWrite) continue;
				params.push(new ParameterInfo(propertyInfo.name, propertyInfo.type, true));
			}
			
			const initMethodName : String = "___init___";
			const ns : BCNamespace = new BCNamespace('', NamespaceKind.PACKAGE_NAMESPACE);
			const method : MethodInfo = new MethodInfo(	dynamicClass, 
														initMethodName, 
														null, 
														MemberVisibility.PUBLIC, 
														false, 
														false, 
														Type.voidType, 
														params
														);
														
			const instructions : Array = [	[Instructions.GetLocal_0],
											[Instructions.PushScope]
											];
											
			var local : int = 0; 
			var proxies : int = 0;
			
			for(var key : Object in mixins)
			{
				const descriptorType : Type = Type(key);
				if(!descriptorType.isInterface) throw new IllegalOperationError('Descriptor (' +
										descriptorType.name + ') should be a type of Interface.');
				
				properties = descriptorType.getProperties();
				total = properties.length;
				for(i = 0; i<total; i++)
				{
					propertyInfo = properties[i];
					if(!propertyInfo.canWrite) continue;
					
					local++;
					
					const propertyTypeName : QualifiedName = buildMixinPropertyName( 
																				ns,
																				propertyInfo.name
																				);
					
					instructions.push([Instructions.GetLocal_0]);
					instructions.push([Instructions.GetLocal, local]);
					instructions.push([Instructions.SetProperty, propertyTypeName]);
				}
				
				proxies++;
			}
						
			const isObject : Boolean = superType.name == "Object";
			if(!isObject)
			{
				// Add the injectors if and only if it's not an object
				for(var variable : String in injectors)
				{
					if(injectors[variable] is Type)
					{
						const variableType : Type = injectors[variable];
						if(variableType.qname.toString() == base.qname.toString())
						{
							// This wanting a reference to it's self.
							const self : QualifiedName = buildMixinPropertyName(ns, variable);
							instructions.push(
								[Instructions.GetLocal_0],
								[Instructions.GetLocal_0],
								[Instructions.SetSuper, self]
							);
							
							injectors[variable] = null;
							delete injectors[variable];
						}
						else
						{
							throw new IllegalOperationError('Unable to inject type (' + 
										variableType.name +	') into variable (' + variable + ')');
						}
					}
					else if(injectors[variable] is IMixinBinding)
					{
						const binding : IMixinBinding = injectors[variable];
						const descriptor : Class = binding.key;
						const implementation : Class = binding.value;
						
						const bindingDescriptorType : Type = Type.getType(descriptor);
						
						const variablePropName : QualifiedName = buildMixinProxyPropertyName(
																			ns, 
																			bindingDescriptorType);
						if(null != dynamicClass.getField(variablePropName.name, ''))
						{
							const variableQName : QualifiedName = buildMixinPropertyName( ns, 
																						  variable
																						  );
							
							instructions.push(
								[Instructions.GetLocal_0],
								[Instructions.GetLocal_0],
								[Instructions.GetProperty, variablePropName],
								[Instructions.SetSuper, variableQName]
							);
							
							injectors[variable] = null;
							delete injectors[variable];
						}
						else
						{
							throw new IllegalOperationError('Unable to inject type (' + 
										variableType.name +	') into variable (' + variable + ')');
						}
					}
					else
					{
						throw new IllegalOperationError('Unable to inject type (' + 
										variableType.name +	') into variable (' + variable + ')');
					}
				}
				
				const methodNames : Dictionary = getMixinTypeMethods(superType);
				const initMethod : MethodInfo = methodNames["__init__"];
				if(null != initMethod)
				{
					instructions.push(
						[Instructions.GetLocal_0],
						[Instructions.CallSuperVoid, initMethod.qname, 0]
					);
				}
			}
			
			// Return void, we've finished.			
			instructions.push(
				[Instructions.ReturnVoid]
			);
			
			// Finish off the init method
			const argumentBytes : int = proxies * 9;
			dynamicClass.addMethod(method);
			dynamicClass.addMethodBody(method, new DynamicMethod(	method, 
																	6 + argumentBytes, 
																	3 + argumentBytes, 
																	4, 
																	5, 
																	instructions
																	));
			return method;
		}
		
		public function get base() : Type
		{
			return _base;
		}

		public function set base(value : Type) : void
		{
			if(null == value) throw new ArgumentError('Given value can not be null.');
			_base = value;
		}
		
		public function get superType() : Type
		{
			return _superType;
		}

		public function set superType(value : Type) : void
		{
			if(null == value) throw new ArgumentError('Given value can not be null.');
			_superType = value;
		}
		
		public function get mixins() : Dictionary
		{
			return _mixins;
		}

		public function set mixins(value : Dictionary) : void
		{
			if(null == value) throw new ArgumentError('Given value can not be null.');
			_mixins = value;
		}
		
		public function get injectors() : Dictionary
		{
			return _injectors;
		}

		public function set injectors(value : Dictionary) : void
		{
			if(null == value) throw new ArgumentError('Given value can not be null.');
			_injectors = value;
		}
	}
}
