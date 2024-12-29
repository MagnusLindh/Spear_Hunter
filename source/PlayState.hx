package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.tile.FlxCaveGenerator;
import flixel.addons.ui.FlxSlider;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import haxe.Timer;

class PlayState extends FlxState
{
	var _tilemap:FlxTilemap;
	var _player:Player;
	var _smoothingIterations:Int = 6;
	var _wallRatio:Float = 0.5;
	var _uiBackground:FlxSprite;
	var _sfxSlider:FlxSlider;
	var _musicSlider:FlxSlider;
	var _menuButton:FlxButton;
	var _title:FlxText;
	public var _playerBullets:FlxTypedGroup<FlxSprite>;
	var _aliens:FlxTypedGroup<Alien>;
	public var _score:Int = 0;
	public var _text = new FlxText();
	var _showSettings:Bool = false;
	var _sfxVolume:Float = 0.5;
	var _musicVolume:Float = 0.5;
	public var _fish:Int = 50;
	public var _time1:Float = Timer.stamp();
	public var _timeDiff:Float;
	var _currentTime:Float;
	public var _timeTotal:Float = 60;
	public var _gameOver:Bool = false;
	var _playerDead:Bool = false;
	var _musicSound:FlxSound;

	override public function create():Void
	{
		_musicSound = FlxG.sound.play("assets/music.mp3",_musicVolume);
		_musicSound.volume = _musicVolume;
		_musicSound.looped = true;

		FlxG.cameras.bgColor = FlxColor.BLUE;

		// Create the tilemap for the cave
		_tilemap = new FlxTilemap();

		// A little player character
		_player = new Player(0, 0);

		// First we will instantiate the bullets you fire at your enemies.
		var numPlayerBullets:Int = 8;
		// Initializing the array is very important and easy to forget!
		_playerBullets = new FlxTypedGroup(numPlayerBullets);
		var sprite:FlxSprite;

		// Create 8 bullets for the player to recycle
		for (i in 0...numPlayerBullets)
		{
			// Instantiate a new sprite offscreen
			sprite = new FlxSprite(-100, -100);
			// Create a 2x8 white box
			sprite.makeGraphic(8, 2);
			sprite.exists = false;
			// Add it to the group of player bullets
			_playerBullets.add(sprite);
		}

		add(_playerBullets);

		// Create some UI
		var UI_WIDTH:Int = 200;
		var UI_POS_X:Int = FlxG.width - UI_WIDTH;

		_uiBackground = new FlxSprite(UI_POS_X, 0);
		_uiBackground.makeGraphic(UI_WIDTH, 245, FlxColor.WHITE);
		_uiBackground.alpha = 0.85;

		_title = new FlxText(UI_POS_X, 2, UI_WIDTH, "Settings");
		_title.setFormat(null, 16, FlxColor.BROWN, CENTER, OUTLINE_FAST, FlxColor.BLACK);

		_sfxSlider = new FlxSlider(this, "_sfxVolume", FlxG.width - 180, 50, 0, 1, 150);
		_sfxSlider.nameLabel.text = "Sfx Volume";

		_musicSlider = new FlxSlider(this, "_musicVolume", FlxG.width - 180, 120, 0, 1, 150);
		_musicSlider.nameLabel.text = "Music Volume";

		_menuButton = new FlxButton(FlxG.width - 140, 190, "Menu", switchState);

		// create the score text
		_timeDiff = FlxMath.roundDecimal(Timer.stamp() - _time1, 0);
		_text.text = "Score " + _score + " Fish " + _fish + " Time " + (_timeTotal-_timeDiff);
		_text.color = FlxColor.CYAN; // set the color to cyan
		_text.size = 16; // set the text's size to 32px
		_text.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.GREEN, 2); // give the text a 4-pixel deep, blue shadow

		var settingsButton = new FlxButton(550, 450, "Settings", switchSettings);

		//show settings
		if (!_showSettings){
			_uiBackground.kill();
			_title.kill();
			_sfxSlider.kill();
			_musicSlider.kill();
			_menuButton.kill();
		}

		// Add all the stuff in correct order
		add(_tilemap);
		add(_player);
		add(_uiBackground);
		add(_title);
		add(_sfxSlider);
		add(_musicSlider);
		add(_menuButton);
		generateCave();
		add(_text);
		add(settingsButton);
	}

	override public function update(elapsed:Float):Void
	{
		// Update timer
		_timeDiff = FlxMath.roundDecimal(Timer.stamp() - _time1, 0);
		if (!_gameOver && _currentTime<_timeDiff){
			_currentTime=_timeDiff;
			_text.text = "Score " + _score + " Fish " + _fish + " Time " + (_timeTotal-_timeDiff);// create the score text
			if (_timeDiff>=_timeTotal){
				_text.text = "Final score " + _score + " - " + rating(_score);
				_gameOver = true; 
			}
		}


		// Collide the player with the walls
		FlxG.collide(_tilemap, _player);

		// Collide bullets with walls
		FlxG.collide(_tilemap, _playerBullets, bulletHitWall);

		// Collide aliens with walls
		FlxG.collide(_tilemap,_aliens); 

		// Overlap fish and spear
		FlxG.overlap(_aliens,_playerBullets,spearHitFish);

		// Overlap fish and player
		FlxG.overlap(_aliens,_player, playerHitFish);

		// Make sure the player can't leave the screen area
		FlxSpriteUtil.screenWrap(_player);

		super.update(elapsed);
	}

	function rating(s){
		if (s>45){
			return "Jacques-Yves Cousteau";
		} else if (s>40){
			return "Aquaman";
		} else if (s>35) {
			return "Octopus Oligarch";
		} else if (s>30) {
			return "Captain Cod";
		} else if (s>25) {
			return "Master of Mackerel";
		} else if (s>20) {
			return "Lobster Lieutenant";
		} else if (s>15) {
			return "Boatswain";
		} else if (s>10) {
			return "Fishmonger";
		} else if (s>5) {
			return "Shrimp peeler";
		} else if (s>0) {
			return "Sea urchin";
		} else {
			return "Sea cucumber";
		}
	}

	private function switchState():Void
	{
		FlxG.switchState(new MenuState());
	}

	function switchSettings():Void
	{
		// switch showSettings 
		_showSettings ? _showSettings=false : _showSettings=true;

		if (_showSettings){
			_uiBackground.revive();
			_title.revive();
			_sfxSlider.revive();
			_musicSlider.revive();
			_menuButton.revive();
		} else {
			_uiBackground.kill();
			_title.kill();
			_sfxSlider.kill();
			_musicSlider.kill();
			_menuButton.kill();
			_musicSound.volume = _musicVolume;
		}
	}
	function bulletHitWall(Object1:FlxObject, Object2:FlxObject):Void
	{
		var wallSound:FlxSound = FlxG.sound.play("assets/rockImpact.wav",_sfxVolume);
		#if FLX_PITCH
		wallSound.pitch = FlxG.random.float(0.9, 1.1);
		#end
		Object2.kill();
	}

	function spearHitFish(Object1:FlxObject, Object2:FlxObject):Void
	{
		var fishSound:FlxSound = FlxG.sound.play("assets/fishImpact.wav",_sfxVolume);
		#if FLX_PITCH
		fishSound.pitch = FlxG.random.float(0.9, 1.1);
		#end
		Object1.kill();
		Object2.kill();
		if (!_gameOver)
		{
			_score=_score+2;
			_fish--;
			_timeDiff = FlxMath.roundDecimal(Timer.stamp() - _time1, 0);
			_text.text = "Score " + _score + " Fish " + _fish + " Time " + (_timeTotal-_timeDiff);
		}
	}

	function playerHitFish(Object1:FlxObject, Object2:FlxObject):Void
	{
		if (!_gameOver){
			var bubbleSound:FlxSound = FlxG.sound.play("assets/bubble.wav",_sfxVolume);
			#if FLX_PITCH
			bubbleSound.pitch = FlxG.random.float(0.9, 1.1);
			#end
			Object2.kill();	
			_gameOver = true;
			_playerDead = true;
			_text.text = "Game over";
		}
	}

	function generateCave():Void
	{
		// Determine the width and height (in tiles) needed to fill the screen with tiles that are 8x8 pixels
		var width:Int = Math.floor(FlxG.width / 8);
		var height:Int = Math.floor((FlxG.height) / 8);

		// Get the time before starting the generation to calculate the timer later
		//var time1:Float = Timer.stamp();

		var caveData:String = FlxCaveGenerator.generateCaveString(width, height, _smoothingIterations, _wallRatio);

		// Calculate the time it took to create the cave and update the text
		//var timeDiff:Float = FlxMath.roundDecimal(Timer.stamp() - time1, 4);

		// Loads the cave to the tilemap
		_tilemap.loadMapFromCSV(caveData, "assets/caveWallTiles.png", 8, 8, AUTO);
		_tilemap.updateBuffers();

		// Find an empty tile for the player
		var emptyTiles:Array<FlxPoint> = _tilemap.getTileCoords(0, false);
		var randomEmptyTile:FlxPoint = emptyTiles[FlxG.random.int(0, emptyTiles.length)];
		_player.setPosition(randomEmptyTile.x, randomEmptyTile.y);

		// ...then we go through and make the invaders. This looks all mathy but it's not that bad!
		// We're basically making 5 rows of 10 invaders, and each row is a different color.
		var numAliens:Int = _fish;
		_aliens = new FlxTypedGroup(numAliens);
		var a:Alien;
		var i:Int = 0;
		var emptyTiles:Array<FlxPoint>;
		var randomEmptyTile:FlxPoint;
		while (i<numAliens)
		{
			emptyTiles = _tilemap.getTileCoords(0, false);
			randomEmptyTile = emptyTiles[FlxG.random.int(0, emptyTiles.length)];
			a = new Alien(Std.int(randomEmptyTile.x), Std.int(randomEmptyTile.y));
			if (!FlxMath.isDistanceWithin(_player, a, 50,true)){
				i++;
				_aliens.add(a);
			}
		}

		add(_aliens);
	}
}
