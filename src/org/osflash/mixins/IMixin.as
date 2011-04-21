package org.osflash.mixins
{
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public interface IMixin
	{
		
		/**
		 * Subscribes a implementation to the mixin, with the key descriptor.
		 * @param descriptor A class descriptor that will be binded to the implementation.
		 * @param implementation A class implementation that is binded to the descriptor. 
		 * @return a IMixinBinding, which contains the descriptor and implementation as parameters.
		 * @throws ArgumentError if implementation is <code>null</code> 
		 */
		function add(descriptor : Class, implementation : Class) : IMixinBinding;
		
		/**
		 * Define an implementation for the mixin to create. This is the base for the mixin, which
		 * will be created from the descriptor and defined with the implementation.
		 * @param implementation A base class that will be verified and created with the added implementations.
		 * @throws ArgumentError if implementation is <code>null</code>
		 * @throws ArgumentError if the implementation doesn't implement the descriptors
		 */
		function define(implementation : Class) : void;
		
		/**
		 * Create a definitive concreate instance from implementations.
		 * @param definitive A defined implementation you want to create as a concrete instance. 
		 * @throws ArgumentError if implementation is <code>null</code>
		 */
		function create(definitive : Class) : *;
		
		/**
		 * Add observer to know when the class is created or not.
		 * @param observer A IMixinObserver to know if when a mixin is available.
		 */
		function addObserver(observer : IMixinObserver) : void;
		
		/**
		 * Remove an observer from the mixin to prevent listening anymore.
		 * @param observer A IMixinObserver used to remove it from the mixin.
		 */
		function removeObserver(observer : IMixinObserver) : void;
		
		/**
		 * Unsubscribes a descriptor and implemenation from the mixin.
		 * @param descriptor The key for the mixin binding.
		 * @param implementation The value for the mixin binding.
		 * @return a IMixinBinding, which contains the descriptor and implementation as parameters.
		 */
		function remove(descriptor : Class, implementation : Class) : IMixinBinding;
		
		/**
		 * Unsubscribes all observers and implementations from the mixin.
		 */
		function removeAll() : void;
	}
}
