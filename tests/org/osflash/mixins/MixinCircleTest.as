package org.osflash.mixins
{
	import asunit.framework.IAsync;

	import org.osflash.mixins.support.ICircle;
	import org.osflash.mixins.support.IPosition;
	import org.osflash.mixins.support.ISize;
	import org.osflash.mixins.support.impl.PositionImpl;
	import org.osflash.mixins.support.impl.SizeImpl;
	import org.osflash.mixins.support.observers.MixinCircleTestObservers;
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
			const observer : MixinCircleTestObservers = new MixinCircleTestObservers();
			
			mixin.completedSignal.add(observer.mixinCompletedSignal);
			mixin.errorSignal.add(observer.mixinErrorSiginal);
			
			mixin.add(IPosition, PositionImpl);
			mixin.add(ISize, SizeImpl);
			mixin.define(ICircle);
		}
	}
}
