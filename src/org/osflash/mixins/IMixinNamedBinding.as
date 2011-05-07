package org.osflash.mixins
{
	import org.flemit.bytecode.QualifiedName;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public interface IMixinNamedBinding extends IMixinBinding
	{
		
		/**
		 * Get the name of the mixin binding
		 */
		function get name() : QualifiedName;
		
		function set name(value : QualifiedName) : void;
	}
}
