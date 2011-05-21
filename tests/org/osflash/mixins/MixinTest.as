package org.osflash.mixins
{
	import org.osflash.mixins.support.shape.ICircle;
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
		public function descriptor_can_not_be_null_on_add() : void
		{
			mixin.add(null, NameImpl);
		}
		
		[Test(expects="ArgumentError")]
		public function implementation_can_not_be_null_on_add() : void
		{
			mixin.add(IName, null);
		}
		
		[Test(expects="ArgumentError")]
		public function descriptor_and_implementation_can_not_be_null_on_add() : void
		{
			mixin.add(null, null);
		}
		
		[Test(expects="ArgumentError")]
		public function definition_can_not_be_null_on_define() : void
		{
			mixin.define(null);
		}
		
		public function superClass_can_be_null_on_define() : void
		{
			mixin.define(ICircle, null);
		}
		
		[Test(expects="ArgumentError")]
		public function descriptor_can_not_be_null_on_remove() : void
		{
			mixin.remove(null);
		}
		
		[Test(expects="ArgumentError")]
		public function definition_can_not_be_null_on_undefine() : void
		{
			mixin.undefine(null);
		}
	}
}
