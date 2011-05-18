package org.osflash.mixins.generator
{
	import org.flemit.bytecode.DynamicClass;
	import org.flemit.bytecode.QualifiedName;
	import org.flemit.reflection.Type;
	import org.osflash.mixins.generator.generators.MixinClassMetadataGenerator;
	import org.osflash.mixins.generator.generators.MixinConstructorGenerator;
	import org.osflash.mixins.generator.generators.MixinInterfaceGenerator;
	import org.osflash.mixins.generator.generators.MixinIntialiserGenerator;
	import org.osflash.mixins.generator.generators.MixinScriptInitialiserGenerator;
	import org.osflash.mixins.generator.generators.MixinStaticInitialiserGenerator;

	import flash.utils.Dictionary;
	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public class MixinGenerator
	{
		
		/**
		 * @private
		 */
		protected var interfaceGenerator : MixinInterfaceGenerator;
		
		/**
		 * @private
		 */
		protected var constructorGenerator : MixinConstructorGenerator;
		
		/**
		 * @private
		 */
		protected var classMetadataGenerator : MixinClassMetadataGenerator;
		
		/**
		 * @private
		 */
		protected var scriptInitialiserGenerator : MixinScriptInitialiserGenerator;
		
		/**
		 * @private
		 */
		protected var staticInitialiserGenerator : MixinStaticInitialiserGenerator; 
		
		/**
		 * @private
		 */
		protected var initialiserGenerator : MixinIntialiserGenerator;
		
		public function MixinGenerator()
		{
			interfaceGenerator = new MixinInterfaceGenerator();
			initialiserGenerator = new MixinIntialiserGenerator();
			constructorGenerator = new MixinConstructorGenerator();
			classMetadataGenerator = new MixinClassMetadataGenerator();
			scriptInitialiserGenerator = new MixinScriptInitialiserGenerator();
			staticInitialiserGenerator = new MixinStaticInitialiserGenerator();
		}
		
		public function generate(	name : QualifiedName, 
									base : Type,
									superType : Type,
									mixins : Dictionary,
									injectors : Dictionary
								) : DynamicClass
		{			
			const interfaces : Array = [base].concat(base.getInterfaces());			
			const dynamicClass : DynamicClass = new DynamicClass(name, superType, interfaces);
			
			interfaceGenerator.superType = superType;
			interfaceGenerator.generator(dynamicClass);
			
			classMetadataGenerator.qname = name;
			classMetadataGenerator.generator(dynamicClass);
						
			constructorGenerator.generator(dynamicClass);
			
			scriptInitialiserGenerator.generator(dynamicClass);
			staticInitialiserGenerator.generator(dynamicClass);
			
			// add mixins & injectors here.
			initialiserGenerator.base = base;
			initialiserGenerator.mixins = mixins;
			initialiserGenerator.superType = superType;
			initialiserGenerator.injectors = injectors;
			initialiserGenerator.generator(dynamicClass);
						
			return dynamicClass;
		}
				
		/**
		 * Dispose the current generator.
		 */
		public function dispose() : void
		{
			interfaceGenerator.dispose();
			interfaceGenerator = null;
			
			initialiserGenerator.dispose();
			initialiserGenerator = null;
			
			constructorGenerator.dispose();
			constructorGenerator = null;
			
			classMetadataGenerator.dispose();
			classMetadataGenerator = null;
			
			scriptInitialiserGenerator.dispose();
			scriptInitialiserGenerator = null;
			
			staticInitialiserGenerator.dispose();
			staticInitialiserGenerator = null;
		}
	}
}
