package org.osflash.mixins
{
	import asunit.framework.IAsync;
	import asunit.asserts.assertNotNull;
	import asunit.asserts.assertTrue;
	import asunit.asserts.fail;

	import org.osflash.mixins.generator.MixinGenerationSignals;
	import org.osflash.mixins.support.IName;
	import org.osflash.mixins.support.IPosition;
	import org.osflash.mixins.support.IRectangle;
	import org.osflash.mixins.support.ISize;
	import org.osflash.mixins.support.ISquare;
	import org.osflash.mixins.support.impl.NameImpl;
	import org.osflash.mixins.support.impl.PositionImpl;
	import org.osflash.mixins.support.impl.SizeImpl;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class MixinShapeTest
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
			mixin.define(IRectangle);
			
			const signals : MixinGenerationSignals = mixin.generate();
			signals.completedSignal.add(async.add(verifyCreationShapeImplementation, 1000));
			signals.errorSignal.add(failIfCalled);
		}

		private function verifyCreationShapeImplementation(mixin : IMixin) : void
		{
			const squareImpl : ISquare = mixin.create(ISquare, true);
			
			assertNotNull('ISquare implementation is not null', squareImpl);			
			assertTrue('Valid creation of ISquare implementation', squareImpl is ISquare);
			assertTrue('Valid creation of ISize implementation', squareImpl is ISize);
			assertTrue('Valid creation of IPosition implementation', squareImpl is IPosition);
			
			const rectangleImpl : IRectangle = mixin.create(IRectangle, false);
						
			assertNotNull('IRectangle implementation is not null', rectangleImpl);			
			assertTrue('Valid creation of IRectangle implementation', rectangleImpl is IRectangle);
			assertTrue('Valid creation of ISize implementation', rectangleImpl is ISize);
			assertTrue('Valid creation of IPosition implementation', rectangleImpl is IPosition);
		}
		
		private function failIfCalled(mixin : IMixin, mixinError : MixinError) : void
		{
			fail('Failed to create mixin (' + mixin + ") with error " + mixinError);
		}
	}
}
