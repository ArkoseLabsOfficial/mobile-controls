package mobile.openfl.controls;

class DPad extends InputHandler {
	public var controlIDs:Array<String> = [];

	public function new(data:ControlDef) {
		super(data.position != null ? data.position[0] : 0, data.position != null ? data.position[1] : 0, data.showbounds == true);
		jsonName = data.name;
		controlIDs = cast data.id;

		var tex:String = data.texture;
		var subTex:String = null;
		var subColor:String = null;
		if (data.subgraphic != null) {
			var subData:SubGraphicDef = cast data.subgraphic;
			if (Std.isOfType(data.subgraphic, String)) {
				subTex = cast data.subgraphic;
			} else {
				subTex = subData.texture;
				if (subData.color != null)
					subColor = subData.color;

				if (subData.position != null) {
					subOffsetX = subData.position[0];
					subOffsetY = subData.position[1];
				}
				if (subData.scale != null) {
					subScale = subData.scale;
				}
			}
		}

		var scale:Float = data.scale != null ? cast data.scale : 1.0;
		loadElementGraphics(tex, subTex, data.spritesheet, [Config.DPAD_PATH, Config.MODDED_DPAD_PATH], data.color, scale, subColor);

		var bW = baseGraphic.scrollRect != null ? baseGraphic.scrollRect.width : baseGraphic.bitmapData.width;
		var bH = baseGraphic.scrollRect != null ? baseGraphic.scrollRect.height : baseGraphic.bitmapData.height;
		var relMidX = (bW * baseScale) / 2;
		var relMidY = (bH * baseScale) / 2;

		var offsets = data.offset;
		var hitboxesD = data.hitbox;

		if (offsets != null && hitboxesD != null) {
			for (i in 0...controlIDs.length) {
				var cPos:Array<Float> = offsets[i];
				var cBnd:Array<Int> = hitboxesD[i];

				var relBoundX = relMidX + (cPos[0] * baseScale) - ((cBnd[0] * baseScale) / 2);
				var relBoundY = relMidY + (cPos[1] * baseScale) - ((cBnd[1] * baseScale) / 2);

				createBoundHitbox(relBoundX, relBoundY, cBnd[0] * baseScale, cBnd[1] * baseScale);
			}
		}
	}

	override public function updateInputs() {
		if (disabled)
			return;
		super.updateInputs();

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
	}
}
