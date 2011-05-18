package org.osflash.mixins.generator.generators
{
	import org.flemit.reflection.PropertyInfo;
	import org.flemit.reflection.Type;

	import flash.utils.Dictionary;
	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public function getMixinTypeProperties(superType : Type) : Dictionary
	{
		const propertyNames : Dictionary = new Dictionary();
		if(null == superType) return propertyNames;
		
		const properties : Array = superType.getProperties(false, true, true);
		const total : int = properties.length;
		for(var i : int = 0; i<total; i++)
		{
			const property : PropertyInfo = properties[i];
			const propertyName : String = property.name;
			propertyNames[propertyName] = property;
		}
		
		return propertyNames;
	}
}
