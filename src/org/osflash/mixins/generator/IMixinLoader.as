package org.osflash.mixins.generator
{
	import org.osflash.mixins.IMixin;

	import flash.display.Loader;
	import flash.system.ApplicationDomain;

	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public interface IMixinLoader
	{

		function add(mixin : IMixin) : IMixin;

		function remove(mixin : IMixin) : IMixin;

		function contains(mixin : IMixin) : Boolean;

		/**
		 * Load the bytecode in to the aync Loader for the execution.
		 */
		function load(domain : ApplicationDomain = null) : MixinLoaderSignals;

		function dispose() : void;

		function get loader() : Loader;
	}
}
