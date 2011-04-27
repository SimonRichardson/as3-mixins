package org.osflash.mixins
{
	import asunit.asserts.assertNotNull;
	import asunit.asserts.assertTrue;
	import asunit.asserts.fail;
	import asunit.framework.IAsync;
	import org.osflash.mixins.generator.MixinGenerationSignals;
	import org.osflash.mixins.support.ICircle;
	import org.osflash.mixins.support.defs.IName;
	import org.osflash.mixins.support.defs.IPosition;
	import org.osflash.mixins.support.defs.IRadius;
	import org.osflash.mixins.support.impl.NameImpl;
	import org.osflash.mixins.support.impl.PositionImpl;
	import org.osflash.mixins.support.impl.RadiusImpl;

	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class MixinCircleTest
	{
		[Inject]
		public var async : IAsync;
		
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
			mixin.add(IPosition, PositionImpl);
			mixin.add(IRadius, RadiusImpl);
			mixin.add(IName, NameImpl);
			
			mixin.define(ICircle);
			
			const signals : MixinGenerationSignals = mixin.generate();
			signals.completedSignal.add(async.add(verifyCreationISquareImplementation, 1000));
			signals.errorSignal.add(failIfCalled);
		}

		private function verifyCreationISquareImplementation(mixin : IMixin) : void
		{
			const impl : ICircle = mixin.create(ICircle);
			
			assertNotNull('ICircle implementation is not null', impl);			
			assertTrue('Valid creation of ICircle implementation', impl is ICircle);
			assertTrue('Valid creation of IRadius implementation', impl is IRadius);
			assertTrue('Valid creation of IPosition implementation', impl is IPosition);
		}
		
		private function failIfCalled(mixin : IMixin, mixinError : MixinError) : void
		{
			fail('Failed to create mixin (' + mixin + ") with error " + mixinError);
		}
	}
}
