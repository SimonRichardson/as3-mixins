package org.osflash.mixins.generator.generators
{
	import org.flemit.bytecode.BCNamespace;
	import org.flemit.bytecode.DynamicClass;
	import org.flemit.bytecode.DynamicMethod;
	import org.flemit.bytecode.NamespaceKind;
	import org.flemit.bytecode.QualifiedName;
	import org.flemit.reflection.FieldInfo;
	import org.flemit.reflection.MemberVisibility;
	import org.flemit.reflection.MetadataInfo;
	import org.flemit.reflection.MethodInfo;
	import org.flemit.reflection.PropertyInfo;
	import org.flemit.reflection.Type;
	import org.osflash.mixins.MixinError;
	import org.osflash.mixins.generator.MethodType;

	import flash.utils.Dictionary;
	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public class MixinInterfaceGenerator implements IGenerator
	{
		
		/**
		 * @private
		 */		
		private var _superType : Type;
		
		/**
		 * @inheritDoc
		 */
		public function generator(dynamicClass : DynamicClass) : void
		{
			const definitions : Array = dynamicClass.getInterfaces();
			
			const isObject : Boolean = superType.name == "Object";
			
			if(!isObject)
			{
				const methodNames : Dictionary = getMixinTypeMethods(superType);
				const propertyNames : Dictionary = getMixinTypeProperties(superType);
			}
			
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
						const overrideMethod : Boolean = isObject 
															? false 
															: (null != methodNames[method.name]);
						
						if(overrideMethod)
						{
							var ignoreMethod : Boolean = false;
							
							const superMethod : MethodInfo = methodNames[method.name];
							const superMethodMetaData : Array = superMethod.metadata;
							const numMetadata : int = superMethodMetaData.length;
							for(var j : int = 0; j<numMetadata; j++)
							{
								const metadata : MetadataInfo = superMethodMetaData[j];
								if(metadata.name == 'Override')
								{
									// TODO : work out which override to use (calling super, or not)
									ignoreMethod = true;
									break;
								}
							}
							
							// We've got some meta data here that tell us that the super method
							// want's to have priority over the bytecode injection. If this 
							// happens we want to not generate the method at hand.
							if(ignoreMethod) continue;
						}
						
						const classMethod : MethodInfo = new MethodInfo(	dynamicClass, 
																			method.name, 
																			null, 
																			method.visibility, 
																			method.isStatic, 
																			overrideMethod, 
																			method.returnType, 
																			method.parameters
																			);
						
						const classMethodBody : DynamicMethod = generateMixinMethod(	
																				definition, 
																				classMethod, 
																				MethodType.METHOD
																				);
						
						dynamicClass.addMethod(classMethod);
						dynamicClass.addMethodBody(classMethod, classMethodBody);
						
						const methodNS : BCNamespace = new BCNamespace(	
																	'', 
																	NamespaceKind.PACKAGE_NAMESPACE
																	);
						const methodPropertyName : QualifiedName = buildMixinProxyPropertyName(	
																						methodNS, 
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
						const overrideProperty : Boolean = isObject
														? false
														: (null != propertyNames[property.name]);
						
						const classProperty : PropertyInfo = new PropertyInfo(	dynamicClass, 
																				property.name, 
																				null, 
																				property.visibility, 
																				property.isStatic, 
																				overrideProperty, 
																				property.type, 
																				property.canRead, 
																				property.canWrite
																				);
						dynamicClass.addProperty(classProperty);
						
						
						const proxyNS : BCNamespace = new BCNamespace(	'', 
																	NamespaceKind.PACKAGE_NAMESPACE
																	);
						const proxyPropertyName : QualifiedName = buildMixinProxyPropertyName(	
																						proxyNS, 
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
							const getter : DynamicMethod = generateMixinMethod(	
																			definition, 
																			classProperty.getMethod, 
																			MethodType.PROPERTY_GET
																			);
							dynamicClass.addMethodBody(	classProperty.getMethod, getter);
						}
						
						if (property.canWrite)
						{
							const setter : DynamicMethod = generateMixinMethod(	
																			definition, 
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
		 * @inheritDoc
		 */
		public function dispose() : void
		{
			_superType = null;
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
	}
}
