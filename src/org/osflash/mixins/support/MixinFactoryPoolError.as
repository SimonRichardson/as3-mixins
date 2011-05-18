package org.osflash.mixins.support
{
	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public final class MixinFactoryPoolError extends Error
	{
		public static const POOL_EXHAUSTED : MixinFactoryPoolError = new MixinFactoryPoolError(
													'The MixinFactoryPool because exhausted when ' + 
													'trying to allocate a node.');
		
		public static const MIXIN_NULL_ON_PUSH : MixinFactoryPoolError = new MixinFactoryPoolError(
													'The MixinFactoryPool because mixin was null ' +
													'when trying to push.');
															
		public function MixinFactoryPoolError(message : String)
		{
			super(message);
		}
	}
}
