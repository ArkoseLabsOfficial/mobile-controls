package mobile.flixel.controls;

#if flixel
class Joystick extends InputHandler {
	public var controlIDs:Array<String> = [];

	private var maxRadius:Float = 50.0;

	public var touchZone:FlxSprite;

	private var currentTouchID:Int = -1;

	public function new(data:ControlDef) {
		var posX:Float = data.position != null ? data.position[0] : 0;
		var posY:Float = data.position != null ? data.position[1] : 0;
		super(posX, posY, data.showbounds == true);

		jsonName = data.name;
		controlIDs = cast data.id;
		var scale:Float = data.scale != null ? cast data.scale : 1.0;
		maxRadius = (data.radius != null ? data.radius : maxRadius) * scale;

		var tex:String = data.texture != null ? data.texture : data.graphic;
		var subTex:String = null;

		if (data.subgraphic != null) {
			var subData:SubGraphicDef = cast data.subgraphic;
			if (Std.isOfType(data.subgraphic, String)) {
				subTex = cast data.subgraphic;
			} else {
				subTex = subData.texture;
				if (subData.position != null) {
					subOffsetX = subData.position[0];
					subOffsetY = subData.position[1];
				}
				if (subData.scale != null) {
					subScale = subData.scale;
				}
			}
		}

		loadElementGraphics(tex, subTex, data.spritesheet, [Config.JOYSTICK_PATH, Config.MODDED_JOYSTICK_PATH], data.color, scale);

		var relMidX = baseGraphic.width / 2;
		var relMidY = baseGraphic.height / 2;

		if (data.border != null && data.border.length >= 2) {
			var bW:Int = Std.int(data.border[0] * scale);
			var bH:Int = Std.int(data.border[1] * scale);
			touchZone = new FlxSprite(relMidX - bW / 2, relMidY - bH / 2);
			touchZone.makeGraphic(bW, bH, 0xFFFFFFFF);
			touchZone.alpha = 0.15;
			touchZone.visible = (data.showborder == true);
			insert(0, touchZone);
		} else {
			touchZone = baseGraphic;
		}

		var offsets = data.offset != null ? data.offset : data.clickposition;
		var hitboxesD = data.hitbox != null ? data.hitbox : data.clickbound;

		if (offsets != null && hitboxesD != null) {
			for (i in 0...controlIDs.length) {
				var cPos:Array<Float> = offsets[i];
				var cBnd:Array<Int> = hitboxesD[i];
				var relBoundX = relMidX + cPos[0] - (cBnd[0] / 2);
				var relBoundY = relMidY + cPos[1] - (cBnd[1] / 2);
				createBoundHitbox(relBoundX, relBoundY, cBnd[0], cBnd[1]);
			}
		}
	}

	private function isPointerInZone(px:Float, py:Float):Bool {
		if (touchZone == baseGraphic) {
			return px >= x && px <= x + baseGraphic.width && py >= y && py <= y + baseGraphic.height;
		} else {
			return px >= x + touchZone.x
				&& px <= x + touchZone.x + touchZone.width
				&& py >= y + touchZone.y
				&& py <= y + touchZone.y + touchZone.height;
		}
	}

	override public function updateInputs() {
		var isTouching = false;
		var touchX:Float = baseGraphic.getGraphicMidpoint().x;
		var touchY:Float = baseGraphic.getGraphicMidpoint().y;

		var cams = cameras != null && cameras.length > 0 ? cameras : [camera != null ? camera : FlxG.camera];
		var point = FlxPoint.get();

		var blockedByDeadZone = false;

		for (cam in cams) {
			#if FLX_TOUCH
			for (touch in FlxG.touches.list) {
				var tPos = touch.getWorldPosition(cam, point);
				for (dz in deadZones) {
					if (dz != null && dz.overlapsPoint(tPos, true, cam)) {
						blockedByDeadZone = true;
						break;
					}
				}
				if (blockedByDeadZone)
					break;
			}

			if (currentTouchID == -1 && !blockedByDeadZone) {
				for (touch in FlxG.touches.list) {
					if (ignoredPointers.contains(touch.touchPointID))
						continue;
					var tPos = touch.getWorldPosition(cam, point);

					if (touch.justPressed && (isPointerInZone(tPos.x, tPos.y) || checkHitboxes(tPos, cam))) {
						currentTouchID = touch.touchPointID;
						break;
					}
				}
			}

			if (currentTouchID >= 0 && !blockedByDeadZone) {
				var found = false;
				for (touch in FlxG.touches.list) {
					if (touch.touchPointID == currentTouchID) {
						if (touch.pressed) {
							isTouching = true;
							var tPos = touch.getWorldPosition(cam, point);
							touchX = tPos.x;
							touchY = tPos.y;
							found = true;
						}
						break;
					}
				}
				if (!found)
					currentTouchID = -1;
			}
			#end

			#if FLX_MOUSE
			if (!blockedByDeadZone && FlxG.mouse.pressed) {
				var mPos = FlxG.mouse.getWorldPosition(cam, point);
				for (dz in deadZones) {
					if (dz != null && dz.overlapsPoint(mPos, true, cam)) {
						blockedByDeadZone = true;
						break;
					}
				}
			}

			if (!blockedByDeadZone && !ignoredPointers.contains(-2)) {
				var mPos = FlxG.mouse.getWorldPosition(cam, point);
				if (currentTouchID == -1 && FlxG.mouse.justPressed) {
					if (isPointerInZone(mPos.x, mPos.y) || checkHitboxes(mPos, cam)) {
						currentTouchID = -2;
					}
				}

				if (currentTouchID == -2) {
					if (FlxG.mouse.pressed) {
						isTouching = true;
						touchX = mPos.x;
						touchY = mPos.y;
					} else {
						currentTouchID = -1;
					}
				}
			}
			#end

			if (blockedByDeadZone) {
				isTouching = false;
				currentTouchID = -1;
				break;
			}

			if (isTouching || currentTouchID != -1)
				break;
		}
		point.put();

		if (isTouching) {
			var mid = baseGraphic.getGraphicMidpoint();
			var dx = touchX - mid.x;
			var dy = touchY - mid.y;
			var dist = Math.sqrt(dx * dx + dy * dy);

			if (dist > maxRadius) {
				dx = (dx / dist) * maxRadius;
				dy = (dy / dist) * maxRadius;
			}

			subGraphic.x = mid.x + dx - (subGraphic.width / 2) + subOffsetX;
			subGraphic.y = mid.y + dy - (subGraphic.height / 2) + subOffsetY;

			var anyPressed = false;
			for (i in 0...hitboxes.length) {
				var box = hitboxes[i];
				var isPressed = checkOverlap(box);

				if (isPressed) {
					activeIDs.push(controlIDs[i]);
					anyPressed = true;
				}

				updateBoundBrightness(box, isPressed);
			}

			applyBrightness(anyPressed);
		} else {
			centerSubGraphic();
			applyBrightness(false);
			for (box in hitboxes) {
				updateBoundBrightness(box, false);
			}
		}
	}

	override public function resetInputs() {
		super.resetInputs();
		currentTouchID = -1;
	}

	private function checkHitboxes(point:FlxPoint, cam:flixel.FlxCamera):Bool {
		for (box in hitboxes) {
			if (box.overlapsPoint(point, true, cam))
				return true;
		}
		return false;
	}
}
#end
