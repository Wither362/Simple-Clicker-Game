package openfl.display;

import flixel.system.FlxAssets;
import haxe.Timer;
import openfl.events.Event;
import openfl.system.System;
import openfl.text.TextField;
import openfl.text.TextFormat;
// #if gl_stats
import openfl.display._internal.stats.Context3DStats;
import openfl.display._internal.stats.DrawCallContext;
// #end
// #if flash
import openfl.Lib;
// #end
import openfl.Memory;

/**
	The FPS class provides an easy-to-use monitor to display
	the current frame rate of an OpenFL project
**/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
class FPS extends TextField
{
	/**
		The current frame rate, expressed using frames-per-second
	**/
	public var currentFPS(default, null):Int;
	private var memPeak:Float = 0;

	@:noCompletion private var cacheCount:Int;
	@:noCompletion private var currentTime:Float;
	@:noCompletion private var times:Array<Float>;

	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		super();

		this.x = x;
		this.y = y;

		currentFPS = 0;
		selectable = true;
		mouseEnabled = true;
		defaultTextFormat = new TextFormat("_sans", 14, color, true);
		text = "FPS: ";

		cacheCount = 0;
		currentTime = 0;
		times = [];

		#if !flash
		addEventListener(Event.ENTER_FRAME, function(e)
		{
			var time = Lib.getTimer();
			__enterFrame(time - currentTime);
		});
		#end
		
		width = 300;
		height = 300;
	}

	// Event Handlers
	@:noCompletion
	private #if !flash override #end function __enterFrame(deltaTime:Float):Void
	{
		currentTime += deltaTime;
		times.push(currentTime);

		while (times[0] < currentTime - 1000)
		{
			times.shift();
		}

		var mem:Float = Math.round(System.totalMemory / 1024 / 1024 * 100) / 100;
		if (mem > memPeak)
			memPeak = mem;

		var currentCount = times.length;
		currentFPS = Math.round((currentCount + cacheCount) / 2);

		if (currentCount != cacheCount /*&& visible*/)
		{
			text = "FPS: " + currentFPS + 
			"\nMemory Usage: " + mem + " MB" + 
			"\nMemory Peak: " + memPeak + " MB";

			textColor = 0xFFFFFFFF;
			if (mem > 3000 || currentFPS <= 30)
			{
				textColor = 0xFFFF0000;
			}
			if (mem > 3000 || currentFPS <= 15)
			{
				textColor = 0xFF8D0000;
			}
			if (mem > 3000 || currentFPS <= 5)
			{
				textColor = 0xFF000000;
			}
			//#if (gl_stats && !disable_cffi && (!html5 || !canvas))
			// text += "\ntotalDC: " + Context3DStats.totalDrawCalls();
			// text += "\nstageDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE);
			// text += "\nstage3DDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE3D);
			//#end
		}

		cacheCount = currentCount;
	}
}