package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;

/**
 * Class declaration for the squid monster class
 */
class Alien extends FlxSprite
{
	/**
	 * A simple timer for deciding when to shoot
	 */
	var _swimClock:Float;

	/**
	 * This is the constructor for the squid monster.
	 * We are going to set up the basic values and then create a simple animation.
	 */
	public function new(X:Int, Y:Int)
	{
		// Initialize sprite object
		super(X, Y);
		// Load this animated graphic file
		loadGraphic("assets/scuba.png", true,8,8);
		resetSwimClock();

		// Time to create a simple animation! "alien.png" has 3 frames of animation in it.
		// We want to play them in the order 1, 2, 3, 1 (but of course this stuff is 0-index).
		// To avoid a weird, annoying appearance the framerate is randomized a little bit
		// to a value between 6 and 10 (6+4) frames per second.
		// Three types of fish 0, 1 and 2 times two to get the correct frames.
		var fishType = Math.floor(FlxG.random.float()*3)*2;
		this.animation.add("Default", [10+fishType, 11+fishType], Math.floor(6 + FlxG.random.float() * 4));

		// Now that the animation is set up, it's very easy to play it back!
		this.animation.play("Default");
	}

	override function kill() {
		//var snd:String = FlxG.random.getObject(["assets/alien_die0.wav", "assets/alien_die1.wav"]);
		//FlxG.sound.play(snd, 0.9);
		super.kill();
	}

	/**
	 * Basic game loop is BACK y'all
	 */
	override public function update(elapsed:Float):Void
	{
		_swimClock -= elapsed;
		if (_swimClock<=0){
			velocity.x = FlxG.random.float() * 10 - 5;
			velocity.y = FlxG.random.float() * 10 - 5;
			if (velocity.x > 0){
				flipX = true;
			} else {
				flipX = false;
			}
			resetSwimClock();
		}

		super.update(elapsed);
	}

	/**
	 * This function just resets our swim logic timer to a random value between 1 and 11
	 */
	 
	function resetSwimClock():Void
	{
		_swimClock = 1 + FlxG.random.float() * 10;
	}
	
}
