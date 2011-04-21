package org.osflash.mixins
{
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public interface IMixin
	{
		
		/**
		 * 
		 */
		function add(descriptor : Class, implementation : Class) : IMixinBinding;
		
		/**
		 * 
		 */
		function remove(descriptor : Class) : IMixinBinding;
		
		/**
		 * 
		 */
		function removeAll() : void;
		
		/**
		 * 
		 */
		function define(implementation : Class) : void;
		
		/**
		 * 
		 */
		function create(definitive : Class) : *;
		
		/**
		 * 
		 */
		function addObserver(observer : IMixinObserver) : void;
		
		/**
		 * 
		 */
		function removeObserver(observer : IMixinObserver) : void;
	}
}
