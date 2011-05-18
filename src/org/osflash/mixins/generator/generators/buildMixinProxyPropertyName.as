package org.osflash.mixins.generator.generators
{
	import org.flemit.bytecode.BCNamespace;
	import org.flemit.bytecode.QualifiedName;
	import org.flemit.reflection.Type;
	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public function buildMixinProxyPropertyName(	ns : BCNamespace, 
													interfaceType : Type
													) : QualifiedName
	{
		const name : String = '_' +interfaceType.fullName.replace(/[\. : ]/g, '_');
		return new QualifiedName(ns, name);
	}
}
