package org.osflash.mixins.generator.generators
{
	import org.flemit.bytecode.BCNamespace;
	import org.flemit.bytecode.DynamicClass;
	import org.flemit.bytecode.DynamicMethod;
	import org.flemit.bytecode.Instructions;
	import org.flemit.bytecode.MultipleNamespaceName;
	import org.flemit.bytecode.NamespaceKind;
	import org.flemit.bytecode.NamespaceSet;
	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public class MixinScriptInitialiserGenerator implements IGenerator
	{
		
		/**
		 * @inheritDoc
		 */
		public function generator(dynamicClass : DynamicClass) : void
		{
			dynamicClass.addMethodBody(	dynamicClass.scriptInitialiser, 
										generateScriptInitialiser(dynamicClass)
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
	}
}
