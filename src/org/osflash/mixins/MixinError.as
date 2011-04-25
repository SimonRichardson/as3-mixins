package org.osflash.mixins
{
	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public final class MixinError extends Error
	{

		public function MixinError(message : String)
		{
			super(message);
		}
	}
}
