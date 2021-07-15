package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

using StringTools;

class DialogueBox extends FlxSpriteGroup
{
	var box:FlxSprite;

	var curCharacter:String = '';

	var dialogue:Alphabet;
	var dialogueList:Array<String> = [];

	// SECOND DIALOGUE FOR THE PIXEL SHIT INSTEAD???
	var swagDialogue:FlxTypeText;

	var dropText:FlxText;

	public var finishThing:Void->Void;

	var portraitLeft:FlxSprite;
	var portraitRight:FlxSprite;

	var handSelect:FlxSprite;
	var bgFade:FlxSprite;

	var imageOverlay:FlxSprite;

	var inputAllowed:Bool = true;

	public function new(talkingRight:Bool = true, ?dialogueList:Array<String>)
	{
		super();

		bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), 0xFFB3DFd8);
		bgFade.scrollFactor.set();
		bgFade.alpha = 0;
		add(bgFade);

		new FlxTimer().start(0.83, function(tmr:FlxTimer)
		{
			bgFade.alpha += (1 / 5) * 0.7;
			if (bgFade.alpha > 0.7)
				bgFade.alpha = 0.7;
		}, 5);

		box = new FlxSprite(-20, 45);
		
		var hasDialog = false;
		switch (PlayState.SONG.song.toLowerCase())
		{
			default:
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('speech_bubble_talking', 'shared');
				box.animation.addByPrefix('normalOpen', 'Speech Bubble Normal Open', 24, false);
				box.animation.addByPrefix('normal', 'speech bubble normal', 24, false);
				box.setGraphicSize(Std.int(box.width * 1 * 0.9));
				box.y = (FlxG.height - box.height) + 80;
		}

		this.dialogueList = dialogueList;
		
		if (!hasDialog)
			return;
		
		portraitLeft = new FlxSprite(-20, 40);
		add(portraitLeft);
		portraitLeft.visible = false;

		// small things: fix thorns layering issue
		if (PlayState.SONG.song.toLowerCase() == 'thorns')
		{
			var face:FlxSprite = new FlxSprite(320, 170).loadGraphic(Paths.image('weeb/spiritFaceForward'));
			face.setGraphicSize(Std.int(face.width * 6));
			add(face);
		}

		portraitRight = new FlxSprite(0, 40);
		add(portraitRight);
		portraitRight.visible = false;
		
		box.animation.play('normalOpen');
		box.updateHitbox();
		add(box);

		box.screenCenter(X);
		// portraitLeft.screenCenter(X);


		if (!talkingRight)
		{
			// box.flipX = true;
		}

		swagDialogue = new FlxTypeText(240, 500, Std.int(FlxG.width * 0.6), "", 32);
		swagDialogue.setFormat(Paths.font("vcr.ttf"), 40, FlxColor.BLACK, LEFT);
		dropText = new FlxText(242, 502, Std.int(FlxG.width * 0.6), "", 32);
		dropText.setFormat(Paths.font("vcr.ttf"), 40, FlxColor.BLACK, LEFT);

		if (PlayState.SONG.song.toLowerCase() == 'senpai' || PlayState.SONG.song.toLowerCase() == 'roses' || PlayState.SONG.song.toLowerCase() == 'thorns') {
			dropText = new FlxText(242, 502, Std.int(FlxG.width * 0.6), "", 32);
			dropText.font = 'Pixel Arial 11 Bold';
			dropText.color = 0xFFD89494;

			swagDialogue = new FlxTypeText(240, 500, Std.int(FlxG.width * 0.6), "", 32);
			swagDialogue.font = 'Pixel Arial 11 Bold';
			swagDialogue.color = 0xFF3F2021;
			swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];
		}

		add(dropText);
		add(swagDialogue);

		dialogue = new Alphabet(0, 80, "", false, true);
		// dialogue.x = 90;
		// add(dialogue);

		imageOverlay = new FlxSprite();
		imageOverlay.x = 0;
		imageOverlay.y = 0;
		add(imageOverlay);
	}

	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;

	override function update(elapsed:Float)
	{
		// HARD CODING CUZ IM STUPDI
		if (PlayState.SONG.song.toLowerCase() == 'roses')
			portraitLeft.visible = false;
		if (PlayState.SONG.song.toLowerCase() == 'thorns')
		{
			portraitLeft.color = FlxColor.BLACK;
			swagDialogue.color = FlxColor.WHITE;
			dropText.color = FlxColor.BLACK;
		}

		dropText.text = swagDialogue.text;

		if (box.animation.curAnim != null)
		{
			if (box.animation.curAnim.name == 'normalOpen' && box.animation.curAnim.finished)
			{
				box.animation.play('normal');
				dialogueOpened = true;
			}
		}

		if (dialogueOpened && !dialogueStarted)
		{
			startDialogue();
			dialogueStarted = true;
		}

		if (FlxG.keys.justPressed.ANY  && dialogueStarted == true)
		{
			if (inputAllowed == true)
				advanceDialogue();
		}
		
		super.update(elapsed);
	}

	var isEnding:Bool = false;

	function advanceDialogue(playSound:Bool = true) {
		remove(dialogue);
			
		if (playSound == true)
			FlxG.sound.play(Paths.sound('clickText'), 0.8);

		if (dialogueList[1] == null && dialogueList[0] != null)
		{
			if (!isEnding)
			{
				isEnding = true;

				switch (PlayState.SONG.song.toLowerCase())
				{
					case 'thorns':
						FlxG.sound.music.fadeOut(2.2, 0);
				}

				new FlxTimer().start(0.2, function(tmr:FlxTimer)
				{
					box.alpha -= 1 / 5;
					bgFade.alpha -= 1 / 5 * 0.7;
					portraitLeft.visible = false;
					portraitRight.visible = false;
					swagDialogue.alpha -= 1 / 5;
					dropText.alpha = swagDialogue.alpha;
				}, 5);

				new FlxTimer().start(1.2, function(tmr:FlxTimer)
				{
					finishThing();
					kill();
				});
			}
		}
		else
		{
			dialogueList.remove(dialogueList[0]);

			portraitLeft.visible = false;
			portraitRight.visible = false;

			startDialogue();
		}
	}

	function startDialogue():Void
	{
		cleanDialog();
		// var theDialog:Alphabet = new Alphabet(0, 70, dialogueList[0], false, true);
		// dialogue = theDialog;
		// add(theDialog);

		// swagDialogue.text = ;
		swagDialogue.resetText(dialogueList[0]);
		swagDialogue.start(0.04, true);

		switch (curCharacter)
		{
			case 'bf':
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('bfText'), 0.6)];
				swagDialogue.color = FlxColor.fromRGB(80, 165, 235);
				portraitLeft.visible = false;
				if (!portraitRight.visible)
				{
					portraitRight.frames = Paths.getSparrowAtlas('characters/portraits/bfPortraitClean', 'shared');
					portraitRight.animation.addByPrefix('enter', 'Boyfriend portrait enter clean', 24, false);
					portraitRight.setGraphicSize(Std.int(portraitRight.width * 1 * 0.75));
					portraitRight.antialiasing = true;
					portraitRight.updateHitbox();
					portraitRight.scrollFactor.set();
					// portraitRight.screenCenter(X);

					portraitRight.x = (box.x + box.width) - (portraitRight.width) - 110;
					portraitRight.y = box.y - 188;

					portraitRight.scale.x = 1.2;
					portraitRight.scale.y = 1.2;

					portraitRight.visible = true;
					portraitRight.animation.play('enter');
				}
			case 'scott':
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('scottText'), 0.6)];
				swagDialogue.color = FlxColor.fromRGB(0, 31, 153);
				portraitRight.visible = false;
				if (!portraitLeft.visible)
				{
					portraitLeft.frames = Paths.getSparrowAtlas('characters/portraits/scottPortrait', 'shared');
					portraitLeft.animation.addByPrefix('enter', 'Scott Portrait Enter', 24, false);
					portraitLeft.setGraphicSize(Std.int(portraitLeft.width * 1 * 0.75));
					portraitLeft.antialiasing = true;
					portraitLeft.updateHitbox();
					portraitLeft.scrollFactor.set();
					// portraitLeft.screenCenter(X);

					portraitLeft.x = box.x + 64;
					portraitLeft.y = box.y - 232;

					portraitLeft.visible = true;
					portraitLeft.animation.play('enter');
				}
			case 'scott-pain':
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('scottText'), 0.6)];
				swagDialogue.color = FlxColor.fromRGB(0, 31, 153);
				portraitRight.visible = false;
				if (!portraitLeft.visible)
				{
					portraitLeft.frames = Paths.getSparrowAtlas('characters/portraits/ScottPainPortrait', 'shared');
					portraitLeft.animation.addByPrefix('enter', 'Scott Pain Portrait Enter', 24, false);
					portraitLeft.setGraphicSize(Std.int(portraitLeft.width * 1 * 0.75));
					portraitLeft.antialiasing = true;
					portraitLeft.updateHitbox();
					portraitLeft.scrollFactor.set();
					// portraitLeft.screenCenter(X);

					portraitLeft.x = box.x + 64;
					portraitLeft.y = box.y - 224;

					portraitLeft.visible = true;
					portraitLeft.animation.play('enter');
				}
			case 'scott-nerv':
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('scottText'), 0.6)];
				swagDialogue.color = FlxColor.fromRGB(0, 31, 153);
				portraitRight.visible = false;
				if (!portraitLeft.visible)
				{
					portraitLeft.frames = Paths.getSparrowAtlas('characters/portraits/scottnervPortrait', 'shared');
					portraitLeft.animation.addByPrefix('enter', 'Scott Nerv Portrait Enter', 24, false);
					portraitLeft.setGraphicSize(Std.int(portraitLeft.width * 1 * 0.75));
					portraitLeft.antialiasing = true;
					portraitLeft.updateHitbox();
					portraitLeft.scrollFactor.set();
					// portraitLeft.screenCenter(X);

					portraitLeft.x = box.x + 64;
					portraitLeft.y = box.y - 224;

					portraitLeft.visible = true;
					portraitLeft.animation.play('enter');
				}
			case 'jeb':
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('scottText'), 0.6)];
				swagDialogue.color = FlxColor.fromRGB(60, 34, 35);
				portraitRight.visible = false;
				if (!portraitLeft.visible)
				{
					portraitLeft.frames = Paths.getSparrowAtlas('characters/portraits/jebPortrait', 'shared');
					portraitLeft.animation.addByPrefix('enter', 'Jeb Portrait Enter', 24, false);
					portraitLeft.setGraphicSize(Std.int(portraitLeft.width * 1 * 0.75));
					portraitLeft.antialiasing = true;
					portraitLeft.updateHitbox();
					portraitLeft.scrollFactor.set();
					// portraitLeft.screenCenter(X);

					portraitLeft.x = box.x + 64;
					portraitLeft.y = box.y - 224;

					portraitLeft.visible = true;
					portraitLeft.animation.play('enter');
				}
			case 'jeb-gun':
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('scottText'), 0.6)];
				swagDialogue.color = FlxColor.fromRGB(60, 34, 35);
				portraitRight.visible = false;
				if (!portraitLeft.visible)
				{
					portraitLeft.frames = Paths.getSparrowAtlas('characters/portraits/JebGunPortrait', 'shared');
					portraitLeft.animation.addByPrefix('enter', 'Jeb Gun Portrait Enter', 24, false);
					portraitLeft.setGraphicSize(Std.int(portraitLeft.width * 1 * 0.75));
					portraitLeft.antialiasing = true;
					portraitLeft.updateHitbox();
					portraitLeft.scrollFactor.set();
					// portraitLeft.screenCenter(X);

					portraitLeft.x = box.x + 64;
					portraitLeft.y = box.y - 224;

					portraitLeft.visible = true;
					portraitLeft.animation.play('enter');
				}
			case 'terry':
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('scottText'), 0.6)];
				swagDialogue.color = FlxColor.fromRGB(27, 21, 55);
				portraitRight.visible = false;
				if (!portraitLeft.visible)
				{
					portraitLeft.frames = Paths.getSparrowAtlas('characters/portraits/terryPortrait', 'shared');
					portraitLeft.animation.addByPrefix('enter', 'Terry Portrait Enter', 24, false);
					portraitLeft.setGraphicSize(Std.int(portraitLeft.width * 1 * 0.75));
					portraitLeft.antialiasing = true;
					portraitLeft.updateHitbox();
					portraitLeft.scrollFactor.set();
					// portraitLeft.screenCenter(X);

					portraitLeft.x = box.x + 64;
					portraitLeft.y = box.y - 224;

					portraitLeft.visible = true;
					portraitLeft.animation.play('enter');
				}
			case 'rex':
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('scottText'), 0.6)];
				swagDialogue.color = FlxColor.fromRGB(125, 125, 125);
				portraitRight.visible = false;
				if (!portraitLeft.visible)
				{
					portraitLeft.frames = Paths.getSparrowAtlas('characters/portraits/rexPortrait', 'shared');
					portraitLeft.animation.addByPrefix('enter', 'Rex Portrait Enter', 24, false);
					portraitLeft.setGraphicSize(Std.int(portraitLeft.width * 1 * 0.75));
					portraitLeft.antialiasing = true;
					portraitLeft.updateHitbox();
					portraitLeft.scrollFactor.set();
					// portraitLeft.screenCenter(X);

					portraitLeft.x = box.x + 64;
					portraitLeft.y = box.y - 224;

					portraitLeft.visible = true;
					portraitLeft.animation.play('enter');
				}
			case 'target-employee':
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('scottText'), 0.6)];
				swagDialogue.color = FlxColor.fromRGB(27, 21, 55);
				portraitRight.visible = false;
				if (!portraitLeft.visible)
				{
					portraitLeft.frames = Paths.getSparrowAtlas('characters/portraits/targetemployeePortrait', 'shared');
					portraitLeft.animation.addByPrefix('enter', 'Target Employee Portrait Enter', 24, false);
					portraitLeft.setGraphicSize(Std.int(portraitLeft.width * 1 * 0.75));
					portraitLeft.antialiasing = true;
					portraitLeft.updateHitbox();
					portraitLeft.scrollFactor.set();
					// portraitLeft.screenCenter(X);

					portraitLeft.x = box.x + 64;
					portraitLeft.y = box.y - 224;

					portraitLeft.visible = true;
					portraitLeft.animation.play('enter');
				}
			case 'gf':
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('scottText'), 0.6)];
				swagDialogue.color = FlxColor.fromRGB(238, 21, 54);
				portraitLeft.visible = false;
				if (!portraitLeft.visible)
				{
					portraitRight.frames = Paths.getSparrowAtlas('characters/portraits/gfPortrait', 'shared');
					portraitRight.animation.addByPrefix('enter', 'Girlfriend portrait enter', 24, false);
					portraitRight.setGraphicSize(Std.int(portraitRight.width * 1 * 0.75));
					portraitRight.antialiasing = true;
					portraitRight.updateHitbox();
					portraitRight.scrollFactor.set();
					// portraitRight.screenCenter(X);

					portraitRight.x = (box.x + box.width) - (portraitRight.width) - 110;
					portraitRight.y = box.y - 188;

					portraitRight.scale.x = 1.2;
					portraitRight.scale.y = 1.2;

					portraitRight.visible = true;
					portraitRight.animation.play('enter');
				}
			case 'jerry':
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('scottText'), 0.6)];
				swagDialogue.color = FlxColor.fromRGB(102, 0, 0);
				portraitRight.visible = false;
				if (!portraitLeft.visible)
				{
					portraitLeft.frames = Paths.getSparrowAtlas('characters/portraits/jerryPortrait', 'shared');
					portraitLeft.animation.addByPrefix('enter', 'Jerry  Portrait Enter', 24, false);
					portraitLeft.setGraphicSize(Std.int(portraitLeft.width * 1 * 0.75));
					portraitLeft.antialiasing = true;
					portraitLeft.updateHitbox();
					portraitLeft.scrollFactor.set();
					// portraitLeft.screenCenter(X);

					portraitLeft.x = box.x + 64;
					portraitLeft.y = box.y - 224;

					portraitLeft.visible = true;
					portraitLeft.animation.play('enter');
				}
			case 'cutsceneModeEnable':
				box.visible = false;
				swagDialogue.visible = false;
				inputAllowed = false;
				advanceDialogue(false);
			case 'cutsceneModeDisable':
				box.visible = true;
				swagDialogue.visible = true;
				inputAllowed = true;
				advanceDialogue(false);
			case 'showImage':
				imageOverlay.loadGraphic(Paths.image(dialogueList[0], 'shared'));
				imageOverlay.visible = true;
				advanceDialogue(false);
			case 'hideImage':
				imageOverlay.visible = false;
				advanceDialogue(false);
			case 'waitToAdvance':
				new FlxTimer().start(Std.parseFloat(dialogueList[0]), function(tmr:FlxTimer) {
					advanceDialogue(false);
				});
			case 'playMusic':
				FlxG.sound.playMusic(Paths.music(dialogueList[0], 'shared'));
				advanceDialogue(false);
			case 'pauseMusic':
				FlxG.sound.music.pause();
				advanceDialogue(false);
			case 'resumeMusic':
				FlxG.sound.music.resume();
				advanceDialogue(false);
			
		}
	}

	function cleanDialog():Void
	{
		var splitName:Array<String> = dialogueList[0].split(":");
		curCharacter = splitName[1];
		dialogueList[0] = dialogueList[0].substr(splitName[1].length + 2).trim();
	}
}
