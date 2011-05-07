package org.osflash.mixins.support.shape.impl
{
	import org.osflash.mixins.support.shape.defs.IName;

	import flash.utils.getQualifiedClassName;

	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class NameImpl implements IName
	{
		
		private var _mixin : Object;
		
		public function NameImpl(mixin : Object = null)
		{
			_mixin = mixin || this;
		}
		
		public function toString() : String
		{
			const qname : String = getQualifiedClassName(_mixin);
			const parts : Array = qname.split("::");
			return parts[parts.length - 1];
		}
	}
}
