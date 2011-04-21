package org.osflash.mixins
{
	import asunit.asserts.assertNotNull;
	import asunit.framework.IAsync;

	import org.osflash.mixins.support.ICircle;
	import org.osflash.mixins.support.IPosition;
	import org.osflash.mixins.support.ISize;
	import org.osflash.mixins.support.impl.PositionImpl;
	import org.osflash.mixins.support.impl.SizeImpl;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class MixinCircleTest implements IMixinObserver
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
			mixin.addObserver(this);
			mixin.add(IPosition, PositionImpl);
			mixin.add(ISize, SizeImpl);
			mixin.define(ICircle);
		}
				
		public function mixinCompletedSignal(mixin : IMixin) : void
		{
			const circle : ICircle = mixin.create(ICircle);
			
			assertNotNull('ICircle implementation is not null', circle);
		}

		public function mixinErrorSiginal(mixin : IMixin) : void
		{
		}
	}
}
