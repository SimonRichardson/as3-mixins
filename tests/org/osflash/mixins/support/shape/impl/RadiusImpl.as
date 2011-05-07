package org.osflash.mixins.support.shape.impl
{
	import org.osflash.mixins.support.shape.defs.IRadius;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public final class RadiusImpl implements IRadius
	{
		
		private var _radius : int;

		public function RadiusImpl()
		{
			_radius = 0;
		}
		
		public function get radius() : int
		{
			return _radius;
		}

		public function set radius(value : int) : void
		{
			_radius = value;
		}
	}
}
