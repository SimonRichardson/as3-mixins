package org.osflash.mixins.generator.hash
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public final class SHA1 implements IHash
	{

		/**
		 * Constructor 
		 */
		public function SHA1()
		{
		}

		/**
		 * Perform the appropriate triplet combination function for the current
		 * iteration
		 */
		private function ft(t : int, b : int, c : int, d : int) : int
		{
			if (t < 20)
			{
				return b & c | ~b & d;
			}
			if (t < 40)
			{
				return b ^ c ^ d;
			}
			if (t < 60)
			{
				return b & c | b & d | c & d;
			}
			return b ^ c ^ d;
		}

		/**
		 * Get the input size
		 */
		public function getInputSize() : int
		{
			return 64;
		}

		/**
		 * Determine the appropriate additive constant for the current iteration
		 */
		private function kt(t : int) : int
		{
			return t < 20 ? 1518500249 : (t < 40 ? 1859775393 : (t < 60 ? 2400959708 : 3395469782));
		}

		/**
		 * @inheritDoc
		 */
		public function calculate(byteArray : ByteArray) : ByteArray
		{
			const length : int = byteArray.length;
			const endian : String = byteArray.endian;

			byteArray.endian = Endian.BIG_ENDIAN;

			var byteLength : Number = length * 8;
			while (byteArray.length % 4 != 0)
			{
				byteArray[int(byteArray.length)] = 0;
			}

			byteArray.position = 0;

			var byteData : Array = new Array();
			var i : int = 0;
			while (i < byteArray.length)
			{
				byteData.push(byteArray.readUnsignedInt());
				i = i + 4;
			}

			const calc : Array = core(byteData, byteLength);

			var result : ByteArray = new ByteArray();
			byteLength = size / 4;

			i = 0;
			while (i < byteLength)
			{
				result.writeUnsignedInt(calc[i]);
				i = i + 1;
			}

			byteArray.length = length;
			byteArray.endian = endian;

			return result;
		}

		/**
		 * Bitwise rotate a 32-bit number to the left.
		 */
		private function rol(number : int, rotateCount : int) : int
		{
			return number << rotateCount | number >>> 32 - rotateCount;
		}

		/**
		 * Calculate the HMAC-SHA1 of a key and some data
		 */
		protected function core(data : Array, key : int) : Array
		{
			const vector : Vector.<int> = new Vector.<int>(80, true);

			var a : int = 1732584193;
			var b : int = 4023233417;
			var c : int = 2562383102;
			var d : int = 271733878;
			var e : int = 3285377520;

			data[key >> 5] = data[key >> 5] | 128 << 24 - key % 32;
			data[(key + 64 >> 9 << 4) + 15] = key;

			var j : int = 0;
			const total : int = data.length;
			for (var i : int = 0;i < total; i += 16)
			{
				var oa : int = a;
				var ob : int = b;
				var oc : int = c;
				var od : int = d;
				var oe : int = e;

				for (j = 0;j < 80; ++j)
				{
					if (j < 16)
					{
						vector[j] = data[i + j] || 0;
					}
					else
					{
						vector[j] = rol(vector[j - 3] ^ vector[j - 8] ^ vector[j - 14] ^ vector[j - 16], 1);
					}
					const t : int = rol(a, 5) + ft(j, b, c, d) + e + vector[j] + kt(j);
					e = d;
					d = c;
					c = rol(b, 30);
					b = a;
					a = t;
				}
				a = a + oa;
				b = b + ob;
				c = c + oc;
				d = d + od;
				e = e + oe;
			}
			return [a, b, c, d, e];
		}

		/**
		 * @inheritDoc
		 */
		public function get size() : int
		{
			return 20;
		}

		/**
		 * String representation of the object
		 */
		public function toString() : String
		{
			return '[SHA1]';
		}
	}
}
