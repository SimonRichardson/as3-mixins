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
		private var _poolGrowSize : int;
		
		/**
		 * @private
		 */
		private var _size : int;
		
		/**
		 * @private
		 */
		private var _activeSize : int;

		/**
		 * @private
		 */
		private const _pool : Vector.<MixinFactoryPoolNode> = new Vector.<MixinFactoryPoolNode>();
		
		public function MixinFactoryPool(	mixin : IMixin,
											definitive : Class,
											defaultArguments : Object = null
											)
		{
			_mixin = mixin;
			
			_arguments = [];
			
			this.definitive = definitive;
			this.defaultArguments = defaultArguments;
			
			_size = 0;
			_activeSize = 0;
			_poolGrowSize = POOL_GROWTH_SIZE;
			
			grow();
		}
		
		/**
		 * Pop a mixin of the stack
		 */
		public function pop() : Object
		{
			if(_activeSize == 0)
			{
				grow();
			}
			
			var exhausted : Boolean = true;
			var node : MixinFactoryPoolNode;
			var index : int = _pool.length;
			while(--index > -1)
			{
				node = _pool[index];
				if(!node.active)
				{
					exhausted = false;
					break;
				}
			}
			
			if(exhausted) throw MixinFactoryPoolError.POOL_EXHAUSTED;
			if(null == node) throw new IllegalOperationError('Unable to locate a node for use.');
			
			node.active = true;
			
			const object : Object = node.mixin;
			if(object.hasOwnProperty('__init__'))
			{
				// magic method
				const init : Function = object['__init__'];
				const total : int = _arguments.length;
				
				// Hot pathing.
				if(total == 0) init();
				if(total == 1) init(_arguments[0]);
				if(total == 2) init(_arguments[0], _arguments[1]);
				if(total == 3) init(_arguments[0], _arguments[1], _arguments[2]);
				else init.apply(null, _arguments);
			}
			
			_activeSize--;
			
			return object;
		}
		
		/**
		 * Push a mixin implementation back on to the stack
		 * 
		 * @param value mixin implementation
		 */
		public function push(value : Object) : void
		{
			if(null == value) throw new ArgumentError('Given mixin instance can not be null.');
			if(!(value is _definitive)) throw new ArgumentError('Given mixin does not extend' +
											' the correct definitive class (' + _definitive + ')');
			
			var index : int = _pool.length;
			while(--index > -1)
			{
				const node : MixinFactoryPoolNode = _pool[index];
				if(null == node.mixin) throw MixinFactoryPoolError.MIXIN_NULL_ON_PUSH;
				if(node.mixin == value)
				{
					if(!node.active) throw new ArgumentError('Given mixin instance already ' +
													'in the pool. You can not added it again.');
					node.active = false;
					break;
				}
			}
			
			_activeSize++;
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
					const mixin : Object = _mixin.create(_definitive, _defaultArguments);
					const node : MixinFactoryPoolNode = new MixinFactoryPoolNode(mixin);
					
					_pool.push(node);
					
					_size++;
					_activeSize++;
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
		public function get poolSize() : int 
		{ 
			var size : int = 0;
			var index : int = _pool.length;
			while(--index > -1)
			{
				const node : MixinFactoryPoolNode = _pool[index];
				if(!node.active)
					size++;
			}
			return size;
		}
		
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
			
			var index : int = _pool.length;
			while(--index > -1)
			{
				const node : MixinFactoryPoolNode = _pool[index];
				if(!(node.mixin is _definitive)) 
				{
					throw new ArgumentError('Given Mixin does not extend the correct definitive ' + 
																	'class (' + _definitive + ')');
				}
			}
		}
	}
}
