package org.osflash.mixins.support.shape.defs
{
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public interface ISize
	{
		
		function get width() : int;
		
		function set width(value : int) : void;
		
		function get height() : int;
		
		function set height(value : int) : void;
		
		function get regular() : Boolean;
		
		function set regular(value : Boolean) : void;
	}
}
