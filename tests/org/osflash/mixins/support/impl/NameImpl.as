package org.osflash.mixins.support.impl
{
	import flash.utils.getQualifiedClassName;
	import org.osflash.mixins.support.IName;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class NameImpl implements IName
	{

		public function getName() : String
		{
			const qname : String = getQualifiedClassName(this);
			const parts : Array = qname.split("::");
			return parts[parts.length - 1];
		}
	}
}
