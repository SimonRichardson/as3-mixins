package org.osflash.mixins.generator.uid
{
	import org.osflash.mixins.generator.hash.Hash;
	import org.osflash.mixins.generator.sprintf.sprintf;

	import flash.utils.ByteArray;
	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public final class UID
	{
		
		private static var TICK : int = 0;

		private static const BUFFER : ByteArray = new ByteArray();

		public static function create() : String 
		{
			const a : String = TICK.toString() + new Date().getTime().toString();
			const b : String = new Date().getMilliseconds().toString();
			const c : String = (Math.random() * Number.MAX_VALUE).toString();
			const d : String = (Math.random() * Number.MAX_VALUE).toString();
			
			BUFFER.writeUTFBytes(a);
			BUFFER.writeUTFBytes(b);
			BUFFER.writeUTFBytes(c);
			BUFFER.writeUTFBytes(d);
			
			const encoded : ByteArray = Hash.sha1.calculate(BUFFER);
			
			BUFFER.position = 0;
			BUFFER.length = 0;
			
			var result : String = "";
			var n : int = 0;
			while (n < 20)
			{
                result += sprintf("%02x", encoded[n]);
				n++;
			}
			
			return result;
		}
	}
}
