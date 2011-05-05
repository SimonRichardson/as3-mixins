package org.osflash.mixins.support.impl
{
	import org.osflash.mixins.support.defs.IName;

	import flash.utils.getQualifiedClassName;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class NameImpl implements IName
	{
		
		public function toString() : String
		{
			const qname : String = getQualifiedClassName(this);
			const parts : Array = qname.split("::");
			return parts[parts.length - 1];
		}
	}
}
