package org.osflash.mixins.generator.generators
{
	import org.flemit.reflection.MethodInfo;
	import org.flemit.reflection.Type;

	import flash.utils.Dictionary;
	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public function getMixinTypeMethods(superType : Type) : Dictionary
	{
		const methodNames : Dictionary = new Dictionary();
		if(null == superType) return methodNames;
		
		const methods : Array = superType.getMethods(false, true, true);
		const total : int = methods.length;
		for(var i : int = 0; i<total; i++)
		{
			const method : MethodInfo = methods[i];
			const methodName : String = method.name;
			methodNames[methodName] = method;
		}
		
		return methodNames;
	}
}
