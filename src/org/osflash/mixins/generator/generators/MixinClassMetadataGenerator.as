package org.osflash.mixins.generator.generators
{
	import org.flemit.bytecode.QualifiedName;
	import org.flemit.bytecode.DynamicClass;
	import org.flemit.reflection.MetadataInfo;

	import flash.utils.Dictionary;

	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public class MixinClassMetadataGenerator implements IGenerator
	{
		
		/**
		 * @private
		 */		
		private var _qname : QualifiedName;
		
		/**
		 * @inheritDoc
		 */
		public function generator(dynamicClass : DynamicClass) : void
		{
			// TODO : Actually make this run through real metadata not use hardcoded.
			const parameters : Dictionary = new Dictionary();
			parameters['extraClass'] = qname.toString();
			
			dynamicClass.addMetadata(new MetadataInfo('Frame', parameters));
		}
		
		/**
		 * @inheritDoc
		 */
		public function dispose() : void
		{
			_qname = null;
		}

		public function get qname() : QualifiedName
		{
			return _qname;
		}

		public function set qname(value : QualifiedName) : void
		{
			if(null == value) throw new ArgumentError('Given value can not be null.');
			_qname = value;
		}
	}
}
