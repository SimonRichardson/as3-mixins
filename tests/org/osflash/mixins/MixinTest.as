package org.osflash.mixins
{
	import asunit.framework.IAsync;

	import org.osflash.mixins.support.shape.defs.IName;
	import org.osflash.mixins.support.shape.impl.NameImpl;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class MixinTest
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
		
		[Test(expects="ArgumentError")]
		public function test_descriptor_can_not_be_null() : void
		{
			mixin.add(null, NameImpl);
		}
		
		[Test(expects="ArgumentError")]
		public function test_implementation_can_not_be_null() : void
		{
			mixin.add(IName, null);
		}
		
		[Test(expects="ArgumentError")]
		public function test_descriptor_and_implementation_can_not_be_null() : void
		{
			mixin.add(null, null);
		}
	}
}
