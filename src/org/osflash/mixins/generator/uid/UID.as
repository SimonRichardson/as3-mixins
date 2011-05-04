package org.osflash.mixins.generator.uid
{
	import flash.system.System;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public final class UID
	{
		
		/**
		 * @private
		 */
		private static var counter : Number = 0;
		
		/**
		 * @private
		 */
		private static const tab : String = "0123456789abcdef";
		
		/**
		 * @private
		 */
		private static const w : Array = new Array(80);
		
		/**
		 * Create a new unique id.
		 */
		public static function create() : String
		{
			const dt : Date = new Date();
			const id1 : Number = dt.getTime();
			const id2 : Number = Math.random() * 99999;
			const id3 : String = System.totalMemory.toString();
			
			return hex_sha1(id1 + id2 + id3 + counter++).toUpperCase();
		}
		
		/**
		 * @private
		 */
		private static function hex_sha1(src : String) : String
		{
			return binb2hex(core_sha1(str2binb(src), src.length * 8));
		}

		/**
		 * @private
		 */
		private static function core_sha1(x : Array, len : Number) : Array
		{
			x[len >> 5] |= 0x80 << (24 - len % 32);
			x[((len + 64 >> 9) << 4) + 15] = len;
			
			w.length = 0;
			
			var a : int = 1732584193;
			var b : int = -271733879;
			var c : int = -1732584194;
			var d : int = 271733878;
			var e : int = -1009589776;
			
			const total : int = x.length;
			for (var i : int = 0; i < total; i += 16)
			{
				var olda : int = a;
				var oldb : int = b;
				var oldc : int = c;
				var oldd : int = d;
				var olde : int = e;
				
				for (var j : int = 0; j < 80; j++)
				{
					if (j < 16) w[j] = x[i + j];
					else w[j] = rol(w[j - 3] ^ w[j - 8] ^ w[j - 14] ^ w[j - 16], 1);
					
					var t : int = safe_add(safe_add(rol(a, 5), sha1_ft(j, b, c, d)), safe_add(safe_add(e, w[j]), sha1_kt(j)));
					e = d;
					d = c;
					c = rol(b, 30);
					b = a;
					a = t;
				}
				
				a = safe_add(a, olda);
				b = safe_add(b, oldb);
				c = safe_add(c, oldc);
				d = safe_add(d, oldd);
				e = safe_add(e, olde);
			}
			
			return [a, b, c, d, e];
		}
		
		/**
		 * @private
		 */
		private static function sha1_ft(t : int, b : int, c : int, d : int) : int
		{
			if (t < 20) return (b & c) | ((~b) & d);
			if (t < 40) return b ^ c ^ d;
			if (t < 60) return (b & c) | (b & d) | (c & d);
			return b ^ c ^ d;
		}

		/**
		 * @private
		 */
		private static function sha1_kt(t : int) : int
		{
			return (t < 20) ? 1518500249 : (t < 40) ? 1859775393 : (t < 60) ? -1894007588 : -899497514;
		}

		/**
		 * @private
		 */
		private static function safe_add(x : int, y : int) : int
		{
			const lsw : int = (x & 0xFFFF) + (y & 0xFFFF);
			const msw : int = (x >> 16) + (y >> 16) + (lsw >> 16);
			return (msw << 16) | (lsw & 0xFFFF);
		}

		/**
		 * @private
		 */
		private static function rol(num : int, cnt : int) : int
		{
			return (num << cnt) | (num >>> (32 - cnt));
		}

		/**
		 * @private
		 */
		private static function str2binb(str : String) : Array
		{
			const bin : Array = [];
			const mask : int = (1 << 8) - 1;
			const total : int = str.length * 8;
			
			for (var i : int = 0; i < total; i += 8)
			{
				bin[i >> 5] |= (str.charCodeAt(i / 8) & mask) << (24 - i % 32);
			}
			
			return bin;
		}

		/**
		 * @private
		 */
		private static function binb2hex(binarray : Array) : String
		{
			var str : String = "";
			
			const total : int = binarray.length * 4;
			for (var i : int = 0; i < total; i++)
			{
				const key : int = binarray[i >> 2];
				const mod : int = (3 - i % 4) * 8;
				
				str += tab.charAt((key >> (mod + 4)) & 0xF) + tab.charAt((key >> mod) & 0xF);
			}
			
			return str;
		}
	}
}
