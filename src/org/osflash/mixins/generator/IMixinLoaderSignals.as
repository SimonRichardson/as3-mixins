package org.osflash.mixins.generator
{
	import org.osflash.signals.ISignal;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public interface IMixinLoaderSignals
	{
		
		function dispose() : void;
		
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
