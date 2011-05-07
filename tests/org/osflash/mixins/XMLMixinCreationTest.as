package org.osflash.mixins
{
	import org.osflash.mixins.support.shape.impl.RadiusImpl;
	import asunit.asserts.assertNotNull;
	import asunit.asserts.assertTrue;
	import asunit.asserts.fail;
	import asunit.framework.IAsync;

	import org.osflash.mixins.generator.signals.IMixinLoaderSignals;
	import org.osflash.mixins.support.MixinPreloader;
	import org.osflash.mixins.support.shape.ICircle;
	import org.osflash.mixins.support.shape.IRectangle;
	import org.osflash.mixins.support.shape.ISquare;
	import org.osflash.mixins.support.shape.defs.IPosition;
	import org.osflash.mixins.support.shape.defs.ISize;
	import org.osflash.mixins.support.shape.impl.NameImpl;
	import org.osflash.mixins.support.shape.impl.PositionImpl;
	import org.osflash.mixins.support.shape.impl.SizeImpl;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class XMLMixinCreationTest
	{
		// I hate doing this, there are a couple of options to fix this though.
		// 1. Do this
		// 2. Use -include='path.to.class.ClassName'
		// 3. Use [Frame(extraClass='path.to.class.ClassName'] in a document that does get compiled
		// 4. Make a ant script that generates a list of includes at compile time.
		PositionImpl, SizeImpl, NameImpl, RadiusImpl;
		IRectangle, ICircle;
				
		[Inject]
		public var async : IAsync;
		
		
		[Before]
		public function setUp():void
		{
			
		}
		
		[After]
		public function tearDown():void
		{
			
		}
		
		[Test]
		public function create_mixin_with_xml_and_verify_creation() : void
		{
			const xml : XML = <mixins version="1.0">
								<mixin>
									<add 
										desc="org.osflash.mixins.support.shape.defs.IPosition"
										impl="org.osflash.mixins.support.shape.impl.PositionImpl"
										/>
									<add 
										desc='org.osflash.mixins.support.shape.defs.ISize'
										impl='org.osflash.mixins.support.shape.impl.SizeImpl'
										/>
									<add 
										desc="org.osflash.mixins.support.shape.defs.IName"
										impl="org.osflash.mixins.support.shape.impl.NameImpl"
										/>
									<define
										impl='org.osflash.mixins.support.shape.ISquare'
										/>
									<define
										impl='org.osflash.mixins.support.shape.IRectangle'
										/>		
								</mixin>
								<mixin>
									<add 
										desc="org.osflash.mixins.support.shape.defs.IPosition"
										impl="org.osflash.mixins.support.shape.impl.PositionImpl"
										/>
									<add 
										desc='org.osflash.mixins.support.shape.defs.IRadius'
										impl='org.osflash.mixins.support.shape.impl.RadiusImpl'
										/>
									<add 
										desc="org.osflash.mixins.support.shape.defs.IName"
										impl="org.osflash.mixins.support.shape.impl.NameImpl"
										/>
									<define
										impl='org.osflash.mixins.support.shape.ICircle'
										/>	
								</mixin>
							</mixins>;
			
			const preloader : MixinPreloader = new MixinPreloader();
			const signals : IMixinLoaderSignals = preloader.loadXML(xml);
			signals.completedSignal.add(async.add(handleCompletedSignal, 1000));
			signals.errorSignal.add(failIfCalled);
		}
		
		private function handleCompletedSignal(mixins : Vector.<IMixin>) : void
		{
			const mixin : IMixin = mixins[0];
			const impl : ISquare = mixin.create(ISquare, {regular:true});
			
			assertNotNull('ISquare implementation is not null', impl);			
			assertTrue('Valid creation of ISquare implementation', impl is ISquare);
			assertTrue('Valid creation of ISize implementation', impl is ISize);
			assertTrue('Valid creation of IPosition implementation', impl is IPosition);
		}
		
		private function failIfCalled(mixins : IMixin, mixinError : MixinError) : void
		{
			fail('Failed to create mixins (' + mixins + ") with error " + mixinError);
		}
	}
}
