package org.osflash.mixins
{
	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public final class MixinError extends Error
	{

		public static const IO_ERROR : int = 0x01;

		public static const ERROR : int = 0x02; 
		
		public static const METHOD_GENERATOR_ERROR : int = 0x03;
													
		public static const PROPERTY_GENERATOR_ERROR : int = 0x04; 

		public static const CONSTRUCTOR_ARGUMENT_MISMATCH : int = 0x05; 
		
		public static const ARGUMENTS_ARE_REQURIED : int = 0x06;
		
		public function MixinError(message : String)
		{
			super(message);
		}
		
		public static function throwError(type : int) : void
		{
			switch(type)
			{
				case IO_ERROR:
					throw new MixinError("IO Error when trying to " + 
													"generate the loading loader for the mixins.");
					break;
				case ERROR:
					throw new MixinError("Error when trying to " + 
													"generate the loading loader for the mixins.");
					break;
				case METHOD_GENERATOR_ERROR:
					throw new MixinError("Error when " + 
													"trying to add a method with the same name " + 
													"as an existing method. Consider marking " +
													"implementation for ignore during generation");
					break;
				case PROPERTY_GENERATOR_ERROR:
					throw new MixinError("Error when " + 
													"trying to add a property with the same name " + 
													"as an existing property. Consider marking " + 
													"implementation for ignore during generation");
					break;
				case CONSTRUCTOR_ARGUMENT_MISMATCH:
					throw new MixinError("Error " +
													"trying to define arguments");
					break;
				case ARGUMENTS_ARE_REQURIED:
					throw new MixinError("Error " + 
													"arguments are required, even if the " + 
													"arguments on the implementation are optional"); 
					break;
				default:
					throw new ArgumentError('Given argument is Unknown.');
			}
		}
	}
}
