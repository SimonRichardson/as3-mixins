package org.osflash.mixins
{
	import asunit.asserts.assertEquals;
	import asunit.asserts.assertNotNull;
	import asunit.asserts.assertTrue;
	import asunit.asserts.fail;
	import asunit.framework.IAsync;

	import org.osflash.mixins.generator.MixinGenerationSignals;
	import org.osflash.mixins.support.ICircle;
	import org.osflash.mixins.support.IPosition;
	import org.osflash.mixins.support.IRadius;
	import org.osflash.mixins.support.impl.PositionImpl;
	import org.osflash.mixins.support.impl.RadiusImpl;


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
			mixin.add(IPosition, PositionImpl);
			mixin.add(IRadius, RadiusImpl);
			mixin.define(ICircle);
			
			const signals : MixinGenerationSignals = mixin.generate();
			signals.completedSignal.add(verifyCreationICircleImplementation);
			signals.errorSignal.add(failIfCalled);
		}

		private function verifyCreationICircleImplementation(mixin : IMixin) : void
		{
			const impl : ICircle = mixin.create(ICircle);
			
			assertNotNull('ICircle implementation is not null', impl);			
			assertTrue('Valid creation of ICircle implementation', impl is ICircle);
			assertTrue('Valid creation of IRadius implementation', impl is IRadius);
			assertTrue('Valid creation of IPosition implementation', impl is IPosition);
		}
		
		[Test]
		public function create_circle_mixin_and_add_radius() : void
		{
			mixin.add(IPosition, PositionImpl);
			mixin.add(IRadius, RadiusImpl);
			mixin.define(ICircle);
			
			const signals : MixinGenerationSignals = mixin.generate();
			signals.completedSignal.add(addRadiusAndVerifyAddition);
			signals.errorSignal.add(failIfCalled);
		}
		
		private function addRadiusAndVerifyAddition(mixin : Mixin) : void
		{
			const impl : ICircle = mixin.create(ICircle);
			
			impl.radius = 5;
			
			assertEquals('ICircle radius should be equal to 5', impl.radius, 5);
		}
		
		[Test]
		public function create_circle_mixin_and_add_radius_multiple_times() : void
		{
			mixin.add(IPosition, PositionImpl);
			mixin.add(IRadius, RadiusImpl);
			mixin.define(ICircle);
			
			const signals : MixinGenerationSignals = mixin.generate();
			signals.completedSignal.add(addRadiusMultipleTimesAndVerifyAddition);
			signals.errorSignal.add(failIfCalled);
		}
		
		private function addRadiusMultipleTimesAndVerifyAddition(mixin : Mixin) : void
		{
			const impl : ICircle = mixin.create(ICircle);
			
			for(var i : int = 0; i<100; i++)
			{
				const rand : int = int(Math.random() * Number.MAX_VALUE);
				
				impl.radius = rand;
				
				assertEquals('ICircle radius should be equal to ' + rand, impl.radius, rand);
			}
		}
		
		private function failIfCalled(mixin : IMixin, mixinError : MixinError) : void
		{
			fail('Failed to create mixin (' + mixin + ") with error " + mixinError);
		}
	}
}
