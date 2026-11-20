// МАГИЧЕСКОЕ ДЕРЬМО ТРАСТ МИ - rich
static var PIVOT = FlxPoint.get(723.45, -1041);
static var GF_OFFSET = 120;
static var ROPE_OFFSET = 777; // НЕВЕР СТОП ГЭМБЛИНГ!!!! 🎰🎰🎰
/*static*/ var SWAY_SPEED = 30 / (Conductor.crochet * 4 / 1000); // привет свау

var tv:Character;
var rope:FlxSprite;
var acceleration = 0;
var direction = 0;

function onCreatePost()
{
	tv = getVar("gf_tv");

	rope = new FlxSprite(gf.x - gfGroup.x, gf.y - gfGroup.y, Paths.image("КраснБелНоТоргЦентр/тоилет_тиви_веревка"));
	rope.x += (gf.width + rope.width) / 2 - 110;
	rope.y -= rope.height - 300;
	rope.scale.set(0.9, 0.9);
	rope.updateHitbox();
	rope.maxAngular = SWAY_SPEED;
	rope.shader = tv.shader;

	gfGroup.insert(0, rope);
	gfGroup.y += GF_OFFSET;

	// setOrigin(rope);
	// setOrigin(gf);
	for (spr in gfGroup.members)
		setOrigin(spr);

	gfGroup.x += gf.offset.x;
	gfGroup.y += gf.offset.y;

	rope.y -= ROPE_OFFSET;
	// acceleration = SWAY_SPEED * 2;
}

function setOrigin(spr:FlxSprite)
{
	// хз как но оно работает - rich
	spr.updateHitbox();
	spr.origin.set(PIVOT.x - spr.x + spr.offset.x * spr.scale.x, PIVOT.y - spr.y + spr.offset.y * spr.scale.y);
}

function onUpdate(elapsed:Float)
{
	if (direction == 0)
		return;

	var threshold = 2.5;
	if (rope.angle > threshold && rope.angularAcceleration > 0 || rope.angle < -threshold && rope.angularAcceleration < 0)
		direction *= -1;

	rope.angularAcceleration = acceleration * direction;
}

function onUpdatePost(elapsed:Float)
{
	// gf.angle = rope.angle;
	// gfGroup.angle = rope.angle;
	for (spr in gfGroup.members)
		spr.angle = rope.angle;
}

function onEvent(name:String, value1:String, value2:String, value3:String)
{
	if (name != "")
		return;

	switch (value1)
	{
		case "тоилет_тиви":
			var crochet = Conductor.crochet / 1000;
			// 8 битов на опускание веревки
			FlxTween.num(rope.y, rope.y + ROPE_OFFSET, crochet * 8, {
				ease: FlxEase.backOut,
				onComplete: _ ->
				{
					if (tv != null)
					{
						@:bypassAccessor tv.idleSuffix = "-alt";
						tv.recalculateDanceIdle();
						tv.animation.timeScale = 1.5;
						tv.playAnim("imgay");
						tv.skipDance = true;
					}

					// 2-х битовая тряска тряски
					var offset = FlxG.random.int(8, 12);
					FlxTween.num(gfGroup.y, gfGroup.y - offset, crochet * 2,
					{
						ease: FlxEase.backOut,
						onComplete: _ ->
						{
							// 6 битов на поднятие тоилет тиви
							FlxTween.num(gfGroup.y, gfGroup.y - GF_OFFSET + offset, crochet * 6, {
								ease: FlxEase.backInOut,
								onComplete: _ ->
								{
									if (tv != null)
									{
										tv.skipDance = false;
										tv.dance();
									}

									// начинаем перекрут
									direction = FlxG.random.int(-1, 1, [0]);
									// ждем 1 бит и 3 бита на увеличение силы раскачки
									FlxTween.num(SWAY_SPEED / 2, SWAY_SPEED * 2, crochet * 3, {startDelay: crochet}, a -> acceleration = a);
								}
							}, gfGroup.set_y);
						}
					}, gfGroup.set_y);
				}}, rope.set_y);

		case "холд_ап":
			if (tv != null)
			{
				tv.animation.timeScale = 1;
				tv.danceEveryNumBeats = 2;
			}

		case "спид_ап":
			if (tv != null)
			{
				tv.animation.timeScale = 1.5;
				tv.danceEveryNumBeats = 1;
			}
	}
}

function onGameOverStart()
{
	if (tv != null)
		tv.animation.timeScale = 1;
}