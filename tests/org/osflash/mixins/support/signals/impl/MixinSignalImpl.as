package org.osflash.mixins.support.signals.impl
{
	import org.osflash.signals.ISignal;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class MixinSignalImpl
	{
		
		[Inject]
		public var signal : ISignal;
		
		public function dispatch2(...args) : void
		{
			signal.dispatch.apply(null, args); 
		}
	}
}
