package org.osflash.mixins
{
	import org.osflash.mixins.support.debug.MixinFactoryPoolDebug;
	import org.osflash.mixins.generator.signals.IMixinLoaderSignals;
	import org.osflash.mixins.support.IMixinFactoryPool;
	import org.osflash.mixins.support.MixinFactoryPool;
	import org.osflash.mixins.support.shape.IRectangle;
	import org.osflash.mixins.support.shape.defs.IName;
	import org.osflash.mixins.support.shape.defs.IPosition;
	import org.osflash.mixins.support.shape.defs.ISize;
	import org.osflash.mixins.support.shape.impl.NameImpl;
	import org.osflash.mixins.support.shape.impl.PositionImpl;
	import org.osflash.mixins.support.shape.impl.SizeImpl;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	[SWF(width=800, height=600, frameRate=64, backgroundColor=0x333333)]
	public class FactoryPoolPerformance extends Sprite
	{
		private var _out0: TextField;
		private var _out1: TextField;
		
		private var _t0: int;

		private var _f: int;
		private var _min:int;
		private var _max:int;
		
		private var _mixin : IMixin;
		private var _pool : IMixinFactoryPool;
		private var _items : Vector.<IRectangle>;
		private var _debug : MixinFactoryPoolDebug;

		public function FactoryPoolPerformance()
		{
			mouseChildren = false;
			mouseEnabled = false;
			
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
			
			_mixin = new Mixin();
			_mixin.add(IPosition, PositionImpl);
			_mixin.add(ISize, SizeImpl);
			_mixin.add(IName, NameImpl);
			
			_mixin.define(IRectangle);
						
			const signals : IMixinLoaderSignals = _mixin.generate();
			signals.completedSignal.add(handleCompletedMixinSignal);
		}
		
		private function handleCompletedMixinSignal(mixin : IMixin) : void
		{
			_pool = new MixinFactoryPool(mixin, IRectangle);
			_pool.poolGrowSize = 500;
			
			_debug = new MixinFactoryPoolDebug();
			_debug.add(_pool);
			
			_items = new Vector.<IRectangle>();
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			mixin;
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
			var n : int = 5000/4;
			var m0 : int = getTimer();
			while(--n > -1) 
			{
				_items.push(_pool.pop());
			}
			
			var t0 : int = _items.length;
			while(--t0 > -1)
			{
				_pool.push(_items.pop());
			}
			
			// trace(_debug.report().toXMLString());
			
			var dt: int = (getTimer() - m0);
			if(dt < _min) _min = dt;
			if(dt > _max) _max = dt;
			_out1.text = dt+'ms';
		}
	}
}
