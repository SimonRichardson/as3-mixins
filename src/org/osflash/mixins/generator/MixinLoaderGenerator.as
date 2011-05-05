package org.osflash.mixins.generator
{
	import org.flemit.SWFHeader;
	import org.flemit.SWFWriter;
	import org.flemit.bytecode.IByteCodeLayout;
	import org.flemit.tags.DoABCTag;
	import org.flemit.tags.EndTag;
	import org.flemit.tags.FileAttributesTag;
	import org.flemit.tags.FrameLabelTag;
	import org.flemit.tags.ITag;
	import org.flemit.tags.ScriptLimitsTag;
	import org.flemit.tags.SetBackgroundColorTag;
	import org.flemit.tags.ShowFrameTag;

	import flash.display.Loader;
	import flash.net.FileReference;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	
	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public class MixinLoaderGenerator
	{
		
		/**
		 * The current SWF header version for the loader to generate.
		 */
		public static const SWF_HEARDER_TYPE : int = 10;
		
		/**
		 * @private
		 */
		private var _layout : IByteCodeLayout;
		
		/**
		 * @private
		 */
		private var _domain : ApplicationDomain;
		
		/**
		 * @private
		 */
		private const _buffer : ByteArray = new ByteArray();
		
		/**
		 * @private
		 */
		private const _loader : Loader = new Loader();
		
		/**
		 * @private
		 */
		private const _header : SWFHeader = new SWFHeader(SWF_HEARDER_TYPE);
		
		/**
		 * @private
		 */
		private const _writer : SWFWriter = new SWFWriter();
						
		/**
		 * Load the bytecode in to the aync Loader for the execution.
		 */
		public function load(layout : IByteCodeLayout, domain : ApplicationDomain) : void
		{
			_layout = layout;
			_domain = domain;
						
			_writer.write(_buffer, _header, Vector.<ITag>([
					new FileAttributesTag(false, false, false, true, true),
					new ScriptLimitsTag(),
					new SetBackgroundColorTag(0xFF, 0x0, 0x0),
					new FrameLabelTag("MixinFrameLabel"),
					new DoABCTag("MixinGenerated", _layout),
					new ShowFrameTag(),
					new EndTag()
			]));
			
			_buffer.position = 0;
			
			// Add the loader context
			const loaderContext:LoaderContext = new LoaderContext(false, _domain);
			enableAIRDynamicExecution(loaderContext);
			
			//
			new FileReference().save(_buffer, "dump.swf");
			_buffer.position = 0;
			//
			
			// Loader the buffer to the loaded bytes
			_loader.loadBytes(_buffer, loaderContext);
			
			_buffer.position = 0;
			_buffer.length = 0;
		}
		
		/**
		 * Dispose the current loader and buffer
		 */
		public function dispose() : void
		{
			_domain = null;
			
			_buffer.position = 0;
			_buffer.length = 0;
			
			if(null != _layout)
			{
				_layout.dispose();
				_layout = null;
			}
			
			try
			{
				_loader.unloadAndStop(true);	
			}
			catch(error : Error) {};
		}
		
		/**
		 * Needed for all AIR applications. Otherwise code execution will not work.
		 * 
		 * @param loaderContext LoaderContext for which to allow conde excution to work on.
		 */
		protected function enableAIRDynamicExecution(loaderContext:LoaderContext) : void
		{
			if (loaderContext.hasOwnProperty("allowLoadBytesCodeExecution"))
			{
				loaderContext["allowLoadBytesCodeExecution"] = true;
			}
		}
		
		/**
		 * Get the current Loader used for the inject process.
		 * 
		 * @return Loader
		 */
		public function get loader() : Loader
		{
			return _loader;
		}
	}
}
