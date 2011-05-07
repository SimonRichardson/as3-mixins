package org.osflash.mixins.support.shape.impl
{
	import org.osflash.mixins.support.shape.defs.IPosition;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public final class PositionImpl implements IPosition
	{
		
		private var _x : Number;
		
		private var _y : Number;

		public function PositionImpl()
		{
			_x = 0;
			_y = 0;
		}
		
		public function get x() : Number
		{
			return _x;
		}

		public function set x(value : Number) : void
		{
			_x = value;
		}

		public function get y() : Number
		{
			return _y;
		}

		public function set y(value : Number) : void
		{
			_y = value;
		}
	}
}
