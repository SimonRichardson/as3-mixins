package org.osflash.mixins.generator.signals
{
	import org.osflash.mixins.IMixin;
	import org.osflash.mixins.MixinError;
	import org.osflash.mixins.generator.IMixinLoader;
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	import org.osflash.signals.natives.NativeSignal;

	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.errors.IllegalOperationError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.system.ApplicationDomain;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class SingleMixinLoaderSignals implements IMixinLoaderSignals
	{
		
		/**
		 * @private
		 */
		private const _completedSignal : ISignal = new Signal(IMixin);
		
		/**
		 * @private
		 */
		private const _progressSignal : ISignal = new Signal(Number, ProgressEvent);
		
		/**
		 * @private
		 */
		private const _errorSignal : ISignal = new Signal(IMixin, MixinError);
		
		/**
		 * @private
		 */
		private var _mixin : IMixin;
		
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
		private var _loaderProgressSignal : ISignal;

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
		public function SingleMixinLoaderSignals(mixin : IMixin, generator : IMixinLoader)
		{
			if(null == mixin) throw new ArgumentError('Given IMixin can not be null');
			if(null == generator) throw new ArgumentError('Given IMixinLoader can not be null');
			
			_mixin = mixin;
			_generator = generator;
			
			_loader = generator.loader;
			if(null == _loader) throw new IllegalOperationError('MixingLoaderGenerator.loader() ' +
																			'can not be null.');
			
			const loaderInfo : LoaderInfo = _loader.contentLoaderInfo;
			
			_loaderCompletedSignal = new NativeSignal(loaderInfo, Event.COMPLETE, Event);
			_loaderCompletedSignal.addOnce(handleLoaderCompletedSignal);
			
			_loaderProgressSignal = new NativeSignal(loaderInfo, ProgressEvent.PROGRESS, Event);
			_loaderProgressSignal.addOnce(handleLoaderProgressSignal);
			
			_loaderIOErrorSignal = new NativeSignal(loaderInfo, IOErrorEvent.IO_ERROR, IOErrorEvent);
			_loaderIOErrorSignal.addOnce(handleLoaderErrorSignal);
			
			_loaderErrorSignal = new NativeSignal(loaderInfo, ErrorEvent.ERROR, ErrorEvent);
			_loaderErrorSignal.addOnce(handleLoaderErrorSignal);
		}
		
		public function dispose() : void
		{
			_loaderCompletedSignal.removeAll();
			_loaderCompletedSignal = null;
			
			_loaderProgressSignal.removeAll();
			_loaderProgressSignal = null;
			
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
			
			_mixin.inject(domain);
			
			completedSignal.dispatch(_mixin);
		}
		
		/**
		 * @private
		 */
		private function handleLoaderProgressSignal(event : ProgressEvent) : void
		{
			const percentage : Number = event.bytesTotal / event.bytesLoaded;
			progressSignal.dispatch(percentage, event);
		}
				
		/**
		 * @private
		 */
		private function handleLoaderErrorSignal(event : ErrorEvent) : void
		{
			if(event is IOErrorEvent)
				errorSignal.dispatch(_mixin, MixinError.IO_ERROR);
			else
				errorSignal.dispatch(_mixin, MixinError.ERROR);
		}
		
		/**
		 * Add a signal to know when the class has been created.
		 */
		public function get completedSignal() : ISignal	{ return _completedSignal; }
		
		/**
		 * @inheritDoc
		 */
		public function get progressSignal() : ISignal { return _progressSignal; }
		
		/**
		 * Add a signal to know when the class has been not be succesfully created.
		 */
		public function get errorSignal() : ISignal { return _errorSignal; }
		
		/**
		 * Get the current mixin that the signals are actioning on.
		 */
		public function get mixins() : IMixin { return _mixin; }
	}
}
