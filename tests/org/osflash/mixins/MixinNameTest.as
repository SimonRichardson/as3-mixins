package org.osflash.mixins
{
	import asunit.asserts.assertEquals;
	import asunit.asserts.fail;
	import asunit.framework.IAsync;

	import org.flemit.bytecode.QualifiedName;
	import org.osflash.mixins.generator.signals.IMixinLoaderSignals;
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
	public class MixinNameTest
	{
		
		[Inject]
		public var async : IAsync;
						
		protected var mixin : IMixin; 
		
		protected var mixinName : String;
		
		[Before]
		public function setUp():void
		{
			mixin = new Mixin();
		}
		
		[After]
		public function tearDown():void
		{
			mixinName = null;
			
			mixin.removeAll();
			mixin = null;
		}
		
		[Test]
		public function test_changing_name_on_dynamic_sticks() : void
		{
			mixin.add(IPosition, PositionImpl);
			mixin.add(IRadius, RadiusImpl);
			mixin.add(IName, NameImpl);
			
			const binding : IMixinNamedBinding = mixin.define(ICircle, CircleImpl);
			const qname : QualifiedName = binding.name;
			
			mixinName = "IAmAmazing";
			
			binding.name = new QualifiedName(qname.ns, mixinName);
			
			const signals : IMixinLoaderSignals = mixin.generate();
			signals.completedSignal.add(async.add(verifyGetName, 1000));
			signals.errorSignal.add(failIfCalled);
		}
		
		private function verifyGetName(mixin : Mixin) : void
		{
			const impl : ICircle = mixin.create(ICircle);
			
			assertEquals('ICircle getName should be equal to IAmAmazing', mixinName, impl.toString());
		}
		
		private function failIfCalled(mixin : IMixin, mixinError : MixinError) : void
		{
			fail('Failed to create mixin (' + mixin + ") with error " + mixinError);
		}
	}
}
