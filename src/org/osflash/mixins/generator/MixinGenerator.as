package org.osflash.mixins.generator
{
	import org.flemit.bytecode.BCNamespace;
	import org.flemit.bytecode.DynamicClass;
	import org.flemit.bytecode.DynamicMethod;
	import org.flemit.bytecode.Instructions;
	import org.flemit.bytecode.MultipleNamespaceName;
	import org.flemit.bytecode.NamespaceKind;
	import org.flemit.bytecode.NamespaceSet;
	import org.flemit.bytecode.QualifiedName;
	import org.flemit.reflection.FieldInfo;
	import org.flemit.reflection.MemberVisibility;
	import org.flemit.reflection.MethodInfo;
	import org.flemit.reflection.ParameterInfo;
	import org.flemit.reflection.PropertyInfo;
	import org.flemit.reflection.Type;
	import org.osflash.mixins.MixinError;

	import flash.utils.Dictionary;
	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public class MixinGenerator
	{

		public function generate(	name : QualifiedName, 
									base : Type,
									superType : Type,
									mixins : Dictionary
								) : DynamicClass
		{			
			const interfaces : Array = [base].concat(base.getInterfaces());			
			const dynamicClass : DynamicClass = new DynamicClass(name, superType, interfaces);
			
			addInterfaceMembers(dynamicClass);
			
			dynamicClass.constructor = createConstructor(dynamicClass);
			
			dynamicClass.addMethodBody(	dynamicClass.scriptInitialiser, 
										generateScriptInitialiser(dynamicClass)
										);
			dynamicClass.addMethodBody(	dynamicClass.staticInitialiser, 
										generateStaticInitialiser(dynamicClass)
										);
			dynamicClass.addMethodBody(	dynamicClass.constructor, 
										generateInitialiser(dynamicClass, mixins)
										);
						
			return dynamicClass;
		}
				
		/**
		 * Dispose the current generator.
		 */
		public function dispose() : void
		{
			
		}
		
		/**
		 * @private
		 */
		protected function createConstructor(dynamicClass : DynamicClass) : MethodInfo
		{
			const params:Array = [];
						
			const properties : Array = dynamicClass.getProperties();
			const total : int = properties.length;
			for (var i : int = 0; i < total; i++) 
			{
				const propertyInfo : PropertyInfo = properties[i];
				params.push(new ParameterInfo(propertyInfo.name, propertyInfo.type, true));
			}
			
			return new MethodInfo(	dynamicClass, 
									"ctor", 
									null, 
									MemberVisibility.PUBLIC, 
									false, 
									false, 
									Type.star, 
									params
								);
		}
		
		/**
		 * @private
		 */
		protected function generateInitialiser(	dynamicClass : DynamicClass, 
												mixins : Dictionary
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
			
			// create the __init__ method 
			const initMethod : MethodInfo = generateInitMethod(dynamicClass, mixins);
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
												mixins : Dictionary
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
				params.push(new ParameterInfo(propertyInfo.name, propertyInfo.type, true));
			}
			
			const ns : BCNamespace = new BCNamespace('', NamespaceKind.PACKAGE_NAMESPACE);
			const method : MethodInfo = new MethodInfo(	dynamicClass, 
														"__init__", 
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
				const descriptorTypeName : QualifiedName = buildProxyPropName(	ns, 
																				descriptorType
																				);
				const implType : Type = Type.getType(mixins[key]);
				
				instructions.push([Instructions.GetLocal_0]);
				instructions.push([Instructions.FindPropertyStrict, implType.qname]);
				instructions.push([Instructions.ConstructProp, implType.qname, 0]);
				instructions.push([Instructions.SetProperty, descriptorTypeName]);
				
				properties = descriptorType.getProperties();
				total = properties.length;
				for(i = 0; i<total; i++)
				{
					local++;
					
					propertyInfo = properties[i];
					
					const propertyTypeName : QualifiedName = buildPropName( ns,
																			propertyInfo.name
																			);
					
					instructions.push([Instructions.GetLocal_0]);
					instructions.push([Instructions.GetLocal, local]);
					instructions.push([Instructions.SetProperty, propertyTypeName]);
				}
				
				proxies++;
			}
			
			instructions.push(
				[Instructions.ReturnVoid]
			);
			
			// TODO : work out the injectables here.
			
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
		
		/**
		 * @private
		 */
		protected function buildProxyPropName(	ns : BCNamespace, 
												interfaceType : Type
												) : QualifiedName
		{
			const name : String = '_' +interfaceType.fullName.replace(/[\. : ]/g, '_');
			return new QualifiedName(ns, name);
		}
		
		/**
		 * @private
		 */
		protected function buildPropName(	ns : BCNamespace,
											propertyName : String
											) : QualifiedName
		{
			// TODO : sanity check the property name
			return new QualifiedName(ns, propertyName);
		}
		
		/**
		 * @private
		 */
		private function addInterfaceMembers(dynamicClass : DynamicClass) : void
		{
			const definitions : Array = dynamicClass.getInterfaces();
			
			var i : int;
			var total : int;
			
			for each(var definition : Type in definitions)
			{
				const definitionInterfaces : Array = definition.getInterfaces();
				total = definitionInterfaces.length;
				for(i = 0; i<total; i++)
				{
					const extendedInterface : Type = definitionInterfaces[i];
					if (definitions.indexOf(extendedInterface) == -1)
					{
						definitions.push(extendedInterface);
					}
				}
				
				const definitionMethods : Array = definition.getMethods();
				total = definitionMethods.length;
				for(i = 0; i<total; i++)
				{
					const method : MethodInfo = definitionMethods[i];
					if(null == dynamicClass.getMethod(method.name))
					{
						const classMethod : MethodInfo = new MethodInfo(	dynamicClass, 
																			method.name, 
																			null, 
																			method.visibility, 
																			method.isStatic, 
																			false, 
																			method.returnType, 
																			method.parameters
																			);
						
						const classMethodBody : DynamicMethod = generateMethod(	definition, 
																				classMethod, 
																				MethodType.METHOD
																				);
						
						dynamicClass.addMethod(classMethod);
						dynamicClass.addMethodBody(classMethod, classMethodBody);
						
						const methodNS : BCNamespace = new BCNamespace(	'', 
																	NamespaceKind.PACKAGE_NAMESPACE
																	);
						const methodPropertyName : QualifiedName = buildProxyPropName(	methodNS, 
																						definition
																						);
						if(!dynamicClass.getField(methodPropertyName.name, ''))
						{
							dynamicClass.addSlot(new FieldInfo(	dynamicClass, 
																methodPropertyName.name, 
																methodPropertyName.toString(), 
																MemberVisibility.PUBLIC, 
																false, 
																definition
																));
						}
					}
					else
					{
						throw MixinError.METHOD_GENERATOR_ERROR;
					}
				}
				
				const definitionProperties : Array = definition.getProperties();
				total = definitionProperties.length;
				for(i = 0; i<total; i++)
				{
					const property : PropertyInfo = definitionProperties[i];
					if(null == dynamicClass.getProperty(property.name))
					{
						const classProperty : PropertyInfo = new PropertyInfo(	dynamicClass, 
																				property.name, 
																				null, 
																				property.visibility, 
																				property.isStatic, 
																				false, 
																				property.type, 
																				property.canRead, 
																				property.canWrite
																				);
						dynamicClass.addProperty(classProperty);
						
						
						const proxyNS : BCNamespace = new BCNamespace(	'', 
																	NamespaceKind.PACKAGE_NAMESPACE
																	);
						const proxyPropertyName : QualifiedName = buildProxyPropName(	proxyNS, 
																						definition
																						);
						
						if(!dynamicClass.getField(proxyPropertyName.name, ''))
						{
							dynamicClass.addSlot(new FieldInfo(	dynamicClass, 
																proxyPropertyName.name, 
																proxyPropertyName.toString(), 
																MemberVisibility.PUBLIC, 
																false, 
																definition
																));
						}
						
						if (property.canRead)
						{
							const getter : DynamicMethod = generateMethod(	definition, 
																			classProperty.getMethod, 
																			MethodType.PROPERTY_GET
																			);
							dynamicClass.addMethodBody(	classProperty.getMethod, getter);
						}
						
						if (property.canWrite)
						{
							const setter : DynamicMethod = generateMethod(	definition, 
																			classProperty.setMethod, 
																			MethodType.PROPERTY_SET
																			);
							dynamicClass.addMethodBody(classProperty.setMethod, setter);
						}
						
					}
					else
					{
						throw MixinError.PROPERTY_GENERATOR_ERROR;
					}
				}
			}
		}
		
		/**
		 * @private
		 */
		protected function generateMethod(	type : Type, 
											method : MethodInfo, 
											methodType : uint
											) : DynamicMethod
		{
			const argCount : uint = method.parameters.length;
			const ns : BCNamespace = new BCNamespace('', NamespaceKind.PACKAGE_NAMESPACE);
			const proxyPropertyName : QualifiedName = buildProxyPropName(ns, type);
			
			const instructions : Array = [	[Instructions.GetLocal_0],
											[Instructions.PushScope],
										    ];
			
			if (methodType == MethodType.METHOD)
			{
				instructions.push([Instructions.GetLex, proxyPropertyName]);
				
				for (var i : int=0; i < argCount; i++)
				{
					instructions.push([Instructions.GetLocal, i+1]);
				}
				
				if (method.returnType == Type.voidType)
					instructions.push([Instructions.CallPropVoid, method.qname, argCount]);
				else
					instructions.push([Instructions.CallProperty, method.qname, argCount]);
				
			}
			else if (methodType == MethodType.PROPERTY_GET || methodType == MethodType.PROPERTY_SET)
			{
				const methodName : String = method.fullName.match(/(\w+)\/\w+$/)[1];
				const methodQName : QualifiedName = new QualifiedName(ns, methodName); 
				
				if (methodType == MethodType.PROPERTY_SET)
				{
					instructions.push([Instructions.GetLocal_0]);
					instructions.push([Instructions.GetLex, proxyPropertyName]);
					instructions.push([Instructions.GetLocal_1]);
					instructions.push([Instructions.SetProperty, methodQName]);
				}
				else
				{
					instructions.push([Instructions.GetLocal_0]);
					instructions.push([Instructions.GetLex, proxyPropertyName]);
					instructions.push([Instructions.GetProperty, methodQName]);
				}
			}
			
			if (method.returnType == Type.voidType) // void
				instructions.push([Instructions.ReturnVoid]);
			else
				instructions.push([Instructions.ReturnValue]);
			
			return new DynamicMethod(method, 7 + argCount, argCount + 2, 4, 5, instructions);
		}
		
		/**
		 * @private
		 */
		protected function generateScriptInitialiser(dynamicClass : DynamicClass) : DynamicMethod
		{
			const clsNamespaceSet:NamespaceSet = new NamespaceSet(
												[new BCNamespace(	dynamicClass.packageName, 
																	NamespaceKind.PACKAGE_NAMESPACE
																	)]
																	);
		
			if (dynamicClass.isInterface)
			{
				const dynamicNamespace : MultipleNamespaceName = new MultipleNamespaceName(
																				dynamicClass.name, 
																				clsNamespaceSet
																				);
																				
				return new DynamicMethod(dynamicClass.scriptInitialiser, 3, 2, 1, 3, [
					[Instructions.GetLocal_0],
					[Instructions.PushScope],
					[Instructions.FindPropertyStrict, dynamicNamespace], 
					[Instructions.PushNull],
					[Instructions.NewClass, dynamicClass],
					[Instructions.InitProperty, dynamicClass.qname],
					[Instructions.ReturnVoid]
				]);
			}
			else
			{
				return new DynamicMethod(dynamicClass.scriptInitialiser, 3, 2, 1, 3, [
					[Instructions.GetLocal_0],
					[Instructions.PushScope],
					[Instructions.FindPropertyStrict, dynamicClass.multiNamespaceName], 
					[Instructions.GetLex, dynamicClass.baseType.qname],
					[Instructions.PushScope],
					[Instructions.GetLex, dynamicClass.baseType.qname],
					[Instructions.NewClass, dynamicClass],
					[Instructions.PopScope],
					[Instructions.InitProperty, dynamicClass.qname],
					[Instructions.ReturnVoid]
				]);
			}
		}
		
		/**
		 * @private
		 */
		protected function generateStaticInitialiser(dynamicClass:DynamicClass):DynamicMethod
		{
			return new DynamicMethod(dynamicClass.staticInitialiser, 2, 2, 3, 4, [
						[Instructions.GetLocal_0],
						[Instructions.PushScope],
						[Instructions.ReturnVoid]
					]);
			
		}
		
	}
}
