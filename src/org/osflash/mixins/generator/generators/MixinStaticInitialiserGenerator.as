package org.osflash.mixins.generator.generators
{
	import org.flemit.bytecode.DynamicClass;
	import org.flemit.bytecode.DynamicMethod;
	import org.flemit.bytecode.Instructions;
	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public class MixinStaticInitialiserGenerator implements IGenerator
	{
		
		
		/**
		 * @inheritDoc
		 */
		public function generator(dynamicClass : DynamicClass) : void
		{
			dynamicClass.addMethodBody(	dynamicClass.staticInitialiser, 
										generateStaticInitialiser(dynamicClass)
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
