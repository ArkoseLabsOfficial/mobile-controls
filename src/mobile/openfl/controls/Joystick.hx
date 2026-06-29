package mobile.openfl.controls;

class Joystick extends InputHandler {
	public var controlIDs:Array<String> = [];

	private var maxRadius:Float = 50.0;

	public var touchZone:Sprite;

	private var currentTouchID:Int = -999;

	public function new(data:ControlDef) {
		super(data.position != null ? data.position[0] : 0, data.position != null ? data.position[1] : 0, data.showbounds == true);
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

		var bW = baseGraphic.scrollRect != null ? baseGraphic.scrollRect.width : baseGraphic.bitmapData.width;
		var bH = baseGraphic.scrollRect != null ? baseGraphic.scrollRect.height : baseGraphic.bitmapData.height;
		var relMidX = (bW * baseScale) / 2;
		var relMidY = (bH * baseScale) / 2;

		touchZone = new Sprite();
		if (data.border != null && data.border.length >= 2) {
			var zW = data.border[0] * scale;
			var zH = data.border[1] * scale;
			touchZone.graphics.beginFill(0xFFFFFF, 0.15);
			touchZone.graphics.drawRect(0, 0, zW, zH);
			touchZone.graphics.endFill();
			touchZone.x = relMidX - (zW / 2);
			touchZone.y = relMidY - (zH / 2);
		} else {
			touchZone.graphics.beginFill(0xFFFFFF, 0.15);
			touchZone.graphics.drawRect(0, 0, bW * scale, bH * scale);
			touchZone.graphics.endFill();
		}
		if (data.showborder != true)
			touchZone.alpha = 0;
		addChildAt(touchZone, 0);

		var offsets = data.offset != null ? data.offset : data.clickposition;
		var hitboxesD = data.hitbox != null ? data.hitbox : data.clickbound;

		if (offsets != null && hitboxesD != null) {
			for (i in 0...controlIDs.length) {
				var cPos:Array<Float> = offsets[i];
				var cBnd:Array<Int> = hitboxesD[i];
				var relBoundX = relMidX + (cPos[0] * scale) - ((cBnd[0] * scale) / 2);
				var relBoundY = relMidY + (cPos[1] * scale) - ((cBnd[1] * scale) / 2);
				createBoundHitbox(relBoundX, relBoundY, cBnd[0] * scale, cBnd[1] * scale);
			}
		}
	}

	override public function updateInputs() {
		if (disabled)
			return;
		super.updateInputs();

		var bW = baseGraphic.scrollRect != null ? baseGraphic.scrollRect.width : baseGraphic.bitmapData.width;
		var bH = baseGraphic.scrollRect != null ? baseGraphic.scrollRect.height : baseGraphic.bitmapData.height;

		var globalMidX = this.x + (((bW * baseScale) / 2) * this.scaleX);
		var globalMidY = this.y + (((bH * baseScale) / 2) * this.scaleY);

		var isTouching = false;
		var touchX = globalMidX;
		var touchY = globalMidY;

		var blockedByDeadZone = false;
		for (p in InputHandler.activePointers) {
			if (p.isDown) {
				for (dz in deadZones) {
					if (dz != null && dz.hitTestPoint(p.x, p.y, true)) {
						blockedByDeadZone = true;
						break;
					}
				}
				if (blockedByDeadZone)
					break;
			}
		}

		if (currentTouchID == -999 && !blockedByDeadZone) {
			for (p in InputHandler.activePointers) {
				if (p.isDown && touchZone.hitTestPoint(p.x, p.y, true)) {
					currentTouchID = p.id;
					break;
				}
			}
		}

		if (currentTouchID != -999 && !blockedByDeadZone) {
			var p = InputHandler.activePointers.get(currentTouchID);
			if (p != null && p.isDown) {
				isTouching = true;
				touchX = p.x;
				touchY = p.y;
			} else {
				currentTouchID = -999;
			}
		}

		if (blockedByDeadZone) {
			isTouching = false;
			currentTouchID = -999;
		}

		if (isTouching) {
			var dx = touchX - globalMidX;
			var dy = touchY - globalMidY;
			var dist = Math.sqrt(dx * dx + dy * dy);

			var globalMaxRadius = maxRadius * this.scaleX;

			if (dist > globalMaxRadius) {
				dx = (dx / dist) * globalMaxRadius;
				dy = (dy / dist) * globalMaxRadius;
			}

			var localDx = dx / this.scaleX;
			var localDy = dy / this.scaleY;

			var sW = subGraphic.scrollRect != null ? subGraphic.scrollRect.width : subGraphic.bitmapData.width;
			var sH = subGraphic.scrollRect != null ? subGraphic.scrollRect.height : subGraphic.bitmapData.height;

			subGraphic.x = ((bW * baseScale) / 2) + localDx - ((sW * baseScale * subScale) / 2) + subOffsetX;
			subGraphic.y = ((bH * baseScale) / 2) + localDy - ((sH * baseScale * subScale) / 2) + subOffsetY;

			var anyPressed = false;
			for (i in 0...hitboxes.length) {
				var box = hitboxes[i];
				var isPressed = false;

				if (box.hitTestPoint(touchX, touchY, true)) {
					isPressed = true;
				}

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
			for (box in hitboxes)
				updateBoundBrightness(box, false);
		}
	}

	override public function resetInputs() {
		super.resetInputs();
		currentTouchID = -999;
	}
}
