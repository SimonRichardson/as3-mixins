package org.osflash.mixins.support.impl
{
	import org.osflash.mixins.support.ISize;

	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public final class SizeImpl implements ISize
	{
		
		private var _width : int;
		
		private var _height : int;

		public function SizeImpl()
		{
			_width = 0;
			_height = 0;
		}
		
		public function get width() : int
		{
			return _width;
		}

		public function set width(value : int) : void
		{
			_width = value;
		}
		
		public function get height() : int
		{
			return _height;
		}

		public function set height(value : int) : void
		{
			_height = value;
		}
	}
}
