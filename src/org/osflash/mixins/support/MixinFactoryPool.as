package org.osflash.mixins.support
{
	import flash.errors.IllegalOperationError;
	import org.osflash.mixins.IMixin;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class MixinFactoryPool
	{
		
		public static const POOL_GROWTH_SIZE : int = 8;
		
		/**
		 * @private
		 */
		private var _mixin : IMixin;
		
		/**
		 * @private
		 */
		private var _definitive : Class;
		
		/**
		 * @private
		 */
		private var _defaultArguments : Object;
		
		/**
		 * @private 
		 */
		private var _arguments : Array;

		/**
		 * @private
		 */
		private var _pool : Array;
		
		/**
		 * @private 
		 */
		private var _poolGrowSize : int;
		
		/**
		 * @private
		 */
		private var _size : int;
		
		public function MixinFactoryPool(	mixin : IMixin,
											definitive : Class,
											defaultArguments : Object = null
											)
		{
			_mixin = mixin;
			
			_pool = [];
			_arguments = [];
			
			this.definitive = definitive;
			this.defaultArguments = defaultArguments;
			
			_size = 0;
			_poolGrowSize = POOL_GROWTH_SIZE;
			
			grow();
		}
		
		/**
		 * Pop a mixin of the stack
		 */
		public function pop() : Object
		{
			if(_pool.length == 0)
			{
				grow();
			}
			
			const object : Object = _pool.pop();
			if(object.hasOwnProperty('__init__'))
			{
				// magic method
				const init : Function = object['__init__'];
				if(_arguments.length == 0) init();
				else init.apply(null, _arguments);
			}
			
			return object;
		}
		
		/**
		 * Push a mixin implementation back on to the stack
		 * 
		 * @param value mixin implementation
		 */
		public function push(value : Object) : void
		{
			const index : int = _pool.indexOf(value);
			if(index >= 0) throw new ArgumentError('Given Mixin implementation already exists in ' +
																					'the pool.');
			if(!(value is _definitive)) throw new ArgumentError('Given Mixin does not extend' +
											' the correct definitive class (' + _definitive + ')');
			_pool.push(value);
		}
		
		/**
		 * @private
		 */
		protected function grow() : void
		{
			try
			{
				var index : int = poolGrowSize;
				while(--index > -1)
				{
					_pool.push(_mixin.create(_definitive, _defaultArguments));
					_size++;
				}
			}
			catch(error : Error)
			{
				throw new IllegalOperationError('Unable to grow the Mixin pool.');
			}
		}
		
		/**
		 * Get the current size of all the mixins.
		 */
		public function get size() : int { return _size; }
		
		/**
		 * Get the current size of the pool.
		 */
		public function get poolSize() : int { return _pool.length; }
		
		/**
		 * Get the default growth size of the pool. This is so you can make more out when the pool 
		 * is exhausted.
		 */
		public function get poolGrowSize() : int { return _poolGrowSize; }
		public function set poolGrowSize(value : int) : void 
		{
			if(value < 1) throw new ArgumentError('Given value can not be less than 1');
			_poolGrowSize = value; 
		}
		
		/**
		 * Get the default arguments, which will be used everytime a pop is done
		 */
		public function get defaultArguments() : Object { return _defaultArguments; }
		public function set defaultArguments(args : Object) : void 
		{ 
			_arguments.length = 0;
			
			for each(var item : * in args)
			{
				_arguments.push(item);
			}
		}
		
		/**
		 * Get the definitive class
		 */
		public function get definitive() : Class { return _definitive; }
		public function set definitive(value : Class) : void 
		{
			if(null == value) throw new ArgumentError('Given value can not be null.');
			
			_definitive = value;
			
			const total : int = _pool.length;
			for(var i : int = 0; i<total; i++)
			{
				if(!(value is _definitive)) throw new ArgumentError('Given Mixin does not extend' +
											' the correct definitive class (' + _definitive + ')');
			}
		}
	}
}
