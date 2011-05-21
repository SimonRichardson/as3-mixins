package org.osflash.mixins.support
{
	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public interface IMixinFactoryPool
	{
		function pop() : Object;
		
		function push(value : Object) : void;
		
		function get size() : int;
		
		function get poolSize() : int;
		
		function get poolGrowSize() : int;
		function set poolGrowSize(value : int) : void;
		
		function get defaultArguments() : Object;
		function set defaultArguments(args : Object) : void;
		
		function get definitive() : Class;
		function set definitive(value : Class) : void;
	}
}
