package org.osflash.mixins
{
	import asunit.asserts.assertEquals;
	import asunit.asserts.assertNotNull;
	import asunit.asserts.assertTrue;
	import asunit.asserts.fail;
	import asunit.framework.IAsync;

	import org.osflash.mixins.generator.signals.IMixinLoaderSignals;
	import org.osflash.mixins.support.signals.IMixinSignal;
	import org.osflash.mixins.support.signals.impl.MixinSignalImpl;
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class MixinSignalTest
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
		
		[Tester]
		public function create_signal_mixin_and_verify_creation() : void
		{
			mixin.add(ISignal, Signal);
			
			mixin.define(IMixinSignal);
			
			const signals : IMixinLoaderSignals = mixin.generate();
			signals.completedSignal.add(async.add(verifyCreationIMixinSignalImplementation, 1000));
			signals.errorSignal.add(failIfCalled);
		}

		private function verifyCreationIMixinSignalImplementation(mixin : IMixin) : void
		{
			const impl : IMixinSignal = mixin.create(IMixinSignal, {valueClasses:[String, int], strict:true});
						
			assertNotNull('ICircle implementation is not null', impl);			
			assertTrue('Valid creation of ISignal implementation', impl is ISignal);
		}
		
		[Test]
		public function create_signal_mixin_and_verify_callback() : void
		{
			mixin.add(ISignal, Signal);
			
			mixin.define(IMixinSignal, MixinSignalImpl);
			
			const signals : IMixinLoaderSignals = mixin.generate();
			signals.completedSignal.add(async.add(verifyIMixinSignalCallback, 1000));
			signals.errorSignal.add(failIfCalled);
		}

		private function verifyIMixinSignalCallback(mixin : IMixin) : void
		{
			const impl : IMixinSignal = mixin.create(IMixinSignal, {valueClasses:[String, int], strict:true});
			
			assertNotNull('ICircle implementation is not null', impl);			
			assertTrue('Valid creation of ISignal implementation', impl is ISignal);
			
			impl.add(async.add(function(s : String, i : int) : void 
			{
				assertEquals('Valid string argument', '1234', s);
				assertEquals('Valid int argument', 5678, i);
			}, 1000));
			
			impl.dispatch("1234", 5678);
		}
		
		private function failIfCalled(mixin : IMixin, mixinError : MixinError) : void
		{
			fail('Failed to create mixin (' + mixin + ") with error " + mixinError);
		}
	}
}
