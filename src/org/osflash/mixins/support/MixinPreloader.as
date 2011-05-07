package org.osflash.mixins.support
{
	import org.osflash.mixins.IMixin;
	import org.osflash.mixins.Mixin;
	import org.osflash.mixins.generator.IMixinLoader;
	import org.osflash.mixins.generator.MixinLoader;
	import org.osflash.mixins.generator.signals.IMixinLoaderSignals;

	import flash.errors.IllegalOperationError;
	import flash.utils.getDefinitionByName;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class MixinPreloader
	{
		
		/**
		 * Load mixins via XML, which will pass back a IMixinLoaderSignals to enable you to hook
		 * on to various ISignals. Once loaded completed it use the mixin in the completed argument
		 * to generate the mixins at runtime.
		 * 
		 * <pre>
		 * const xml : XML = <mixins version="1.0">
		 * <mixin>
		 * 	<add desc="org.osflash.mixins.support.shape.defs.IPosition" impl="org.osflash.mixins.support.shape.impl.PositionImpl"/>
		 * 	<add desc='org.osflash.mixins.support.shape.defs.ISize' impl='org.osflash.mixins.support.shape.impl.SizeImpl'/>
		 * 	<add desc="org.osflash.mixins.support.shape.defs.IName" impl="org.osflash.mixins.support.shape.impl.NameImpl"/>
		 * 	<define	impl='org.osflash.mixins.support.shape.ISquare'/>
		 * 	<define impl='org.osflash.mixins.support.shape.IRectangle'/>		
		 * </mixin>
		 * </mixins>;
		 * 
		 * const preloader : MixinPreloader = new MixinPreloader();
		 * const signals : IMixinLoaderSignals = preloader.loadXML(xml);
		 * signals.completedSignal.add(function(mixin : IMixin) : void {
		 * 	const impl : ISquare = mixin.create(ISquare);
		 * });
		 *</pre>
		 * @param xml XML containing the xml required to generate the xml
		 * @return IMixinLoaderSignals
		 */
		public function loadXML(xml : XML) : IMixinLoaderSignals
		{
			if(null == xml) throw new ArgumentError('Given xml can not be null.');
			
			const mixinLoader : IMixinLoader = new MixinLoader();
			
			const elements : XMLList = xml.child('mixin');
			for each(var element : XML in elements)
			{
				const mixin : IMixin = new Mixin();
				
				const adds : XMLList = element.child('add');
				for each(var add : XML in adds)
				{
					try
					{
						const addDescName : String = parseClassName(add.@desc);
						const addDescClass : Class = getDefinitionByName(addDescName) as Class;
						if(null == addDescClass) throw new ArgumentError('Given descriptor (' +
												addDescName + ') can not be found.');
						
						const addImplName : String = parseClassName(add.@impl);
						const addImplClass : Class = getDefinitionByName(addImplName) as Class;
						if(null == addImplClass) throw new ArgumentError('Given implementation (' +
												addImplName + ') can not be found.');
						
						mixin.add(addDescClass, addImplClass);
					}
					catch(error : Error)
					{
						throw new IllegalOperationError('Unable to add() to the mixin.');
					}
				}
				
				const defines : XMLList = element.child('define');
				for each(var define : XML in defines)
				{
					try
					{
						const defineImplName : String = parseClassName(define.@impl);
						const defineImplClass : Class = getDefinitionByName(defineImplName) as Class;
						if(null == defineImplClass) throw new ArgumentError('Given ' + 
									'implementation (' + defineImplName + ') can not be found.');
						
						mixin.define(defineImplClass);
					}
					catch(error : Error)
					{
						throw new IllegalOperationError('Unable to locate classes for defining.');
					}
				}
				
				mixinLoader.add(mixin);
			}
			
			return load(mixinLoader);
		}
		
		/**
		 * Convience method for loading a mixin.
		 */
		public function load(loader : IMixinLoader) : IMixinLoaderSignals
		{
			return loader.load();
		}
		
		/**
		 * @private
		 */
		private function parseClassName(value : String) : String
		{
			if(value.indexOf('[class') == 0)
				throw new IllegalOperationError('Unable to locate the class path name (' + 
																					value + ')');
			return value;
		}
	}
}
