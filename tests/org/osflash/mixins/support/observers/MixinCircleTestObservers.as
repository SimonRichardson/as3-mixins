package org.osflash.mixins.support.observers
{
	import asunit.asserts.assertNotNull;

	import org.osflash.mixins.IMixin;
	import org.osflash.mixins.support.ICircle;

	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class MixinCircleTestObservers
	{

		public function mixinCompletedSignal(mixin : IMixin) : void
		{
			const circle : ICircle = mixin.create(ICircle);

			assertNotNull('ICircle implementation is not null', circle);
		}

		public function mixinErrorSiginal(mixin : IMixin) : void
		{
		}
	}
}
