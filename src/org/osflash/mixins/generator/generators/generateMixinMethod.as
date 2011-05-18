package org.osflash.mixins.generator.generators
{
	import org.flemit.bytecode.BCNamespace;
	import org.flemit.bytecode.DynamicMethod;
	import org.flemit.bytecode.Instructions;
	import org.flemit.bytecode.NamespaceKind;
	import org.flemit.bytecode.QualifiedName;
	import org.flemit.reflection.MethodInfo;
	import org.flemit.reflection.Type;
	import org.osflash.mixins.generator.MethodType;
	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public function generateMixinMethod(	type : Type, 
											method : MethodInfo, 
											methodType : uint
											) : DynamicMethod
	{
		const argCount : uint = method.parameters.length;
		const ns : BCNamespace = new BCNamespace('', NamespaceKind.PACKAGE_NAMESPACE);
		const proxyPropertyName : QualifiedName = buildMixinProxyPropertyName(ns, type);
		
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
}
