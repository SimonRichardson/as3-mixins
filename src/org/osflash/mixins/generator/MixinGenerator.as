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
	import org.flemit.reflection.MemberVisibility;
	import org.flemit.reflection.MethodInfo;
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
									mixins : Dictionary
								) : DynamicClass
		{			
			const superClass : Type = Type.getType(Object);
			
			const interfaces : Array = [].concat(base).concat(base.getInterfaces());			
			const dynamicClass : DynamicClass = new DynamicClass(name, superClass, interfaces);
			
			addInterfaceMembers(dynamicClass);
			
			dynamicClass.constructor = createConstructor(dynamicClass);
			
			dynamicClass.addMethodBody(	dynamicClass.scriptInitialiser, 
										generateScriptInitialier(dynamicClass)
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
		 * @private
		 */
		protected function createConstructor(dynamicClass : DynamicClass) : MethodInfo
		{
			return new MethodInfo(	dynamicClass, 
									"ctor", 
									null, 
									MemberVisibility.PUBLIC, 
									false, 
									false, 
									Type.star, 
									[]
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
			const argCount : uint = baseConstructor.parameters.length;
			const namespaze : BCNamespace = new BCNamespace('', NamespaceKind.PACKAGE_NAMESPACE);
			const proxies : int = 0;
			
			const instructions : Array = [	[Instructions.GetLocal_0],
												[Instructions.PushScope],
												// begin construct super
												[Instructions.GetLocal_0], // 'this'
												[Instructions.ConstructSuper, argCount]
												];
						
			for (var interfaceType : Type in mixins) 
			{
				const proxyObject : Object = mixins[interfaceType];
				const proxyObjectType : Type = Type.getType(proxyObject);
				const proxyPropertyName : QualifiedName = buildProxyPropName(	namespaze, 
																				interfaceType
																				);
				
				instructions.push([Instructions.FindProperty, proxyPropertyName]);
				instructions.push([Instructions.FindPropertyStrict, proxyObjectType.qname]);
				instructions.push([Instructions.ConstructProp, proxyObjectType.qname, 0]);
				instructions.push([Instructions.InitProperty, proxyPropertyName]);
				
				proxies++;
			}
			
			instructions.push(
				[Instructions.ReturnVoid]
			);
			
			const argumentBytes : int = proxies * 9;
				
			return new DynamicMethod(	dynamicClass.constructor, 
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
																				dynamicClass, 
																				classMethod, 
																				null, 
																				false, 
																				classMethod.name, 
																				MethodType.METHOD
																				);
						
						dynamicClass.addMethod(classMethod);
						dynamicClass.addMethodBody(classMethod, classMethodBody);
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
						
						if (property.canRead)
						{
							const getter : DynamicMethod = generateMethod(	definition, 
																			dynamicClass, 
																			classProperty.getMethod, 
																			null, 
																			false, 
																			classProperty.name, 
																			MethodType.PROPERTY_GET
																			);
							dynamicClass.addMethodBody(	classProperty.getMethod, getter);
						}
						
						if (property.canWrite)
						{
							const setter : DynamicMethod = generateMethod(	definition, 
																			dynamicClass, 
																			classProperty.setMethod, 
																			null, 
																			false, 
																			classProperty.name, 
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
											dynamicClass : DynamicClass, 
											method : MethodInfo, 
											baseMethod : MethodInfo, 
											baseIsDelegate : Boolean, 
											name : String, 
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
				instructions.push([Instructions.GetLex, proxyPropertyName]);
				instructions.push([Instructions.GetProperty, methodQName]);
				
				if (methodType == MethodType.PROPERTY_SET)
					instructions.push([Instructions.Pop]);
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
		protected function generateScriptInitialier(dynamicClass : DynamicClass) : DynamicMethod
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
				// TODO: Support where base class is not Object
				return new DynamicMethod(dynamicClass.scriptInitialiser, 3, 2, 1, 3, [
					[Instructions.GetLocal_0],
					[Instructions.PushScope],
					//[GetScopeObject, 0],
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
