package org.osflash.mixins.generator
{
	import org.osflash.mixins.IMixin;
	import org.osflash.mixins.MixinError;
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public final class MixinGenerationSignals
	{
		
		/**
		 * @private
		 */
		private const _completedSignal : ISignal = new Signal(IMixin);
		
		/**
		 * @private
		 */
		private const _errorSignal : ISignal = new Signal(IMixin, MixinError);
		
		/**
		 * Add a signal to know when the class has been created.
		 */
		public function get completedSignal() : ISignal	{ return _completedSignal; }
		
		/**
		 * Add a signal to know when the class has been not be succesfully created.
		 */
		public function get errorSignal() : ISignal	{ return _errorSignal; }
	}
}
