package org.osflash.mixins.generator.signals
{
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.errors.IllegalOperationError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.system.ApplicationDomain;
	import org.osflash.mixins.IMixin;
	import org.osflash.mixins.MixinError;
	import org.osflash.mixins.generator.IMixinLoader;
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	import org.osflash.signals.natives.NativeSignal;

	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class MultipleMixinLoaderSignals implements IMixinLoaderSignals
	{
		
		/**
		 * @private
		 */
		private const _completedSignal : ISignal = new Signal(Vector.<IMixin>);
		
		/**
		 * @private
		 */
		private const _errorSignal : ISignal = new Signal(Vector.<IMixin>, MixinError);
		
		/**
		 * @private
		 */
		private var _mixins : Vector.<IMixin>;
		
		/**
		 * @private
		 */
		private var _generator : IMixinLoader;
		
		/**
		 * @private
		 */
		private var _loader : Loader;
		
		/**
		 * @private 
		 */
		private var _loaderCompletedSignal : ISignal;

		/**
		 * @private 
		 */
		private var _loaderIOErrorSignal : ISignal;

		/**
		 * @private 
		 */
		private var _loaderErrorSignal : ISignal;
		
		/**
		 */
		public function MultipleMixinLoaderSignals(mixins : Vector.<IMixin>, generator : IMixinLoader)
		{
			if(null == mixins) throw new ArgumentError('Given Vector.<IMixin> can not be null');
			if(null == generator) throw new ArgumentError('Given IMixinLoader can not be null');
			
			_mixins = mixins;
			_generator = generator;
			
			_loader = generator.loader;
			if(null == _loader) throw new IllegalOperationError('MixingLoaderGenerator.loader() ' +
																			'can not be null.');
			
			const loaderInfo : LoaderInfo = _loader.contentLoaderInfo;
			
			_loaderCompletedSignal = new NativeSignal(loaderInfo, Event.COMPLETE, Event);
			_loaderCompletedSignal.addOnce(handleLoaderCompletedSignal);
			
			_loaderIOErrorSignal = new NativeSignal(loaderInfo, IOErrorEvent.IO_ERROR, IOErrorEvent);
			_loaderIOErrorSignal.addOnce(handleLoaderErrorSignal);
			
			_loaderErrorSignal = new NativeSignal(loaderInfo, ErrorEvent.ERROR, ErrorEvent);
			_loaderErrorSignal.addOnce(handleLoaderErrorSignal);
		}
		
		public function dispose() : void
		{
			_loaderCompletedSignal.removeAll();
			_loaderCompletedSignal = null;
			
			_loaderIOErrorSignal.removeAll();
			_loaderIOErrorSignal = null;
			
			_loaderErrorSignal.removeAll();
			_loaderErrorSignal = null;
		}
		
		/**
		 * @private
		 */
		private function handleLoaderCompletedSignal(event : Event) : void
		{
			const loaderInfo : LoaderInfo = _loader.contentLoaderInfo;
			const domain : ApplicationDomain = loaderInfo.applicationDomain;
			
			var index : int = _mixins.length;
			while(--index > -1)
			{
				_mixins[index].inject(domain);
			}
			
			completedSignal.dispatch(_mixins);
		}
				
		/**
		 * @private
		 */
		private function handleLoaderErrorSignal(event : ErrorEvent) : void
		{
			if(event is IOErrorEvent)
				errorSignal.dispatch(_mixins, MixinError.IO_ERROR);
			else
				errorSignal.dispatch(_mixins, MixinError.ERROR);
		}
		
		/**
		 * Add a signal to know when the class has been created.
		 */
		public function get completedSignal() : ISignal	{ return _completedSignal; }
		
		/**
		 * Add a signal to know when the class has been not be succesfully created.
		 */
		public function get errorSignal() : ISignal { return _errorSignal; }
		
		/**
		 * Get the current mixin that the signals are actioning on.
		 */
		public function get mixins() : Vector.<IMixin>
		{
			return _mixins;
		}
	}
}
