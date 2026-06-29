package mobile.flixel.controls;

#if flixel
class InputHandler extends FlxSpriteGroup {
	public var jsonName:String = null;
	public var activeIDs:Array<String> = [];
	public var lastActiveIDs:Array<String> = [];
	public var ignoredPointers:Array<Int> = [];

	public var disabled:Bool = false;
	public var disableBright:Bool = false;
	public var showBounds:Bool = false;

	public var subOffsetX:Float = 0;
	public var subOffsetY:Float = 0;
	public var subScale:Float = 1.0;

	public var deadZones:Array<FlxSprite> = [];

	public var baseGraphic:FlxSprite;
	public var subGraphic:FlxSprite;

	public var hitboxes:Array<FlxSprite> = [];

	public var currentPointerID:Int = -1;
	public var onButtonDown:FlxTypedSignal<(InputHandler, String) -> Void> = new FlxTypedSignal<(InputHandler, String) -> Void>();
	public var onButtonUp:FlxTypedSignal<(InputHandler, String) -> Void> = new FlxTypedSignal<(InputHandler, String) -> Void>();

	public function new(x:Float, y:Float, showBounds:Bool = false) {
		super(x, y);
		this.showBounds = showBounds;

		baseGraphic = new FlxSprite(0, 0);
		baseGraphic.makeGraphic(1, 1, 0x00000000);

		subGraphic = new FlxSprite(0, 0);
		subGraphic.makeGraphic(1, 1, 0x00000000);

		add(baseGraphic);
		add(subGraphic);

		#if FLX_TOUCH
		for (touch in FlxG.touches.list)
			ignoredPointers.push(touch.touchPointID);
		#end
		#if FLX_MOUSE
		if (FlxG.mouse.pressed)
			ignoredPointers.push(-2);
		#end
	}

	public function loadElementGraphics(graphicName:String, subName:String, sheetName:String, basePaths:Array<String>, colorHex:String, scaleVal:Float) {
		jsonName = graphicName;

		var loadFrames = function(target:FlxSprite, gName:String, sName:String, sPath:Array<String>) {
			var pngPath = sPath[1] + sName + ".png";
			var xmlPath = sPath[1] + sName + ".xml";

			if (!FileSystem.exists(pngPath))
				pngPath = sPath[0] + sName + ".png";
			if (!FileSystem.exists(xmlPath))
				xmlPath = sPath[0] + sName + ".xml";

			if (FileSystem.exists(pngPath) && FileSystem.exists(xmlPath)) {
				var bmd = FileSystem.getBitmapData(pngPath);
				var xmlText = File.getContent(xmlPath);
				if (bmd != null && xmlText != null) {
					var graphic = flixel.graphics.FlxGraphic.fromBitmapData(bmd);
					target.frames = FlxAtlasFrames.fromSparrow(graphic, xmlText);
					target.animation.addByPrefix("idle", gName, 24, true);
					target.animation.play("idle");
					return true;
				}
			}
			return false;
		};

		var baseImageFile = basePaths[1] + graphicName + ".png";
		if (!FileSystem.exists(baseImageFile))
			baseImageFile = basePaths[0] + graphicName + ".png";

		var subImageFile = basePaths[1] + subName + ".png";
		if (!FileSystem.exists(subImageFile))
			subImageFile = basePaths[0] + subName + ".png";

		if (sheetName != null && sheetName != "") {
			if (!loadFrames(baseGraphic, graphicName, sheetName, basePaths))
				baseGraphic.loadGraphic(FileSystem.getBitmapData(baseImageFile));
		} else if (graphicName != null) {
			baseGraphic.loadGraphic(FileSystem.getBitmapData(baseImageFile));
		}

		if (subName != null && subName != "") {
			if (sheetName != null && sheetName != "") {
				if (!loadFrames(subGraphic, subName, sheetName, basePaths))
					subGraphic.loadGraphic(FileSystem.getBitmapData(subImageFile));
			} else {
				subGraphic.loadGraphic(FileSystem.getBitmapData(subImageFile));
			}
		} else {
			subGraphic.visible = false;
		}

		baseGraphic.scale.set(scaleVal, scaleVal);
		subGraphic.scale.set(scaleVal * subScale, scaleVal * subScale);
		baseGraphic.updateHitbox();
		subGraphic.updateHitbox();

		centerSubGraphic();

		if (colorHex != null && colorHex != "") {
			var col:FlxColor = FlxColor.fromString(colorHex);
			baseGraphic.color = col;
			subGraphic.color = col;
		}
	}

	public function centerSubGraphic() {
		if (subGraphic != null && baseGraphic != null && subGraphic.visible) {
			subGraphic.x = baseGraphic.x + (baseGraphic.width - subGraphic.width) / 2 + subOffsetX;
			subGraphic.y = baseGraphic.y + (baseGraphic.height - subGraphic.height) / 2 + subOffsetY;
		}
	}

	public function createBoundHitbox(relX:Float, relY:Float, w:Int, h:Int):FlxSprite {
		var box = new FlxSprite(relX, relY);
		box.makeGraphic(w, h, FlxColor.WHITE);
		box.visible = showBounds;
		box.alpha = 0.4;
		add(box);
		hitboxes.push(box);
		return box;
	}

	public function updateBoundBrightness(box:FlxSprite, isPressed:Bool) {
		if (!showBounds)
			return;
		box.color = isPressed ? FlxColor.GREEN : FlxColor.WHITE;
		box.alpha = isPressed ? 0.8 : 0.4;
	}

	override public function update(elapsed:Float) {
		if (disabled)
			return;

		#if FLX_TOUCH
		var i = ignoredPointers.length;
		while (i-- > 0) {
			var id = ignoredPointers[i];
			if (id != -2) {
				var active = false;
				for (touch in FlxG.touches.list) {
					if (touch.touchPointID == id) {
						active = true;
						break;
					}
				}
				if (!active)
					ignoredPointers.remove(id);
			}
		}
		#end
		#if FLX_MOUSE
		if (!FlxG.mouse.pressed)
			ignoredPointers.remove(-2);
		#end

		lastActiveIDs = activeIDs.copy();
		activeIDs = [];

		updateInputs();

		for (id in activeIDs) {
			if (!lastActiveIDs.contains(id) && onButtonDown != null)
				onButtonDown.dispatch(this, id);
		}
		for (id in lastActiveIDs) {
			if (!activeIDs.contains(id) && onButtonUp != null)
				onButtonUp.dispatch(this, id);
		}

		super.update(elapsed);
	}

	public dynamic function updateInputs() {}

	public function checkOverlap(rect:FlxSprite):Bool {
		var overlap = false;
		var cams = cameras != null && cameras.length > 0 ? cameras : [camera != null ? camera : FlxG.camera];
		var point = FlxPoint.get();

		for (cam in cams) {
			#if FLX_TOUCH
			for (touch in FlxG.touches.list) {
				if (ignoredPointers.contains(touch.touchPointID))
					continue;

				var worldPos = touch.getWorldPosition(cam, point);

				for (dz in deadZones) {
					if (dz != null && dz.overlapsPoint(worldPos, true, cam)) {
						point.put();
						return false;
					}
				}

				if (rect.overlapsPoint(worldPos, true, cam)) {
					overlap = true;
					currentPointerID = touch.touchPointID;
				}
			}
			#end

			#if FLX_MOUSE
			if (FlxG.mouse.pressed && !ignoredPointers.contains(-2)) {
				var worldPos = FlxG.mouse.getWorldPosition(cam, point);

				for (dz in deadZones) {
					if (dz != null && dz.overlapsPoint(worldPos, true, cam)) {
						point.put();
						return false;
					}
				}

				if (rect.overlapsPoint(worldPos, true, cam)) {
					overlap = true;
					currentPointerID = -2;
				}
			}
			#end
		}

		point.put();
		return overlap;
	}

	public function pressed(id:String):Bool {
		return activeIDs.contains(id);
	}

	public function justPressed(id:String):Bool {
		return activeIDs.contains(id) && !lastActiveIDs.contains(id);
	}

	public function justReleased(id:String):Bool {
		return !activeIDs.contains(id) && lastActiveIDs.contains(id);
	}

	public function released(id:String):Bool {
		return !activeIDs.contains(id);
	}

	public function resetInputs() {
		activeIDs = [];
		lastActiveIDs = [];
		currentPointerID = -1;
		centerSubGraphic();
		applyBrightness(false);
		for (box in hitboxes) {
			if (box != null)
				updateBoundBrightness(box, false);
		}
	}

	public function applyBrightness(isPressed:Bool) {
		if (disableBright)
			return;
		var targetColor = isPressed ? 0xFFAAAAAA : FlxColor.WHITE;
		baseGraphic.color = targetColor;
		if (subGraphic.visible)
			subGraphic.color = targetColor;
	}
}
#end
