package mobile.openfl.controls;

class Button extends InputHandler {
	public var controlID:String;

	public function new(data:ControlDef) {
		super(data.position != null ? data.position[0] : 0, data.position != null ? data.position[1] : 0, false);
		jsonName = data.name;
		controlID = cast data.id;

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
		loadElementGraphics(tex, subTex, data.spritesheet, [Config.BUTTON_PATH, Config.MODDED_BUTTON_PATH], data.color, scale, subColor);
	}

	override public function updateInputs() {
		if (disabled)
			return;
		super.updateInputs();

		var isHit = checkOverlap(this);

		if (isHit)
			activeIDs.push(controlID);
		applyBrightness(activeIDs.length > 0);
	}
}
