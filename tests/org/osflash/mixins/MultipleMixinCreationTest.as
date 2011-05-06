package org.osflash.mixins
{
	import asunit.asserts.fail;
	import asunit.framework.IAsync;

	import org.osflash.mixins.generator.MixinLoader;
	import org.osflash.mixins.generator.signals.IMixinLoaderSignals;
	import org.osflash.mixins.support.ICircle;
	import org.osflash.mixins.support.ISquare;
	import org.osflash.mixins.support.defs.IName;
	import org.osflash.mixins.support.defs.IPosition;
	import org.osflash.mixins.support.defs.IRadius;
	import org.osflash.mixins.support.defs.ISize;
	import org.osflash.mixins.support.impl.CircleImpl;
	import org.osflash.mixins.support.impl.NameImpl;
	import org.osflash.mixins.support.impl.PositionImpl;
	import org.osflash.mixins.support.impl.RadiusImpl;
	import org.osflash.mixins.support.impl.SizeImpl;

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
			
		}
		
		private function failIfCalled(mixins : Vector.<IMixin>, mixinError : MixinError) : void
		{
			fail('Failed to create mixins (' + mixins + ") with error " + mixinError);
		}
	}
}
