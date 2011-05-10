package org.osflash.mixins
{
	import asunit.asserts.assertEquals;
	import asunit.asserts.assertNotNull;
	import asunit.asserts.assertTrue;
	import asunit.asserts.fail;
	import asunit.framework.IAsync;

	import org.osflash.mixins.generator.signals.IMixinLoaderSignals;
	import org.osflash.mixins.support.MixinFactoryPool;
	import org.osflash.mixins.support.shape.ICircle;
	import org.osflash.mixins.support.shape.defs.IName;
	import org.osflash.mixins.support.shape.defs.IPosition;
	import org.osflash.mixins.support.shape.defs.IRadius;
	import org.osflash.mixins.support.shape.impl.CircleImpl;
	import org.osflash.mixins.support.shape.impl.NameImpl;
	import org.osflash.mixins.support.shape.impl.PositionImpl;
	import org.osflash.mixins.support.shape.impl.RadiusImpl;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class MixinFactoryPoolTest
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
		public function verify_pool_size() : void
		{
			mixin.add(IPosition, PositionImpl);
			mixin.add(IRadius, RadiusImpl);
			mixin.add(IName, NameImpl);
			
			mixin.define(ICircle, CircleImpl);
			
			const signals : IMixinLoaderSignals = mixin.generate();
			signals.completedSignal.add(async.add(verifyPoolSize, 1000));
			signals.errorSignal.add(failIfCalled);
		}
		
		private function verifyPoolSize(mixin : IMixin) : void
		{
			const pool : MixinFactoryPool = new MixinFactoryPool(mixin, ICircle);
			
			assertEquals('Size should equal default pool size', pool.poolGrowSize, pool.size);
			assertEquals('PoolSize should equal default pool size', pool.poolGrowSize, pool.poolSize);
		}
		
		[Test]
		public function verify_pool_size_after_pop() : void
		{
			mixin.add(IPosition, PositionImpl);
			mixin.add(IRadius, RadiusImpl);
			mixin.add(IName, NameImpl);
			
			mixin.define(ICircle, CircleImpl);
			
			const signals : IMixinLoaderSignals = mixin.generate();
			signals.completedSignal.add(async.add(verifyPoolSizeAfterPop, 1000));
			signals.errorSignal.add(failIfCalled);
		}
		
		private function verifyPoolSizeAfterPop(mixin : IMixin) : void
		{
			const pool : MixinFactoryPool = new MixinFactoryPool(mixin, ICircle);
			
			pool.pop();
			
			assertEquals('Size should equal default pool size', pool.poolGrowSize, pool.size);
		}
		
		[Test]
		public function verify_pool_size_after_mulitple_pop() : void
		{
			mixin.add(IPosition, PositionImpl);
			mixin.add(IRadius, RadiusImpl);
			mixin.add(IName, NameImpl);
			
			mixin.define(ICircle, CircleImpl);
			
			const signals : IMixinLoaderSignals = mixin.generate();
			signals.completedSignal.add(async.add(verifyPoolSizeAfterMultiplePop, 1000));
			signals.errorSignal.add(failIfCalled);
		}
		
		private function verifyPoolSizeAfterMultiplePop(mixin : IMixin) : void
		{
			const pool : MixinFactoryPool = new MixinFactoryPool(mixin, ICircle);
			
			const poolGrowSize : int = pool.poolGrowSize;
			for(var i : int = 0; i<poolGrowSize + 1; i++)
			{
				pool.pop();
			}
			
			const size : int = pool.poolGrowSize * 2;
			assertEquals('Size should equal default pool size', size, pool.size);
		}
		
		[Test]
		public function verify_pool_size_after_pop_and_push() : void
		{
			mixin.add(IPosition, PositionImpl);
			mixin.add(IRadius, RadiusImpl);
			mixin.add(IName, NameImpl);
			
			mixin.define(ICircle, CircleImpl);
			
			const signals : IMixinLoaderSignals = mixin.generate();
			signals.completedSignal.add(async.add(verifyPoolSizeAfterPopAndPush, 1000));
			signals.errorSignal.add(failIfCalled);
		}
		
		private function verifyPoolSizeAfterPopAndPush(mixin : IMixin) : void
		{
			const pool : MixinFactoryPool = new MixinFactoryPool(mixin, ICircle);
			
			pool.push(pool.pop());
			
			assertEquals('Size should equal default pool size', pool.poolGrowSize, pool.size);
		}
		
		[Test]
		public function verify_pool_size_after_mulitple_pop_and_push() : void
		{
			mixin.add(IPosition, PositionImpl);
			mixin.add(IRadius, RadiusImpl);
			mixin.add(IName, NameImpl);
			
			mixin.define(ICircle, CircleImpl);
			
			const signals : IMixinLoaderSignals = mixin.generate();
			signals.completedSignal.add(async.add(verifyPoolSizeAfterMultiplePopAndPush, 1000));
			signals.errorSignal.add(failIfCalled);
		}
		
		private function verifyPoolSizeAfterMultiplePopAndPush(mixin : IMixin) : void
		{
			const pool : MixinFactoryPool = new MixinFactoryPool(mixin, ICircle);
			const poolGrowSize : int = pool.poolGrowSize;
			
			const results : Vector.<ICircle> = new Vector.<ICircle>();
			
			var i : int;
			for(i = 0; i<poolGrowSize + 1; i++)
			{
				results.push(pool.pop() as ICircle);
			}
			
			const total : int = results.length;
			for(i = 0; i<total; i++)
			{
				pool.push(results[i]);
			}
			
			const size : int = pool.poolGrowSize * 2;
			assertEquals('Size should equal default pool size', size, pool.size);
		}
		
		[Test]
		public function verify_pool_pop_creation() : void
		{
			mixin.add(IPosition, PositionImpl);
			mixin.add(IRadius, RadiusImpl);
			mixin.add(IName, NameImpl);
			
			mixin.define(ICircle, CircleImpl);
			
			const signals : IMixinLoaderSignals = mixin.generate();
			signals.completedSignal.add(async.add(verifyPoolImplementationCreation, 1000));
			signals.errorSignal.add(failIfCalled);
		}
		
		private function verifyPoolImplementationCreation(mixin : IMixin) : void
		{
			const pool : MixinFactoryPool = new MixinFactoryPool(mixin, ICircle);
			
			const impl : ICircle = pool.pop() as ICircle;
			
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
