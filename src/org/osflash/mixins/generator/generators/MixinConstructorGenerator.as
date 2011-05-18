package org.osflash.mixins.generator.generators
{
	import org.flemit.bytecode.DynamicClass;
	import org.flemit.reflection.MemberVisibility;
	import org.flemit.reflection.MethodInfo;
	import org.flemit.reflection.ParameterInfo;
	import org.flemit.reflection.PropertyInfo;
	import org.flemit.reflection.Type;
	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public class MixinConstructorGenerator implements IGenerator
	{
		
		/**
		 * @inheritDoc
		 */
		public function generator(dynamicClass : DynamicClass) : void
		{
			const params:Array = [];
						
			const properties : Array = dynamicClass.getProperties();
			const total : int = properties.length;
			for (var i : int = 0; i < total; i++) 
			{
				const propertyInfo : PropertyInfo = properties[i];
				if(!propertyInfo.canWrite) continue;
				params.push(new ParameterInfo(propertyInfo.name, propertyInfo.type, true));
			}
			
			dynamicClass.constructor = new MethodInfo(	dynamicClass, 
														"ctor", 
														null, 
														MemberVisibility.PUBLIC, 
														false, 
														false, 
														Type.star, 
														params
													);
		}
		
		/**
		 * @inheritDoc
		 */
		public function dispose() : void
		{
		}
	}
}
