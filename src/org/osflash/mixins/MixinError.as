package org.osflash.mixins
{
	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public final class MixinError extends Error
	{

		public static const IO_ERROR : MixinError = new MixinError("IO Error when trying to " + 
													"generate the loading loader for the mixins.");

		public static const ERROR : MixinError = new MixinError("Error when trying to " + 
													"generate the loading loader for the mixins.");
		
		public static const METHOD_GENERATOR_ERROR : MixinError = new MixinError("Error when " + 
													"trying to add a method with the same name " + 
													"as an existing method. Consider marking " +
													"implementation for ignore during generation");
													
		public static const PROPERTY_GENERATOR_ERROR : MixinError = new MixinError("Error when " + 
													"trying to add a property with the same name " + 
													"as an existing property. Consider marking " + 
													"implementation for ignore during generation");

		public static const CONSTRUCTOR_ARGUMENT_MISMATCH : MixinError = new MixinError("Error " +
													"trying to define arguments");
		
		public static const ARGUMENTS_ARE_REQURIED : MixinError = new MixinError("Error " + 
													"arguments are required, even if the " + 
													"arguments on the implementation are optional");
		
		public function MixinError(message : String)
		{
			super(message);
		}
	}
}
