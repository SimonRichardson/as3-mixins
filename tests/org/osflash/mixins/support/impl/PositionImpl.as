package org.osflash.mixins.support.impl
{
	import org.osflash.mixins.support.IPosition;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public final class PositionImpl implements IPosition
	{
		
		private var _x : int;
		
		private var _y : int;

		public function PositionImpl()
		{
			_x = 0;
			_y = 0;
		}
		
		public function get x() : int
		{
			return _x;
		}

		public function set x(value : int) : void
		{
			_x = value;
		}

		public function get y() : int
		{
			return _y;
		}

		public function set y(value : int) : void
		{
			_y = value;
		}
	}
}
