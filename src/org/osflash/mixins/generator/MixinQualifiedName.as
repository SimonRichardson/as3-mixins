package org.osflash.mixins.generator
{
	import org.flemit.bytecode.BCNamespace;
	import org.flemit.bytecode.NamespaceKind;
	import org.flemit.bytecode.QualifiedName;
	import org.flemit.reflection.Type;
	import org.osflash.mixins.generator.uid.UID;
	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public final class MixinQualifiedName
	{
		
		/**
		 * Create a uniquely qualified name namespace for the mixins. 
		 * 
		 * @param type Type of class to generate from the namespace
		 * @return QualifiedName containing the name space and the unique name.
		 */		
		public static function create(type : Type) : QualifiedName
		{
			// Look for the exising namespace
			const ns : BCNamespace = type.qname.ns.kind != NamespaceKind.PACKAGE_NAMESPACE
									 ? type.qname.ns
									 : BCNamespace.packageNS(type.packageName);
									 
			// Create the new unique id
			const uid : String = UID.create();
			
			// Use the found namespace and then make it unique to prevent collisions.
			return new QualifiedName(ns, type.name + uid);
		}
	}
}
