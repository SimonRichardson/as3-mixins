package org.osflash.mixins
{
	import org.osflash.mixins.generator.IMixinLoaderSignals;
	import org.osflash.mixins.support.ISquare;
	import org.osflash.mixins.support.defs.IName;
	import org.osflash.mixins.support.defs.IPosition;
	import org.osflash.mixins.support.defs.ISize;
	import org.osflash.mixins.support.impl.NameImpl;
	import org.osflash.mixins.support.impl.PositionImpl;
	import org.osflash.mixins.support.impl.SizeImpl;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.getTimer;

	[SWF(width=800, height=600, frameRate=64, backgroundColor=0x333333)]
	public class GeneratePerformance extends Sprite
	{
		
		private var _out0: TextField;
		private var _out1: TextField;
		
		private var _t0: int;

		private var _f: int;
		private var _min:int;
		private var _max:int;
		
		public function GeneratePerformance()
		{
			_out0 = new TextField();
			_out0.defaultTextFormat = new TextFormat('arial', 24, 0xff00ff);
			_out0.autoSize = TextFieldAutoSize.LEFT;
			_out0.x = 0x20;
			_out0.y = 0x20;
			
			_out1 = new TextField();
			_out1.defaultTextFormat = new TextFormat('arial', 24, 0xff00ff);
			_out1.autoSize = TextFieldAutoSize.LEFT;
			_out1.x = 0x200;
			_out1.y = 0x20;
			
			addChild(_out0);
			addChild(_out1);
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function onEnterFrame(event: Event): void
		{
			var t1: int = getTimer();
			if((t1 - _t0) >= 1000) 
			{
				_out0.text = _f+'fps\n'+(System.totalMemory >> 20)+'mb\n'+_min+'ms\n'+_max+'ms';
				_f = 0;
				_t0 = t1;
			}

			_f++;
			
			var n: int = 10;
			var m0: int = getTimer();
			while(--n != 0) 
			{
				const mixin : IMixin = new Mixin();
				mixin.add(IPosition, PositionImpl);
				mixin.add(ISize, SizeImpl);
				mixin.add(IName, NameImpl);
				
				mixin.define(ISquare);
							
				const signal : IMixinLoaderSignals = mixin.generate();
				signal.completedSignal.add(handleCreatedMixinSignal);
				
				mixin.removeAll();
			}
			
			var dt: int = (getTimer() - m0);
			if(dt < _min) _min = dt;
			if(dt > _max) _max = dt;
			_out1.text = dt+'ms';
		}
		
		private function handleCreatedMixinSignal(mixin : IMixin) : void
		{
			
		}
	}
}
