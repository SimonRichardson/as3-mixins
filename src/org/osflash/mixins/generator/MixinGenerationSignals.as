package org.osflash.mixins.generator
{
	import org.osflash.mixins.IMixin;
	import org.osflash.mixins.MixinError;
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	import org.osflash.signals.natives.NativeSignal;

	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.errors.IllegalOperationError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.system.ApplicationDomain;
	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public final class MixinGenerationSignals
	{
		
		/**
		 * @private
		 */
		private const _completedSignal : ISignal = new Signal(IMixin);
		
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
		private var _generator : MixinLoaderGenerator;
		
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
		public function MixinGenerationSignals(mixin : IMixin, generator : MixinLoaderGenerator)
		{
			if(null == mixin) throw new ArgumentError('Given IMixin can not be null');
			if(null == generator) throw new ArgumentError('Given MixinLoaderGenerator can not ' + 
																						'be null');
			
			_mixin = mixin;
			_generator = generator;
			
			_loader = generator.loader;
			if(null == _loader) throw new IllegalOperationError('MixingLoaderGenerator.loader() ' +
												'can not be null.');
			
			const loaderInfo : LoaderInfo = _loader.contentLoaderInfo;
			
			_loaderCompletedSignal = new NativeSignal(loaderInfo, Event.COMPLETE, Event);
			_loaderCompletedSignal.add(handleLoaderCompletedSignal);
			
			_loaderIOErrorSignal = new NativeSignal(loaderInfo, IOErrorEvent.IO_ERROR, IOErrorEvent);
			_loaderIOErrorSignal.add(handleLoaderErrorSignal);
			
			_loaderErrorSignal = new NativeSignal(loaderInfo, ErrorEvent.ERROR, ErrorEvent);
			_loaderErrorSignal.add(handleLoaderErrorSignal);
		}

		/**
		 * @private
		 */
		private function handleLoaderCompletedSignal(event : Event) : void
		{
			const loaderInfo : LoaderInfo = _loader.contentLoaderInfo;
			const domain : ApplicationDomain = loaderInfo.applicationDomain;
			
			mixin.inject(domain);
			
			completedSignal.dispatch(_mixin);
		}
				
		/**
		 * @private
		 */
		private function handleLoaderErrorSignal(event : ErrorEvent) : void
		{
			if(event is IOErrorEvent)
			{
				errorSignal.dispatch(mixin, MixinError.IO_ERROR);
			}
			else
			{
				errorSignal.dispatch(mixin, MixinError.ERROR);
			}	
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
		public function get mixin() : IMixin { return _mixin; }
	}
}
