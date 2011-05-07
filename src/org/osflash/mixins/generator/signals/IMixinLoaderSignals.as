package org.osflash.mixins.generator.signals
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
		 * 
		 * @return ISignal which will broadcast the completed event
		 */
		function get completedSignal() : ISignal;
		
		/**
		 * Add a signal to know how far a something has progressed.
		 * 
		 * @return ISignal which will broadcast the progress event
		 */
		function get progressSignal() : ISignal;
		
		/**
		 * Add a signal to know when the class has been not be succesfully created.
		 * 
		 * @return ISignal which will broadcast if there was an error whilst loading.
		 */
		function get errorSignal() : ISignal;
	}
}
