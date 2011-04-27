package org.osflash.mixins.support.impl
{
	import org.osflash.mixins.support.defs.ISize;

	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public final class SizeImpl implements ISize
	{
		
		private var _width : int;
		
		private var _height : int;
		
		private var _regular : Boolean;

		public function SizeImpl(regular : Boolean = false)
		{
			_width = 0;
			_height = 0;
			
			_regular = regular;
		}
		
		public function get width() : int
		{
			return _width;
		}

		public function set width(value : int) : void
		{
			_width = value;
			
			if(_regular) _height = value;
		}
		
		public function get height() : int
		{
			return _height;
		}

		public function set height(value : int) : void
		{
			_height = value;
			
			if(_regular) _width = value;
		}

		public function get regular() : Boolean
		{
			return _regular;
		}

		public function set regular(value : Boolean) : void
		{
			_regular = value;
		}
	}
}
