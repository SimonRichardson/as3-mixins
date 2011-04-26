package org.osflash.mixins.generator.hash
{
	import flash.utils.ByteArray;
	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public interface IHash
	{

		/**
		 * Calculate the hash from a <code>ByteArray</code> and return a <code>ByteArray</code>
		 * 
		 * @return ByteArray of the computed hash.
		 */
		function calculate(byteArray : ByteArray) : ByteArray;

		/**
		 * Returns the size of the Hash that will be computed.
		 * 
		 * @return int of the Hash
		 */
		function get size() : int;
	}
}
