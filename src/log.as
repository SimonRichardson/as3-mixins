package
{
	import flash.utils.getDefinitionByName;
	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public function log(...args) : void
	{
		getDefinitionByName("trace").apply(null, args);
	}
}
