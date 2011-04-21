package org.osflash.mixins
{
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public interface IMixinObserver
	{
		
		function mixinCompletedSignal(mixin : IMixin) : void;
		
		function mixinErrorSiginal(mixin : IMixin) : void;
	}
}
