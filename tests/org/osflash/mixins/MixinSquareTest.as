package org.osflash.mixins
{
	import asunit.asserts.assertEquals;
	import asunit.asserts.assertNotNull;
	import asunit.asserts.assertTrue;
	import asunit.asserts.fail;
	import asunit.framework.IAsync;
	import org.osflash.mixins.generator.MixinGenerationSignals;
	import org.osflash.mixins.support.ISquare;
	import org.osflash.mixins.support.defs.IName;
	import org.osflash.mixins.support.defs.IPosition;
	import org.osflash.mixins.support.defs.ISize;
	import org.osflash.mixins.support.impl.NameImpl;
	import org.osflash.mixins.support.impl.PositionImpl;
	import org.osflash.mixins.support.impl.SizeImpl;



	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class MixinSquareTest
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
		public function create_square_mixin_and_verify_creation() : void
		{
			mixin.add(IPosition, PositionImpl);
			mixin.add(ISize, SizeImpl);
			mixin.add(IName, NameImpl);
			
			mixin.define(ISquare);
			
			const signals : MixinGenerationSignals = mixin.generate();
			signals.completedSignal.add(async.add(verifyCreationISquareImplementation, 1000));
			signals.errorSignal.add(failIfCalled);
		}

		private function verifyCreationISquareImplementation(mixin : IMixin) : void
		{
			const impl : ISquare = mixin.create(ISquare, true);
			
			assertNotNull('ISquare implementation is not null', impl);			
			assertTrue('Valid creation of ISquare implementation', impl is ISquare);
			assertTrue('Valid creation of ISize implementation', impl is ISize);
			assertTrue('Valid creation of IPosition implementation', impl is IPosition);
		}
		
		[Test]
		public function create_square_mixin_and_verify_getName() : void
		{
			mixin.add(IPosition, PositionImpl);
			mixin.add(ISize, SizeImpl);
			mixin.add(IName, NameImpl);
			
			mixin.define(ISquare);
			
			const signals : MixinGenerationSignals = mixin.generate();
			signals.completedSignal.add(async.add(verifyGetName, 1000));
			signals.errorSignal.add(failIfCalled);
		}
		
		private function verifyGetName(mixin : Mixin) : void
		{
			const impl : ISquare = mixin.create(ISquare, true);
			
			assertEquals('ISquare getName should be equal to NameImpl', 'NameImpl', impl.getName());
		}
		
		[Test]
		public function create_square_mixin_and_add_radius() : void
		{
			mixin.add(IPosition, PositionImpl);
			mixin.add(ISize, SizeImpl);
			mixin.add(IName, NameImpl);
			
			mixin.define(ISquare);
			
			const signals : MixinGenerationSignals = mixin.generate();
			signals.completedSignal.add(async.add(addWidthAndVerifyAddition, 1000));
			signals.errorSignal.add(failIfCalled);
		}
		
		private function addWidthAndVerifyAddition(mixin : Mixin) : void
		{
			const impl : ISquare = mixin.create(ISquare, true);
			
			impl.width = 5;
			
			assertEquals('ISquare width should be equal to 5', impl.width, 5);
			
			impl.height = 1;
			
			assertEquals('ISquare height should be equal to 1', impl.height, 1);
		}
		
		[Test]
		public function create_square_mixin_and_add_width_multiple_times() : void
		{
			mixin.add(IPosition, PositionImpl);
			mixin.add(ISize, SizeImpl);
			mixin.add(IName, NameImpl);
			
			mixin.define(ISquare);
			
			const signals : MixinGenerationSignals = mixin.generate();
			signals.completedSignal.add(async.add(addSizeMultipleTimesAndVerifyAddition, 1000));
			signals.errorSignal.add(failIfCalled);
		}
		
		private function addSizeMultipleTimesAndVerifyAddition(mixin : Mixin) : void
		{
			const impl : ISquare = mixin.create(ISquare, true);
			
			for(var i : int = 0; i<1000; i++)
			{
				const width : int = int(Math.random() * Number.MAX_VALUE);
				
				impl.width = width;
				
				assertEquals('ISquare width should be equal to ' + width, impl.width, width);
				
				const height : int = int(Math.random() * Number.MAX_VALUE);
				
				impl.height = height;
				
				assertEquals('ISquare height should be equal to ' + height, impl.height, height);
			}
		}
		
		[Test]
		public function create_multiple_square_mixins() : void
		{
			mixin.add(IPosition, PositionImpl);
			mixin.add(ISize, SizeImpl);
			mixin.add(IName, NameImpl);
			
			mixin.define(ISquare);
			
			const signals : MixinGenerationSignals = mixin.generate();
			signals.completedSignal.add(async.add(	verifyCreationOfMultipleISquareImplementation, 
													1000
													));
			signals.errorSignal.add(failIfCalled);
		}
		
		private function verifyCreationOfMultipleISquareImplementation(mixin : Mixin) : void
		{
			for(var i : int = 0; i<1000; i++)
			{
				const impl : ISquare = mixin.create(ISquare, true);
			
				assertNotNull('ISquare implementation is not null', impl);			
				assertTrue('Valid creation of ISquare implementation', impl is ISquare);
				assertTrue('Valid creation of ISize implementation', impl is ISize);
				assertTrue('Valid creation of IPosition implementation', impl is IPosition);
			}
		}
		
		private function failIfCalled(mixin : IMixin, mixinError : MixinError) : void
		{
			fail('Failed to create mixin (' + mixin + ") with error " + mixinError);
		}
	}
}
