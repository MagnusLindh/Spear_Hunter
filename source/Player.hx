package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.sound.FlxSound;
import haxe.Timer;

class Player extends FlxSprite
{
	var _isReadyToJump:Bool = true;
	var _jumpPower:Int = 200;

	// This is the player object class.  Most of the comments I would put in here
	// would be near duplicates of the Enemy class, so if you're confused at all
	// I'd recommend checking that out for some ideas!
	public function new(X:Int, Y:Int)
	{
		super(X, Y);
		loadGraphic("assets/scuba.png", true, 8);

		// bounding box tweaks
		width = 6;
		height = 7;
		offset.x = 1;
		offset.y = 1;

		// basic player physics
		var runSpeed:Int = 80;
		drag.x = runSpeed * 8;
		drag.y = runSpeed * 8;
		maxVelocity.x = runSpeed;
		maxVelocity.y = runSpeed;

		// animations
		animation.add("idle", [0,1,2,1],4);
		animation.add("swimDown", [3,4,5,6], 8);
		animation.add("swimLeft", [7,8,9,7], 8);
	}

	override public function update(elapsed:Float):Void
	{
		// MOVEMENT
		acceleration.x = 0;
		acceleration.y = 0;

		if (FlxG.keys.anyPressed([LEFT, A]))
		{
			flipX = false;
			acceleration.x -= drag.x;
		}
		else if (FlxG.keys.anyPressed([RIGHT, D]))
		{
			flipX = true;
			acceleration.x += drag.x;
		}

		if (FlxG.keys.anyPressed([UP, W]))
		{
			flipY = true;
			acceleration.y -= drag.y;
		}

		if (FlxG.keys.anyPressed([DOWN, S]))
		{
			flipY = false;
			acceleration.y += drag.y;
		}

		if (FlxG.keys.justPressed.SPACE)
		{
			// Play a sound effect when the player shoots with slight random pitch
			var shootSound:FlxSound = FlxG.sound.play("assets/fire.wav", 0.5);
			#if FLX_PITCH
			shootSound.pitch = FlxG.random.float(0.9, 1.1);
			#end
			// Space bar was pressed! FIRE A BULLET
			var playState:PlayState = cast FlxG.state;
			var bullet:FlxSprite = playState._playerBullets.recycle();
			bullet.reset(x, y);
			if (flipX==true){
				bullet.velocity.x = 400;
			} else {
				bullet.velocity.x = -400;
			}
			if (!playState._gameOver){
				playState._score--;
				playState._timeDiff = FlxMath.roundDecimal(Timer.stamp() - playState._time1, 0);
				playState._text.text = "Score " + playState._score + " Fish " + playState._fish + " Time " + (playState._timeTotal-playState._timeDiff);
			}
		}

		// ANIMATION
		if (velocity.x != 0)
		{
			animation.play("swimLeft");
		} 
		else if (velocity.y != 0)
		{
			animation.play("swimDown");
		}	
		else
		{
			animation.play("idle");
			flipY = false;
		}

		super.update(elapsed);
	}
}
