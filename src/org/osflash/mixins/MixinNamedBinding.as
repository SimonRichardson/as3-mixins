package org.osflash.mixins
{
	import org.flemit.bytecode.QualifiedName;
	import org.flemit.reflection.Type;
	import org.osflash.mixins.generator.MixinQualifiedName;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class MixinNamedBinding extends MixinBinding implements IMixinNamedBinding
	{
		
		/**
		 * @private
		 */
		private var _name : QualifiedName;
		
		public function MixinNamedBinding(key : Class, value : Class)
		{
			super(key, value);
			
			_name = MixinQualifiedName.create(Type.getType(key));
		}
		
		/**
		 * @inheritDoc
		 */
		public function get name() : QualifiedName { return _name; }
		public function set name(value : QualifiedName) : void { _name = value; }
	}
}
