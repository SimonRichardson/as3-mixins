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
													
		public function MixinFactoryPoolError(message : String)
		{
			super(message);
		}
	}
}
