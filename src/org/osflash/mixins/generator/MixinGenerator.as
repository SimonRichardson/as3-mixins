package org.osflash.mixins.generator
{
	import org.flemit.bytecode.DynamicClass;
	import org.flemit.bytecode.QualifiedName;
	import org.flemit.reflection.Type;

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
			return null;
		}
	}
}
