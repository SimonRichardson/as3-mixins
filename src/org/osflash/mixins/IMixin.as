package org.osflash.mixins
{
	import org.osflash.signals.ISignal;
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
		 * Unsubscribes a descriptor and implemenation from the mixin.
		 * @param descriptor The key for the mixin binding.
		 * @param implementation The value for the mixin binding.
		 * @return a IMixinBinding, which contains the descriptor and implementation as parameters.
		 */
		function remove(descriptor : Class) : IMixinBinding;
		
		/**
		 * Unsubscribes all observers and implementations from the mixin.
		 */
		function removeAll() : void;
		
		/**
		 * Add a signal to know when the class has been created.
		 */
		function get completedSignal() : ISignal;
		
		/**
		 * Add a signal to know when the class has been not be succesfully created.
		 */
		function get errorSignal() : ISignal;
	}
}
