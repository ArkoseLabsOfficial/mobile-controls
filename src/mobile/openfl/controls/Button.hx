package mobile.openfl.controls;

class Button extends InputHandler {
    public var controlID:String;

    public function new(data:Dynamic) {
        super(data.position != null ? data.position[0] : 0, data.position != null ? data.position[1] : 0, false);
        jsonName = data.name;
        controlID = data.id;

        var tex:String = data.texture != null ? data.texture : data.graphic;
        var subTex:String = null;
        if (data.subgraphic != null) {
            subTex = data.subgraphic.texture != null ? data.subgraphic.texture : data.subgraphic;
            if (data.subgraphic.position != null) {
                subOffsetX = data.subgraphic.position[0];
                subOffsetY = data.subgraphic.position[1];
            }
            if (data.subgraphic.scale != null) {
                subScale = data.subgraphic.scale;
            }
        }

        loadElementGraphics(tex, subTex, data.spritesheet, Config.BUTTON_PATH, data.color, data.scale != null ? data.scale : 1.0);
    }

    override public function updateInputs() {
        if (disabled) return;
        super.updateInputs();

        var isHit = false;
        if (checkOverlap(this)) {
            isHit = true;
        }

        if (isHit) activeIDs.push(controlID);
        applyBrightness(activeIDs.length > 0);
    }
}