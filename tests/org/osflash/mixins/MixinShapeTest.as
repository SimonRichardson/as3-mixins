package org.osflash.mixins
{
	import asunit.asserts.assertEquals;
	import asunit.asserts.assertFalse;
	import asunit.asserts.assertNotNull;
	import asunit.asserts.assertTrue;
	import asunit.asserts.fail;
	import asunit.framework.IAsync;

	import org.osflash.mixins.generator.IMixinLoaderSignals;
	import org.osflash.mixins.support.IRectangle;
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
			
			const signals : IMixinLoaderSignals = mixin.generate();
			signals.completedSignal.add(async.add(verifyCreationShapeImplementation, 1000));
			signals.completedSignal.add(async.add(verifySquareIsRegular, 1000));
			signals.completedSignal.add(async.add(verifySquareArguments, 1000));
			signals.errorSignal.add(failIfCalled);
		}

		private function verifyCreationShapeImplementation(mixin : IMixin) : void
		{
			const squareImpl : ISquare = mixin.create(ISquare, {regular:true});
			
			assertNotNull('ISquare implementation is not null', squareImpl);			
			assertTrue('Valid creation of ISquare implementation', squareImpl is ISquare);
			assertTrue('Valid creation of ISize implementation', squareImpl is ISize);
			assertTrue('Valid creation of IPosition implementation', squareImpl is IPosition);
			
			const rectangleImpl : IRectangle = mixin.create(IRectangle);
						
			assertNotNull('IRectangle implementation is not null', rectangleImpl);			
			assertTrue('Valid creation of IRectangle implementation', rectangleImpl is IRectangle);
			assertTrue('Valid creation of ISize implementation', rectangleImpl is ISize);
			assertTrue('Valid creation of IPosition implementation', rectangleImpl is IPosition);
		}
		
		private function verifySquareIsRegular(mixin : IMixin) : void
		{
			const squareImpl : ISquare = mixin.create(ISquare, {regular:true});
			
			squareImpl.width = 10;
			
			assertTrue('ISquare should be regular', squareImpl.regular);
			assertEquals('Setting width to 10 should also set height to 10', 10, squareImpl.height);
			
			squareImpl.height = -5;
			
			assertEquals('Setting height to -5 should also set width to -5', -5, squareImpl.width);
		}
		
		private function verifySquareArguments(mixin : IMixin) : void
		{
			const squareImpl : ISquare = mixin.create(ISquare, {	regular:false, 
																	width:100,
																	height:205,
																	x:25,
																	y:99
																	});
			
			assertFalse('Property regular should be false', squareImpl.regular);
			assertEquals('Property width should be 100', 100, squareImpl.width);
			assertEquals('Property height should be 205', 205, squareImpl.height);
			assertEquals('Property x should be 25', 25, squareImpl.x);
			assertEquals('Property y should be 99', 99, squareImpl.y);
		}
		
		private function failIfCalled(mixin : IMixin, mixinError : MixinError) : void
		{
			fail('Failed to create mixin (' + mixin + ") with error " + mixinError);
		}
	}
}
