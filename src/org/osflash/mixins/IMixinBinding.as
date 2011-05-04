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
		function get key() : Class;
		
		function set key(value :  Class) : void;
		
		/**
		 * 
		 */
		function get value() : Class;
		
		function set value(value :  Class) : void;
		
		/**
		 * 
		 */
		function get ignore() : Boolean;
		
		function set ignore(value : Boolean) : void;
	}
}
