package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.ui.FlxSlider;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;

class MenuState extends FlxState
{
	override function create()
	{
		super.create();

		FlxG.cameras.bgColor = FlxColor.BLUE;
		
		var text = new FlxText();
		text.text = "Spear Hunter";
		text.color = FlxColor.PINK;
		text.size = 16;
		text.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.RED, 4);
		text.screenCenter();
		add(text);
		
		var button = new FlxButton(0, 0, "Start Game", switchState);
		button.screenCenter();
		button.y = text.y + text.height + 16;
		add(button);
	}
	
	private function switchState():Void
	{
		FlxG.switchState(new PlayState());
	}
}