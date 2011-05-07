package org.osflash.mixins
{
	import asunit.asserts.assertEquals;
	import asunit.asserts.assertNotNull;
	import asunit.asserts.assertTrue;
	import asunit.asserts.fail;
	import asunit.framework.IAsync;

	import org.osflash.mixins.generator.MixinLoader;
	import org.osflash.mixins.generator.signals.IMixinLoaderSignals;
	import org.osflash.mixins.support.shape.ICircle;
	import org.osflash.mixins.support.shape.ISquare;
	import org.osflash.mixins.support.shape.defs.IName;
	import org.osflash.mixins.support.shape.defs.IPosition;
	import org.osflash.mixins.support.shape.defs.IRadius;
	import org.osflash.mixins.support.shape.defs.ISize;
	import org.osflash.mixins.support.shape.impl.CircleImpl;
	import org.osflash.mixins.support.shape.impl.NameImpl;
	import org.osflash.mixins.support.shape.impl.PositionImpl;
	import org.osflash.mixins.support.shape.impl.RadiusImpl;
	import org.osflash.mixins.support.shape.impl.SizeImpl;


	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class MultipleMixinCreationTest
	{
		[Inject]
		public var async : IAsync;
		
		protected var mixin0 : IMixin; 
		
		protected var mixin1 : IMixin; 
		
		[Before]
		public function setUp():void
		{
			mixin0 = new Mixin();
			mixin1 = new Mixin();
		}
		
		[After]
		public function tearDown():void
		{
			mixin0.removeAll();
			mixin0 = null;
			
			mixin1.removeAll();
			mixin1 = null;
		}
		
		[Test]
		public function create_both_mixins_and_verify_creation() : void
		{
			mixin0.add(IPosition, PositionImpl);
			mixin0.add(IRadius, RadiusImpl);
			mixin0.add(IName, NameImpl);
			
			mixin0.define(ICircle, CircleImpl);
			
			mixin1.add(IPosition, PositionImpl);
			mixin1.add(ISize, SizeImpl);
			mixin1.add(IName, NameImpl);
			
			mixin1.define(ISquare);
			
			const loader : MixinLoader = new MixinLoader();
			loader.add(mixin0);
			loader.add(mixin1);
			
			const signals : IMixinLoaderSignals = loader.load();
			signals.completedSignal.add(async.add(handleCompletedSignal, 1000));
			signals.errorSignal.add(failIfCalled);
		}
		
		private function handleCompletedSignal(mixins : Vector.<IMixin>) : void
		{
			assertEquals('Resulting mixins length should be 2', 2, mixins.length);
			
			const mixin_0 : IMixin = mixins[1];
						
			const impl0 : ICircle = mixin_0.create(ICircle);
						
			assertNotNull('ICircle implementation is not null', impl0);			
			assertTrue('Valid creation of ICircle implementation', impl0 is ICircle);
			assertTrue('Valid creation of IRadius implementation', impl0 is IRadius);
			assertTrue('Valid creation of IPosition implementation', impl0 is IPosition);
			
			const mixin_1 : IMixin = mixins[1];
			
			const impl1 : ISquare = mixin_1.create(ISquare, {regular:true});
			
			assertNotNull('ISquare implementation is not null', impl1);			
			assertTrue('Valid creation of ISquare implementation', impl1 is ISquare);
			assertTrue('Valid creation of ISize implementation', impl1 is ISize);
			assertTrue('Valid creation of IPosition implementation', impl1 is IPosition);
		}
		
		private function failIfCalled(mixins : Vector.<IMixin>, mixinError : MixinError) : void
		{
			fail('Failed to create mixins (' + mixins + ") with error " + mixinError);
		}
	}
}
