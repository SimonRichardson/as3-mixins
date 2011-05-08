package org.osflash.mixins
{
	import asunit.asserts.assertFalse;
	import asunit.asserts.assertTrue;
	import asunit.asserts.fail;
	import asunit.framework.IAsync;

	import org.osflash.mixins.generator.signals.IMixinLoaderSignals;
	import org.osflash.mixins.support.init.IBasic;
	import org.osflash.mixins.support.init.defs.ISomething;
	import org.osflash.mixins.support.init.impl.BasicImpl;
	import org.osflash.mixins.support.init.impl.SomethingImpl;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class MixinInitTest
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
		public function verify_that_init_is_called() : void
		{
			mixin.add(ISomething, SomethingImpl);
			
			mixin.define(IBasic, BasicImpl);
			
			const signals : IMixinLoaderSignals = mixin.generate();
			signals.completedSignal.add(async.add(verifyInitCalled, 1000));
			signals.errorSignal.add(failIfCalled);
		}
		
		private function verifyInitCalled(mixin : IMixin) : void
		{
			const basic : BasicImpl = mixin.create(IBasic) as BasicImpl;
			assertTrue('__init__ should have been called in BasicImpl', basic.initCalled);
		}
		
		[Test]
		public function verify_that_init_is_called_again_if_magic___init___is_called() : void
		{
			mixin.add(ISomething, SomethingImpl);
			
			mixin.define(IBasic, BasicImpl);
			
			const signals : IMixinLoaderSignals = mixin.generate();
			signals.completedSignal.add(async.add(verifyMagic___Init___Called, 1000));
			signals.errorSignal.add(failIfCalled);
		}
		
		private function verifyMagic___Init___Called(mixin : IMixin) : void
		{
			const basic : BasicImpl = mixin.create(IBasic) as BasicImpl;
			assertTrue('__init__ should have been called in BasicImpl', basic.initCalled);
			
			basic.reset();
			
			assertFalse('initCalled should have been reset to false', basic.initCalled);
			
			basic["___init___"]();
			
			assertTrue('__init__ should have been called in BasicImpl again', basic.initCalled);
		}
		
		private function failIfCalled(mixin : IMixin, mixinError : MixinError) : void
		{
			fail('Failed to create mixin (' + mixin + ") with error " + mixinError);
		}
	}
}
