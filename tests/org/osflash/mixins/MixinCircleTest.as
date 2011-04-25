package org.osflash.mixins
{
	import asunit.asserts.assertEquals;
	import asunit.asserts.assertNotNull;
	import asunit.asserts.fail;
	import asunit.framework.IAsync;

	import org.osflash.mixins.support.ICircle;
	import org.osflash.mixins.support.IPosition;
	import org.osflash.mixins.support.ISize;
	import org.osflash.mixins.support.impl.PositionImpl;
	import org.osflash.mixins.support.impl.SizeImpl;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class MixinCircleTest
	{
		
		[Inject]
		protected var async :  IAsync;
				
		protected var mixin : IMixin; 
		
		[Before]
		public function setUp():void
		{
			mixin = new Mixin();
		}
		
		[After]
		public function tearDown():void
		{
			mixin.removeAll();
			mixin = null;
		}
		
		[Test]
		public function create_circle_mixin_and_verify_creation() : void
		{
			mixin.completedSignal.add(handleCompletedSignal);
			mixin.errorSignal.add(handleErrorSiginal);
			
			mixin.add(IPosition, PositionImpl);
			mixin.add(ISize, SizeImpl);
			mixin.define(ICircle);
		}

		private function handleErrorSiginal(mixin : IMixin, mixinError : MixinError) : void
		{
			fail('Failed to create mixin (' + mixin + ") with error " + mixinError);
		}

		private function handleCompletedSignal(mixin : IMixin) : void
		{
			const impl : ICircle = mixin.create(ICircle);
			
			assertNotNull('ICirlce implementation is not null', impl);
			assertEquals('Valid creation of ICircle implementation', impl);
		}
	}
}
