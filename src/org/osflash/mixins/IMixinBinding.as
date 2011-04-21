package org.osflash.mixins
{
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public interface IMixinBinding
	{
		
		/**
		 * 
		 */
		function get implementation() : Class;
		
		function set implementation(value :  Class) : void;
		
		/**
		 * 
		 */
		function get ignore() : Boolean;
		
		function set ignore(value : Boolean) : void;
	}
}
