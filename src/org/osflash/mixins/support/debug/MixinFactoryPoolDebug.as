package org.osflash.mixins.support.debug
{
	import org.osflash.mixins.support.IMixinFactoryPool;

	import flash.utils.getQualifiedClassName;
	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public class MixinFactoryPoolDebug
	{
		
		private const _pools : Vector.<IMixinFactoryPool> = new Vector.<IMixinFactoryPool>();
		
		public function MixinFactoryPoolDebug()
		{
			
		}
		
		public function add(pool : IMixinFactoryPool) : void
		{
			if(null == pool) throw new ArgumentError('Given value can not be null.');
			
			const index : int = _pools.indexOf(pool);
			if(index == -1) _pools.push(pool);
			else
			{
				throw new ArgumentError('You can not add the same IMixinFactoryPool again.');
			}
		}
		
		public function remove(pool : IMixinFactoryPool) : void
		{
			if(null == pool) throw new ArgumentError('Given value can not be null.');
			
			const index : int = _pools.indexOf(pool);
			if(index >= 0) _pools.splice(index, 1);
		}
		
		public function report() : XML
		{
			const total : int = _pools.length;
			const result : XML = <factory total={total} />;
			
			for(var i : int = 0; i < total; i++)
			{
				const factory : IMixinFactoryPool = _pools[i];
				const definitive : Class = factory.definitive;
				
				const poolName : String = getQualifiedClassName(definitive);
				const size : int = factory.size;
				const poolSize : int = factory.poolSize;
				const poolGrowSize : int = factory.poolGrowSize;
				
				const health : int = size / poolSize * 100;
				const percentage : String = health + '%';
				
				const pool : XML = <pool 	name={poolName} 
											size={size}
											poolSize={poolSize}
											poolGrowSize={poolGrowSize}
											health={percentage}
											/>;
				
				result.appendChild(pool);
			}
			
			return result;
		}
	}
}
