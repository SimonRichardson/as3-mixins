package org.osflash.mixins.generator.generators
{
	import org.flemit.bytecode.DynamicClass;

	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public interface IGenerator
	{

		function generator(dynamicClass : DynamicClass) : void;
		
		function dispose() : void;
	}
}
