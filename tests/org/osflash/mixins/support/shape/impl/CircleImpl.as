package org.osflash.mixins.support.shape.impl
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import org.osflash.mixins.support.shape.ICircle;

	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class CircleImpl extends Sprite
	{

		[Inject]
		public var circle : ICircle;
		
		public function draw() : void
		{
			const g : Graphics = graphics;
			g.beginFill(Math.random() * 0xffffff);
			g.drawCircle(circle.x, circle.y, circle.radius);
			g.endFill();
		}
	}
}
