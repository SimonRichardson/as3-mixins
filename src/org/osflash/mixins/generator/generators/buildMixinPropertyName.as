package org.osflash.mixins.generator.generators
{
	import org.flemit.bytecode.BCNamespace;
	import org.flemit.bytecode.QualifiedName;
	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public function buildMixinPropertyName(	ns : BCNamespace,
											propertyName : String
											) : QualifiedName
	{
		// TODO : sanity check the property name
		return new QualifiedName(ns, propertyName);
	}
}
