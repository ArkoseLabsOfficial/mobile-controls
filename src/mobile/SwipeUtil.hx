package mobile;

import flixel.FlxG;

class SwipeUtil
{
	/**
	 * Indicates if there is an up swipe gesture detected.
	 */
	public static var up(get, never):Bool;

	/**
	 * Indicates if there is a down swipe gesture detected.
	 */
	public static var down(get, never):Bool;

	/**
	 * Indicates if there is a left swipe gesture detected.
	 */
	public static var left(get, never):Bool;

	/**
	 * Indicates if there is a right swipe gesture detected.
	 */
	public static var right(get, never):Bool;

	/**
	 * Determines if there is an up swipe in the FlxG.swipes array.
	 *
	 * @return True if any swipe direction is up, false otherwise.
	 */
	@:noCompletion
	static function get_up():Bool
	{
		#if FLX_POINTER_INPUT
		for (swipe in FlxG.swipes)
		{
			if (swipe.degrees > 45 && swipe.degrees < 135 && swipe.distance > 20) return true;
		}
		#end

		return false;
	}

	/**
	 * Determines if there is a down swipe in the FlxG.swipes array.
	 *
	 * @return True if any swipe direction is down, false otherwise.
	 */
	@:noCompletion
	static function get_down():Bool
	{
		#if FLX_POINTER_INPUT
		for (swipe in FlxG.swipes)
		{
			if (swipe.degrees > -135 && swipe.degrees < -45 && swipe.distance > 20) return true;
		}
		#end

		return false;
	}

	/**
	 * Determines if there is a left swipe in the FlxG.swipes array.
	 *
	 * @return True if any swipe direction is left, false otherwise.
	 */
	@:noCompletion
	static function get_left():Bool
	{
		#if FLX_POINTER_INPUT
		for (swipe in FlxG.swipes)
		{
			if (swipe.degrees > 45 && swipe.degrees < -45 && swipe.distance > 20) return true;
		}
		#end

		return false;
	}

	/**
	 * Determines if there is a right swipe in the FlxG.swipes array.
	 *
	 * @return True if any swipe direction is right, false otherwise.
	 */
	@:noCompletion
	static function get_right():Bool
	{
		#if FLX_POINTER_INPUT
		for (swipe in FlxG.swipes)
		{
			if (swipe.degrees > -45 && swipe.degrees < 45 && swipe.distance > 20) return true;
		}
		#end

		return false;
	}
}